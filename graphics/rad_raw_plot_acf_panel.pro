;+ 
; NAME: 
; RAD_RAW_PLOT_ACF_PANEL
; 
; PURPOSE: 
; This procedure plots the ACFs from RAW_ACF files in a panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_RAW_PLOT_ACF_PANEL
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
; TIME: A scalar giving the time to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; BEAM: Set this keyword to specify the beam number from which to plot
; the time series.
;
; GATE: Set this keyword to specify the gate number from which to plot
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
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
;
; LINESTYLE: Set this keyword to change the style of the line.
; Default is 0 (solid).
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
; If you desire to use the software for proraw-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such proraw-making or
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
; OR IMPLIED. NO WARRANTY OF rawNESS FOR A PARTICULAR PURPOSE IS
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
pro rad_raw_plot_acf_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	beam=beam, gate=gate, $
	main=main, interferometer=interferometer, $
	channel=channel, scan_id=scan_id, $
	freq_band=freq_band, yrange=yrange, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	linestyle=linestyle, linethick=linethick, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, $
	first=first, last=last, with_info=with_info, no_title=no_title

common rad_data_blk

; get index for current data
	
if rad_raw_info.nrecs eq 0L then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data in RAD_RAW_DATA.'
		rad_raw_info
	endif
	return
endif

if n_elements(beam) eq 0 then $
	beam = rad_get_beam()

if n_elements(gate) eq 0 then $
	gate = rad_get_gate()

if ~keyword_set(freq_band) then $
	freq_band = [3.0, 30.0]

if n_params() lt 4 then begin
	if ~keyword_set(silent) and ~keyword_set(position) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif
if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info, no_title=no_title)

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, rad_raw_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = 1200

if n_elements(time) ne 1 then begin
	prinfo, 'TIME must be scalar, using first element.'
	time = time[0]
endif

sfjul, date, time, ajul, long=long

if n_elements(xtitle) eq 0 then $
	_xtitle = 'Lag Time [ms]' $
else $
	_xtitle = xtitle

if n_elements(xtickformat) eq 0 then $
	_xtickformat = '' $
else $
	_xtickformat = xtickformat

if n_elements(xtickname) eq 0 then $
	_xtickname = '' $
else $
	_xtickname = xtickname

if n_elements(ytitle) eq 0 then $
	_ytitle = '' $
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

if ~keyword_set(scan_id) then $
	scan_id = -1

if n_elements(channel) eq 0 and scan_id eq -1 then begin
	channel = rad_raw_info.channels[0]
endif

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~keyword_set(linethick) then $
	linethick = 1.

if ~keyword_set(main) and ~keyword_set(interferometer) then $
	main = 1

if keyword_set(main) then $
	param = 'acf' $
else $
	param = 'xcf'

; get data
xtag = 'lagtime'
ytag = param
if ~tag_exists(rad_raw_data, xtag) then begin
	prinfo, 'Parameter '+xtag+' does not exist in RAD_RAW_DATA.'
	return
endif
if ~tag_exists(rad_raw_data, ytag+'_r') then begin
	prinfo, 'Parameter '+ytag+'_r does not exist in RAD_RAW_DATA.'
	return
endif
if ~tag_exists(rad_raw_data, ytag+'_i') then begin
	prinfo, 'Parameter '+ytag+'_i does not exist in RAD_RAW_DATA.'
	return
endif
dd = execute('xdata = rad_raw_data.'+xtag)
dd = execute('ydata_r = rad_raw_data.'+ytag+'_r')
dd = execute('ydata_i = rad_raw_data.'+ytag+'_i')

; select data to plot
; must raw beam, channel, scan_id, time (roughly) and frequency
;
; check first whether data is available for the user selection
; then find data to actually plot
beam_inds = where(rad_raw_data.beam eq beam, cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for beam '+string(beam)
	return
endif
txdata = rad_raw_data.juls[beam_inds]
tchann = rad_raw_data.channel[beam_inds]
ttfreq = rad_raw_data.tfreq[beam_inds]
tscani = rad_raw_data.scan_id[beam_inds]
if n_elements(channel) ne 0 then begin
	scch_inds = where(tchann eq channel, cc)
	if cc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No data found for for beam '+string(beam)+$
				' and channel '+string(channel)
		return
	endif
endif else if scan_id ne -1 then begin
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
ttfreq = ttfreq[scch_inds]
juls_inds = where(txdata ge ajul-5.d/1440.d and txdata le ajul+5.d/1440.d, cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for beam '+string(beam)+$
			' and time '+format_time(time)
	return
endif
txdata = 0
ttfreq = ttfreq[juls_inds]
tfre_inds = where(ttfreq*0.001 ge freq_band[0] and ttfreq*0.001 le freq_band[1], cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for beam '+string(beam)+$
			' and channel '+string(_channel)+' and time '+format_time(time) + $
			' and freq. band '+string(freq_band)
	return
endif
ttfreq = 0

; get indeces of data to plot
if n_elements(channel) ne 0 then begin
	beam_inds = where(rad_raw_data.beam eq beam and $
		rad_raw_data.channel eq channel and $
		rad_raw_data.tfreq*0.001 ge freq_band[0] and $
		rad_raw_data.tfreq*0.001 le freq_band[1], $
		nbeam_inds)
endif else if scan_id ne -1 then begin
	beam_inds = where(rad_raw_data.beam eq beam and $
		rad_raw_data.scan_id eq scan_id and $
		rad_raw_data.tfreq*0.001 ge freq_band[0] and $
		rad_raw_data.tfreq*0.001 le freq_band[1], $
		nbeam_inds)
endif
if nbeam_inds lt 1 then begin
	prinfo, 'No data found for beam '+string(beam)
	return
endif

dd = min(abs(rad_raw_data.juls[beam_inds] - ajul), tindex)
if dd*1440.d gt 5. then $
	prinfo, 'Time found but more than 5 minutes away from target time.'

if ~keyword_set(yrange) then begin
	yrange = [min([ydata_r[beam_inds[tindex],gate,*],ydata_i[beam_inds[tindex],gate,*]]),(max([ydata_r[beam_inds[tindex],gate,*],ydata_i[beam_inds[tindex],gate,*]]) > 1.)]
endif

; check if format is sardines.
; if yes, loose the x axis information
; unless it is given
fmt = get_format(sardines=sd, tokyo=ty)
if sd and ~keyword_set(last) then begin
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

; set up coordinate system for plot
plot, xdata[beam_inds[tindex],*], ydata_r[beam_inds[tindex],gate,*], $
	/nodata, position=position, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xrange=xrange, yrange=yrange, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	color=get_foreground()

; overplot data
oplot, xdata[beam_inds[tindex],0:rad_raw_data.mplgs[beam_inds[tindex]]-2], $
	ydata_r[beam_inds[tindex],gate,0:rad_raw_data.mplgs[beam_inds[tindex]]-2], $
	thick=linethick, color=30, linestyle=linestyle, psym=-2, symsize=symsize
oplot, xdata[beam_inds[tindex],0:rad_raw_data.mplgs[beam_inds[tindex]]-2], $
	ydata_i[beam_inds[tindex],gate,0:rad_raw_data.mplgs[beam_inds[tindex]]-2], $
	thick=linethick, color=250, linestyle=linestyle, psym=-5, symsize=symsize

; returned the actually used scan_id
if scan_id eq -1 then $
	scan_id = rad_raw_info.scan_ids[(channel-1) > 0]

end
