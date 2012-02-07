;+
; NAME: 
; RAD_MAP_PLOT_IMF
;
; PURPOSE: 
; This procedure plots a panel showing the IMF By-Bz components.
; This is meant to be used when plotting map files.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_PLOT_IMF
;
; OPTIONAL INPUTS:
; Xmaps: The total number of columns of plots on the resulting page.
; Default is 1. This defines the position of the panel next to which the
; IMF panel is placed.
;
; Ymaps: The total number of rows of plots on the resulting page.
; Default is 1. This defines the position of the panel next to which the
; IMF panel is placed.
;
; Xmap: The current horizontal (column) index of this panel.
; Default is 0. This defines the position of the panel next to which the
; IMF panel is placed.
;
; Ymap: The current vertical (row) index of this panel.
; Default is 0. This defines the position of the panel next to which the
; IMF panel is placed.
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
; GAP: The gap between the main plot panel and the IMF clock panel,
; in normalized coordinates.
;
; POSITION: Set this keyword to a 4-element vector of normalized coordinates 
; if you want to override the internal
; positioning calculations.
;
; PANEL_POSITION: Set this keyword to a 4-element vector of normalized coordinates of
; the panel next to which the IMF panel will be placed.
;
; IMF: Set this keyword to a 2-element vector giving the By and Bz component
; to plot. If not set, RAD_MAP_PLOT_IMF will attempt to read the IMF conditions
; from the structure RAD_MAP_DATA in RAD_DATA_BLK.
;
; SIZE: The size of the panel, in normalized coordinates,
; default is .15*(panel_position[2]-panel_position[0])
;
; THICK: The thickness of the IMF arrow.
;
; LAG_TIME: Set this keyword to a scalar giving IMF timelag
; to plot. If not set, RAD_MAP_PLOT_IMF will attempt to read the IMF lag
; from the structure RAD_MAP_DATA in RAD_DATA_BLK.
;
; CHARSIZE: The charsize of the annotations.
;
; COLOR: Set this keyword to the color index to use for the
; IMF arrow and the annotations.
;
; SCALE: The scale of the IMF clock, default is [-5,5] nT.
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
; Based on code by Adrian Grocott.
;-
PRO rad_map_plot_imf, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	gap=gap, position=position, panel_position=panel_position, $
	hemisphere=hemisphere, north=north, south=south, $
	int_hemisphere=int_hemisphere, index=index, $
	imf=imf, size=size, thick=thick, $
	lag_time=lag_time, charsize=charsize, $
	color=color, scale=scale

common rad_data_blk

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
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
if ~keyword_set(int_hemisphere) then $
	int_hemisphere = (hemisphere lt 0)

if n_elements(index) gt 0 then begin

	sfjul, date, time, (*rad_map_data[int_hemisphere]).mjuls[index], /jul_to_date
	parse_date, date, year, month, day
	sfjul, date, time, jul
	
endif else begin

	if ~keyword_set(date) then begin
		if ~keyword_set(silent) then $
			prinfo, 'No DATE given, trying for scan date.'
		caldat, (*rad_map_data[int_hemisphere]).sjuls[0], month, day, year
		date = year*10000L + month*100L + day
	endif
	parse_date, date, year, month, day

	if ~keyword_set(time) then $
		time = 0000

	if n_elements(time) gt 1 then begin
		if ~keyword_set(silent) then $
			prinfo, 'TIME must be a scalar, selecting first element: '+string(time[0], format='(I4)')
		time = time[0]
	endif
	sfjul, date, time, jul, long=long

	; calculate index from date and time
	if n_elements(index) eq 0 then $
		dd = min( abs( (*rad_map_data[int_hemisphere]).mjuls-jul ), index) $
	else $
		dd = 0.

endelse

if ~keyword_set(panel_position) then $
	panel_position = define_panel(xmaps, ymaps, xmap, ymap, /square)

if ~keyword_set(size) then $
	size = .15*(panel_position[2]-panel_position[0])

if ~keyword_set(position) then $
	position = define_imfpanel(panel_position, gap=gap, size=size)

if ~keyword_set(scale) then $
	scale = [-5,5]
range = scale[1]-scale[0]

if ~keyword_set(imf) then begin
	if n_elements(index) lt 1 then begin
		prinfo, 'I have no idea from what time to take the IMF. I am guessing the first.'
		index = 0
	endif
	if n_elements(int_hemisphere) lt 1 then $
		int_hemisphere = 0
	imf = reform((*rad_map_data[int_hemisphere]).b_imf[index,1:2])
endif

if ~keyword_set(lag_time) then begin
	if n_elements(index) lt 1 then begin
		prinfo, 'I have no idea from what time to take the IMF. I am guessing the first.'
		index = 0
	endif
	if n_elements(int_hemisphere) lt 1 then $
		int_hemisphere = 0
	lag_time = (*rad_map_data[int_hemisphere]).imf_delay[index]
endif

if ~keyword_set(color) then $
	color = 253

if ~keyword_set(thick) then $
	thick = 1

if ~keyword_set(charsize) then $
	charsize = get_charsize(1,3)

gray = get_gray()

; plot coordinate system without axis
plot, [0,0], /nodata, position=position, xstyle=5, ystyle=5, $
	xrange=scale, yrange=scale
; plot cross
oplot, [0,0], !y.crange, color=gray
oplot, !x.crange, [0,0], color=gray
; make some tickmarks
for i=scale[0], scale[1] do begin
	oplot, [i,i], [0, -.02*range], color=gray
	oplot, [0,.02*range], [i,i], color=gray
endfor

; draw IMF vector
arrow, 0, 0, imf[0], imf[1], /data, color=color, $
	hthick=thick, thick=thick, hsize=300./(1.+(!d.name eq 'X')*64.)*charsize

; label axes
xyouts, .1*range, scale[1], '+Z', $
	charsize=charsize, alignment=0.0, color=color
xyouts, scale[1], -.1*range, '+Y', $
	charsize=charsize, alignment=0.0, color=color

; tell about delay
xyouts, (position[2]+position[0])/2., position[1]-.3*charsize*(position[3]-position[1])-.01*get_charsize(xmaps,ymaps), $
;xyouts, 0., scale[0]-charsize, $
	'(-'+strtrim(lag_time,2)+' min)!C('+(*rad_map_data[int_hemisphere]).imf_model[index]+')', /norm, $
  charsize=charsize, alignment=0.5, color=color

; tell about delay
;xyouts, (position[2]+position[0])/2., position[1]-.3*charsize*(position[3]-position[1])-3.*.01*get_charsize(xmaps,ymaps), $
;xyouts, 0., scale[0]-charsize, $
;	'('+(*rad_map_data[int_hemisphere]).imf_model[index]+')', /norm, $
;  charsize=charsize, alignment=0.5, color=color

END
