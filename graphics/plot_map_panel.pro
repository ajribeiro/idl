;+ 
; NAME: 
; PLOT_MAP_PANEL
; 
; PURPOSE: 
; Deprecated, use MAP_PLOT_PANEL.
;-
pro plot_map_panel, _extra=_extra

prinfo, 'Use MAP_PLOT_PANEL.'

return

end

xmaps, ymaps, xmap, ymap, $
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
	hemisphere=hemisphere, rotate=rotate, $
	no_coast=no_coast, no_fill=no_fill, no_axis=no_axis

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
	position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, /bar)

if ~keyword_set(coords) then $
	coords = get_coordinates()

if strcmp(strlowcase(coords), 'mlt') then begin
	if ~keyword_set(date) then begin
		prinfo, 'You must provide a date/time for MLT plotting.'
		return
	endif
	if n_elements(time) lt 1 then $
		time = 1200
	sfjul, date, time, jul, long=long
endif

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(grid_linethick) then $
	grid_linethick = 1

if n_elements(grid_linestyle) eq 0 then $
	grid_linestyle = 0

if n_elements(grid_linecolor) eq 0 then $
	grid_linecolor = get_gray()

if ~keyword_set(coast_linethick) then $
	coast_linethick = 1

if n_elements(coast_linestyle) eq 0 then $
	coast_linestyle = 0

if n_elements(coast_linecolor) eq 0 then $
	coast_linecolor = get_foreground()

if n_elements(land_fillcolor) eq 0 then $
	land_fillcolor = 123

if n_elements(lake_fillcolor) eq 0 then $
	lake_fillcolor = 20

if ~keyword_set(hemisphere) then $
	hemisphere = 1.

; Plot axis
plot, [0,0], /nodata, xstyle=5, ystyle=5, $
	yrange=yrange, xrange=xrange, position=position

if ~keyword_set(no_coast) then begin
	overlay_coast, coords=coords, jul=jul, no_fill=no_fill, $
		coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
		coast_linethick=coast_linethick, $
		land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
		hemisphere=hemisphere, rotate=rotate
endif

overlay_map_grid, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick

if ~keyword_set(no_axis) then begin
	; Plot axis
	plot, [0,0], /nodata, xstyle=1, ystyle=1, $
		yrange=yrange, xrange=xrange, position=position, $
		xtitle=xtitle, ytitle=ytitle, color=get_foreground(), $
		xtickname=replicate(' ', 50), ytickname=replicate(' ', 50)
endif

end
