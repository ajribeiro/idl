;+
; NAME: 
; AMP_OVERLAY_CURRENT
;
; PURPOSE: 
; This procedure overlays the radial currents from an AMPERE file on a map.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; AMP_OVERLAY_CURRENT
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
; NORTH: Set this keyword to plot the magnetic perturbation vectors for the northern hemisphere.
;
; SOUTH: Set this keyword to plot the magnetic perturbation vectors for the southern hemisphere.
;
; HEMISPHERE: Set this to 1 for the northern and to -1 for the southern hemisphere.
;
; COORDS: Set this to a string containing the name of the coordinate system to plot the map in.
; Allowable systems are geographic ('geog'), magnetic ('magn') and magnetic local time ('mlt').
;
; SCALE: Set this keyword to a 2-element vector containing the minimum and maximum magnetic perturbation  
; used for coloring the vectors.
;
; SILENT: Set this kewyword to surpress warning messages.
;
; COMMON BLOCKS:
; AMP_DATA_BLK: The common block holding magnetic perturbation and current data.
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
; Written by Lasse Clausen, Jan, 5, 2011
;-
pro amp_overlay_current, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, scale=scale, min_value=min_value, $
	n_levels=n_levels, $
	thick=thick, neg_linestyle=neg_linestyle, pos_linestyle=pos_linestyle, $
	neg_color=neg_color, pos_color=pos_color, $
	c_charsize=c_charsize, c_charthick=c_charthick, $
	silent=silent, fill=fill

common amp_data_blk
common recent_panel

; get color preferences
foreground  = get_foreground()
ncolors     = get_ncolors()
bottom      = get_bottom()

; set some default input
if ~keyword_set(thick) then $
	thick = !p.thick

if n_elements(neg_linestyle) eq 0 then $
	neg_linestyle = 0

if n_elements(pos_linestyle) eq 0 then $
	pos_linestyle = 5

if ~keyword_set(scale) then begin
	scale = [-1.6,1.6]
endif

if ~keyword_set(min_value) then begin
	min_value = 0.2
endif

if ~keyword_set(n_levels) then begin
	n_levels = 7
endif

if n_elements(neg_color) eq 0 and n_elements(pos_color) eq 0 then begin
	ctname = get_colortable()
	rad_load_colortable, /bluewhitered
	ncol2 = ncolors/2
	neg_color = round((1.-findgen(n_levels+1)/(n_levels))*ncol2) + bottom
	neg_color[0] -= 7
	pos_color = round(findgen(n_levels+1)/(n_levels)*(ncol2-1)) + ncol2 + bottom + 1
	pos_color[0] += 7
	reset_colorbar = 1
endif else begin
	if n_elements(neg_color) eq 0 then $
		neg_color = get_blue()
	if n_elements(pos_color) eq 0 then $
		pos_color = get_red()
endelse

npos_color = n_elements(pos_color)
if npos_color ne n_levels+1 then begin
	if npos_color gt 1 then $
		prinfo, 'Number of positive colors not equal to N_LEVELS+1 or 1, choosing first.'
	pos_color = replicate(pos_color[0], n_levels+1)
endif

nneg_color = n_elements(neg_color)
if nneg_color ne n_levels+1 then begin
	if nneg_color gt 1 then $
		prinfo, 'Number of negative colors not equal to N_LEVELS+1 or 1, choosing first.'
	neg_color = replicate(neg_color[0], n_levels+1)
endif

if ~keyword_set(c_charsize) then $
	c_charsize = get_charsize(rxmaps, rymaps)

if ~keyword_set(c_charthick) then $
	c_charthick = !p.charthick

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'mlt',/fold) and ~strcmp(coords, 'magn',/fold) then begin
	prinfo, 'Coordinate system must be MLT or MAGN. Setting to MLT'
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

if amp_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if n_elements(index) gt 0 then begin

	sfjul, date, time, (*amp_data[int_hemi]).mjuls[index], /jul_to_date
	parse_date, date, year, month, day
	sfjul, date, time, jul

endif else begin

	if ~keyword_set(date) then begin
		if ~keyword_set(silent) then $
			prinfo, 'No DATE given, trying for map date.'
		caldat, (*amp_data[int_hemi]).sjuls[0], month, day, year
		date = year*10000L + month*100L + day
	endif
	parse_date, date, year, month, day

	if n_elements(time) lt 1 then $
		time = 0000

	if n_elements(time) gt 1 then begin
		if ~keyword_set(silent) then $
			prinfo, 'TIME must be a scalar, selecting first element: '+string(time[0], format='(I4)')
		time = time[0]
	endif
	sfjul, date, time, jul, long=long

	; calculate index from date and time
	dd = min( abs( (*amp_data[int_hemi]).mjuls-jul ), index)

	; check if time distance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

endelse

if strcmp(coords,'mlt',/fold) then $
	mlt0inmlonh = 0. $
else $
	mlt0inmlonh = -mlt(year,(jul-julday(1,1,year,0))*86400.d,0.)

nlats = (*amp_data[int_hemi]).nlat[index]
nlons = (*amp_data[int_hemi]).nlon[index]
plats = 90.-reform((*amp_data[int_hemi]).colat[index, *])
plons = ( reform((*amp_data[int_hemi]).mlt[index, *]) + mlt0inmlonh )*(strcmp(coords,'mlt',/fold) ? 1. : 15.)
tmp = calc_stereo_coords(plats, plons, mlt=strcmp(coords,'mlt',/fold))
xxs = fltarr(nlats, nlons+1)
yys = fltarr(nlats, nlons+1)
jrs = fltarr(nlats, nlons+1)
for a=0, nlats-1 do begin
	for b=0, nlons do begin
		xxs[a,b] = tmp[0,(b mod nlons)*nlats+a]
		yys[a,b] = tmp[1,(b mod nlons)*nlats+a]
		jrs[a,b] = abs((*amp_data[int_hemi]).jr[index,(b mod nlons)*nlats+a]) lt min_value ? 0. : (*amp_data[int_hemi]).jr[index,(b mod nlons)*nlats+a]
	endfor
endfor

; overlay contours
; in order to get the filling of the negative contours right, 
; we take minus the current and use the same levels as
; for the positive contours, just in blue
if keyword_set(fill) then begin
	; negative
	contour, -jrs, xxs, yys, $
		/overplot, xstyle=4, ystyle=4, noclip=0, $
		thick=thick, c_linestyle=neg_linestyle, c_color=neg_color, c_charsize=c_charsize, c_charthick=c_charthick, $
		levels=min_value+(-scale[0]-min_value)*findgen(n_levels+1.)/float(n_levels), /follow, $
		path_xy=path_xy, path_info=path_info
	for i = 0, n_elements(path_info) - 1 do begin
		;print, 'neg: ', path_info[i].high_low
		if path_info[i].high_low eq (keyword_set(south)) then $
			continue
		s = [indgen(path_info[i].n), 0]
		; Plot the closed paths:
		polyfill, path_xy[*, path_info[i].offset + s], /norm, color=neg_color[path_info[i].level], noclip=0
	endfor
	; positive
	contour, jrs, xxs, yys, $
		/overplot, xstyle=4, ystyle=4, noclip=0, $
		thick=thick, c_linestyle=pos_linestyle, c_color=pos_color, c_charsize=c_charsize, c_charthick=c_charthick, $
		levels=min_value+(scale[1]-min_value)*findgen(n_levels+1.)/float(n_levels), /follow, $
		path_xy=path_xy, path_info=path_info
	for i = 0, n_elements(path_info) - 1 do begin
		;print, 'pos: ', path_info[i].high_low
		if path_info[i].high_low eq (keyword_set(south)) then $
			continue
		s = [indgen(path_info[i].n), 0]
		; Plot the closed paths:
		polyfill, path_xy[*, path_info[i].offset + s], /norm, color=pos_color[path_info[i].level], noclip=0
	endfor
	neg_levcols = neg_color[n_levels-1]
	pos_levcols = pos_color[n_levels-1]
endif else begin
	neg_levcols = reverse(neg_color)
	pos_levcols = pos_color
	neg_levcols = neg_color[n_levels-1]
	pos_levcols = pos_color[n_levels-1]
endelse

; negative
contour, jrs, xxs, yys, $
	/overplot, xstyle=4, ystyle=4, noclip=0, $
	thick=thick, c_linestyle=neg_linestyle, c_color=neg_levcols, c_charsize=c_charsize, c_charthick=c_charthick, $
	levels=scale[0]+(-scale[0]-min_value)*findgen(n_levels+1.)/float(n_levels), /follow
; positive
contour, jrs, xxs, yys, $
	/overplot, xstyle=4, ystyle=4, noclip=0, $
	thick=thick, c_linestyle=pos_linestyle, c_color=pos_levcols, c_charsize=c_charsize, c_charthick=c_charthick, $
	levels=min_value+(scale[1]-min_value)*findgen(n_levels+1.)/float(n_levels), /follow

if n_elements(reset_colorbar) ne 0 then $
	rad_load_colortable, ctname

end
