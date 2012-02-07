;+
; NAME: 
; RAD_MAP_PLOT_VECTOR_SCALE
;
; PURPOSE: 
; This procedure plots a small line next to a map panel
; indicating the scale of the vectors used on the map.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_PLOT_VECTOR_SCALE
;
; OPTIONAL INPUTS:
; Xmaps: The total number of columns of plots on the resulting page.
; Default is 1. This defines the position of the panel next to which the
; vector scale is placed.
;
; Ymaps: The total number of rows of plots on the resulting page.
; Default is 1. This defines the position of the panel next to which the
; vector scale is placed.
;
; Xmap: The current horizontal (column) index of this panel.
; Default is 0. This defines the position of the panel next to which the
; vector scale is placed.
;
; Ymap: The current vertical (row) index of this panel.
; Default is 0. This defines the position of the panel next to which the
; vector scale is placed.
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
; GAP: The gap between the main plot panel and the vector scale panel,
; in normalized coordinates.
;
; POSITION: Set this keyword to a 4-element vector of normalized coordinates 
; if you want to override the internal
; positioning calculations.
;
; PANEL_POSITION: Set this keyword to a 4-element vector of normalized coordinates of
; the panel next to which the vector scale panel will be placed.
;
; FACTOR: In order to match the scale of the vector scale with
; those on the plot, we need to know the FACTOR used in RAD_MAP/GRD_OVERLAY_VECTORS.
;
; THICK: The thickness of the vector scale.
;
; XRANGE: In order to match the scale of the vector scale with
; those on the plot, we need to know the XRANGE of the map
; used in RAD_MAP/GRD_PLOT_PANEL.
;
; CHARSIZE: The charsize of the annotations.
;
; COLOR: Set this keyword to the color index to use for the
; vector scale and the annotations.
;
; SCALE: In order to match the scale of the vector scale with
; those on the plot, we need to know the SCALE of the map
; used in RAD_MAP/GRD_OVERLAY_VECTORS.
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
PRO rad_map_plot_vector_scale, xmaps, ymaps, xmap, ymap, $
	gap=gap, position=position, panel_position=panel_position, $
	factor=factor, thick=thick, $
	xrange=xrange, charsize=charsize, $
	color=color, scale=scale

load_usersym, /circle

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif
if ~keyword_set(panel_position) then begin
	panel_position = define_panel(xmaps, ymaps, xmap, ymap, /square)
endif

; to have the length of the vector in the same 
; length as those on the map plot, we need to know
; the xrange of the map plot and the scale used in 
; that plot, as well as the factor
; the length of a velocity vector in degrees is
; factor*abs(vdata[2,i]/!re/1e3)
; hence if we divide that by the xrange
; we get the length of the vector in normal
; coordinates (i think)
if n_elements(xrange) ne 2 then begin
	prinfo, 'Need XRANGE.'
	return
endif
if n_elements(scale) ne 2 then begin
	prinfo, 'Need SCALE.'
	return
endif
range = scale[1]-scale[0]
if n_elements(factor) ne 1 then begin
	prinfo, 'Need FACTOR.'
	return
endif
size = (factor*abs(range/!re/1e3)*!radeg)/(xrange[1]-xrange[0])*(panel_position[2]-panel_position[0])

if ~keyword_set(position) then $
	position = define_imfpanel(panel_position, size=size, gap=gap, /low)

if ~keyword_set(color) then $
	color = 253

if ~keyword_set(thick) then $
	thick = 1

if ~keyword_set(charsize) then $
	charsize = 1

range = scale[1]-scale[0]

; plot coordinate system without axis
plot, [0,0], /nodata, position=position, xstyle=5, ystyle=5, $
	xrange=[0,1], yrange=[-1,1]

plots, 0, 0, psym=8, color=color, symsize=.6
oplot, [0,1], [0,0], color=color

xyouts, -0.1, .4, align=.0, $
	strtrim(range,2)+' ms!E-1!N',charsize=.6*get_charsize(xmaps,ymaps), color=color

END
