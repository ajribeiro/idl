;+ 
; NAME: 
; RAD_MAP_CALC_GRAD_VECS
;
; PURPOSE: 
; This procedure calculates the magnitude and azimuth of velocity vectors based on the
; coefficients of the spherical expansion for the potential. The position where velocity
; vectors are calculated are those of the actual radar measurements and those where model
; values where included to constrain the potential fit.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; Result = RAD_MAP_CALC_GRAD_VECS(Int_hemi, Index)
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
function rad_map_calc_grad_vecs, int_hemi, index

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

; get coefficients of the expansion
coeffs = (*(*rad_map_data[int_hemi]).coeffs[index])

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
; Calculate vectors
rvecs = rad_map_eval_grad_vecs(real_pos, coeffs[*,2], latmin, order)
rmag = reform(sqrt(rvecs[0,*]^2 + rvecs[1,*]^2))
q = where (rmag ne 0, qc)
if (qc eq 0) then begin
  prinfo, 'All "real" vectors have 0 length.'
  return, 0
endif
raz    = fltarr(n_elements(rmag))
raz[q] = atan(rvecs[1,q],-rvecs[0,q])*!radeg
; Now shift back into 'real word'
if lat_shft ne 0. then begin
  xat_shft = -lat_shft
  npnts    =  n_elements(rmag)
  crd_shft, lon_shft, xat_shft, npnts, real_pos, raz
endif

; get model velocity data
model_vec = (*(*rad_map_data[int_hemi]).mvecs[index])
model_nvec = (*rad_map_data[int_hemi]).modnum[index]
model_pos = transpose([[model_vec[*].mlat], [model_vec[*].mlon]])
; First shift coordinates into 'model' reference (pole shifted 4 deg nightwards)
if lat_shft ne 0. then begin
  npnts = N_ELEMENTS(model_pos)/2L
  kaz = FLTARR(npnts)
  crd_shft, lon_shft, lat_shft, npnts, model_pos, kaz
endif
; Calculate vectors
mvecs = rad_map_eval_grad_vecs(model_pos, coeffs[*,2], latmin, order)
mmag = reform(sqrt(mvecs[0,*]^2 + mvecs[1,*]^2))
q = where (mmag ne 0, qc)
if (qc eq 0) then begin
  prinfo, 'All model vectors have 0 length.'
  return, 0
endif
maz    = fltarr(n_elements(mmag))
maz[q] = atan(mvecs[1,q],-mvecs[0,q])*!radeg
; Now shift back into 'real word'
if (lat_shft ne 0) then begin
  xat_shft = -lat_shft
  npnts    =  n_elements(mmag)
  crd_shft, lon_shft, xat_shft, npnts, model_pos, maz
endif

real  = {pos:real_pos,  vectors:transpose([[rmag], [raz]])}
model = {pos:model_pos, vectors:transpose([[mmag], [maz]])}

return, {real:real, model:model}

end