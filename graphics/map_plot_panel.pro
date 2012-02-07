;+ 
; NAME: 
; MAP_PLOT_PANEL
; 
; PURPOSE: 
; This procedure plots a stereographic map grid and overlays coast
; lines.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; MAP_PLOT_PANEL
;
; OPTIONAL INPUTS:
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
; DATE: A scalar giving the date to plot, in YYYYMMDD format.
;
; TIME: A scalar giving the time to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; COORDS: Set this keyword to a string naming the coordinate system.
; Allowable inputs are 'mlt', 'magn' and 'geog'.
; Default is 'magn'.
;
; XRANGE: Set this keyword to change the range of the x axis.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; XTITLE: Set this keyword to change the title of the x axis.
;
; YTITLE: Set this keyword to change the title of the y axis.
;
; XTICKS: Set this keyword to change the number of major x tick marks.
;
; XMINOR: Set this keyword to change the number of minor x tick marks.
;
; YTICKS: Set this keyword to change the number of major y tick marks.
;
; YMINOR: Set this keyword to change the number of minor y tick marks.
;
; POSITION: Set this keyword to a 4-element vector holding the normalized
; coordinates of the ouput panel. Use this to override internal positioning.
;
; GRID_LINESTYLE: Set this keyword to change the style of the grid lines.
; Default is 0 (solid).
;
; GRID_LINECOLOR: Set this keyword to a color index to change the color of the grid lines.
; Default is black.
;
; GRID_LINETHICK: Set this keyword to change the thickness of the grid lines.
; Default is 1.
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
; SOUTH: Set this keyword to plot a map of the southern hemisphere.
;
; NORTH: Set this keyword to plot a map of the norther hemisphere (default).
;
; ROTATE: Set this keyword to a number of degrees by which to rotate the map clockwise.
;
; NO_FILL: Set this keyword to surpress filling of land masses and lakes with colors.
;
; NO_AXIS: Set this keyword to surpress y and x axes.
;
; NO_COAST: Set this keyword to surpress overlaying coast lines.
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
; Based on Steve Milan's PLOT_POLAR.
; Written by Lasse Clausen, Dec, 1 2009
;-
pro map_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, jul=jul, $
	coords=coords, xrange=xrange, yrange=yrange, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $ 
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	position=position, bar=bar, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, $
	grid_charcolor=grid_charcolor, grid_charthick=grid_charthick, $
	grid_charsize=grid_charsize, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	hemisphere=hemisphere, north=north, south=south, rotate=rotate, $
	no_coast=no_coast, no_fill=no_fill, no_axis=no_axis, no_grid=no_grid, no_label=no_label, $
	title=title, no_legend=no_legend, isotropic=isotropic

if n_params() lt 4 then begin
	if ~keyword_set(silent) and ~keyword_set(position) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(yrange) then $
	yrange = [-31,31]

if ~keyword_set(xrange) then $
	xrange = [-31,31]

aspect = float(xrange[1]-xrange[0])/float(yrange[1]-yrange[0])
if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, bar=bar)

if ~keyword_set(coords) then $
	coords = get_coordinates()

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if strcmp(strlowcase(coords), 'mlt') then begin
	if ~keyword_set(jul) then begin
		if ~keyword_set(date) then begin
			prinfo, 'You must provide a date/time for MLT plotting.'
			return
		endif
		if n_elements(time) lt 1 then $
			time = 1200
		sfjul, date, time, jul, long=long
	endif
endif

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(grid_linethick) then $
	grid_linethick = 1

if n_elements(grid_linestyle) eq 0 then $
	grid_linestyle = 0

if n_elements(grid_linecolor) eq 0 then $
	grid_linecolor = get_gray()

if ~keyword_set(grid_charsize) then $
	grid_charsize = get_charsize(xmaps, ymaps)

if n_elements(grid_charthick) eq 0 then $
	grid_charthick = !p.charthick

if n_elements(grid_charcolor) eq 0 then $
	grid_charcolor = get_black()

if ~keyword_set(coast_linethick) then $
	coast_linethick = 3

if n_elements(coast_linestyle) eq 0 then $
	coast_linestyle = 0

if n_elements(coast_linecolor) eq 0 then $
	coast_linecolor = get_gray()

if n_elements(land_fillcolor) eq 0 then $
	land_fillcolor = 123

if n_elements(lake_fillcolor) eq 0 then $
	lake_fillcolor = 20

if ~keyword_set(hemisphere) then begin
  if keyword_set(north) then $
    hemisphere = 1. $
  else if keyword_set(south) then $
    hemisphere = -1. $
  else $
    hemisphere = 1.
endif

; Plot axis
plot, [0,0], /nodata, xstyle=5, ystyle=5, isotropic=isotropic, $
	yrange=yrange, xrange=xrange, position=position

if ~keyword_set(no_coast) then begin
	overlay_coast, coords=coords, jul=jul, no_fill=no_fill, $
		coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
		coast_linethick=coast_linethick, $
		land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
		hemisphere=hemisphere, rotate=rotate
endif

if ~keyword_set(no_grid) then begin
	map_overlay_grid, $
		grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
		grid_linethick=grid_linethick, rotate=rotate
endif

IF N_ELEMENTS(xticks) EQ 0 THEN xticks = 1
IF N_ELEMENTS(yticks) EQ 0 THEN yticks = 1
IF N_ELEMENTS(xminor) EQ 0 THEN xminor = 1
IF N_ELEMENTS(yminor) EQ 0 THEN yminor = 1

if ~keyword_set(no_axis) then begin
	; Plot axis
	plot, [0,0], /nodata, xstyle=1, ystyle=1, isotropic=isotropic, $
		yrange=yrange, xrange=xrange, position=position, $
		xtitle=xtitle, ytitle=ytitle, color=get_foreground(), $
		xtickname=replicate(' ', 50), ytickname=replicate(' ', 50), $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		title=title
	if ~keyword_set(no_legend) then begin
		; put a little legend on the plot to indicate input parameters
		xpos = !x.crange[0] - .01*(!x.crange[1]-!x.crange[0])
		ypos = !y.crange[1]
		str = (coords eq 'geog' ? 'Geographic' : (coords eq 'magn' ? 'Magnetic' : 'MLT') ) + ' coordinates'
		xyouts, xpos, ypos, orientation=90., $
			str, align=1., $
			/data, charsize=get_charsize(1,3)
	endif
endif

if ~keyword_set(no_label) then begin
	map_label_grid, hemisphere=hemisphere, coords=coords, $
		color=grid_charcolor, charthick=grid_charthick, $
		charsize=grid_charsize, rotate=rotate
endif

end
