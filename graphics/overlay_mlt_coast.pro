;+ 
; NAME: 
; OVERLAY_MLT_COAST
; 
; PURPOSE: 
; This procedure overlays coast lines in magnetic local time (MLT) coordinates 
; on a stereographic map grid.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
;
; INPUTS:
; Jul: Set this to the Julian Day Number to use for the plotting of the coast lines.
;
; KEYWORD PARAMETERS:
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
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; NO_FILL: Set this keyword to surpress filling of land masses and lakes with colors.
;
; ROTATE: Set this keyword to a number of degree by which to rotate the coast
; clockwise. Make sure that you give the same number of degrees to
; MAP_PLOT_PANEL and all other plotting routines.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's OVERLAY_POLAR_COAST.
; Written by Lasse Clausen, Nov, 24 2009
;-
PRO overlay_mlt_coast, jul, silent=silent, no_fill=no_fill, $
		coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
		coast_linethick=coast_linethick, $
		land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
		hemisphere=hemisphere, rotate=rotate

if n_params() lt 1 then begin
	prinfo, 'You must provide a date/time for MLT plotting.'
	return
endif

if ~keyword_set(hemisphere) then $
	hemisphere = 1.

if ~keyword_set(coast_linethick) then $
	coast_linethick = 1.

if n_elements(coast_linestyle) eq 0 then $
	coast_linestyle = 0

if n_elements(coast_linecolor) eq 0 then $
	coast_linecolor = get_foreground()

if n_elements(land_fillcolor) eq 0 then $
	land_fillcolor = 123

if n_elements(lake_fillcolor) eq 0 then $
	lake_fillcolor = 20

caldat, jul, mm, dd, year
ut_sec = (jul-julday(1,1,year,0,0,0))*86400.d

openr, lun, getenv('RAD_RESOURCE_PATH')+'/world_data.dat', /get_lun
readf, lun, tnum
coast = make_array(11, tnum)
readf, lun, coast
free_lun, lun

ind = where(coast[0,*] eq 0 and coast[1,*] eq 0, bits)

if ~keyword_set(no_fill) then begin
	layers = make_array(bits-1, /int)
	for i=0, bits-2 do $
		layers[i] = coast[10,ind[i]+1]
	
	;- fill continents first
	ninds = where(layers eq 0, count)
	if count ne 0 then begin
		for i=0, count-1 do begin
			;- read coast in magnetic coords
			lat = reform(coast[5,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			lon = reform(coast[6,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			hinds = where(coast[9,ind[ninds[i]]+1:ind[ninds[i]+1]-1] eq hemisphere, $
				hcount)
			if hcount lt 3 then $
				continue
			lat = lat[hinds]
			lon = lon[hinds]
			xx = lat
			yy = lon
			;- convert to mlt
			for k=0, n_elements(lon)-1 do begin
				lon[k] = mlt(year, ut_sec, lon[k])
				;- then convert to stereo coords
				tmp = calc_stereo_coords(lat[k], lon[k], /mlt)
				xx[k] = tmp[0]
				yy[k] = tmp[1]
			endfor
			; we need to insert some imaginary points
			; if only half the continent is drawn.
			diff = sqrt((xx-shift(xx, -1))^2 + (yy-shift(yy, -1))^2)
			splits = where(diff gt 2., cs)
			;if i eq 73 then stop
			for s=0, cs-1 do begin
				ang1 = atan(yy[splits[s]+s*2L], xx[splits[s]+s*2L])
				ang2 = atan(yy[(splits[s]+s*2L+1L) mod (hcount+s*2L-1L)], xx[(splits[s]+s*2L+1L) mod (hcount+s*2L-1L)])
				rad = 90.*( sqrt( 1. + tan( (ang2-ang1)/2. )^2 ) - 1.) + 10.
				if splits[s] eq hcount-1L then begin
					nxx = [ xx[0:splits[s]+s*2L], $
						xx[splits[s]+s*2L]+rad*cos(ang1), $
						xx[0]+rad*cos(ang2) ]
					nyy = [ yy[0:splits[s]+s*2L], $
						yy[splits[s]+s*2L]+rad*sin(ang1), $
						yy[0]+rad*sin(ang2) ]
				endif else begin
					nxx = [ xx[0:splits[s]+s*2L], $
						xx[splits[s]+s*2L]+rad*cos(ang1), $
						xx[splits[s]+s*2L+1L]+rad*cos(ang2), $
						xx[splits[s]+s*2L+1L:hcount-1L] ]
					nyy = [ yy[0:splits[s]+s*2L], $
						yy[splits[s]+s*2L]+rad*sin(ang1), $
						yy[splits[s]+s*2L+1L]+rad*sin(ang2), $
						yy[splits[s]+s*2L+1L:hcount-1L] ]
				endelse
				xx = nxx
				yy = nyy
			endfor
			if n_elements(rotate) ne 0 then begin
				_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
				_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
				xx = _x1
				yy = _y1
			endif
			;if keyword_set(rotate) then $
			;	swap, xx, yy, /right
			polyfill, xx, yy, color=land_fillcolor, noclip=0
		endfor
	endif
	;- fill lakes
	ninds = where(layers eq 1, count)
	if count ne 0 then begin
		for i=0, count-1 do begin
			lat = reform(coast[5,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			lon = reform(coast[6,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			hinds = where(coast[9,ind[ninds[i]]+1:ind[ninds[i]+1]-1] eq hemisphere, $
				hcount)
			if hcount lt 3 then $
				continue
			lat = lat[hinds]
			lon = lon[hinds]
			xx = lat
			yy = lon
			;- convert to mlt
			for k=0, n_elements(lon)-1 do begin
				lon[k] = mlt(year, ut_sec, lon[k])
				;- then convert to stereo coords
				tmp = calc_stereo_coords(lat[k], lon[k], /mlt)
				xx[k] = tmp[0]
				yy[k] = tmp[1]
			endfor
			; we need to insert some imaginary points
			; if only half the continent is drawn.
			diff = sqrt((xx-shift(xx, -1))^2 + (yy-shift(yy, -1))^2)
			splits = where(diff gt 2., cs)
			;if i eq 73 then stop
			for s=0, cs-1 do begin
				ang1 = atan(yy[splits[s]+s*2L], xx[splits[s]+s*2L])
				ang2 = atan(yy[(splits[s]+s*2L+1L) mod (hcount+s*2L-1L)], xx[(splits[s]+s*2L+1L) mod (hcount+s*2L-1L)])
				rad = 90.*( sqrt( 1. + tan( (ang2-ang1)/2. )^2 ) - 1.) + 10.
				if splits[s] eq hcount-1L then begin
					nxx = [ xx[0:splits[s]+s*2L], $
						xx[splits[s]+s*2L]+rad*cos(ang1), $
						xx[0]+rad*cos(ang2) ]
					nyy = [ yy[0:splits[s]+s*2L], $
						yy[splits[s]+s*2L]+rad*sin(ang1), $
						yy[0]+rad*sin(ang2) ]
				endif else begin
					nxx = [ xx[0:splits[s]+s*2L], $
						xx[splits[s]+s*2L]+rad*cos(ang1), $
						xx[splits[s]+s*2L+1L]+rad*cos(ang2), $
						xx[splits[s]+s*2L+1L:hcount-1L] ]
					nyy = [ yy[0:splits[s]+s*2L], $
						yy[splits[s]+s*2L]+rad*sin(ang1), $
						yy[splits[s]+s*2L+1L]+rad*sin(ang2), $
						yy[splits[s]+s*2L+1L:hcount-1L] ]
				endelse
				xx = nxx
				yy = nyy
			endfor
			if n_elements(rotate) ne 0 then begin
				_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
				_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
				xx = _x1
				yy = _y1
			endif
			;if keyword_set(rotate) then $
			;	swap, xx, yy, /right
			polyfill, xx, yy, color=lake_fillcolor, noclip=0
		endfor
	endif
	
	;- fill islands in lakes
	ninds = where(layers eq 2, count)
	if count ne 0 then begin
		for i=0, count-1 do begin
			lat = reform(coast[5,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			lon = reform(coast[6,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			hinds = where(coast[9,ind[ninds[i]]+1:ind[ninds[i]+1]-1] eq hemisphere, $
				hcount)
			if hcount lt 3 then $
				continue
			lat = lat[hinds]
			lon = lon[hinds]
			xx = lat
			yy = lon
			;- convert to mlt
			for k=0, n_elements(lon)-1 do begin
				lon[k] = mlt(year, ut_sec, lon[k])
				;- then convert to stereo coords
				tmp = calc_stereo_coords(lat[k], lon[k], /mlt)
				xx[k] = tmp[0]
				yy[k] = tmp[1]
			endfor
			; we need to insert some imaginary points
			; if only half the continent is drawn.
			diff = sqrt((xx-shift(xx, -1))^2 + (yy-shift(yy, -1))^2)
			splits = where(diff gt 2., cs)
			;if i eq 73 then stop
			for s=0, cs-1 do begin
				ang1 = atan(yy[splits[s]+s*2L], xx[splits[s]+s*2L])
				ang2 = atan(yy[(splits[s]+s*2L+1L) mod (hcount+s*2L-1L)], xx[(splits[s]+s*2L+1L) mod (hcount+s*2L-1L)])
				rad = 90.*( sqrt( 1. + tan( (ang2-ang1)/2. )^2 ) - 1.) + 10.
				if splits[s] eq hcount-1L then begin
					nxx = [ xx[0:splits[s]+s*2L], $
						xx[splits[s]+s*2L]+rad*cos(ang1), $
						xx[0]+rad*cos(ang2) ]
					nyy = [ yy[0:splits[s]+s*2L], $
						yy[splits[s]+s*2L]+rad*sin(ang1), $
						yy[0]+rad*sin(ang2) ]
				endif else begin
					nxx = [ xx[0:splits[s]+s*2L], $
						xx[splits[s]+s*2L]+rad*cos(ang1), $
						xx[splits[s]+s*2L+1L]+rad*cos(ang2), $
						xx[splits[s]+s*2L+1L:hcount-1L] ]
					nyy = [ yy[0:splits[s]+s*2L], $
						yy[splits[s]+s*2L]+rad*sin(ang1), $
						yy[splits[s]+s*2L+1L]+rad*sin(ang2), $
						yy[splits[s]+s*2L+1L:hcount-1L] ]
				endelse
				xx = nxx
				yy = nyy
			endfor
			if n_elements(rotate) ne 0 then begin
				_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
				_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
				xx = _x1
				yy = _y1
			endif
			;if keyword_set(rotate) then $
			;	swap, xx, yy, /right
			polyfill, xx, yy, color=land_fillcolor, noclip=0
		endfor
	endif
endif

for i=0, bits-2 do begin
	lat = reform(coast[5,ind[i]+1:ind[i+1]-1])
	lon = reform(coast[6,ind[i]+1:ind[i+1]-1])
	hinds = where(coast[9,ind[i]+1:ind[i+1]-1] eq hemisphere, $
		hcount)
	if hcount lt 3 then $
		continue
	lat = lat[hinds]
	lon = lon[hinds]
	xx = lat
	yy = lon
	;- convert to mlt
	for k=0, n_elements(lon)-1 do begin
		lon[k] = mlt(year, ut_sec, lon[k])
		;- then convert to stereo coords
		tmp = calc_stereo_coords(lat[k], lon[k], /mlt)
		xx[k] = tmp[0]
		yy[k] = tmp[1]
	endfor
	; we need to insert some imaginary points
	; if only half the continent is drawn.
	diff = sqrt((xx-shift(xx, -1))^2 + (yy-shift(yy, -1))^2)
	splits = where(diff gt 2., cs)
	;if i eq 73 then stop
	for s=0, cs-1 do begin
		ang1 = atan(yy[splits[s]+s*2L], xx[splits[s]+s*2L])
		ang2 = atan(yy[(splits[s]+s*2L+1L) mod (hcount+s*2L-1L)], xx[(splits[s]+s*2L+1L) mod (hcount+s*2L-1L)])
		rad = 90.*( sqrt( 1. + tan( (ang2-ang1)/2. )^2 ) - 1.) + 10.
		if splits[s] eq hcount-1L then begin
			nxx = [ xx[0:splits[s]+s*2L], $
				xx[splits[s]+s*2L]+rad*cos(ang1), $
				xx[0]+rad*cos(ang2) ]
			nyy = [ yy[0:splits[s]+s*2L], $
				yy[splits[s]+s*2L]+rad*sin(ang1), $
				yy[0]+rad*sin(ang2) ]
		endif else begin
			nxx = [ xx[0:splits[s]+s*2L], $
				xx[splits[s]+s*2L]+rad*cos(ang1), $
				xx[splits[s]+s*2L+1L]+rad*cos(ang2), $
				xx[splits[s]+s*2L+1L:hcount-1L] ]
			nyy = [ yy[0:splits[s]+s*2L], $
				yy[splits[s]+s*2L]+rad*sin(ang1), $
				yy[splits[s]+s*2L+1L]+rad*sin(ang2), $
				yy[splits[s]+s*2L+1L:hcount-1L] ]
		endelse
		xx = nxx
		yy = nyy
	endfor
	if n_elements(rotate) ne 0 then begin
		_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
		_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
		xx = _x1
		yy = _y1
	endif
	;if keyword_set(rotate) then $
	;	swap, xx, yy, /right
	oplot, xx, yy, linestyle=coast_linestyle, color=coast_linecolor, $
		thick=coast_linethick, noclip=0
endfor

END
