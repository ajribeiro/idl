;+ 
; NAME: 
; OVERLAY_COAST
; 
; PURPOSE: 
; This procedure overlays coast lines on a stereographic map grid produced by MAP_PLOT_PANEL.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
;
; KEYWORD PARAMETERS:
; COORDS: Set this keyword to the coordinates in which to overlay the coast lines
;
; JUL: Set this keyword to the Julian Day Number to use for the plotting of the coast lines.
; This keyword only applies when using Magnetic Local Time coordinates.
;
; SILENT: Set this keyword to surpress all messages/warnings.
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
; NO_FILL: Set this keyword to surpress filling of land masses and lakes with colors.
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; ROTATE: Set this keyword to a number of degree by which to rotate the coast
; clockwise. Make sure that you give the same number of degrees to
; MAP_PLOT_PANEL and all other plotting routines.
;
; NORTH: Set this keyword to overlay the northern hemisphere coast.
;
; SOUTH: Set this keyword to overlay the southern hemisphere coast.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's OVERLAY_POLAR_COAST.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro overlay_coast, coords=coords, jul=jul, silent=silent, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	hemisphere=hemisphere, north=north, south=south, rotate=rotate, no_fill=no_fill

if ~keyword_set(coords) then $
	coords = get_coordinates()

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if ~keyword_set(hemisphere) then begin
  if keyword_set(north) then $
    hemisphere = 1. $
  else if keyword_set(south) then $
    hemisphere = -1. $
  else $
    hemisphere = 1.
endif

if ~keyword_set(coast_linethick) then $
	coast_linethick = 2

if n_elements(coast_linestyle) eq 0 then $
	coast_linestyle = 0

if n_elements(coast_linecolor) eq 0 then $
	coast_linecolor = get_foreground()

if n_elements(land_fillcolor) eq 0 then $
	land_fillcolor = 123

if n_elements(lake_fillcolor) eq 0 then $
	lake_fillcolor = 20

if coords eq 'geog' then $
	overlay_geo_coast, silent=silent, no_fill=no_fill, $
		coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
		coast_linethick=coast_linethick, $
		land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
		hemisphere=hemisphere, rotate=rotate $
else if coords eq 'magn' then $
	overlay_mag_coast, silent=silent, no_fill=no_fill, $
		coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
		coast_linethick=coast_linethick, $
		land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
		hemisphere=hemisphere, rotate=rotate $
else if coords eq 'mlt' then begin
	if ~keyword_set(jul) then begin
		prinfo, 'You must provide a date/time for MLT plotting.'
		return
	endif
	overlay_mlt_coast, jul, silent=silent, no_fill=no_fill, $
		coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
		coast_linethick=coast_linethick, $
		land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
		hemisphere=hemisphere, rotate=rotate
endif else $
	prinfo, 'Coordinate system "'+coords+'" not (yet) allowed in OVERLAY_COAST.'

end
