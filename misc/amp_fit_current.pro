function jfit, xx, pp
	return, pp[0] + pp[1]*exp( -((xx-pp[2])/pp[3])^2 )*sin(2.*!pi*(xx-pp[2])/(3.*pp[3]) + pp[4])
end

function mfiti, xx, pp
	return, pp[0] + pp[1]*cos(2.*!pi*xx/24. + pp[2])
end

function mfit, xx, pp
	return, pp[0] + pp[1]*cos(2.*!pi*xx/24. + pp[2]) + pp[3]*cos(2.*(2.*!pi*xx/24. + pp[4]))
end

pro amp_fit_current, date=date, time=time, index=index, $
	both=both, north=north, south=south, hemisphere=hemisphere

if keyword_set(both) then begin
	amp_fit_current, /north
	amp_fit_current, /south
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
	parse_date, date, year, month, day

	if n_elements(time) lt 1 then $
		time = [0000,2400]
	
	sfjul, date, time, sjul, fjul, long=long

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

	inds = sindex + lindgen( (findex-sindex) > 1 )

endelse
nn = n_elements(inds)

xx = findgen(24)
nxx = findgen(nfit)/(nfit-1.)*24.
; we trust the flanks more than the day/nightside
wei = 3.*[ .1, .1, .1, .1, 1., 1., 1., 1., 1., .1, .1, .1, .1, .1, .1, .1, 1., 1., 1., 1., 1., .1, .1, .1]
dlat = 3.
minpts = 10l
nfit = 1000.
adat = (*amp_data[int_hemi])

perc = 1.
for i=0, nn-1 do begin

	if float(i)*10./nn gt perc then begin
		prinfo, string(perc*10.,format='(I2)')+'% done...'
		perc += 1.
	endif

	for m=0, 23 do begin

		minds = reverse(where( abs ( ( adat.mlt[sindex+inds[i],*] mod 24. ) - m ) lt .5 and $
			adat.colat[sindex+inds[i],*] le 30. and adat.colat[sindex+inds[i],*] ge 10., mc ))

		jr = reform(adat.jr[sindex+inds[i],minds])
		lats = reform(90.-adat.colat[sindex+inds[i],minds])

		dd = max(jr, maxind, subscript_min=minind)
		pguess = [0.0, 0.5, (lats[minind]+lats[maxind])/2., 5.0, 0.0]
		jcoeffs = mpfitfun('jfit', lats, jr, replicate(1./stddev(jr), mc), pguess, yfit=yfit, /quiet, perror=perror)
		nxx = 60.+findgen(nfit)/(nfit-1.)*30.
		nyy = jfit(nxx, jcoeffs)
		jrmin = min(nyy, minind)
		jrmax = max(nyy, maxind)
		if m lt 12 then begin
			adat.jr_fit_pos[sindex+inds[i],m,0] = nxx[maxind]
			adat.jr_fit_pos[sindex+inds[i],m,1] = nxx[minind]
			adat.jr_fit_pos[sindex+inds[i],m,2] = jrmax
			adat.jr_fit_pos[sindex+inds[i],m,3] = jrmin
		endif else begin
			adat.jr_fit_pos[sindex+inds[i],m,0] = nxx[minind]
			adat.jr_fit_pos[sindex+inds[i],m,1] = nxx[maxind]
			adat.jr_fit_pos[sindex+inds[i],m,2] = jrmin
			adat.jr_fit_pos[sindex+inds[i],m,3] = jrmax
		endelse
		adat.jr_fit_pos[sindex+inds[i],m,4] = sqrt(total((jr-yfit)^2))

	endfor

	yy0 = reform(adat.jr_fit_pos[sindex+inds[i],*,0])
	yy1 = reform(adat.jr_fit_pos[sindex+inds[i],*,1])
	pguess = [70.0, 1.0, 0.1]

	; initial fit of circle
	imcoeffs0 = mpfitfun('mfiti', xx, yy0, reform(adat.jr_pos_fit[sindex+inds[i],*,4]), pguess, weight=wei, yfit=yfit0, /quiet, perror=perror)
	imcoeffs1 = mpfitfun('mfiti', xx, yy1, reform(adat.jr_pos_fit[sindex+inds[i],*,4]), pguess, weight=wei, yfit=yfit1, /quiet, perror=perror)
	; throw away all points that are more than 2 degrees of circle fit
	ginds0 = where( abs( yy0-yfit0 ) le dlat, cc0, complement=ninds0, ncomplement=nin0)
	ginds1 = where( abs( yy1-yfit1 ) le dlat, cc1, complement=ninds1, ncomplement=nin1)
	if cc0 gt minpts then begin
		nguess = [imcoeffs0, 1.0, 0.1]
		mcoeffs0 = mpfitfun('mfit', xx[ginds0], yy0[ginds0], abs(yy0[ginds0]-yfit0[ginds0]), nguess, /quiet, perror=perror)
		adat.jr_fit_coeffs[sindex+inds[i],*,0] = mcoeffs0
	endif else begin
		adat.jr_fit_coeffs[sindex+inds[i],*,0] = replicate(!values.f_nan, 5)
	endelse
	if cc1 gt minpts then begin
		nguess = [imcoeffs1, 1.0, 0.1]
		mcoeffs1 = mpfitfun('mfit', xx[ginds1], yy1[ginds1], abs(yy1[ginds1]-yfit1[ginds1]), nguess, /quiet, perror=perror)
		adat.jr_fit_coeffs[sindex+inds[i],*,1] = mcoeffs1
	endif else begin
		adat.jr_fit_coeffs[sindex+inds[i],*,1] = replicate(!values.f_nan, 5)
	endelse

endfor

end

