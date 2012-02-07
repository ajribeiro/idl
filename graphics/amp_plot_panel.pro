;+
; NAME: 
; AMP_PLOT_PANEL
;
; PURPOSE: 
; This procedure plots a panel containing a map and 
; overlays the AMPERE magnetic perturbation vectors.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; AMP_PLOT_PANEL
;
; OPTIONAL INPUTS
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
; YRANGE: The y range of the map plot, default is [-31,31].
;
; XRANGE: The x range of the map plot, default is [-31,31].
;
; SCALE: Set this keyword to a 2-element vector containing the minimum and maximum velocity 
; used for coloring the vectors.
;
; COAST: Set this keyword to plot coast lines.
;
; NO_FILL: Set this keyword to surpress filling of the coastal lines.
;
; CROSS: Set this keyword to plot a coordinate cross rather than a box.
;
; FACTOR: Set this keyword to alter the length of vectors.
;
; SIZE: Set this keyword to adjust thickness of vector and size of dot.
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
; Written by Lasse Clausen, Jan, 5, 2011
;-
pro amp_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	position=position, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, xrange=xrange, yrange=yrange, scale=scale, $
	coast=coast, no_fill=no_fill, cross=cross, $
	factor=factor, symsize=symsize, $
	raw=raw, fit=fit, dbeast=dbeast, dbnorth=dbnorth, current=current, poynting=poynting, p1=p1, p2=p2, $
	min_value=min_value, fill=fill, $
	silent=silent

common amp_data_blk

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

if ~keyword_set(fit) and ~keyword_set(raw) and ~keyword_set(dbeast) and ~keyword_set(dbnorth) and ~keyword_set(current) and ~keyword_set(poynting) then begin
	prinfo, 'Must choose whether to plot raw or fitted data, current or poynting. Choosing fit.'
	fit = 1
	raw = 0
	dbeast = 0
	dbnorth = 0
	current = 0
	poynting = 0
endif

if n_elements(yrange) ne 2 then $
	yrange = [-46,46]

if n_elements(xrange) ne 2 then $
	xrange = [-46,46]

if n_elements(index) gt 0 then begin

	sfjul, date, time, (*amp_data[int_hemi]).mjuls[index], /jul_to_date
	parse_date, date, year, month, day
	sfjul, date, time, jul

endif else begin

	if ~keyword_set(date) then begin
		if ~keyword_set(silent) then $
			prinfo, 'No DATE given, trying for scan date.'
		caldat, (*amp_data[int_hemi]).sjuls[0], month, day, year
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
	dd = min( abs( (*amp_data[int_hemi]).mjuls-jul ), index)

	; check if time distance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Grid found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

endelse

if n_params() lt 4 then begin
	if ~keyword_set(silent) and ~keyword_set(position) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'mlt',/fold) and ~strcmp(coords, 'magn',/fold) then begin
	prinfo, 'Coordinate system must be MLT or MAGN. Setting to MLT'
	coords = 'mlt'
endif

;help, north, south, hemisphere

; plot map panel with coast
map_plot_panel, xmaps, ymaps, xmap, ymap, position=position, $
	date=date, time=time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, $
	no_coast=~keyword_set(coast), no_fill=no_fill, $
	no_axis=keyword_set(cross), coast_linecolor=get_gray(), $
  hemisphere=hemisphere, south=south, north=north

if keyword_set(fit) or keyword_set(raw) then begin
	; overlay magnetic perturbation vectors
	amp_overlay_vectors, date=date, time=time, long=long, $
		index=index, north=north, south=south, hemisphere=hemisphere, $
		coords=coords, scale=scale, $
		factor=factor, symsize=symsize, raw=raw, fit=fit
endif

if keyword_set(dbeast) or keyword_set(dbnorth) then begin
	; overlay magnetic perturbation as contours
	amp_overlay_magnetic_pert, date=date, time=time, long=long, $
		index=index, north=north, south=south, hemisphere=hemisphere, $
		coords=coords, scale=scale, dbeast=dbeast, dbnorth=dbnorth, $
		fill=fill
endif

if keyword_set(current) then begin
	; overlay radial current
	amp_overlay_current, date=date, time=time, long=long, $
		index=index, north=north, south=south, hemisphere=hemisphere, $
		coords=coords, scale=scale, min_value=min_value, fill=fill
endif

if keyword_set(poynting) then begin
	; overlay radial poynting flux
	amp_overlay_poynting, date=date, time=time, long=long, $
		index=index, north=north, south=south, hemisphere=hemisphere, $
		coords=coords, scale=scale, min_value=min_value, fill=fill, p1=p1, p2=p2
endif

end
