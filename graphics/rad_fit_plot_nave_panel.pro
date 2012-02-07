;+ 
; NAME: 
; RAD_FIT_PLOT_NAVE_PANEL
; 
; PURPOSE: 
; This procedure plots the time series of the number of pulse sequences per beam sounding, nave, in a panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_FIT_PLOT_NAVE_PANEL
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
; BEAM: Set this keyword to specify the beam number from which to plot
; the time series.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
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
pro rad_fit_plot_nave_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	beam=beam, channel=channel, scan_id=scan_id, $
	yrange=yrange, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, panel_position=panel_position, $
	last=last, first=first, with_info=with_info, info=info, no_title=no_title, $
	title=title, horizontal_ytitle=horizontal_ytitle, rightyaxis=rightyaxis

common rad_data_blk

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	return

if (*rad_fit_info[data_index]).nrecs eq 0L then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data in index '+string(data_index)
		rad_fit_info
	endif
	return
endif

if n_params() lt 4 then begin
	if ~keyword_set(silent) and ~keyword_set(position) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if n_elements(beam) eq 0 then $
	beam = rad_get_beam()

if ~keyword_set(scan_id) then $
	scan_id = -1

if n_elements(channel) eq 0 and scan_id eq -1 then begin
		channel = (*rad_fit_info[data_index]).channels[0]
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	if (*rad_fit_info[data_index]).nrecs eq 0L then begin
		if ~keyword_set(silent) then begin
			prinfo, 'No data in index '+string(data_index)
			rad_fit_info
		endif
		return
	endif
	caldat, (*rad_fit_data[data_index]).juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long
xrange = [sjul, fjul]

if n_elements(xtitle) eq 0 then $
	_xtitle = 'Time UT' $
else $
	_xtitle = xtitle

if n_elements(xtickformat) eq 0 then $
	_xtickformat = 'label_date' $
else $
	_xtickformat = xtickformat

if n_elements(xtickname) eq 0 then $
	_xtickname = '' $
else $
	_xtickname = xtickname

if n_elements(ytitle) eq 0 then $
	_ytitle = 'Nave' $
else $
	_ytitle = ytitle

if n_elements(ytickformat) eq 0 then $
	_ytickformat = '' $
else $
	_ytickformat = ytickformat

if n_elements(ytickname) eq 0 then $
	_ytickname = '' $
else $
	_ytickname = ytickname

if n_elements(yticks) eq 0 then $
	_yticks = ( keyword_set(info) ? 1 : 0 ) $
else $
	_yticks = yticks

if n_elements(yminor) eq 0 then $
	_yminor = 3 $
else $
	_yminor = yminor

if ~keyword_set(position) then begin
	if keyword_set(info) then begin
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, /with_info, no_title=no_title)
		position = [position[0], position[3]+0.05, $
			position[2], position[3]+0.09]
	endif else if keyword_set(panel_position) then $
		position = [panel_position[0], panel_position[3]+0.05, panel_position[2], panel_position[3]+0.09] $
	else $
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info, no_title=no_title)
endif

; get data
xtag = 'juls'
ytag = 'nave'
if ~tag_exists((*rad_fit_data[data_index]), xtag) then begin
	prinfo, 'Parameter '+xtag+' does not exist in RAD_FIT_DATA.'
	return
endif
if ~tag_exists((*rad_fit_data[data_index]), ytag) then begin
	prinfo, 'Parameter '+ytag+' does not exist in RAD_FIT_DATA.'
	return
endif
dd = execute('xdata = (*rad_fit_data[data_index]).'+xtag)
dd = execute('ydata = (*rad_fit_data[data_index]).'+ytag)

if ~keyword_set(ystyle) then $
	ystyle = ( keyword_set(rightyaxis) ? 5 : 1 )

if ~keyword_set(yrange) then begin
	yrange = get_default_range('nave')
	if max(ydata) gt yrange[1] then begin
		yrange = [yrange[0], 80]
		if n_elements(yminor) eq 0 then $
			_yminor = 4
	endif
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

; overwrite ytickname depending on INFO set or not
;if keyword_set(info) and ~keyword_set(ytickformat) and not(ty and ~keyword_set(first)) then $
;	_ytickname = ['0', replicate(' ', _yticks-1), strtrim(string(yrange[1]),2)]

if ~keyword_set(xstyle) then $
	xstyle = ( keyword_set(rightyaxis) ? 5 : 1 )

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

; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=( keyword_set(horizontal_ytitle) ? ' ' : _ytitle ), $
	xticks=xticks, xminor=_xminor, yticks=_yticks, yminor=_yminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	xrange=xrange, yrange=yrange, $
	color=get_foreground(), title=title, xticklen=-!p.ticklen, yticklen=-!p.ticklen, ytick_get=ytick_get

;for i=1, n_elements(real_yticks)-2 do $
;	oplot, !x.crange, replicate(real_yticks[i], 2), linestyle=2, color=get_gray(), thick=1

; select data to plot
; must fit beam, channel, scan_id, time (roughly)
;
; check first whether data is available for the user selection
; then find data to actually plot
beam_inds = where((*rad_fit_data[data_index]).beam eq beam, cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for beam '+string(beam)
	return
endif
txdata = xdata[beam_inds]
tchann = (*rad_fit_data[data_index]).channel[beam_inds]
tscani = (*rad_fit_data[data_index]).scan_id[beam_inds]
if n_elements(channel) ne 0 then begin
	scch_inds = where(tchann eq channel, cc)
	if cc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No data found for for beam '+string(beam)+$
				' and channel '+string(channel)
		return
	endif
endif else if keyword_set(scan_id) then begin
	scch_inds = where(tscani eq scan_id, cc)
	if cc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No data found for for beam '+string(beam)+$
				' and scan_id '+string(scan_id)
		return
	endif
endif
tchann = 0
tscani = 0
txdata = txdata[scch_inds]
juls_inds = where(txdata ge sjul-10.d/1440.d and txdata le fjul+10.d/1440.d, cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for beam '+string(beam)+$
			' and time '+format_time(time)
	return
endif
txdata = 0

; get indeces of data to plot
if n_elements(channel) ne 0 then begin
	beam_inds = where((*rad_fit_data[data_index]).beam eq beam and $
		(*rad_fit_data[data_index]).channel eq channel and $
		(*rad_fit_data[data_index]).juls ge sjul-10.d/1440.d and $
		(*rad_fit_data[data_index]).juls le fjul+10.d/1440.d, $
		nbeam_inds)
endif else if keyword_set(scan_id) then begin
	beam_inds = where((*rad_fit_data[data_index]).beam eq beam and $
		(*rad_fit_data[data_index]).scan_id eq scan_id and $
		(*rad_fit_data[data_index]).juls ge sjul-10.d/1440.d and $
		(*rad_fit_data[data_index]).juls le fjul+10.d/1440.d, $
		nbeam_inds)
endif

; overplot data

; plot beginning
xs = xdata[ [beam_inds[0],beam_inds[0],beam_inds[1]] ]
ys = [0.,ydata[beam_inds[0]],ydata[beam_inds[0]]]
oplot, xs, ys, $
	thick=linethick, color=linecolor, linestyle=linestyle, psym=psym

for i=1L, nbeam_inds-2L do begin
	if (xdata[beam_inds[i+1]] - xdata[beam_inds[i]])*1440.d gt 4. then begin
		xs = xdata[ [beam_inds[i],beam_inds[i],beam_inds[i],beam_inds[i]] ] + [0.d, 0.d, 4.d/1440.d, 4.d/1440.d]
		ys = [ydata[beam_inds[i-1]],ydata[beam_inds[i]],ydata[beam_inds[i]],0.]
		oplot, xs, ys, $
			thick=linethick, color=linecolor, linestyle=linestyle, psym=psym
		if i lt nbeam_inds-2L then begin
			i += 1
			xs = xdata[ [beam_inds[i],beam_inds[i],beam_inds[i+1]] ]
			ys = [0.,ydata[beam_inds[i]],ydata[beam_inds[i]]]
			oplot, xs, ys, $
				thick=linethick, color=linecolor, linestyle=linestyle, psym=psym
		endif
	endif else begin
		xs = xdata[ [beam_inds[i],beam_inds[i],beam_inds[i+1]] ]
		ys = [ydata[beam_inds[i-1]],ydata[beam_inds[i]],ydata[beam_inds[i]]]
		oplot, xs, ys, $
			thick=linethick, color=linecolor, linestyle=linestyle, psym=psym
	endelse
endfor

; plot end
oplot, [xdata[beam_inds[i]], xdata[beam_inds[i]]], [ydata[beam_inds[i]], 0.], $
	thick=linethick, color=linecolor, linestyle=linestyle, psym=psym

if keyword_set(rightyaxis) then $
	axis, /yaxis, ystyle=1, yrange=!y.crange, $
		charthick=charthick, charsize=charsize, ytitle=( keyword_set(horizontal_ytitle) ? ' ' : _ytitle ), $
		yticks=_yticks, yminor=_yminor, ytickformat=_ytickformat, ytickname=_ytickname, $
		color=get_foreground(), yticklen=-!p.ticklen

if keyword_set(horizontal_ytitle) and ( ( ystyle and 4) eq 0 or keyword_set(rightyaxis) ) then begin
	if keyword_set(rightyaxis) then begin
		align = 0
		xpos = position[2] + 0.09*(position[2]-position[0])
	endif else begin
		align = 1
		xpos = position[0] - 0.09*(position[2]-position[0])
	endelse
	if strpos(_ytitle, '!C') ne -1 then $
		loff = .02*charsize $
	else $
		loff = 0.
	ypos = (position[1]+position[3])/2. - (keyword_set(info) ? 0.2*(position[3]-position[1]) : 0.) + loff
	xyouts, xpos, ypos, _ytitle, /norm, charthick=charthick, charsize=charsize, width=strwidth, align=align
	plots, xpos+(1.-2.*align)*[strwidth/4., 3./4.*strwidth], ypos-0.01-1.2*loff, /norm, $
		thick=linethick, color=linecolor, linestyle=linestyle, psym=psym
endif

end
