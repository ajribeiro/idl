;+ 
; NAME: 
; OVERLAY_MAP_GRID
; 
; PURPOSE: 
; Deprecated, use MAP_OVERLAY_GRID.
;-
pro overlay_map_grid, _extra=_extra

prinfo, 'Deprecated, use MAP_OVERLAY_GRID'

return

end
$
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, hemisphere=hemisphere

if ~keyword_set(grid_linethick) then $
	grid_linethick = 1

if n_elements(grid_linestyle) eq 0 then $
	grid_linestyle = 0

if n_elements(grid_linecolor) eq 0 then $
	grid_linecolor = get_gray()

if ~KEYWORD_SET(hemisphere) THEN $
	hemisphere=1

FOR grid=10,60,10 DO BEGIN
	lon   = FINDGEN(101)*!pi/50.
	colat = REPLICATE(grid,101)
	OPLOT, colat, lon, /POLAR, LINEstyle=grid_linestyle, COLOR=grid_linecolor, $
		thick=grid_linethick
ENDFOR

hourstep=1
FOR grid=0,23,hourstep DO BEGIN
	x1 = [10.*SIN(grid*!pi/12.), 60.*SIN(grid*!pi/12.)]
	y1 = [10.*COS(grid*!pi/12.), 60.*COS(grid*!pi/12.)]
	PLOTS, x1, y1, LINESTYLE=grid_linestyle, COLOR=grid_linecolor, NOCLIP=0, $
		thick=grid_linethick
ENDFOR
	
END
