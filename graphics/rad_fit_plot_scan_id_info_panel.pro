;+ 
; NAME: 
; RAD_FIT_PLOT_SCAN_ID_INFO_PANEL
; 
; PURPOSE: 
; This procedure plots a panel giving the scan ids (CPID) of the radar data in a panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_SCAN_ID_INFO_PANEL
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
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
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
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
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
; PANEL_POSITION: Set this keyword to a 4-element vector of normalized coordinates of
; the panel above which the noise panel will be placed. Only takes effect when the
; INFO keyword is set.
;
; FIRST: Set this keyword to indicate that this panel is the first panel in
; a ROW of plots. That will force Y axis labels.
;
; LAST: Set this keyword to indicate that this is the last panel in a COLUMN of plots.
; That will force X axis labels.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
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
pro rad_fit_plot_scan_id_info_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	beam=beam, channel=channel, $
	silent=silent, bar=bar, ytitle=ytitle, $
	charthick=charthick, charsize=charsize, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	position=position, panel_position=panel_position, $
	first=first, last=last, with_info=with_info, no_title=no_title, $
	rightyaxis=rightyaxis, legend=legend

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

if n_elements(beam) eq 0 then $
	beam = rad_get_beam()

if n_params() lt 4 then begin
	if ~keyword_set(silent) and ~keyword_set(position) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif
if ~keyword_set(position) then begin
	tposition = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info, no_title=no_title)
	position = [tposition[0], tposition[3]+0.012, tposition[2], tposition[3]+0.048]
endif
if keyword_set(panel_position) then $
	position = [panel_position[0], panel_position[3]+0.012, panel_position[2], panel_position[3]+0.048]

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, (*rad_fit_data[data_index]).juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long
xrange = [sjul, fjul]

if ~keyword_set(ytitle) then $
	_ytitle = 'CPID' $
else $
	_ytitle = ytitle

if n_elements(channel) eq 0 then $
	channel = (*rad_fit_info[data_index]).channels[0]

if ~keyword_set(charthick) then $
	charthick = !p.charthick

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(linethick) then $
	linethick = !p.thick

if ~keyword_set(linecolor) then $
	linecolor = get_foreground()

; get data
xtag = 'juls'
ytag = 'scan_id'
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

; select data to plot
; must fit beam, channel, scan_id, time (roughly) and frequency
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
scch_inds = where(tchann eq channel, cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for for beam '+string(beam)+$
			' and channel '+string(channel)
	return
endif
tchann = 0
txdata = txdata[scch_inds]
juls_inds = where(txdata ge sjul-10.d/1440.d and txdata le fjul+10.d/1440.d, cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for beam '+string(beam)+$
			' and time '+format_time(time)
	return
endif

; get indeces of data to plot
beam_inds = where((*rad_fit_data[data_index]).beam eq beam and $
	(*rad_fit_data[data_index]).channel eq channel and $
	(*rad_fit_data[data_index]).juls ge sjul and $
	(*rad_fit_data[data_index]).juls le fjul, $
	nbeam_inds)
if nbeam_inds lt 1 then begin
	prinfo, 'No data found for beam '+string(beam)
	return
endif
xdata = xdata[beam_inds]
ydata = ydata[beam_inds]
ifmode = (*rad_fit_data[data_index]).ifmode[beam_inds]
	
; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	xstyle=5, ystyle=5, $
	xrange=xrange, yrange=[0,60]

; first color the plotting area according to
; if/rf mode
uifmode = uniq(ifmode)
nnif = n_elements(uifmode)

uscanids = uniq(ydata)
for i=0, nnif-1 do begin
  ii = where(uscanids eq uifmode[i], cc)
  if cc eq 0L then $
    uscanids = [uscanids, uifmode[i]]
endfor
uscanids = uscanids[sort(uscanids)]
nn = n_elements(uscanids)

oplot, replicate(xdata[0], 2), !y.crange, color=linecolor, thick=linethick, linestyle=linestyle, /noclip
cpname = rad_cpid_translate(ydata[0])
ostr = (strlen(cpname) lt 2 ? '' : cpname+' ') + $
	strtrim(string(ydata[0]),2) + $
	( ifmode[0] eq 255 ? '' : ( ifmode[0] eq 0 ? ' RF' : ' IF' ) )
xyouts, xdata[0]+.005*(!x.crange[1]-!x.crange[0]), 0.11*!y.crange[1], ostr, /data, charsize=charsize, $
	charthick=charthick, color=get_foreground()
if nn gt 1 then begin
	for i=0L, nn-1L do begin
		if uscanids[i] le nbeam_inds-2L then begin
			oplot, replicate(xdata[uscanids[i]+1L], 2), !y.crange, $
				color=linecolor, thick=linethick, linestyle=linestyle, /noclip
			if (xdata[uscanids[i]+1L]-!x.crange[0])/(!x.crange[1]-!x.crange[0])*100. gt 85. then $
				align = 1 $
			else $
				align = 0
			cpname = rad_cpid_translate(ydata[uscanids[i]+1L])
			ostr = (strlen(cpname) lt 2 ? '' : cpname+' ') + $
				strtrim(string(ydata[uscanids[i]+1L]),2) + $
				( ifmode[uscanids[i]+1L] eq 255 ? '' : ( ifmode[uscanids[i]+1L] eq 0 ? ' RF' : ' IF' ) )
			xyouts, xdata[uscanids[i]+1L]+.005*(1.-2*align)*(!x.crange[1]-!x.crange[0]), $
				( 0.11 + ( ( (i+1) mod 2 )*.4 ) )*!y.crange[1], $
				ostr, /data, $
				charsize=charsize, charthick=charthick, align=align, color=get_foreground()
		endif
	endfor
endif

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
ypos = (position[1]+position[3])/2. - 0.2*(position[3]-position[1]) + loff
xyouts, xpos, ypos, _ytitle, /norm, charthick=charthick, charsize=charsize, width=strwidth, align=align

;fmt = get_format(tokyo=ty)
;if ty and ~keyword_set(first) then $
;	return

;xoff = ( strcmp(!d.name, 'ps', /fold) ? 0.075 : 0.09 )
;if keyword_set(leftyaxis) then $
;	xpos = position[2] + (1.45+( strcmp(!d.name, 'ps', /fold) ? 0.0 : 0.2 ))*xoff*(position[2]-position[0]) $
;else $
;	xpos = position[0] - xoff*(position[2]-position[0])
;ypos = position[1] + 0.2*(position[3]-position[1])
;xyouts, xpos, ypos, _ytitle, align=1., /norm, charthick=charthick, charsize=charsize

end
