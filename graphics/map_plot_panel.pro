;+ 
; NAME: 
; MAP_PLOT_PANEL
; 
; PURPOSE: 
; This procedure plots a stereographic map grid and overlays coast
; lines.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; MAP_PLOT_PANEL
;
; OPTIONAL INPUTS:
; Xmaps: The total number of columns of plots on the resulting page.
; Default is 1.
;
; Ymaps: The total number of rows of plots on the resulting page.
; Default is 1.
;
; Xmap: The current horizontal (column) index of this panel.
; Default is 0.
;
; Ymap: The current vertical (row) index of this panel.
; Default is 0.
;
; KEYWORD PARAMETERS:
; DATE: A scalar giving the date to plot, in YYYYMMDD format.
;
; TIME: A scalar giving the time to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'mag' and 'geo'.
; Default is 'mag'.
;
; XRANGE: Set this keyword to change the range of the x axis.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; XTITLE: Set this keyword to change the title of the x axis.
;
; YTITLE: Set this keyword to change the title of the y axis.
;
; XTICKS: Set this keyword to change the number of major x tick marks.
;
; XMINOR: Set this keyword to change the number of minor x tick marks.
;
; YTICKS: Set this keyword to change the number of major y tick marks.
;
; YMINOR: Set this keyword to change the number of minor y tick marks.
;
; POSITION: Set this keyword to a 4-element vector holding the normalized
; coordinates of the ouput panel. Use this to override internal positioning.
;
; GRID_LINESTYLE: Set this keyword to change the style of the grid lines.
; Default is 0 (solid).
;
; GRID_LINECOLOR: Set this keyword to a color index to change the color of the grid lines.
; Default is black.
;
; GRID_LINETHICK: Set this keyword to change the thickness of the grid lines.
; Default is 1.
;
; COAST_LINESTYLE: Set this keyword to change the style of the coast line.
; Default is 0 (solid).
;
; COAST_LINECOLOR: Set this keyword to a color index to change the color of the coast line.
; Default is black.
;
; COAST_LINETHICK: Set this keyword to change the thickness of the coast line.
; Default is 1.
;
; LAND_FILLCOLOR: Set this keyword to the color index to use for filling land masses.
; Default is green (123).
;
; LAKE_FILLCOLOR: Set this keyword to the color index to use for filling lakes.
; Default is blue (20).
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; NO_FILL: Set this keyword to surpress filling of land masses and lakes with colors.
;
; NO_AXIS: Set this keyword to surpress y and x axes.
;
; NO_COAST: Set this keyword to surpress overlaying coast lines.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_POLAR.
; Written by Lasse Clausen, Dec, 1 2009
;-
pro map_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, jul=jul, $
	coords=coords, xrange=xrange, yrange=yrange, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $ 
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	position=position, bar=bar, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	hemisphere=hemisphere, north=north, south=south, rotate=rotate, $
	no_coast=no_coast, no_fill=no_fill, no_axis=no_axis, no_grid=no_grid

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
	position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, bar=bar)

if ~keyword_set(coords) then $
	coords = get_coordinates()

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if strcmp(strlowcase(coords), 'mlt') then begin
	if ~keyword_set(jul) then begin
		if ~keyword_set(date) then begin
			prinfo, 'You must provide a date/time for MLT plotting.'
			return
		endif
		if n_elements(time) lt 1 then $
			time = 1200
		sfjul, date, time, jul, long=long
	endif
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
	coast_linethick = 3

if n_elements(coast_linestyle) eq 0 then $
	coast_linestyle = 0

if n_elements(coast_linecolor) eq 0 then $
	coast_linecolor = get_gray()

if n_elements(land_fillcolor) eq 0 then $
	land_fillcolor = 123

if n_elements(lake_fillcolor) eq 0 then $
	lake_fillcolor = 20

if ~keyword_set(hemisphere) then begin
  if keyword_set(north) then $
    hemisphere = 1. $
  else if keyword_set(south) then $
    hemisphere = -1. $
  else $
    hemisphere = 1.
endif

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

if ~keyword_set(no_grid) then begin
	map_overlay_grid, $
		grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
		grid_linethick=grid_linethick, rotate=rotate
endif

if ~keyword_set(no_axis) then begin
	; Plot axis
	plot, [0,0], /nodata, xstyle=1, ystyle=1, $
		yrange=yrange, xrange=xrange, position=position, $
		xtitle=xtitle, ytitle=ytitle, color=get_foreground(), $
		xtickname=replicate(' ', 50), ytickname=replicate(' ', 50)
endif

; put a little legend on the plot to indicate input parameters
xpos = !x.crange[0] - .01*(!x.crange[1]-!x.crange[0])
ypos = !y.crange[1]
str = (coords eq 'geog' ? 'Geographic' : (coords eq 'magn' ? 'Magnetic' : 'MLT') ) + ' coordinates'
xyouts, xpos, ypos, orientation=90., $
	str, align=1., $
	/data, charsize=get_charsize(1,3)

end
