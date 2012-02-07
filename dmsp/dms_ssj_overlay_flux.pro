
pro dms_ssj_overlay_flux, $
	date=date, time=time, long=long, $
	coords=coords, $
	psym=psym, $
	symsize=symsize, scale=scale, $
	north=north, south=south, $
	electrons=electrons, ions=ions, ratio=ratio, $
	energy=energy, number=number, $
	mark_interval=mark_interval, mark_charthick=mark_charthick, mark_charsize=mark_charsize

common dms_data_blk

if ~keyword_set(coords) then $
	coords='magn'

if ~keyword_set(mark_interval) then $
	mark_interval=-1.

if ~keyword_set(mark_charthick) then $
	mark_charthick=!p.charthick

if ~keyword_set(mark_charsize) then $
	mark_charsize=!p.charsize

if ~keyword_set(date) then $
	sfjul, date, tt, dms_ssj_data.juls[0], /jul

if ~keyword_set(time) then $
	time = [0, 2400]

sfjul, date, time, sjul, fjul

if ~keyword_set(electrons) and ~keyword_set(ions) then $
	electrons=1

if ~keyword_set(north) and ~keyword_set(south) then $
	north=1

if ~keyword_set(energy) and ~keyword_set(number) then $
	number=1

; check hemisphere and north and south
if keyword_set(north) then $
	hemisphere = 1. $
else if keyword_set(south) then $
	hemisphere = -1. $
else $
	hemisphere = 1.

if ~keyword_set(psym) then $
	psym=8

if psym eq 8 then $
	load_usersym, /circle

if ~keyword_set(symsize) then $
	symsize=1.5

if ~keyword_set(scale) then begin
	if keyword_set(electrons) then begin
		if keyword_set(energy) then $
			scale=[10.,13.]
		if keyword_set(number) then $
			scale=[6.,9.]
	endif
	if keyword_set(ions) then begin
		if keyword_set(energy) then $
			scale=[8.5,11.5]
		if keyword_set(number) then $
			scale=[5.,8.]
	endif
	if keyword_set(ratio) then begin
		if keyword_set(energy) then $
			scale=[-1.,1.]
		if keyword_set(number) then $
			scale=[-1.,1.]
	endif
endif

jinds = where(dms_ssj_data.juls ge sjul and dms_ssj_data.juls le fjul and dms_ssj_data.hemi eq hemisphere, cc)
if cc eq 0L then begin
	prinfo, 'No data loaded for interval or for hemisphere.'
	return
endif
juls = dms_ssj_data.juls[jinds]
dt = mean(deriv((juls-juls[0])*1440.d))

if coords eq 'geog' then $
	tmp = calc_stereo_coords(dms_ssj_data.glat[jinds], dms_ssj_data.glon[jinds]) $
else if coords eq 'magn' then $
	tmp = calc_stereo_coords(dms_ssj_data.mlat[jinds], dms_ssj_data.mlon[jinds]) $
else if coords eq 'mlt' then $
	tmp = calc_stereo_coords(dms_ssj_data.mlat[jinds], dms_ssj_data.mlt[jinds], /mlt) $
else begin
	prinfo, 'Coordinate system not supported: '+coords
	return
endelse
xpos = tmp[0,*]
ypos = tmp[1,*]

if keyword_set(electrons) then begin
	if keyword_set(energy) then $
		ydata = alog10(dms_ssj_data.jee[jinds])
	if keyword_set(number) then $
		ydata = alog10(dms_ssj_data.jne[jinds])
	load_usersym, /circle, /above
endif
if keyword_set(ions) then begin
	if keyword_set(energy) then $
		ydata = alog10(dms_ssj_data.jei[jinds])
	if keyword_set(number) then $
		ydata = alog10(dms_ssj_data.jni[jinds])
	load_usersym, /circle, /below
endif
if keyword_set(ratio) then begin
	if keyword_set(energy) then $
		ydata = ( alog10(dms_ssj_data.jee[jinds]) - alog10(dms_ssj_data.jei[jinds]) ) / $
			( alog10(dms_ssj_data.jee[jinds]) + alog10(dms_ssj_data.jei[jinds]) )
	if keyword_set(number) then $
		ydata = ( alog10(dms_ssj_data.jne[jinds]) - alog10(dms_ssj_data.jni[jinds]) ) / $
			( alog10(dms_ssj_data.jne[jinds]) + alog10(dms_ssj_data.jni[jinds]) )
	load_usersym, /rectangle, /below
endif

ydata = smooth(ydata, 5, /nan)

for p=0, cc-1L do begin
		col = get_color_index(ydata[p], param='power', scale=scale)
		plots, xpos[p], ypos[p], color=col, psym=psym, symsize=symsize, /data, noclip=0
endfor

if mark_interval ne -1 then begin
	dx = smooth(deriv(xpos), 11)
	dy = smooth(deriv(ypos), 11)
	load_usersym, /circle
	mark_every = round(mark_interval*60./dt)
	n_dots = n_elements(xpos)/mark_every+1L
	ind_dots = (lindgen(n_dots)*mark_every) < (cc-1L)
	mark_every = floor(230./n_dots)
;		col_dots = lindgen(n_dots)*mark_every+10L
;	plots, xpos[ind_dots], ypos[ind_dots], $
;		color=col_dots, $
;		psym=8, noclip=0, symsize=1.5*symsize
	angs = -atan(dx[ind_dots], dy[ind_dots])*!radeg
endif

if mark_interval ne -1 then begin
	for i=0, n_dots-1 do begin
		plots, xpos[ind_dots[i]], ypos[ind_dots[i]], $
			color=get_foreground(), $
			psym=8, noclip=0, symsize=.5*symsize
		xyouts, xpos[ind_dots[i]], ypos[ind_dots[i]], format_juldate(juls[ind_dots[i]], /short_time), /data, $
			orient=angs[i], charthick=mark_charthick, charsize=mark_charsize, color=get_foreground(), noclip=0
	endfor
endif

end
