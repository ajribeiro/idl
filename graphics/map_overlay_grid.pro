;+ 
; NAME: 
; MAP_OVERLAY_GRID
; 
; PURPOSE: 
; This procedure overplots a stereographic map grid.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; MAP_OVERLAY_GRID
;
; KEYWORD PARAMETERS:
; GRID_LINESTYLE: Set this keyword to change the style of the grid lines.
; Default is 0 (solid).
;
; GRID_LINECOLOR: Set this keyword to a color index to change the color of the grid lines.
; Default is black.
;
; GRID_LINETHICK: Set this keyword to change the thickness of the grid lines.
; Default is 1.
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_POLAR_GRID.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro map_overlay_grid, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, hemisphere=hemisphere, rotate=rotate

if ~keyword_set(grid_linethick) then $
	grid_linethick = 1

if n_elements(grid_linestyle) eq 0 then $
	grid_linestyle = 0

if n_elements(grid_linecolor) eq 0 then $
	grid_linecolor = get_gray()

if ~KEYWORD_SET(hemisphere) THEN $
	hemisphere=1

; latitude rings
FOR grid=10,100,10 DO BEGIN
	lon   = FINDGEN(101)*!pi/50.
	colat = REPLICATE(grid,101)
	OPLOT, colat, lon, /POLAR, LINEstyle=grid_linestyle, COLOR=grid_linecolor, $
		thick=grid_linethick
ENDFOR

; lines of constant longitude
hourstep=1
FOR grid=0,23,hourstep DO BEGIN
	x1 = [10.*SIN(grid*!pi/12.), 100.*SIN(grid*!pi/12.)]
	y1 = [10.*COS(grid*!pi/12.), 100.*COS(grid*!pi/12.)]
	if n_elements(rotate) ne 0 then begin
		_x1 = cos(rotate*!dtor)*x1 - sin(rotate*!dtor)*y1
		_y1 = sin(rotate*!dtor)*x1 + cos(rotate*!dtor)*y1
		x1 = _x1
		y1 = _y1
	endif
	PLOTS, x1, y1, LINESTYLE=grid_linestyle, COLOR=grid_linecolor, NOCLIP=0, $
		thick=grid_linethick
ENDFOR

;for i=0, 3 do begin
;	
;endfor

END
