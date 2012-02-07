;+
; NAME: 
; RAD_MAP_OVERLAY_CONTOURS
;
; PURPOSE: 
; This procedure overlays the potential contours.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_OVERLAY_CONTOURS
;
; KEYWORD PARAMETERS:
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; TIME: A 2-element vector giving the time range to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; INDEX: The index number of the map to plot. If not set, that map with the timestamp closest
; to the gien input date will be plotted.
;
; NORTH: Set this keyword to plot the convection pattern for the northern hemisphere.
;
; SOUTH: Set this keyword to plot the convection pattern for the southern hemisphere.
;
; HEMISPHERE; Set this to 1 for the northern and to -1 for the southern hemisphere.
;
; COORDS: Set this to a string containing the name of the coordinate system to plot the map in.
; Allowable systems are geographic ('geog'), magnetic ('magn') and magnetic local time ('mlt').
;
; THICK: Set this keyword to an integer indicating the thickness of the contours.
;
; NEG_LINESTYLE: Set this keyword to an integer indicating the linestyle used for the negative contours.
;
; POS_LINESTYLE: Set this keyword to an integer indicating the linestyle used for the positive contours.
;
; NEG_COLOR: Set this keyword to an integer index indicating the color used for the negative contours.
;
; POS_COLOR: Set this keyword to an integer index indicating the color used for the positive contours.
;
; C_CHARSIZE: Set this to a value for the character size of the contour annotations.
;
; C_CHARTHICK: Set this to a value for the character thickness of the contour annotations.
;
; SILENT: Set this kewyword to surpress warning messages.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding map data.
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
; Written by Lasse Clausen, Dec, 11 2009
;-
pro rad_map_overlay_contours, date=date, time=time, long=long, jul=jul, $
	north=north, south=south, hemisphere=hemisphere, $
	index=index, coords=coords, $
	thick=thick, neg_linestyle=neg_linestyle, pos_linestyle=pos_linestyle, $
	neg_color=neg_color, pos_color=pos_color, fill=fill, $
	c_charsize=c_charsize, c_charthick=c_charthick, $
	silent=silent, no_legend=no_legend

common rad_data_blk
common recent_panel

; set some default input
if ~keyword_set(thick) then $
	thick = !p.thick

if n_elements(neg_linestyle) eq 0 then $
	neg_linestyle = 0

if n_elements(pos_linestyle) eq 0 then $
	pos_linestyle = 5

IF KEYWORD_SET(lots) THEN BEGIN
  n_levels   = 20
  diffc =  3
ENDIF ELSE BEGIN
  n_levels   = 10
  diffc =  6
ENDELSE

; get color preferences
foreground  = get_foreground()
ncolors     = get_ncolors()
bottom      = get_bottom()

if n_elements(neg_color) eq 0 and n_elements(pos_color) eq 0 then begin
	ctname = get_colortable()
	rad_load_colortable, /bluewhitered
	ncol2 = ncolors/2
	neg_color = round((1.-findgen(n_levels)/(n_levels-1.))*ncol2) + bottom
	neg_color[0] -= 7
	pos_color = round(findgen(n_levels)/(n_levels-1.)*(ncol2-1)) + ncol2 + bottom + 1
	pos_color[0] += 7
	reset_colorbar = 1
endif else begin
	if n_elements(neg_color) eq 0 then $
		neg_color = 40
	if n_elements(pos_color) eq 0 then $
		pos_color = 253
endelse

if ~keyword_set(c_charsize) then $
	c_charsize = get_charsize(rxmaps, rymaps)

if ~keyword_set(c_charthick) then $
	c_charthick = !p.charthick

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'mlt') and ~strcmp(coords, 'magn') then begin
	prinfo, 'Coordinate system must be MLT or MAGN, setting to mlt'
	coords = 'mlt'
endif

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

if rad_map_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if n_elements(index) gt 0 then begin

	sfjul, date, time, (*rad_map_data[int_hemi]).mjuls[index], /jul_to_date
	parse_date, date, year, month, day
	sfjul, date, time, jul
	
endif else begin

	if ~keyword_set(date) then begin
		if ~keyword_set(silent) then $
			prinfo, 'No DATE given, trying for map date.'
		caldat, (*rad_map_data[int_hemi]).sjuls[0], month, day, year
		date = year*10000L + month*100L + day
	endif

	if n_elements(time) lt 1 then $
		time = 0000

	if n_elements(time) gt 1 then begin
		if ~keyword_set(silent) then $
			prinfo, 'TIME must be a scalar, selecting first element: '+string(time[0], format='(I4)')
		time = time[0]
	endif

	if ~keyword_set(jul) then $
		sfjul, date, time, jul, long=long
	caldat, jul, month, day, year

	; calculate index from date and time
	dd = min( abs( (*rad_map_data[int_hemi]).mjuls-jul ), index)

	; check if time ditance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

endelse

; calculate potential data for chosen index and hemisphere
; IN MAGNETIC COORDINATES!!!!!!!!
pot_data = rad_map_calc_potential(int_hemi, index)
nlons = n_elements(pot_data.zonarr)
nlats = n_elements(pot_data.zatarr)

; get longitude shift
lon_shft = (*rad_map_data[int_hemi]).lon_shft[index]

utsec = (jul - julday(1, 1, year, 0, 0))*86400.d
; calculate lon_shft, i.e. shift magnetic longitude into mlt coordinates
if coords eq 'mlt' then begin
	lon_shft += mlt(year, utsec, 0.)*15.
	lons = ((pot_data.zonarr[*] + lon_shft)/15.) mod 24.
endif else $
	lons = (pot_data.zonarr[*] + lon_shft)

;print, pot_data.zatarr
;print, lon_shft
;print, pot_data.zonarr[*]
;print, lons

; Convert to polar grid in correct coordinates
polarx=FLTARR(nlons,nlats)
polary=FLTARR(nlons,nlats)
FOR j=0, nlats-1 DO BEGIN
	FOR i=0, nlons-1 DO BEGIN
		tmp = calc_stereo_coords(pot_data.zatarr[j], lons[i], mlt=(coords eq 'mlt'))
		polarx[i,j] = tmp[0]
		polary[i,j] = tmp[1]
	ENDFOR
ENDFOR

; overlay contours
; in order to get the filling of the negative contours right, 
; we take minus the potential and use the same levels as
; for the positive contours, just in blue
if keyword_set(fill) then begin
	; negative
	contour, -pot_data.potarr, polarx, polary, $
		/overplot, xstyle=4, ystyle=4, noclip=0, $
		thick=thick, c_linestyle=neg_linestyle, c_color=neg_color, c_charsize=c_charsize, c_charthick=c_charthick, $
		levels=3+findgen(n_levels)*diffc, max_value=100, /follow, $
		path_xy=path_xy, path_info=path_info
	for i = 0, n_elements(path_info) - 1 do begin
		if path_info[i].high_low eq 0b then $
			continue
		s = [indgen(path_info[i].n), 0]
		; Plot the closed paths:
		polyfill, path_xy[*, path_info[i].offset + s], /norm, color=neg_color[path_info[i].level], noclip=0
	endfor
	; positive
	contour, pot_data.potarr, polarx, polary, $
		/overplot, xstyle=4, ystyle=4, noclip=0, $
		thick=thick, c_linestyle=pos_linestyle, c_color=pos_color, c_charsize=c_charsize, c_charthick=c_charthick, $
		levels=3+findgen(n_levels)*diffc, max_value=100, /follow, $
		path_xy=path_xy, path_info=path_info
	for i = 0, n_elements(path_info) - 1 do begin
		if path_info[i].high_low eq 0b then $
			continue
		s = [indgen(path_info[i].n), 0]
		; Plot the closed paths:
		polyfill, path_xy[*, path_info[i].offset + s], /norm, color=pos_color[path_info[i].level], noclip=0
	endfor
endif

; overlay contours
; negative
contour, pot_data.potarr, polarx, polary, $
	/overplot, xstyle=4, ystyle=4, $
	thick=thick, c_linestyle=neg_linestyle, color=neg_color[n_elements(neg_color)-1], c_charsize=c_charsize, c_charthick=c_charthick, $
	levels=-57+findgen(n_levels)*diffc, max_value=100, /follow, noclip=0;, /closed
; positive
contour,pot_data.potarr, polarx, polary, $
	/overplot, xstyle=4, ystyle=4, $
	thick=thick, c_linestyle=pos_linestyle, color=pos_color[n_elements(pos_color)-1], c_charsize=c_charsize, c_charthick=c_charthick, $
	levels=3+findgen(n_levels)*diffc, max_value=100, /follow, noclip=0;, /closed

; put in symbols at the maximum and minimum points
dims = size(pot_data.potarr, /dim)
pot_max = max(pot_data.potarr, maxind, min=pot_min, subscript_min=minind)
kref = maxind mod dims[0]
mref = fix(maxind/dims[0])
plots, polarx[kref,mref], polary[kref,mref], psym=1, symsize=0.75, thick=thick, $
	color=foreground, noclip=0

kref = minind mod dims[0]
mref = fix(minind/dims[0])
plots, polarx[kref,mref], polary[kref,mref], psym=7, symsize=0.75, thick=thick, $
	color=foreground, noclip=0

if ~keyword_set(no_legend) then begin
	info_str = 'FitOrder: '+string((*rad_map_data[int_hemi]).fit_order[index],format='(I1)') + $
		', '+(rad_map_info[int_hemi].mapex ? 'mapEX' : 'APLmap')+' format'
	xyouts, !x.crange[0]-.01*(!x.crange[1]-!x.crange[0]), !y.crange[0]+.01*(!y.crange[1]-!y.crange[0]), $
		info_str, orient=90, charsize=get_charsize(1,3)
endif

pot_str = textoidl('\Phi_{pc}')+'='+strtrim(string(fix((*rad_map_data[int_hemi]).pot_drop[index]/1000.)),2)+'kV'
xyouts, !x.crange[1]-.05*(!x.crange[1]-!x.crange[0]), !y.crange[1]-.1*(!y.crange[1]-!y.crange[0]), $
	pot_str, align=1, charsize=.75*get_charsize(rxmaps, rymaps)

if n_elements(reset_colorbar) ne 0 then $
	rad_load_colortable, ctname

end
