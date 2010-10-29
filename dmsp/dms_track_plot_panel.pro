pro dms_track_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, $
	silent=silent, $
	charthick=charthick, charsize=charsize, symsize=symsize, $ 
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	position=position, bar=bar, mark_interval=mark_interval, $
	mark_charsize=mark_charsize, mark_charthick=mark_charthick, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	linecolor=linecolor, linethick=linethick, $
	hemisphere=hemisphere, north=north, south=south, rotate=rotate, $
	no_coast=no_coast, no_fill=no_fill, no_axis=no_axis, no_map=no_map

common dms_data_blk

if ~keyword_set(linecolor) then $
	linecolor = 253

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(yrange) then $
	yrange = [-31,31]

if ~keyword_set(xrange) then $
	xrange = [-31,31]

aspect = float(xrange[1]-xrange[0])/float(yrange[1]-yrange[0])
if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, bar=bar, with_info=with_info)

if ~keyword_set(date) then begin
	caldat, dms_ssj_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return
endif

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if ~keyword_set(grid_linethick) then $
	grid_linethick = 1

if n_elements(grid_linestyle) eq 0 then $
	grid_linestyle = 0

if n_elements(grid_linecolor) eq 0 then $
	grid_linecolor = get_gray()

if ~keyword_set(fov_linethick) then $
	fov_linethick = 1

if n_elements(fov_linestyle) eq 0 then $
	fov_linestyle = 0

if n_elements(fov_linecolor) eq 0 then $
	fov_linecolor = get_gray()

if ~keyword_set(coast_linethick) then $
	coast_linethick = 3

if n_elements(coast_linestyle) eq 0 then $
	coast_linestyle = 0

if n_elements(coast_linecolor) eq 0 then $
	coast_linecolor = get_gray()

if n_elements(land_fillcolor) eq 0 then $
	land_fillcolor = 123

if n_elements(lake_fillcolor) eq 0 then $
	lake_fillcolor = 20

if ~keyword_set(linethick) then $
	linethick = 3.

if ~keyword_set(symsize) then $
	symsize = .75

if ~keyword_set(mark_interval) then $
	mark_interval = -1

if ~keyword_set(mark_charsize) then $
	mark_charsize = .55*(strupcase(!d.name) eq 'X' ? 2. : 1.)

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

if ~keyword_set(no_map) then begin
	map_plot_panel, xmaps, ymaps, xmap, ymap, $
		date=date, time=time, long=long, $
		coords=coords, xrange=xrange, yrange=yrange, $
		silent=silent, $
		charthick=charthick, charsize=charsize, $ 
		xtitle=xtitle, ytitle=ytitle, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		position=position, $
		grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
		grid_linethick=grid_linethick, $
		coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
		coast_linethick=coast_linethick, $
		land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
		hemisphere=hemisphere, rotate=rotate, no_fill=no_fill
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
if n_elements(rotate) ne 0 then begin
	_x1 = cos(rotate*!dtor)*xpos - sin(rotate*!dtor)*ypos
	_y1 = sin(rotate*!dtor)*xpos + cos(rotate*!dtor)*ypos
	xpos = _x1
	ypos = _y1
endif
oplot, xpos, ypos, color=get_white(), thick=2.*linethick
oplot, xpos, ypos, color=linecolor, thick=linethick

if mark_interval ne -1 then begin
	load_usersym, /circle
	mark_every = round(mark_interval*60./dt)
	n_dots = n_elements(xpos)/mark_every+1L
	ind_dots = (lindgen(n_dots)*mark_every) < (cc-1L)
	mark_every = floor(230./n_dots)
;		col_dots = lindgen(n_dots)*mark_every+10L
	plots, xpos[ind_dots], ypos[ind_dots], $
		color=get_foreground(), $
		psym=8, noclip=0, symsize=symsize
;	plots, xpos[ind_dots], ypos[ind_dots], $
;		color=col_dots, $
;		psym=8, noclip=0, symsize=1.5*symsize
	angs = atan(ypos[ind_dots], xpos[ind_dots])*!radeg + 180.
	for k=0, n_dots-1 do $
		xyouts, xpos[ind_dots[k]], ypos[ind_dots[k]], format_juldate(juls[ind_dots[k]], /short_time), /data, $
			orient=angs[k], charthick=mark_charthick, charsize=mark_charsize, color=linecolor, noclip=0
endif

end