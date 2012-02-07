pro amp_current_fit, date=date, time=time, index=index, $
	both=both, north=north, south=south, hemisphere=hemisphere, order=order, $
	min_current=min_current

if keyword_set(both) then begin
	amp_current_fit, date=date, time=time, index=index, order=order, $
		min_current=min_current, /north
	amp_current_fit, date=date, time=time, index=index, order=order, $
		min_current=min_current, /south
	return
endif

common amp_data_blk

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
		prinfo, 'No data loaded.'
	return
endif

if n_elements(index) gt 0 then begin

	sfjul, date, time, (*amp_data[int_hemi]).mjuls[index], /jul_to_date
	parse_date, date, year, month, day
	sfjul, date, time, jul
	sindex = index
	inds = 0

endif else begin

	if ~keyword_set(date) then begin
		if ~keyword_set(silent) then $
			prinfo, 'No DATE given, trying for map date.'
		caldat, (*amp_data[int_hemi]).sjuls[0], month, day, year
		date = year*10000L + month*100L + day
	endif
	parse_date, date[0], year, month, day

	if n_elements(time) lt 1 then $
		time = [0000,2400]
	
	sfjul, date, time, sjul, fjul, long=long
	print_date, [sjul, fjul]

	; calculate index from date and time
	dd = min( abs( (*amp_data[int_hemi]).mjuls-sjul ), sindex)
	; check if time distance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

	; calculate index from date and time
	dd = min( abs( (*amp_data[int_hemi]).mjuls-fjul ), findex)
	; check if time distance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

	inds = lindgen( (findex-sindex) > 1 )

endelse
nn = n_elements(inds)

if n_elements(order) eq 0 then $
	order = 2

if n_elements(min_current) eq 0 then $
	min_current = 0.2

nfit = 1000.
xx = findgen(24)
; we trust the flanks more than the day/nightside
w1 = exp( -( (findgen(12)-6.)/5. )^2 )
wei = [w1, w1]
dlat = 5.
par_per_func = 2
iguess = reform( rebin(replicate(1., par_per_func), par_per_func, 88/par_per_func), 88 )

perc = 1.

fitcolats = 1. + findgen(nfit)/(nfit-1.)*29.
if int_hemi eq 1 then $
	fitcolats = 180.-fitcolats

prinfo, '00% done...'

for i=0, nn-1 do begin

	if float(i)*10./nn gt perc then begin
		prinfo, string(perc*10.,format='(I2)')+'% done...'
		perc += 1.
	endif

	for m=0, 23 do begin

		if int_hemi eq 0 then begin
			minds = where( abs ( ( (*amp_data[int_hemi]).mlt[sindex+inds[i],*] mod 24. ) - m ) lt .5 and $
				(*amp_data[int_hemi]).colat[sindex+inds[i],*] le 30. and (*amp_data[int_hemi]).colat[sindex+inds[i],*] ge 1. and $
				abs( (*amp_data[int_hemi]).jr[sindex+inds[i],*] ) gt min_current, mc )
		endif else begin
			minds = reverse(where( abs ( ( (*amp_data[int_hemi]).mlt[sindex+inds[i],*] mod 24. ) - m ) lt .5 and $
				(*amp_data[int_hemi]).colat[sindex+inds[i],*] le 179. and (*amp_data[int_hemi]).colat[sindex+inds[i],*] ge 150. and $
				abs( (*amp_data[int_hemi]).jr[sindex+inds[i],*] ) gt min_current, mc ))
		endelse

		if mc lt 6 then begin
			(*amp_data[int_hemi]).jr_fit_pos_r1[sindex+inds[i],m,*] = !values.f_nan
			(*amp_data[int_hemi]).jr_fit_pos_r2[sindex+inds[i],m,*] = !values.f_nan
			continue
		endif

		jrs = reform((*amp_data[int_hemi]).jr[sindex+inds[i],minds])
		colats = reform((*amp_data[int_hemi]).colat[sindex+inds[i],minds])

		dd = max(jrs, maxind, subscript_min=minind)
		
		if m lt 12 then begin
			pguess = [0.0, 0.5, (colats[minind]+colats[maxind])/2., 5.0, 0.0]
			jcoeffs = mpfitfun('jfit', colats, jrs, replicate(1./stddev(jrs), mc), pguess, yfit=yfit, /quiet, perror=perror)
			fitjrs = jfit(fitcolats, jcoeffs)
			jrmin = min(fitjrs, minind)
			jrmax = max(fitjrs, maxind)
			if abs(90.-fitcolats[minind]) lt abs(90.-fitcolats[maxind]) then begin
				(*amp_data[int_hemi]).jr_fit_pos_r1[sindex+inds[i],m,*] = !values.f_nan
				(*amp_data[int_hemi]).jr_fit_pos_r2[sindex+inds[i],m,*] = !values.f_nan
				continue
			endif
			(*amp_data[int_hemi]).jr_fit_pos_r1[sindex+inds[i],m,0] = fitcolats[minind]
			(*amp_data[int_hemi]).jr_fit_pos_r1[sindex+inds[i],m,1] = jrmin
			(*amp_data[int_hemi]).jr_fit_pos_r2[sindex+inds[i],m,0] = fitcolats[maxind]
			(*amp_data[int_hemi]).jr_fit_pos_r2[sindex+inds[i],m,1] = jrmax
		endif else begin
			pguess = [0.0, -0.5, (colats[minind]+colats[maxind])/2., 5.0, 0.0]
			jcoeffs = mpfitfun('jfit', colats, jrs, replicate(1./stddev(jrs), mc), pguess, yfit=yfit, /quiet, perror=perror)
			fitjrs = jfit(fitcolats, jcoeffs)
			jrmin = min(fitjrs, minind)
			jrmax = max(fitjrs, maxind)
			if abs(90.-fitcolats[minind]) gt abs(90.-fitcolats[maxind]) then begin
				(*amp_data[int_hemi]).jr_fit_pos_r1[sindex+inds[i],m,*] = !values.f_nan
				(*amp_data[int_hemi]).jr_fit_pos_r2[sindex+inds[i],m,*] = !values.f_nan
				continue
			endif
			(*amp_data[int_hemi]).jr_fit_pos_r1[sindex+inds[i],m,0] = fitcolats[maxind]
			(*amp_data[int_hemi]).jr_fit_pos_r1[sindex+inds[i],m,1] = jrmax
			(*amp_data[int_hemi]).jr_fit_pos_r2[sindex+inds[i],m,0] = fitcolats[minind]
			(*amp_data[int_hemi]).jr_fit_pos_r2[sindex+inds[i],m,1] = jrmin
		endelse

		(*amp_data[int_hemi]).jr_fit_pos_r1[sindex+inds[i],m,2] = sqrt(total((jrs-yfit)^2))
		(*amp_data[int_hemi]).jr_fit_pos_r2[sindex+inds[i],m,2] = sqrt(total((jrs-yfit)^2))

	endfor
	
	if int_hemi eq 0 then $
		pguess = [20.0, 1.0, 0.1] $
	else $
		pguess = [160.0, 1.0, 0.1]

	;-
	; fit R1 oval
	;-
	gi_r1 = where(finite((*amp_data[int_hemi]).jr_fit_pos_r1[sindex+inds[i],*,0]), gc_r1)
	if gc_r1 gt 3 then begin
		yy_r1 = reform((*amp_data[int_hemi]).jr_fit_pos_r1[sindex+inds[i],gi_r1,0])
		; initial fit of circle
		imcoeffs_r1 = mpfitfun('mfiti', xx[gi_r1], yy_r1, reform((*amp_data[int_hemi]).jr_fit_pos_r1[sindex+inds[i],gi_r1,2]), $
			pguess, weight=wei[gi_r1], yfit=yfit_r1, /quiet, perror=perror)
		(*amp_data[int_hemi]).jr_fit_coeffs_r1[sindex+inds[i],0:2,0] = imcoeffs_r1
		; throw away all points that are more than 2 degrees of circle fit
		ginds_r1 = where( abs( yy_r1-yfit_r1 ) le dlat, cc_r1, complement=ninds_r1, ncomplement=nin_r1)
		if cc_r1 gt par_per_func*order+1 then begin
			nguess = [imcoeffs_r1, iguess[3:87]]
			mcoeffs_r1 = mpfitfun('mfit', xx[gi_r1[ginds_r1]], yy_r1[ginds_r1], abs(yy_r1[ginds_r1]-yfit_r1[ginds_r1]), $
				nguess[0:par_per_func*order], weight=wei[ginds_r1], /quiet, perror=perror)
			(*amp_data[int_hemi]).jr_fit_coeffs_r1[sindex+inds[i],0:par_per_func*order,1] = mcoeffs_r1
			flux = amp_flux_calc(mfit(xx,mcoeffs_r1), dflux=dflux, area=area, darea=darea, north=north, south=south)
			(*amp_data[int_hemi]).flux_r1[sindex+inds[i],*] = [dflux[0], flux, dflux[1]]
			(*amp_data[int_hemi]).area_r1[sindex+inds[i],*] = [darea[0], area, darea[1]]
		endif else begin
			(*amp_data[int_hemi]).jr_fit_coeffs_r1[sindex+inds[i],0:par_per_func*order,1] = replicate(!values.f_nan, par_per_func*order+1)
			(*amp_data[int_hemi]).flux_r1[sindex+inds[i],*] = !values.f_nan
			(*amp_data[int_hemi]).area_r1[sindex+inds[i],*] = !values.f_nan
		endelse
	endif

	;-
	; fit R2 oval
	;-
	gi_r2 = where(finite((*amp_data[int_hemi]).jr_fit_pos_r2[sindex+inds[i],*,0]), gc_r2)
	if gc_r2 gt 3 then begin
		yy_r2 = reform((*amp_data[int_hemi]).jr_fit_pos_r2[sindex+inds[i],gi_r2,0])
		; initial fit of circle
		imcoeffs_r2 = mpfitfun('mfiti', xx[gi_r2], yy_r2, reform((*amp_data[int_hemi]).jr_fit_pos_r2[sindex+inds[i],gi_r2,2]), $
			pguess, weight=wei[gi_r2], yfit=yfit_r2, /quiet, perror=perror)
		(*amp_data[int_hemi]).jr_fit_coeffs_r2[sindex+inds[i],0:2,0] = imcoeffs_r2
		; throw away all points that are more than 2 degrees of circle fit
		ginds_r2 = where( abs( yy_r2-yfit_r2 ) le dlat, cc_r2, complement=ninds_r2, ncomplement=nin_r2)
		if cc_r2 gt par_per_func*order+1 then begin
			nguess = [imcoeffs_r2, iguess[3:87]]
			mcoeffs_r2 = mpfitfun('mfit', xx[gi_r2[ginds_r2]], yy_r2[ginds_r2], abs(yy_r2[ginds_r2]-yfit_r2[ginds_r2]), $
				nguess[0:par_per_func*order], weight=wei[ginds_r2], /quiet, perror=perror)
			(*amp_data[int_hemi]).jr_fit_coeffs_r2[sindex+inds[i],0:par_per_func*order,1] = mcoeffs_r2
			flux = amp_flux_calc(mfit(xx,mcoeffs_r2), dflux=dflux, area=area, darea=darea, north=north, south=south)
			(*amp_data[int_hemi]).flux_r2[sindex+inds[i],*] = [dflux[0], flux, dflux[1]]
			(*amp_data[int_hemi]).area_r2[sindex+inds[i],*] = [darea[0], area, darea[1]]
		endif else begin
			(*amp_data[int_hemi]).jr_fit_coeffs_r2[sindex+inds[i],0:par_per_func*order,1] = replicate(!values.f_nan, par_per_func*order+1)
			(*amp_data[int_hemi]).flux_r2[sindex+inds[i],*] = !values.f_nan
			(*amp_data[int_hemi]).area_r2[sindex+inds[i],*] = !values.f_nan
		endelse
	endif
	
	(*amp_data[int_hemi]).jr_fit_order[sindex+inds[i]] = order

endfor

prinfo, '100% done...'

end

