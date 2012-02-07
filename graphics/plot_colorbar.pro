;+ 
; NAME: 
; PLOT_COLORBAR 
; 
; PURPOSE: 
; This procedure plots a colorbar next to a plot panel. If no position
; is given, the DEFINE_CB_POSITION function is used.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; PLOT_COLORBAR
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
; POSITION: Set this to a 4-elements array specifying the colorbar's position
; if you don't want this routine to calculate where to put it.
;
; LEGEND: Set this to a string to overwrite the default of the colorbar's title
; depending on the loaded parameter.
;
; LEVEL_FORMAT: Set this to a format code to use for the labels.
;
; NO_GND: Set this keyword to surpress the plotting of a ground scatter box.
;
; CHARSIZE: Set this to a number to override the default charsize.
;
; SCALE: Set this to a 2-element vector indicating the scale of the colorbar.
; If omitted, the scale from the common block USER_PREFS is used. 
;
; PARAMETER: Set this to a string to indicate the parameter for which this colorbar
; is valid. If omitted, the parameter from the common block USER_PREFS is used.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; VERTICAL: Set this keyword to plot a vertical colorbar right of the panel. This is the default.
;
; HORIZONTAL: Set this keyword to plot a horizontal colorbar above the panel.
;
; SQUARE: Set this keyword to indicate that the panel is a square.
;
; LEFT: Set this keyword to put labels on the left of a vertical colorbar, rather than on the right.
;
; UNDER: Set this keyword to put labels under a horizontal colorbar, rather than on top.
;
; CHARTHICK: Set this to a number to override the default character thickness.
;
; GROUND: Set this to a velocity value. In the colorbar all velocities within [-GROUND, GROUND] 
; will then be colored gray. Use this keyword in conjunction with the GROUND keyword
; in RAD_FIT_PLOT_RTI.
;
; BAR: Set this keyword to indicate that the panel position next to which you 
; wish to place the colorbar was calculated using the BAR keyword.
;
; GAP: Set this keyword to the size of the gap between the panel and the
; colorbar in normal coordinates (default is 5% of the panel width).
;
; WIDTH: Set this keyword to the width of the colorbar in normalized coordinates.
; Default is 0.015.
;
; NO_LABELS:
;
; NO_ROTATE: This routine plots the colorbar for the parameter given in the
; PARAM keyword. If that keyword is not provided, the parameter is determined
; using GET_PARAMETER(). If the parameter is 'velocity', the default colortable
; is rotated, such that negative values (i.e. motion away from the radar) is 
; colored in reds, whereas motion towards (positive velocity values) is colored
; in blues. Set this keyword to prevent PLOT_COLORBAR from rotating the colorbar.
;
; STEPS: Set this keyword to give the number of steps in the colorbar. If not
; provided, the output from GET_COLORSTEPS() is used.
;
; NO_TITLE: Set this keyword to use the NO_TITLE keyword when calculating the
; position of the panel besides which the colorbar is placed.
;
; PANEL_POSITION: Set this keyword to a 4-element vector containing the normalized
; coordinates of the panel besides which you whcih to place the colorbar.
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
; Based on Steve Milan's PLOT_COLOURBAR.
; Written by Lasse Clausen, Nov, 24 2009
; Completly rewritten by Lasse Clausen, Jan, 18 2011
;-
pro plot_colorbar, xmaps, ymaps, xmap, ymap, $
	position=position, panel_position=panel_position, aspect=aspect, bar=bar, square=square, $
	with_info=with_info, no_title=no_title, $
	gap=gap, width=width, horizontal=horizontal, vertical=vertical, $
	left=left, under=under, $
	charsize=charsize, charthick=charthick, $
	scale=scale, parameter=parameter, ground=ground, sc_values=sc_values, whiteout=whiteout, $
	legend=legend, $
	nlevels=nlevels, level_format=level_format, level_values=level_values, $
	colorsteps=colorsteps, continuous=continuous, $
	no_labels=no_labels, no_rotate=no_rotate, no_shift=no_shift, rotate=rotate, shift=shift, $
	xthick=xthick, ythick=ythick, keep_first_last_label=keep_first_last_label, drop_first_last_label=drop_first_last_label, $
	logarithmic=logarithmic

; Allow several color bars to be stacked
IF N_PARAMS() NE 4 THEN BEGIN
	xmaps = 1
	xmap  = 0
	ymaps = 1
	ymap  = 0
ENDIF

if ~keyword_set(vertical) and ~keyword_set(horizontal) then $
	vertical = 1

if keyword_set(ground) then begin
	if ground lt 0 then $
		_ground = 0 $
	else $
		_ground = ground
endif else $
	_ground = 0

; and some user preferences
scatterflag = rad_get_scatterflag()

; get default from USER_PREFS
if ~keyword_set(parameter) then $
	parameter = get_parameter()

if ~strcmp(parameter, 'velocity', /fold_case) and _ground ne 0 then begin
	prinfo, 'Cannot use GROUND keyword with parameter: '+parameter+'.'
	_ground = 0
endif

; and some user preferences
scatterflag = rad_get_scatterflag()
if strcmp(parameter, 'velocity', /fold_case) and scatterflag eq 3 then $
	_ground = 25

; whiteout overwrites everything
if keyword_set(whiteout) ne 0 then $
	_ground = whiteout

if ~keyword_set(scale) then $
	_scale = get_default_range(parameter) $
else $
	_scale = scale

if n_elements(_scale) ne 2 then begin
	prinfo, 'SCALE must be 2-element vector.'
	return
endif

if n_elements(legend) eq 0 then $
	legend = get_default_title(parameter)

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(charthick) then $
	charthick = !p.charthick

if keyword_set(vertical) then $
	bar = 1

IF KEYWORD_SET(position) THEN $
	bpos = position $
else begin
	if ~keyword_set(panel_position) then $
		panel_position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, bar=bar, square=square, with_info=with_info, no_title=no_title)
	bpos = define_cb_position(panel_position, vertical=vertical, horizontal=horizontal, gap=gap, width=width)
endelse

; get color preferences
foreground  = get_foreground()
ncolors     = get_ncolors()
bottom      = get_bottom()

if ~keyword_set(colorsteps) then $
	_colorsteps = get_colorsteps() $
else $
	_colorsteps = colorsteps

if keyword_set(continuous) then begin
	_colorsteps = ncolors
	if _ground ne 0 then begin
		prinfo, 'You cannot set CONTINUOUS and GROUND at the same time. Unsetting GROUND.'
		_ground = 0
	endif
endif

if ~keyword_set(sc_values) then $
	_sc_values = _scale[0] + FINDGEN(_colorsteps+1)*(_scale[1] - _scale[0])/float(_colorsteps) $
else begin
	_sc_values = sc_values
	if keyword_set(colorsteps) then begin
		if colorsteps ne n_elements(_sc_values)-1 then $
			prinfo, 'Number of values in SC_VALUES is not equal to COLOSTEPS, adjusting.'
	endif
	_colorsteps = n_elements(_sc_values)-1
	_scale = [min(sc_values), max(sc_values)]
endelse

if ~keyword_set(level_format) then $
	level_format = '(I)'

if n_elements(nlevels) eq 0 then $
	_nlevels = ( _colorsteps gt 60 ? 8 : _colorsteps ) $
else $
	_nlevels = nlevels

if n_elements(level_values) eq 0 then begin
	if keyword_set(sc_values) then $
		_level_values = _sc_values $
	else $
		_level_values = _scale[0] + FINDGEN(_nlevels+1)*(_scale[1] - _scale[0])/float(_nlevels)
endif else begin
	_level_values = level_values
	if keyword_set(nlevels) then begin
		if nlevels+1 ne n_elements(_level_values) then begin
			prinfo, 'NLEVELS must be N_ELEMENTS(LEVEL_VALUES)-1. Adjusting.'
			_nlevels = n_elements(_level_values) - 1
		endif
	endif else $
		_nlevels = n_elements(_level_values) - 1
endelse

; these are the indeces in the color table that are
; available for plotting
cin = FIX( FINDGEN(_colorsteps)/(_colorsteps-1.)*(ncolors-1) )+bottom

; we need to see what color table is loaded
ct = get_colortable()
rot = 0
shi = 0
if strcmp(ct, 'bluewhitered', /fold) or strcmp(ct, 'leicester', /fold) or strcmp(ct, 'default', /fold) then $
	rot = 1
if strcmp(ct, 'aj', /fold) or strcmp(ct, 'bw', /fold) or strcmp(ct, 'whitered', /fold) then $
	shi = 1

if n_elements(no_rotate) ne 0 or n_elements(no_shift) ne 0 then begin
	_rotate = 0
	_shift = 0
endif else begin
	if strcmp(parameter, 'velocity', /fold_case) then begin
		_rotate = rot
		_shift = shi
	endif
	if keyword_set(shift) then $
		_shift = 1
	if keyword_set(rotate) then $
		_rotate = 1
endelse

; shift or rotate the color indeces
if keyword_set(_rotate) then $
	cin = rotate(cin, 2)
if keyword_set(_shift) then $
	cin = shift(cin, _colorsteps/2)

if _ground ne 0 then begin
	; if we add a gray box for ground scatter, we need to think about
	; how big this box needs to be in terms of levels
	; here "level" means the value interval one color covers.
	; if one color covers less values than the number assigned
	; for ground scatter, we need to draw more than one box
	addons = (round(_colorsteps/float(_nlevels))-1) > 1
	; but, if the level size is smaller than the ground scatter value
	; we loose colors, so we need to account for that
	minuses = ceil(_ground/(float(_scale[1]-_scale[0])/_colorsteps)-0.99)
	ncin = intarr(_colorsteps+addons-2*minuses)
	ncin[0:_colorsteps/2-minuses-1] = cin[0:_colorsteps/2-minuses-1]
	for a=0, addons-1 do $
		ncin[_colorsteps/2-minuses+a] = (keyword_set(whiteout) ? get_white() : get_gray())
	ncin[_colorsteps/2+addons-minuses:_colorsteps+addons-2*minuses-1] = cin[_colorsteps/2+minuses:_colorsteps-1]
	cin = ncin
	_colorsteps += addons-2*minuses
	nlevel_values = fltarr(_nlevels+2)
	nlevel_values[0:_nlevels/2-1] = _level_values[0:_nlevels/2-1]
	nlevel_values[_nlevels/2] = -_ground
	nlevel_values[_nlevels/2+1] = _ground
	nlevel_values[_nlevels/2+2:_nlevels+1] = _level_values[_nlevels/2+1:_nlevels]
	_level_values = nlevel_values
	_nlevels += 1
	binds = where(_level_values ge -(1.+1e-4)*_ground and _level_values le (1.+1e-4)*_ground, bc, complement=ginds, ncomplement=gc)
	if bc gt 0 then begin
		prinfo, 'GROUND >= first color level value, you might want to reconsider that.'
		;print, _nlevels, _ground
		;help, _level_values
		;help, cin
		;help, _level_values[binds]
		nlevel_values = fltarr(gc+2)
		nlevel_values[0:gc/2-1] = _level_values[ginds[0:gc/2-1]]
		nlevel_values[gc/2] = -_ground
		nlevel_values[gc/2+1] = _ground
		nlevel_values[gc/2+2:gc+1] = _level_values[ginds[gc/2:gc-1]]
		;print, gc+1, _ground
		;print, nlevel_values
		_level_values = nlevel_values
		;help, _level_values, cin
		_nlevels = gc+1
	endif
endif

; set ranges
; later, depending on the setting of VERTICAL and HORIZONTAL
; we'll decide which is xrange and what is yrange
crange = [0, _colorsteps]
wrange = [0,1]
ticks = _nlevels
if strcmp(level_format, 'label_date') then begin
	tickname = strarr(n_elements(_level_values))
	for i=0, n_elements(_level_values)-1 do begin
		tickname[i] = label_date(0, 0, _level_values[i])
	endfor
endif else $
	tickname = strtrim(string(_level_values,format=level_format),2)
if ( n_elements(level_values) eq 0 and ~keyword_set(keep_first_last_label) ) or keyword_set(drop_first_last_label) then $
	tickname[[0,_nlevels]] = ' '
if keyword_set(no_labels) then $
	tickname = replicate(' ', ticks+1)
if keyword_set(logarithmic) then $
	tickname = ''

; VERTICAL COLORBAR
if keyword_set(vertical) then begin
	plot, [0,0], xstyle=5, ystyle=5, yrange=crange, xrange=wrange, $
		position=bpos, /nodata
	for c=0, _colorsteps-1 do $
		polyfill, [0,1,1,0,0], c+[0,0,1,1,0], color=cin[c]
	plot, [0,0], xstyle=1, ystyle=5, yrange=crange, xrange=wrange, $
		position=bpos, /nodata, yticks=ticks, ytick_get=tickvals, $
		xticks=1, xtickname=replicate(' ', 2), $
		xthick=xthick, ythick=ythick
	if _ground gt 0 then $
		polyfill, [0,1,1,0,0], tickvals[ticks/2+[0,0,1,1,0]], color=(keyword_set(whiteout) ? get_white() : get_gray())
	axis, yaxis=1-keyword_set(left), ystyle=1, yrange=_scale, yticks=ticks, $
		ytickname=tickname,	ytitle=legend, charthick=charthick, charsize=charsize, $
		xthick=xthick, ythick=ythick, ylog=logarithmic
	axis, yaxis=keyword_set(left), ystyle=1, yrange=_scale, yticks=ticks, $
		ytickname=replicate(' ', ticks+1), yticklen=1, charthick=charthick, charsize=charsize, $
		xthick=xthick, ythick=ythick, ylog=logarithmic
	;axis, yaxis=1-keyword_set(left), ystyle=1, yrange=crange, yticks=ticks, $
	;	ytickname=tickname, ytitle=legend, charthick=charthick, charsize=charsize, $
	;	xthick=xthick, ythick=ythick, ylog=logarithmic
	;axis, yaxis=keyword_set(left), ystyle=1, yrange=crange, yticks=ticks, $
	;	ytickname=replicate(' ', ticks+1), yticklen=1, charthick=charthick, charsize=charsize, $
	;	xthick=xthick, ythick=ythick, ylog=logarithmic
endif else begin
	plot, [0,0], xstyle=5, ystyle=5, yrange=wrange, xrange=crange, $
		position=bpos, /nodata
	for c=0, _colorsteps-1 do $
		polyfill, c+[0,1,1,0,0], [0,0,1,1,0], color=cin[c]
	plot, [0,0], xstyle=5, ystyle=1, yrange=wrange, xrange=crange, $
		position=bpos, /nodata, xticks=ticks, xtick_get=tickvals, $
		yticks=1, ytickname=replicate(' ', 2), $
		xthick=xthick, ythick=ythick, xlog=logarithmic
	if _ground gt 0 then $
		polyfill, tickvals[ticks/2+[0,0,1,1,0]], [0,1,1,0,0], color=(keyword_set(whiteout) ? get_white() : get_gray())
	axis, xaxis=1-keyword_set(under), xstyle=1, xrange=_scale, xticks=ticks, $
		xtickname=tickname, xtitle=legend, charthick=charthick, charsize=charsize, $
		xthick=xthick, ythick=ythick, xlog=logarithmic
	axis, xaxis=keyword_set(under), xstyle=1, xrange=_scale, xticks=ticks, $
		xtickname=replicate(' ', ticks+1), xticklen=1, charthick=charthick, charsize=charsize, $
		xthick=xthick, ythick=ythick, xlog=logarithmic
endelse

if keyword_set(vertical) then begin
	xl = (bpos[0]+bpos[2])/2.
	yl = bpos[1]-.05*(bpos[3]-bpos[1])
	align = .5
endif else begin
	xl = bpos[2]+.01*(bpos[2]-bpos[0])
	yl = bpos[1]+.5*(bpos[3]-bpos[1])
	align = 0
endelse

; put some labels on the bottom
if scatterflag eq 1 then begin
	xyouts, xl, yl, 'Ground!Cscat only', /normal, $
		color=foreground, charsize=0.8*charsize, charthick=charthick, align=align
endif

if scatterflag eq 2 then begin
	xyouts, xl, yl, 'Ionos!Cscat only', /normal, $
		color=foreground, charsize=0.8*charsize, charthick=charthick, align=align
endif

return
;----------------------------------------------------
;----------------------------------------------------
; HERE FOLLOWS THE OLD VERSION - FOR REFERENCE
;----------------------------------------------------
;----------------------------------------------------


;-
;pro plot_colorbar, xmaps, ymaps, xmap, ymap, position=position, panel_position=panel_position, $
;	legend=legend, level_format=level_format, charsize=charsize, $
;	charthick=charthick, ground=ground, bar=bar, gap=gap, width=width, $
;	no_gnd=no_gnd, scale=scale, parameter=parameter, with_info=with_info, $
;	square=square, horizontal=horizontal, vertical=vertical, $
;	no_labels=no_labels, no_rotate=no_rotate, left=left, under=under, $
;	steps=steps, no_title=no_title, leg_offset=leg_offset

; Allow several color bars to be stacked
IF N_PARAMS() NE 4 THEN BEGIN 
	xmaps = 1
	xmap  = 0 
	ymaps = 1
	ymap  = 0
ENDIF

if ~keyword_set(vertical) and ~keyword_set(horizontal) then $
	vertical = 1

; get default from USER_PREFS
if ~keyword_set(parameter) then $
	parameter = get_parameter()

if ~keyword_set(scale) then $
	scale = get_default_range(parameter)

if ~keyword_set(legend) then $
	legend = get_default_title(parameter)

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if keyword_set(vertical) then $
	bar = 1

IF KEYWORD_SET(position) THEN $
	bpos = position $
else begin
	if ~keyword_set(panel_position) then $
		panel_position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, square=square, with_info=with_info, no_title=no_title)
	bpos = define_cb_position(panel_position, vertical=vertical, horizontal=horizontal, gap=gap, width=width)
endelse

if !d.name eq 'PS' then $
	toffset = .08 $
else $
	toffset = .032
if ~keyword_set(leg_offset) then begin
	if keyword_set(vertical) then begin
		if keyword_set(left) then $
			leg_offset = -(toffset*charsize - (bpos[2]-bpos[0])) $
		else $
			leg_offset = toffset*charsize
	endif else begin
		if keyword_set(under) then $
			leg_offset = -(toffset)*(!d.name eq 'X' ? 1. : .5) $ ; + charsize) $
		else $
			leg_offset = toffset*(!d.name eq 'X' ? 1. : .5)
	endelse
endif

; get color preferences
foreground  = get_foreground()
if ~keyword_set(steps) then $
	color_steps = get_colorsteps() $
else $
	color_steps = steps
ncolors     = get_ncolors()
bottom      = get_bottom()

; and some user preferences
scatterflag = rad_get_scatterflag()

cin =    FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps
; Switch color map for velocity plot, to maintain the red shift
; convention as well as the radar convention
if ~keyword_set(no_rotate) then begin
	IF parameter EQ 'velocity' then begin
		if strcmp(get_colortable(), 'bluewhitered', /fold) or strcmp(get_colortable(), 'leicester', /fold) or strcmp(get_colortable(), 'default', /fold) THEN $
				cin = ROTATE(cin, 2)
		if strcmp(get_colortable(), 'aj', /fold) or strcmp(get_colortable(), 'bw', /fold) or strcmp(get_colortable(), 'whitered', /fold) THEN $
			cin = shift(cin, color_steps/2)
	endif
endif
;	and ~keyword_set(no_rotate) and ~strcmp(get_colortable(), 'bluewhitered', /fold) THEN $
;	cin = shift(cin, color_steps/2)
;	cin = ROTATE(cin, 2)

; VERTICAL COLORBAR
if keyword_set(vertical) then begin

	xpos= bpos[0]
	ypos= bpos[1]
	xbox= bpos[2]-bpos[0]
	ybox_cols =(bpos[3]-bpos[1])/color_steps
	ybox_ticks=(bpos[3]-bpos[1])/color_steps
	ybox_gnd  =(bpos[3]-bpos[1])/10

	; Draw colored boxes
	FOR level=0,color_steps-1 DO begin
		POLYFILL,[xpos,xpos+xbox,xpos+xbox,xpos], $
			 [ypos+ybox_cols*level,ypos+ybox_cols*level, $
			  ypos+ybox_cols*(level+1),ypos+ybox_cols*(level+1)], $
			  COLOR=cin[level],/NORMAL
		PLOTS,xpos+xbox*[0,1,1,0,0],ypos+ybox_ticks*(level+[0,0,1,1,0]), $
			COLOR=foreground,/NORMAL, thick=!x.thick
	endfor

	if keyword_set(ground) and parameter eq 'velocity' then begin
		if ground gt 0 then begin
			ybox_grd  = ground*(bpos[3]-bpos[1])/(scale[1]-scale[0])
			POLYFILL,[xpos,xpos+xbox,xpos+xbox,xpos], $
				[ypos+ybox_cols*color_steps/2-ybox_grd,ypos+ybox_cols*color_steps/2-ybox_grd, $
				ypos+ybox_cols*color_steps/2+ybox_grd,ypos+ybox_cols*color_steps/2+ybox_grd], $
				COLOR=get_gray(),/NORMAL
			PLOTS,xpos+xbox*[0,1,1,0,0],[ $
				ypos+ybox_cols*color_steps/2-ybox_grd, $
				ypos+ybox_cols*color_steps/2-ybox_grd, $
				ypos+ybox_cols*color_steps/2+ybox_grd, $
				ypos+ybox_cols*color_steps/2+ybox_grd, $
				ypos+ybox_cols*color_steps/2-ybox_grd], $
				COLOR=foreground,/NORMAL, thick=!x.thick
			plots, xpos+xbox*[0,1.], [ypos+ybox_cols*color_steps/2, $
				ypos+ybox_cols*color_steps/2], $
				COLOR=foreground,/NORMAL, thick=!x.thick
		endif
	endif

	; Plot levels
	IF ~KEYWORD_SET(level_format) THEN BEGIN
		IF FIX((scale[1]-scale[0])/color_steps) NE FLOAT((scale[1]-scale[0]))/color_steps THEN BEGIN
			level_format='(F10.1)'
		ENDIF ELSE BEGIN
			level_format='(I)'
		ENDELSE
	ENDIF
	lvl = scale[0]+FINDGEN(color_steps+1)*(scale[1]-scale[0])/color_steps
	FOR level=(parameter EQ 'velocity' and scatterflag eq 3),color_steps DO BEGIN
		numb = STRTRIM(FIX(ABS(lvl[level])),2) + $
			'.'+STRTRIM(ABS(FIX(lvl[level]*10)) MOD 10,2)
		IF lvl[level] LT 0 THEN $
			numb='-'+numb
		numb=STRTRIM(STRING(lvl[level],FORMAT=level_format),2)
		lxpos = xpos+1.3*xbox
		align = 0.
		if keyword_set(left) then begin
			lxpos = xpos-0.3*xbox
			align = 1.
		endif
		lypos = ypos+ybox_ticks*level-0.25*ybox_ticks
		if ~keyword_set(no_labels) then $
			XYOUTS, lxpos, lypos, $
				numb, COLOR=foreground, CHARSIZE=.8*charsize,$
				align=align, /NORMAL,charthick=charthick
	ENDFOR

	; Plot title
	if ~keyword_set(no_labels) then begin
		txpos = xpos+leg_offset
		;plots, [txpos, txpos], [0,1], /norm
		typos = ypos+color_steps*ybox_cols*0.5
		XYOUTS, txpos, typos, legend, COLOR=foreground, $
			ORIENTATION=( keyword_set(left) ? 90 : 270 ),CHARSIZE=charsize,$
			align=.5, /NORMAL,charthick=charthick
	endif
	line1=0.6
	line2=(.6+.3)
	
	; Add ground scatter box (or other annotation...)
	IF ~KEYWORD_SET(no_gnd) THEN BEGIN
		IF parameter EQ 'velocity' AND scatterflag EQ 3 THEN BEGIN
			POLYFILL,[xpos,xpos+xbox,xpos+xbox,xpos],		$
				 [ypos-0.15*ybox_gnd,ypos-0.15*ybox_gnd,		$
				  ypos-(0.15+.5)*ybox_gnd,ypos-(0.15+.5)*ybox_gnd],		$
				  COLOR=get_gray(),/NORMAL
			gxpos = xpos+1.4*xbox
			align = 0.
			if keyword_set(left) then begin
				gxpos = xpos-.4*xbox
				align = 1.
			endif
			XYOUTS,gxpos,ypos-line1*ybox_gnd,'Ground',/NORMAL,$
				COLOR=foreground,CHARSIZE=0.8*charsize, align=align,charthick=charthick
			XYOUTS,gxpos,ypos-line2*ybox_gnd,'Scatter',/NORMAL,$
				COLOR=foreground,CHARSIZE=0.8*charsize, align=align,charthick=charthick
		ENDIF
		IF scatterflag EQ 1 and parameter EQ 'velocity' THEN BEGIN
			XYOUTS,xpos,ypos-line1*ybox_gnd,'Ground',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize,charthick=charthick
			XYOUTS,xpos,ypos-line2*ybox_gnd,'scat only',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize,charthick=charthick
		ENDIF
		IF scatterflag EQ 2 and parameter EQ 'velocity' THEN BEGIN
			XYOUTS,xpos,ypos-line1*ybox_gnd,'Ionospheric',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize,charthick=charthick
			XYOUTS,xpos,ypos-line2*ybox_gnd,'scat only',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize,charthick=charthick
		ENDIF
	ENDIF
; HORIZONTAL COLORBAR
endif else if keyword_set(horizontal) then begin

	xpos= bpos[0]
	ypos= bpos[1]
	ybox= bpos[3]-bpos[1]
	xbox_cols =(bpos[2]-bpos[0])/color_steps
	xbox_ticks=(bpos[2]-bpos[0])/color_steps
	xbox_gnd  =(bpos[2]-bpos[0])/10
	
	; Draw colored boxes
	FOR level=0,color_steps-1 DO					$
		POLYFILL,[xpos+xbox_cols*level,xpos+xbox_cols*(1+level),$
			xpos+xbox_cols*(1+level),xpos+xbox_cols*level],	$
			 [ypos,ypos,ypos+ybox,ypos+ybox],	$
			  COLOR=cin[level],/NORMAL

	; Draw outline
	FOR level=0,color_steps-1 DO 					$
		PLOTS,xpos+xbox_ticks*(level+[0,0,1,1,0]),ypos+ybox*[0,1,1,0,0], $
			COLOR=foreground,/NORMAL, thick=!x.thick

	; Plot levels
	IF ~KEYWORD_SET(level_format) THEN BEGIN
		IF FIX((scale[1]-scale[0])/color_steps) NE FLOAT((scale[1]-scale[0]))/color_steps THEN BEGIN
			level_format='(F10.1)'
		ENDIF ELSE BEGIN
			level_format='(I)'
		ENDELSE
	ENDIF
	lvl = scale[0]+FINDGEN(color_steps+1)*(scale[1]-scale[0])/color_steps
	FOR level=(parameter EQ 'velocity' and scatterflag eq 3),color_steps DO BEGIN
		numb = STRTRIM(FIX(ABS(lvl[level])),2) + $
			'.'+STRTRIM(ABS(FIX(lvl[level]*10)) MOD 10,2)
		IF lvl[level] LT 0 THEN $
			numb='-'+numb
		numb=STRTRIM(STRING(lvl[level],FORMAT=level_format),2)
		lxpos = xpos+xbox_ticks*level
		lypos = ypos+1.4*ybox
		if keyword_set(under) then begin
			lypos = ypos-0.5*ybox
		endif
		if ~keyword_set(no_labels) then $
			XYOUTS, lxpos, lypos, charthick=charthick,$
				numb,COLOR=foreground,CHARSIZE=.8*charsize,/NORMAL, align=.5
	ENDFOR
	
	; Plot title
	if ~keyword_set(no_labels) then begin
		txpos = xpos+color_steps*xbox_cols*0.5
		typos = ypos+leg_offset
		XYOUTS,txpos,typos,legend,COLOR=foreground,	$
			ALIGNMENT=0.5,CHARSIZE=charsize,/NORMAL,charthick=charthick
	endif
	line1=0.6
	line2=(0.5+.5)
	
	; Add ground scatter box (or other annotation...)
	IF ~KEYWORD_SET(no_gnd) THEN BEGIN
		IF parameter EQ 'velocity' AND scatterflag EQ 3 THEN BEGIN
			POLYFILL, [xpos-0.15*xbox_gnd,xpos-0.15*xbox_gnd,		$
				  xpos-(0.15+.5)*xbox_gnd,xpos-(0.15+.5)*xbox_gnd],		$
					[ypos,ypos+ybox,ypos+ybox,ypos],		$
				  COLOR=get_gray(),/NORMAL
			gypos1 = ypos+line2*xbox_gnd
			gypos2 = ypos+line1*xbox_gnd
			if keyword_set(under) then begin
				gypos1 = ypos-line1*xbox_gnd
				gypos2 = ypos-line2*xbox_gnd
			endif
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,gypos1,'Ground',/NORMAL,$
				COLOR=foreground,CHARSIZE=0.8*charsize, align=.5,charthick=charthick
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,gypos2,'Scatter',/NORMAL,$
				COLOR=foreground,CHARSIZE=0.8*charsize, align=.5,charthick=charthick
		ENDIF
		sypos1 = ypos+line2*xbox_gnd
		sypos2 = ypos+line1*xbox_gnd
		if keyword_set(under) then begin
			sypos1 = ypos-line1*xbox_gnd
			sypos2 = ypos-line2*xbox_gnd
		endif
		IF scatterflag EQ 1 and parameter EQ 'velocity' THEN BEGIN
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,sypos1,'Ground',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize, align=1.,charthick=charthick
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,sypos2,'scat only',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize, align=1.,charthick=charthick
		ENDIF
		IF scatterflag EQ 2 and parameter EQ 'velocity' THEN BEGIN
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,sypos1,'Ionospheric',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize, align=1.,charthick=charthick
			XYOUTS,xpos-(0.15+0.25)*xbox_gnd,sypos2,'scat only',/NORMAL,COLOR=foreground,$
				CHARSIZE=0.8*charsize, align=1.,charthick=charthick
		ENDIF
	ENDIF
endif
END
