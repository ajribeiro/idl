;+ 
; NAME: 
; RAD_MAP_PLOT_NPOINTS_PANEL
; 
; PURPOSE: 
; This procedure plots the time series of logarithm of the points 
; that went into the map potential fitting in a panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_PLOT_NPOINTS_PANEL
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
; DATA: Set this keyword to plot the number of actual LoS velocity vectors.
; This is the default. See also the MODEL and RATIO keyword.
;
; MODEL: Set this keyword to plot the number of model vectors added to 
; constrain the fit. See also DATA and RATIO keyword.
;
; RATIO: Set this keyword to plot the ratio of the number of
; real LoS vectors vc to the number of model vectors m. The ratio
; is calculated like r = vc / (vc + m)
; A ratio of 0 indicates all vectors are form the model, 
; if the ratio is 1, all vectors are original LoS vectors.
; See also DATA and MODEL keyword.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; PSYM: Set this keyword to change the symbol used for plotting.
;
; XSTYLE: Set this keyword to change the style of the x axis.
;
; YSTYLE: Set this keyword to change the style of the y axis.
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
; LINESTYLE: Set this keyword to change the style of the line.
; Default is 0 (solid).
;
; LINECOLOR: Set this keyword to a color index to change the color of the line.
; Default is black.
;
; LINETHICK: Set this keyword to change the thickness of the line.
; Default is 1.
;
; XTICKFORMAT: Set this keyword to change the formatting of the time for the x axis.
;
; YTICKFORMAT: Set this keyword to change the formatting of the y axis values.
;
; POSITION: Set this keyword to a 4-element vector of normalized coordinates 
; if you want to override the internal
; positioning calculations.
;
; FIRST: Set this keyword to indicate that this panel is the first panel in
; a ROW of plots. That will force Y axis labels.
;
; LAST: Set this keyword to indicate that this is the last panel in a COLUMN of plots.
; That will force X axis labels.
;
; INFO: Set this keyword to plot the panel above a panel which position has been
; defined using DEFINE_PANEL(XMAPS, YMAP, XMAP, YMAP, /WITH_INFO).
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
; Written by: Lasse Clausen, 2009.
;-
pro rad_map_plot_npoints_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	north=north, south=south, hemisphere=hemisphere, $
	data=data, model=model, ratio=ratio, $
	yrange=yrange, ylog=ylog, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, $
	last=last, first=first, with_info=with_info, info=info

common rad_data_blk

if n_params() lt 4 then begin
	if ~keyword_set(silent) and ~keyword_set(position) then $
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
int_hemi = (hemisphere lt 0)

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	if rad_map_info[int_hemi].nrecs eq 0L then begin
		if ~keyword_set(silent) then $
			prinfo, 'No data loaded.'
		return
	endif
	caldat, (*rad_map_data[int_hemi]).sjuls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long
xrange = [sjul, fjul]

if ~keyword_set(data) and ~keyword_set(model) and ~keyword_set(ratio) then $
	data = 1

if ~keyword_set(xtitle) then $
	_xtitle = 'Time UT' $
else $
	_xtitle = xtitle

if ~keyword_set(xtickformat) then $
	_xtickformat = 'label_date' $
else $
	_xtickformat = xtickformat

if ~keyword_set(xtickname) then $
	_xtickname = '' $
else $
	_xtickname = xtickname

if ~keyword_set(ytitle) then begin
	if keyword_set(ratio) then $
		_ytitle = textoidl('N_{vc}/(N_{vc} + N_{mod})') $
	else $
		_ytitle = 'N pts'
endif else $
	_ytitle = ytitle

if ~keyword_set(ytickformat) then $
	_ytickformat = '' $
else $
	_ytickformat = ytickformat

if ~keyword_set(ytickname) then $
	_ytickname = '' $
else $
	_ytickname = ytickname

if ~keyword_set(position) then begin
	if keyword_set(info) then begin
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, /with_info)
		position = [position[0], position[3]+0.08, $
			position[2], position[3]+0.12]
	endif else $
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info)
endif

; check if format is sardines.
; if yes, loose the x axis information
; unless it is given
fmt = get_format(sardines=sd, tokyo=ty)
if (sd and ~keyword_set(last)) or keyword_set(info) then begin
	if ~keyword_set(xtitle) then $
		_xtitle = ' '
	if ~keyword_set(xtickformat) then $
		_xtickformat = ''
	if ~keyword_set(xtickname) then $
		_xtickname = replicate(' ', 60)
endif
if ty and ~keyword_set(first) then begin
	if ~keyword_set(ytitle) then $
		_ytitle = ' '
	if ~keyword_set(ytickformat) then $
		_ytickformat = ''
	if ~keyword_set(ytickname) then $
		_ytickname = replicate(' ', 60)
endif

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

if ~keyword_set(yrange) then begin
	if keyword_set(ratio) then $
		yrange = [0,1] $
	else $
		yrange = get_default_range('npoints')
endif

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(linethick) then $
	linethick = 1.

if ~keyword_set(linecolor) then $
	linecolor = get_foreground()

if ~keyword_set(xticks) then $
	xticks = get_xticks(sjul, fjul, xminor=_xminor)

if keyword_set(xminor) then $
	_xminor = xminor

if ~keyword_set(psym) then $
	psym = 10

; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=(keyword_set(info) ? .6 : 1.)*charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	xrange=xrange, yrange=yrange, ylog=ylog, $
	color=get_foreground()

; get data
xtag = 'mjuls'
if ~tag_exists((*rad_map_data[int_hemi]), xtag) then begin
	prinfo, 'Parameter '+xtag+' does not exist in RAD_MAP_DATA.'
	return
endif
dd = execute('xdata = (*rad_map_data[int_hemi]).'+xtag)

if keyword_set(model) then begin
	ytag = 'modnum'
	if ~tag_exists((*rad_map_data[int_hemi]), ytag) then begin
		prinfo, 'Parameter '+ytag+' does not exist in RAD_MAP_DATA.'
		return
	endif
	dd = execute('ydata = (*rad_map_data[int_hemi]).'+ytag)
endif else if keyword_set(data) then begin
	ytag = 'vcnum'
	if ~tag_exists((*rad_map_data[int_hemi]), ytag) then begin
		prinfo, 'Parameter '+ytag+' does not exist in RAD_MAP_DATA.'
		return
	endif
	dd = execute('ydata = (*rad_map_data[int_hemi]).'+ytag)
endif else if keyword_set(ratio) then begin
	ytag = 'vcnum'
	if ~tag_exists((*rad_map_data[int_hemi]), ytag) then begin
		prinfo, 'Parameter '+ytag+' does not exist in RAD_MAP_DATA.'
		return
	endif
	dd = execute('ydatav = (*rad_map_data[int_hemi]).'+ytag)
	ytag = 'modnum'
	if ~tag_exists((*rad_map_data[int_hemi]), ytag) then begin
		prinfo, 'Parameter '+ytag+' does not exist in RAD_MAP_DATA.'
		return
	endif
	dd = execute('ydatam = (*rad_map_data[int_hemi]).'+ytag)
	ydata = float(ydatav)/float(ydatav+ydatam)
endif else begin
	prinfo, 'Must set DATA, MODEL or RATIO keyword.'
	return
endelse

; overplot data
oplot, xdata, ydata, $
	thick=linethick, color=linecolor, linestyle=linestyle, psym=psym

if keyword_set(ratio) then $
	oplot, !x.crange, [0.5, 0.5], linestyle=2, color=get_gray()

end
