;+ 
; NAME: 
; MAP_LABEL_GRID
; 
; PURPOSE: 
; This procedure labels certain latitudes and longitudes of a stereographic map grid.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; MAP_LABEL_GRID
;
; KEYWORD PARAMETERS:
; COLOR:
;
; CHARTHICK:
;
; CHARSIZE:
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; COORDS: Set this keyword to a string naming the coordinate system.
; Allowable inputs are 'mlt', 'magn' and 'geog'.
; Default is 'magn'. We need this so that we can label "longitudes"
; in "mlt" coordinates correctly.
;
; ROTATE: Set this keyword to a number of degrees by which to rotate the map clockwise.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
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
; Based on Steve Milan's PLOT_POLAR_GRID.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro map_label_grid, coords=coords, hemisphere=hemisphere, $
	color=color, charthick=charthick, charsize=charsize, rotate=rotate, yoff=yoff, $
	latlabel=latlabel, no_label_lats=no_label_lats, no_label_lons=no_label_lons

if ~keyword_set(charthick) then $
	charthick = !p.charthick

if n_elements(color) eq 0 then $
	color = get_black()

if n_elements(charsize) eq 0 then $
	charsize = !p.charsize

if ~KEYWORD_SET(hemisphere) THEN $
	hemisphere=1

if ~keyword_set(coords) then $
	coords = get_coordinates()

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if n_elements(rotate) eq 0 then $
	rotate = 0.

; determin where to put the 
; latitude labels
midangle = round(((atan(mean(!x.crange), mean(!y.crange))*!radeg + 360.) mod 360.)/15.)
if n_elements(latlabel) eq 0 then begin
	if mean(!x.crange) eq 0. and mean(!y.crange) eq 0. then $
		latlabel = 6 $
	else $
		latlabel = midangle
endif

if ~keyword_set(no_label_lats) then begin
	; label some latitudes
	for l=10, 100, 10 do begin
		x1 = (l-.5)*SIN(latlabel*!pi/12.)
		y1 = (l-.5)*COS(latlabel*!pi/12.)
		if n_elements(rotate) ne 0 then begin
			_x1 = cos((rotate mod 15.)*!dtor)*x1 - sin((rotate mod 15.)*!dtor)*y1
			_y1 = sin((rotate mod 15.)*!dtor)*x1 + cos((rotate mod 15.)*!dtor)*y1
			x1 = _x1
			y1 = _y1
		endif
		xyouts, x1, y1, textoidl(string(hemisphere*(90.-l), format='(I3)')+'\circ'), $
			/data, charsize=charsize, charthick=charthick, color=color, noclip=0, orient=180.-(latlabel*15.-(rotate mod 15.))
	endfor
endif

if ~keyword_set(no_label_lons) then begin
	; label some longitudes along the xaxis
	if abs(!y.crange[0]) ge abs(!y.crange[1]) then begin
		if ~keyword_set(yoff) then $
			yoff = -0.06*charsize*(!y.crange[1]-!y.crange[0])
		ypos = (!y.crange[0]+yoff)
		angs = 180. - (findgen(13)+6.)*15. + (rotate mod 15.)
	endif else begin
		if ~keyword_set(yoff) then $
			yoff = 0.01*(!y.crange[1]-!y.crange[0])
		ypos = (!y.crange[1]+yoff)
		angs = 180.- (((findgen(13)-6.)+24.) mod 24.)*15. + (rotate mod 15.)
	endelse
	xpos = (ypos-yoff)*tan(-angs*!dtor)
	inds = where(xpos ge !x.crange[0] and xpos le !x.crange[1], ci)
	for i=0, ci-1 do begin
		if rotate ne 0 then $
			label = rotate-angs[inds[i]] $
		else $
			label = angs[inds[i]]
		if label gt 180. then $
			label -= 360.
		if label lt -180. then $
			label += 360.
		if strcmp(coords, 'mlt', /fold) then $
			strlabel = strtrim(string( ((label+360.) mod 360.)/15., format='(I)') ,2) $
		else $
			strlabel = textoidl(strtrim(string(label,format='(I)'),2)+'\circ')
		xyouts, xpos[inds[i]], ypos, strlabel, $
				/data, charsize=charsize, charthick=charthick, color=color, noclip=1, align=.5
	endfor
endif

return

; label some longitudes along the yaxis
if abs(!x.crange[0]) le abs(!x.crange[1]) then begin
	xpos = (!x.crange[1]+0.01*(!x.crange[1]-!x.crange[0]))
	angs = 180. - (findgen(13))*15. + (rotate mod 15.)
	align = 0.
endif else begin
	xpos = (!x.crange[0]-0.01*(!x.crange[1]-!x.crange[0]))
	angs = 180. - (findgen(13)+12.)*15. + (rotate mod 15.)
	align = 1.
endelse
ypos = xpos/tan((180.-angs+(1.-align*2.))*!dtor)
inds = where(ypos ge !y.crange[0] and ypos le !y.crange[1], ci)
for i=0, ci-1 do begin
	if rotate ne 0 then $
		label = rotate-angs[inds[i]] $
	else $
		label = angs[inds[i]]
	if label gt 180. then $
		label -= 360.
	if label lt -180. then $
		label += 360.
	if strcmp(coords, 'mlt', /fold) then $
		strlabel = strtrim(string( ((label+360.) mod 360.)/15., format='(I)') ,2) $
	else $
		strlabel = textoidl(strtrim(string(label,format='(I)'),2)+'\circ')
	xyouts, xpos, ypos[inds[i]], strlabel, $
			/data, charsize=charsize, charthick=charthick, color=color, noclip=1, align=align
endfor

END
