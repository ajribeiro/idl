;+
; NAME: 
; DMS_SSJ_TRACK_PLOT_PANEL
; 
; PURPOSE:
; This procedure plots the footprint
; for the currently loaded DMSP data on a panel
; created by MAP_PLOT_PANEL.
; 
; CATEGORY:
; DMSP
; 
; CALLING SEQUENCE: 
; DMS_SSJ_TRACK_PLOT_PANEL
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
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; TIME: A 2-element vector giving the time range to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; COORDS: The coodirnates of the map panel. Can be 'geog', 'magn' or 'mlt'.
;
; XRANGE: The xrange of the map panel.
;
; YRANGE: The yrange of the map panel.
;
; SILENT: Set this keyword to surpress messages.
;
; CHARTHICK: The thickness of the characters.
;
; CHARSIZE: The size of the characters.
;
; SYMSIZE: The size of the symbols used for marking the footprint.
;
; XTITLE: The title of the x axis, default is 'Time UT'.
;
; YTITLE: The title of the y axis, default is 'Energy [eV]'.
;
; XMINOR: The number of minor tickmarks on the x axis.
;
; YMINOR: The number of minor tickmarks on the y axis.
;
; XTICKS: The number of tickmarks on the x axis.
;
; YTICKS: The number of tickmarks on the y axis.
;
; POSITION: Set this keyword to a 4-element vector of normalized coordinates 
; if you want to override the internal
; positioning calculations.
;
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
;
; MARK_INTERVAL: The time step between time markers on the DMSP footprint, 
; in (decimal) hours. To set it to 2 minutes, set MARK_INTERVAL to 2./60.
;
; MARK_CHARSIZE: The charsize used for the footprint markers.
;
; MARK_CHARTHICK: The charthick used for the footprint markers.
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
;
; SOUTH: Set this keyword to plot a map of the southern hemisphere.
;
; NORTH: Set this keyword to plot a map of the northern hemisphere (default).
;
; ROTATE: Set this keyword to a number of degrees by which to rotate the map clockwise.
;
; NO_FILL: Set this keyword to surpress filling of land masses and lakes with colors.
;
; NO_AXIS: Set this keyword to surpress y and x axes.
;
; NO_COAST: Set this keyword to surpress overlaying coast lines.
;
; NO_MAP: Set this keyword and MAP_PLOT_PANEL will not be called. The
; data will just be overlayed on whatever plot was plotted last.
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
; Written by Lasse Clausen, Apr, 4 2010
;-
pro dms_track_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, $
	silent=silent, $
	charthick=charthick, charsize=charsize, symsize=symsize, $ 
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	position=position, bar=bar, mark_interval=mark_interval, $
	mark_charsize=mark_charsize, mark_charthick=mark_charthick, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	linecolor=linecolor, linethick=linethick, $
	hemisphere=hemisphere, north=north, south=south, rotate=rotate, $
	no_coast=no_coast, no_fill=no_fill, no_axis=no_axis, no_map=no_map, $
	isotropic=isotropic

common dms_data_blk

if ~keyword_set(linecolor) then $
	linecolor = 253

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
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
	position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, bar=bar, with_info=with_info)

if ~keyword_set(date) then begin
	caldat, dms_ssj_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return
endif

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if ~keyword_set(grid_linethick) then $
	grid_linethick = 1

if n_elements(grid_linestyle) eq 0 then $
	grid_linestyle = 0

if n_elements(grid_linecolor) eq 0 then $
	grid_linecolor = get_gray()

if ~keyword_set(fov_linethick) then $
	fov_linethick = 1

if n_elements(fov_linestyle) eq 0 then $
	fov_linestyle = 0

if n_elements(fov_linecolor) eq 0 then $
	fov_linecolor = get_gray()

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

if ~keyword_set(linethick) then $
	linethick = 3.

if ~keyword_set(symsize) then $
	symsize = .75

if ~keyword_set(mark_interval) then $
	mark_interval = -1

if ~keyword_set(mark_charsize) then $
	mark_charsize = get_charsize(xmaps, ymaps)

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

if ~keyword_set(no_map) then begin
	map_plot_panel, xmaps, ymaps, xmap, ymap, $
		date=date, time=time, long=long, $
		coords=coords, xrange=xrange, yrange=yrange, $
		silent=silent, $
		charthick=charthick, charsize=charsize, $ 
		xtitle=xtitle, ytitle=ytitle, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		position=position, $
		grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
		grid_linethick=grid_linethick, grid_charsize=charsize, $
		coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
		coast_linethick=coast_linethick, isotropic=isotropic, $
		land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
		hemisphere=hemisphere, rotate=rotate, no_fill=no_fill
endif

jinds = where(dms_ssj_data.juls ge sjul and dms_ssj_data.juls le fjul and dms_ssj_data.hemi eq hemisphere, cc)
if cc eq 0L then begin
	prinfo, 'No data loaded for interval or for hemisphere.'
	return
endif
juls = dms_ssj_data.juls[jinds]
dt = mean(deriv((juls-juls[0])*1440.d))

if coords eq 'geog' then $
	tmp = calc_stereo_coords(dms_ssj_data.glat[jinds], dms_ssj_data.glon[jinds]) $
else if coords eq 'magn' then $
	tmp = calc_stereo_coords(dms_ssj_data.mlat[jinds], dms_ssj_data.mlon[jinds]) $
else if coords eq 'mlt' then $
	tmp = calc_stereo_coords(dms_ssj_data.mlat[jinds], dms_ssj_data.mlt[jinds], /mlt) $
else begin
	prinfo, 'Coordinate system not supported: '+coords
	return
endelse
xpos = tmp[0,*]
ypos = tmp[1,*]
if n_elements(rotate) ne 0 then begin
	_x1 = cos(rotate*!dtor)*xpos - sin(rotate*!dtor)*ypos
	_y1 = sin(rotate*!dtor)*xpos + cos(rotate*!dtor)*ypos
	xpos = _x1
	ypos = _y1
endif
oplot, xpos, ypos, color=get_white(), thick=2.*linethick
oplot, xpos, ypos, color=linecolor, thick=linethick

if mark_interval ne -1 then begin
	dx = smooth(deriv(xpos), 11)
	dy = smooth(deriv(ypos), 11)
	load_usersym, /circle
	mark_every = round(mark_interval*60./dt)
	n_dots = n_elements(xpos)/mark_every+1L
	ind_dots = (lindgen(n_dots)*mark_every) < (cc-1L)
	mark_every = floor(230./n_dots)
;		col_dots = lindgen(n_dots)*mark_every+10L
	plots, xpos[ind_dots], ypos[ind_dots], $
		color=get_foreground(), $
		psym=8, noclip=0, symsize=symsize
;	plots, xpos[ind_dots], ypos[ind_dots], $
;		color=col_dots, $
;		psym=8, noclip=0, symsize=1.5*symsize
	angs = -atan(dx[ind_dots], dy[ind_dots])*!radeg
	for k=0, n_dots-1 do $
		xyouts, xpos[ind_dots[k]], ypos[ind_dots[k]], format_juldate(juls[ind_dots[k]], /short_time), /data, $
			orient=angs[k], charthick=mark_charthick, charsize=mark_charsize, color=linecolor, noclip=0
endif

end
