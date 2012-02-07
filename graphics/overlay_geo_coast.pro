;+ 
; NAME: 
; OVERLAY_GEO_COAST
; 
; PURPOSE: 
; This procedure overlays coast lines in geographic coordinates 
; on a stereographic map grid produced by 
; PLOT_MAP_GRID.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
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
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY: 
; Based on Steve Milan's OVERLAY_POLAR_COAST.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro overlay_geo_coast, silent=silent, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	no_fill=no_fill, $
	hemisphere=hemisphere, rotate=rotate

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
			xx = reform(coast[2,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			yy = reform(coast[3,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			hinds = where(coast[4,ind[ninds[i]]+1:ind[ninds[i]+1]-1] eq hemisphere, $
				hcount)
			if hcount lt 3 then $
				continue
			xx = xx[hinds]
			yy = yy[hinds]
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
			xx = reform(coast[2,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			yy = reform(coast[3,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			hinds = where(coast[4,ind[ninds[i]]+1:ind[ninds[i]+1]-1] eq hemisphere, $
				hcount)
			if hcount lt 3 then $
				continue
			xx = xx[hinds]
			yy = yy[hinds]
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
			xx = reform(coast[2,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			yy = reform(coast[3,ind[ninds[i]]+1:ind[ninds[i]+1]-1])
			hinds = where(coast[4,ind[ninds[i]]+1:ind[ninds[i]+1]-1] eq hemisphere, $
				hcount)
			if hcount lt 3 then $
				continue
			xx = xx[hinds]
			yy = yy[hinds]
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
	xx = reform(coast[2,ind[i]+1:ind[i+1]-1])
	yy = reform(coast[3,ind[i]+1:ind[i+1]-1])
	hinds = where(coast[4,ind[i]+1:ind[i+1]-1] eq hemisphere, $
		hcount)
	if hcount lt 3 then $
		continue
	xx = xx[hinds]
	yy = yy[hinds]
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

end
