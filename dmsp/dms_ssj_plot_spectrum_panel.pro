;+
; NAME: 
; DMS_SSJ_PLOT_SPECTRUM_PANEL
; 
; PURPOSE:
; This procedure plots a ion or electron spectrum
; for the currently loaded DMSP SSJ/4 data.
; 
; CATEGORY:
; DMSP
; 
; CALLING SEQUENCE: 
; DMS_SSJ_PLOT_SPECTRUM_PANEL
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
; SCALE: The scale of the ion/electron flux.
;
; SILENT: Set this keyword to surpress messages.
;
; CHARTHICK: The thickness of the characters.
;
; CHARSIZE: The size of the characters.
;
; XSTYLE: The style of the x axis, default is 1.
;
; YSTYLE: The style of the y axis, default is 1.
;
; XTITLE: The title of the x axis, default is 'Time UT'.
;
; YTITLE: The title of the y axis, default is 'Energy [eV]'.
;
; XRANGE: The xrange of the spectrum (time).
;
; YRANGE: The yrange of the spectrum (energies).
;
; XMINOR: The number of minor tickmarks on the x axis.
;
; YMINOR: The number of minor tickmarks on the y axis.
;
; XTICKS: The number of tickmarks on the x axis.
;
; YTICKS: The number of tickmarks on the y axis.
;
; XTICKFORMAT: The format of tickmarks on the x axis.
;
; YTICKFORMAT: The format of tickmarks on the y axis.
;
; XTICKNAME: The labels of tickmarks on the x axis.
;
; YTICKNAME: The labels of tickmarks on the y axis.
;
; POSITION: Set this keyword to a 4-element vector of normalized coordinates 
; if you want to override the internal
; positioning calculations.
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
; ELECTRONS: Set this keyword to plot the electron spectrum (default).
;
; IONS: Set this keyword to plot the ion spectrum.
;
; MARK_INTERVAL: The time step between time markers on the spectrum, 
; in (decimal) hours. To set it to 2 minutes, set MARK_INTERVAL to 2./60.
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
pro dms_ssj_plot_spectrum_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	scale=scale, silent=silent, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xrange=xrange, yrange=yrange, xticks=xticks, yticks=yticks, $
	xminor=xminor, yminor=yminor, $
	ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, position=position, $
	last=last, first=first, bar=bar, with_info=with_info, no_title=no_title, $
	electrons=electrons, ions=ions, mark_interval=mark_interval, $
	no_hemi_marker=no_hemi_marker

common dms_data_blk

if dms_ssj_info.nrecs eq 0L then begin
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

if ~keyword_set(date) then begin
	caldat, dms_ssj_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0,2400]

sfjul, date, time, sjul, fjul, long=long

if ~keyword_set(xrange) then $
	xrange = [sjul,fjul]

if ~keyword_set(electrons) and ~keyword_set(ions) then $
	electrons = 1

if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info, no_title=no_title)

if ~keyword_set(scale) then begin
	if keyword_set(electrons) then $
		scale = [5,10] $
	else $
		scale = [4, 8]
endif

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

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

if ~keyword_set(ytitle) then $
	_ytitle = 'Log Energy [eV]' $
else $
	_ytitle = ytitle

if keyword_set(ytickname) then $
	_ytickname = ytickname

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(xticks) then $
	xticks = get_xticks(sjul, fjul, xminor=_xminor)

if keyword_set(xminor) then $
	_xminor = xminor

if ~keyword_set(mark_interval) then $
	mark_interval = -1

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
if ty and ~keyword_set(first) then begin
	if ~keyword_set(ytitle) then $
		_ytitle = ' '
	if ~keyword_set(ytickformat) then $
		_ytickformat = ''
	if ~keyword_set(ytickname) then $
		_ytickname = replicate(' ', 60)
endif

; set up coordinate system for plot
;plot, [0,0], /nodata, position=position, $
;	charthick=charthick, charsize=charsize, $ 
;	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
;	xtickformat=xtickformat, ytickformat=ytickformat, $
;	xtickname=_xtickname, ytickname=_ytickname, $
;	xrange=xrange, yrange=yrange, $
;	color=get_foreground()

bottom = get_bottom()
ncolors = get_ncolors()
color = get_foreground()

; get data
xtag = 'juls'
if keyword_set(electrons) then $
	ytag = 'deflux' $
else $
	ytag = 'diflux'
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
juls = xdata[jinds]
dt = mean(deriv((juls-juls[0])*1440.d))

image = float(reform(ydata[jinds[0:cc-2L],*]))
ginds = where(image gt 0., ng)
if ng gt 0L then $
	image[ginds] = alog10(image[ginds])

if keyword_set(electrons) then begin
	energies = alog10([ reform((*dms_ssj_info.calibration).eeng - (*dms_ssj_info.calibration).ewid/2.), (*dms_ssj_info.calibration).eeng[0,18] + (*dms_ssj_info.calibration).ewid[0,18]/2.])
	if ~keyword_set(yrange) then $
		yrange = [min(energies), max(energies)]
endif else begin
	energies = alog10(reverse([ reform((*dms_ssj_info.calibration).ieng - (*dms_ssj_info.calibration).iwid/2.), (*dms_ssj_info.calibration).ieng[0,18] + (*dms_ssj_info.calibration).iwid[0,18]/2.]))
	if ~keyword_set(yrange) then $
		yrange = [max(energies), min(energies)]
	image = reverse(image, 2)
endelse

draw_image, image, juls, energies, range=scale, $
	bottom=bottom, ncolors=ncolors, position=position, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	xrange=xrange, yrange=yrange, $
	color=color, no_plot=0

; draw a little indicator for the hemisphere above the panel
if ~keyword_set(no_hemi_marker) then begin
	for i=0L, n_elements(juls)-2 do begin
		if juls[i] lt !x.crange[0] then $
			continue
		if juls[i+1] gt !x.crange[1] then $
			break
		polyfill, juls[i+[0,1,1,0]], !y.crange[1]+[0.4,0.4,1.,1.]*.025*(!y.crange[1]-!y.crange[0]), $
			color=(dms_ssj_data.hemi[jinds[i]] eq -1 ? 230 : 20)
	endfor
endif

if mark_interval ne -1 then begin
	mark_every = round(mark_interval*60./dt)
	n_lines = n_elements(juls)/mark_every+1L
	ind_lines = (lindgen(n_lines)*mark_every) < (cc-1L)
	mark_every = floor(230./n_lines)
	for i=0, n_lines-1 do begin
		oplot, replicate(juls[ind_lines[i]], 2), !y.crange, $
			color=get_gray(), $
			noclip=0, thick=3, linestyle=2
	endfor
endif

;stop
end

