;+
; NAME: 
; DMS_TRACK_PLOT_HEMISPHERE_PANEL
; 
; PURPOSE:
; This procedure plots color coded represenation of whether the 
; DSMP satellite was in the northern or southern hemisphere.
; 
; CATEGORY:
; DMSP
; 
; CALLING SEQUENCE: 
; DMS_TRACK_PLOT_HEMISPHERE_PANEL
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
; CHARTHICK: The thickness of the characters.
;
; CHARSIZE: The size of the characters.
;
; XSTYLE: The style of the x axis, default is 1.
;
; XTITLE: The title of the x axis, default is 'Time UT'.
;
; XRANGE: The xrange of the plot (time).
;
; XMINOR: The number of minor tickmarks on the x axis.
;
; XTICKS: The number of tickmarks on the x axis.
;
; XTICKNAME: The labels of tickmarks on the x axis.
;
; SILENT: Set this keyword to surpress messages.
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
; LAST: Set this keyword to indicate that this is the last panel in a column,
; hence XTITLE and XTICKNAMES will be set.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels. Of course, this keyword only takes
; effect if you doi not use the position keyword.
;
; NO_TITLE: If this keyword is set, the panel size will be calculated without 
; leaving space for a big title on the page. Of course, this keyword only takes
; effect if you do not use the position keyword.
;
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
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
pro dms_track_plot_hemisphere_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, xtitle=xtitle, $
	xrange=xrange, xticks=xticks, $
	xminor=xminor, $
	xtickname=xtickname, position=position, panel_position=panel_position, $
	last=last, first=first, bar=bar, with_info=with_info, no_title=no_title

common dms_data_blk

if dms_ssj_info.nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif
if ~keyword_set(position) then begin
	tposition = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info, no_title=no_title)
	position = [tposition[0], tposition[3]+0.005, tposition[2], tposition[3]+0.025]
endif
if keyword_set(panel_position) then $
	position = [panel_position[0], panel_position[3]+0.005, panel_position[2], panel_position[3]+0.02]

if ~keyword_set(date) then begin
	caldat, dms_ssj_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0,2400]

sfjul, date, time, sjul, fjul, long=long

if ~keyword_set(xrange) then $
	xrange = [sjul,fjul]

if ~keyword_set(xstyle) then $
	xstyle = 1

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

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(charthick) then $
	charthick = 1.

if ~keyword_set(xticks) then $
	xticks = get_xticks(sjul, fjul, xminor=_xminor)

if keyword_set(xminor) then $
	_xminor = xminor

; check if format is sardines.
; if yes, loose the x axis information
; unless it isgiven
fmt = get_format(sardines=sd, tokyo=ty)
if (sd and ~keyword_set(last)) or keyword_set(info) then begin
	if ~keyword_set(xtitle) then $
		_xtitle = ' '
	if ~keyword_set(xtickformat) then $
		_xtickformat = ''
	if ~keyword_set(xtickname) then $
		_xtickname = replicate(' ', 60)
endif

; get data
xtag = 'juls'
ytag = 'hemi'
if ~tag_exists(dms_ssj_data, xtag) then begin
	prinfo, 'Parameter '+xtag+' does not exist in DMS_SSJ_DATA.'
	return
endif
if ~tag_exists(dms_ssj_data, ytag) then begin
	prinfo, 'Parameter '+ytag+' does not exist in DMS_SSJ_DATA.'
	return
endif
dd = execute('xdata = dms_ssj_data.'+xtag)
dd = execute('ydata = dms_ssj_data.'+ytag)

jinds = where(xdata ge sjul and xdata le fjul, cc)
if cc eq 0L then begin
	prinfo, 'No spectra found for interval '+format_time(time)
	return
endif
xdata = xdata[jinds]
ydata = ydata[jinds]

; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	xstyle=5, ystyle=5, $
	xrange=xrange, yrange=[0,1], $
	color=get_foreground()

uhemis = [0L, uniq(ydata)]
nn = n_elements(uhemis)
if uhemis[nn-1] ne cc-1L then $
	uhemis = [uhemis, cc-1L]
nn = n_elements(uhemis)
for i=0L, nn-2L do begin
	xx = [xdata[uhemis[i]], xdata[uhemis[i+1]], xdata[uhemis[i+1]], xdata[uhemis[i]], xdata[uhemis[i]]]
	yy = [0, 0, 1, 1, 0]
	polyfill, xx, yy, color=80-(1 + ydata[uhemis[i+1]])*30
endfor

; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=1, xtitle=_xtitle, ytitle=' ', $
	xticks=xticks, xminor=_xminor, yticks=1, yminor=1, $
	xrange=xrange, yrange=[0,1], $
	xtickformat=_xtickformat, $
	xticklen=-0.04, $
	xtickname=_xtickname, ytickname=replicate(' ', 60), $
	color=get_foreground()

; print information
xyouts, !x.crange[0], 1.4, 'F'+string(dms_ssj_info.sat,format='(I02)')+': '+format_date(date, /hum), color=get_foreground(), $
	charsize=.7*charsize, charthick=1.5*charthick, $
	align = 0.
xmiddle = (!x.crange[1]+!x.crange[0])/2.d
xoff = .03d*(!x.crange[1]-!x.crange[0])
xyouts, xmiddle+xoff, 1.4, 'blue: Northern Hemisphere', color=20, charsize=.7*charsize, charthick=1.5*charthick, $
	align = 0.
xyouts, xmiddle-xoff, 1.4, 'green: Southern Hemisphere', color=80, charsize=.7*charsize, charthick=1.5*charthick, $
	align = 1.

end
