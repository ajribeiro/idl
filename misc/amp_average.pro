pro amp_average, integrate_dt, step_dt=step_dt, $
	both=both, north=north, south=south, hemisphere=hemisphere, silent=silent

if keyword_set(both) then begin
	amp_average, integrate_dt, step_dt=step_dt, /north, silent=silent
	amp_average, integrate_dt, step_dt=step_dt, /south, silent=silent
	return
endif

common amp_data_blk

if n_params() ne 1 then begin
	prinfo, 'Must give time step in minutes.'
	return
endif

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

if amp_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No AMPERE data loaded.'
	return
endif

if ~keyword_set(step_dt) then $
	step_dt = integrate_dt

sfjul, sdate, stime, (*amp_data[int_hemi]).sjuls[0], /jul
sfjul, sdate, stime, sjul

nrecs = long(amp_info[int_hemi].nrecs*5./step_dt)
scnddim = n_elements( (*amp_data[int_hemi]).mlt[0,*] )

; set up temporary structure
amp_data_tmp = { $
	sjuls: dblarr(nrecs), $
	mjuls: dblarr(nrecs), $
	fjuls: dblarr(nrecs), $
	nlat: fltarr(nrecs), $
	nlon: fltarr(nrecs), $
	colat: fltarr(nrecs, scnddim), $
	mlt: fltarr(nrecs, scnddim), $
	dbnorth1: fltarr(nrecs, scnddim), $
	dbeast1: fltarr(nrecs, scnddim), $
	dbnorth2: fltarr(nrecs, scnddim), $
	dbeast2: fltarr(nrecs, scnddim), $
	jr: fltarr(nrecs, scnddim) $
}

; populate structure
cc = 0L
while !true do begin
	asjul = sjul + double(cc*step_dt)/1440.d
	afjul = asjul + double(integrate_dt)/1440.d
	amp_data_tmp.sjuls[cc] = asjul
	amp_data_tmp.fjuls[cc] = afjul
	amp_data_tmp.mjuls[cc] = ( asjul + afjul )/2.d
	ginds = where( (*amp_data[int_hemi]).sjuls ge asjul and (*amp_data[int_hemi]).fjuls lt afjul, gcc)
	if afjul gt amp_info[int_hemi].fjul then $
		break
	if gcc gt 0L then begin
		amp_data_tmp.nlat[cc] = (*amp_data[int_hemi]).nlat[ginds[0]]
		amp_data_tmp.nlon[cc] = (*amp_data[int_hemi]).nlon[ginds[0]]
		amp_data_tmp.colat[cc,*]    = median( (*amp_data[int_hemi]).colat[ginds,*], dim=1 )
		amp_data_tmp.mlt[cc,*]      = median( (*amp_data[int_hemi]).mlt[ginds,*], dim=1 )
		amp_data_tmp.dbnorth1[cc,*] = median( (*amp_data[int_hemi]).dbnorth1[ginds,*], dim=1 )
		amp_data_tmp.dbeast1[cc,*]  = median( (*amp_data[int_hemi]).dbeast1[ginds,*], dim=1 )
		amp_data_tmp.dbnorth2[cc,*] = median( (*amp_data[int_hemi]).dbnorth2[ginds,*], dim=1 )
		amp_data_tmp.dbeast2[cc,*]  = median( (*amp_data[int_hemi]).dbeast2[ginds,*], dim=1 )
		amp_data_tmp.jr[cc,*]       = median( (*amp_data[int_hemi]).jr[ginds,*], dim=1 )
	endif else begin
		amp_data_tmp.nlat[cc] = !values.f_nan
		amp_data_tmp.nlon[cc] = !values.f_nan
		amp_data_tmp.colat[cc,*] = replicate( !values.f_nan, scnddim )
		amp_data_tmp.mlt[cc,*] = replicate( !values.f_nan, scnddim )
		amp_data_tmp.dbnorth1[cc,*] = replicate( !values.f_nan, scnddim )
		amp_data_tmp.dbeast1[cc,*] = replicate( !values.f_nan, scnddim )
		amp_data_tmp.dbnorth2[cc,*] = replicate( !values.f_nan, scnddim )
		amp_data_tmp.dbeast2[cc,*] = replicate( !values.f_nan, scnddim )
		amp_data_tmp.jr[cc,*] = replicate( !values.f_nan, scnddim )
	endelse
	cc += 1L
endwhile

; set up temporary structure
amp_data_hemi = { $
	sjuls: dblarr(cc), $
	mjuls: dblarr(cc), $
	fjuls: dblarr(cc), $
	nlat: fltarr(cc), $
	nlon: fltarr(cc), $
	colat: fltarr(cc, scnddim), $
	mlt: fltarr(cc, scnddim), $
	dbnorth1: fltarr(cc, scnddim), $
	dbeast1: fltarr(cc, scnddim), $
	dbnorth2: fltarr(cc, scnddim), $
	dbeast2: fltarr(cc, scnddim), $
	jr: fltarr(cc, scnddim), $
	p1: fltarr(cc, scnddim), $
	p2: fltarr(cc, scnddim), $
	poynting: fltarr(cc, scnddim), $
	jr_fit_order: intarr(cc), $
	jr_fit_pos_r1: fltarr(cc, 24, 3), $
	jr_fit_pos_r2: fltarr(cc, 24, 3), $
	jr_fit_coeffs_r1: fltarr(cc, 9, 2), $
	jr_fit_coeffs_r2: fltarr(cc, 9, 2), $
	area_r1: fltarr(cc, 3), $
	area_r2: fltarr(cc, 3), $
	flux_r1: fltarr(cc, 3), $
	flux_r2: fltarr(cc, 3) $
}

amp_data_hemi.sjuls = amp_data_tmp.sjuls[0:cc-1L]
amp_data_hemi.mjuls = amp_data_tmp.mjuls[0:cc-1L]
amp_data_hemi.fjuls = amp_data_tmp.fjuls[0:cc-1L]
amp_data_hemi.nlat = amp_data_tmp.nlat[0:cc-1L]
amp_data_hemi.nlon = amp_data_tmp.nlon[0:cc-1L]
amp_data_hemi.colat = amp_data_tmp.colat[0:cc-1L,*]
amp_data_hemi.mlt = amp_data_tmp.mlt[0:cc-1L,*]
amp_data_hemi.dbnorth1 = amp_data_tmp.dbnorth1[0:cc-1L,*]
amp_data_hemi.dbeast1 = amp_data_tmp.dbeast1[0:cc-1L,*]
amp_data_hemi.dbnorth2 = amp_data_tmp.dbnorth2[0:cc-1L,*]
amp_data_hemi.dbeast2 = amp_data_tmp.dbeast2[0:cc-1L,*]
amp_data_hemi.jr = amp_data_tmp.jr[0:cc-1L,*]

; replace pointer to old data structure
; and first all the pointers inside that pointer
if ptr_valid(amp_data[int_hemi]) then begin
	ptr_free, amp_data[int_hemi]
endif
amp_data[int_hemi] = ptr_new(amp_data_hemi)

amp_info[int_hemi].sjul = (*amp_data[int_hemi]).mjuls[0L]
amp_info[int_hemi].fjul = (*amp_data[int_hemi]).mjuls[cc-1L]
amp_info[int_hemi].nrecs = cc
amp_info[int_hemi].poynting = !false

end
