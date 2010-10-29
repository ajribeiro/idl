;+ 
; NAME: 
; RAD_MAP_CALC_MERGE_VECS
;
; PURPOSE: 
; This procedure calculates the magnitude and azimuth of velocity vectors based on
; "merging" the
;  real line-of-sight components from the doppler data from 2 or more
;  overlapping radars.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; Result = RAD_MAP_CALC_MERGE_VECS(Int_hemi, Index)
;
; INPUTS:
; Int_hemi: An integer indicating the hemisphere, 0 for north, 1 for south.
;
; Index: The index number of the coefficients to calculate.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding the currently loaded radar data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Adrian Grocott's SET_UP_ARRAYS, FIND_GRADV, EVAL_COMPONENT and others.
; Written by Lasse Clausen, Dec, 22 2009
;-
function rad_map_calc_merge_vecs, int_hemi, index, indeces=indeces
;-------------------------------------------------------------
;  This function calculates a "merge" vector by combining the
;  real line-of-sight components from the doppler data from 2 or more
;  overlapping radars.
;

common rad_data_blk

if n_elements(int_hemi) eq 0 then $
	int_hemi = 0

if n_elements(index) eq 0 then $
	index = 0

; get the order of the fit
order = (*rad_map_data[int_hemi]).fit_order[index]

; get latitude shift
lat_shft = (*rad_map_data[int_hemi]).lat_shft[index]

; get longitude shift
lon_shft = (*rad_map_data[int_hemi]).lon_shft[index]

; get minimum latitude
latmin = (*rad_map_data[int_hemi]).latmin[index]
tmax      = (90.0 - latmin)*!dtor

; get model velocity data first
mvecs = rad_map_calc_grad_vecs(int_hemi, index)

; get "real" velocity data
real_vec = (*(*rad_map_data[int_hemi]).gvecs[index])
real_nvec = (*rad_map_data[int_hemi]).vcnum[index]
real_pos = transpose([[real_vec[*].mlat], [real_vec[*].mlon]])
; First shift coordinates into 'model' reference (pole shifted 4 deg nightwards)
if lat_shft ne 0. then begin
  npnts = N_ELEMENTS(real_pos)/2L
  kaz = FLTARR(npnts)
  crd_shft, lon_shft, lat_shft, npnts, real_pos, kaz
endif

;Determine where we have overlapping vectors
got_data = where(abs(real_vec.vel.median) LT 9999.0, count)
if count gt 0L then begin
	merged  = make_array(2, 2000, /float, value=-9999.9)
	new_pos = make_array(2, 2000, /float, value=-9999.9)
	vmag    = make_array(2000, /float, value=-9999.9)
	vaz     = make_array(2000, /float, value=-9999.9)
	indeces = make_array(2, 2000, /long, value=-1L)
	m1 = 0
	for i=0,count-1 do begin
		diff = real_pos[*,got_data]-rebin(real_pos[*,i], 2, count, /sample)
		comm = where(diff[0,*] EQ 0.0 AND diff[1,*] EQ 0.0, cc)
		if cc ge 2 then begin
			;we have at least 2 overlapping vectors so calculate merged vectors:
			;what permutations of vector pairs do we have?:
			vec_pairs = intarr(2, cc^2)
			for k=0,cc-1 do $
				for l=0,cc-1 do $
					vec_pairs[*,(k*cc)+l] = [k,l]
			vec_pairs[*,where(vec_pairs[0,*] ge vec_pairs[1,*])] = -1
			vec_pairs = vec_pairs[*,where(vec_pairs[0,*] ne -1)]

			for j=0, n_elements(vec_pairs[0,*])-1 do begin
				astr = real_vec[comm[vec_pairs[0:1,j]]]
				merged[*, m1+j] = [ $
					astr[0].vel.median * sin( astr[0].azm*!dtor ) + $
						astr[1].vel.median * sin( astr[1].azm*!dtor ) , $
					astr[0].vel.median * cos( astr[0].azm*!dtor ) + $
						astr[1].vel.median * cos( astr[1].azm*!dtor ) $
				]
				new_pos[*,m1+j] = real_pos[*,comm[vec_pairs[1,j]]]
				indeces[*,m1+j] = comm[vec_pairs[*,j]]
			endfor
			m1 = m1 + n_elements(vec_pairs[0,*])
		endif
	endfor
endif else begin
	prinfo, 'No real velocity data.'
	return, 0
endelse

IF m1 Gt 0 THEN BEGIN
  rmag = reform(sqrt( merged[0,0:m1-1]^2 + merged[1,0:m1-1]^2 ))
  raz  = reform(atan(merged[0,0:m1-1], merged[1,0:m1-1]) * !radeg)
	; Now shift back into 'real word'
	if lat_shft ne 0. then begin
	  xat_shft = -lat_shft
	  npnts    =  n_elements(rmag)
	  crd_shft, lon_shft, xat_shft, npnts, new_pos, raz
	endif
	real  = {pos:new_pos[*,0:m1-1],  vectors:transpose([[rmag], [raz]])}
	indeces = indeces[*,0:m1-1]
ENDIF else begin
	prinfo, 'No measurements found at the same time at the same place.'
	real = {pos:[-9999.9,-9999.9], vectors:[-9999.9,-9999.9]}
	indeces = [-1L,-1L]
endelse

return, {real:real, model:mvecs.model}

end