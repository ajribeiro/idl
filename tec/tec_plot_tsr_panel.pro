;+ 
; NAME: 
; TEC_PLOT_TSR_PANEL
; 
; PURPOSE: 
; This procedure plots the time series of a TEC parameter in a panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; TEC_PLOT_TSR_PANEL
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
; NAME: Set this keyword to specify the radar name for which to plot
; the time series.
;
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; TIME: A 2-element vector giving the time range to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'tec' and 'dtec' (error). Default is 'tec'.
;
; MEDIANF: Set this keyword to plot median filtered TEC data.
;
; BEAM: Set this keyword to specify the beam number from which to plot
; the time series.
;
; GATE: Set this keyword to specify the gate number from which to plot
; the time series.
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
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; COMMON BLOCKS:
; TEC_DATA_BLK: The common block holding TEC data.
; RADARINFO: The common block holding radar info.
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
; Modified by Evan Thomas, April, 11 2011
;-
pro tec_plot_tsr_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	param=param, beam=beam, gate=gate, $
	yrange=yrange, silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, exclude=exclude, athreshold=athreshold, $
	first=first, last=last, with_info=with_info, no_title=no_title, $
	title=title, startjul=startjul, name=name, medianf=medianf

common tec_data_blk
common radarinfo

	
if tec_info.nrecs eq 0L then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No TEC data available.'
	endif
	return
endif

if ~keyword_set(param) then $
	param = 'tec'

if n_elements(beam) eq 0 then $
	beam = rad_get_beam()

if n_elements(gate) eq 0 then $
	gate = rad_get_gate()

if n_elements(gate) gt 2 then begin
	prinfo, 'GATE must be scalar or 2-element vector.'
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
if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info, no_title=no_title)

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, tec_data.juls[0], month, day, year
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

if n_elements(ytitle) eq 0 then begin
	if strcmp(strlowcase(param), 'tec') then $
		_ytitle = 'TEC [TECU]' $
	else if strcmp(strlowcase(param), 'dtec') then $
		_ytitle = 'Error [DTECU]'
endif

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

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

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

if ~keyword_set(exclude) then $
	exclude = [-10000.,10000.]

; get data
xtag = 'juls'
if keyword_set(medianf) then begin
	ytag = 'medarr'
	if ~tag_exists(tec_median, xtag) then begin
		if ~keyword_set(silent) then $
			prinfo, 'Parameter '+xtag+' does not exist in TEC_MEDIAN.'
		return
	endif
	if ~tag_exists(tec_median, ytag) then begin
		if ~keyword_set(silent) then $
			prinfo, 'Parameter '+ytag+' does not exist in TEC_MEDIAN.'
		return
	endif
	s = execute('xdata = tec_median.'+xtag)
	s = execute('ydata = tec_median.'+ytag)
endif else begin
	ytag = param
	if ~tag_exists(tec_data, xtag) then begin
		prinfo, 'Parameter '+xtag+' does not exist in TEC_DATA.'
		return
	endif
	if ~tag_exists(tec_data, ytag) then begin
		prinfo, 'Parameter '+ytag+' does not exist in TEC_DATA.'
		return
	endif
	dd = execute('xdata = tec_data.'+xtag)
	dd = execute('ydata = tec_data.'+ytag)
endelse


ajul = (sjul+fjul)/2.d
caldat, ajul, mm, dd, year, hh, ii, ss
yrsec = (ajul-julday(1,1,year,0,0,0))*86400.d


ind = where(network[*].code[0] eq name, cc)
if cc eq 0 then begin
		prinfo, 'Radar '+name+' not found.'
	return
endif

site = radarymdhmsgetsite(network[ind], year, mm, dd, hh, ii, ss)
id = network[ind].id
nbeams = site.maxbeam
ngates = site.maxrange
bmsep = site.bmsep

if keyword_set(medianf) then $
	rad_define_beams, id, nbeams, ngates, year, yrsec, /normal, $
		fov_loc_center=fov_loc_center, coords='magn' $
else $
	rad_define_beams, id, nbeams, ngates, year, yrsec, /normal, $
		fov_loc_center=fov_loc_center, coords='geog'

if keyword_set(medianf) then begin
	juls = tec_median.juls
	lats = tec_median.lats
	lons = tec_median.lons
	for i=0,n_elements(lons)-1 do $
		if lons[i] gt 180. then lons[i]=lons[i]-360.
	map_no = tec_median.map_no
endif else begin
	juls = tec_data.juls
	lats = tec_data.glat
	lons = tec_data.glon
	map_no = tec_data.map_no
endelse

; get indices of data to plot
bm_inds = where(juls ge sjul and juls le fjul, inds)
if inds lt 1 then begin
	prinfo, 'No data found for time range.'
	return
endif
tmp = uniq(map_no[bm_inds])
yvalues=fltarr(n_elements(tmp))
xvalues=dblarr(n_elements(tmp))


if keyword_set(medianf) then begin
	for i=0, n_elements(tmp)-1 do begin
		map_inds = where(map_no eq map_no[bm_inds[tmp[i]]], nc)

		xvalues[i] = xdata[map_inds[0]]

		dlat = min(abs(lats-fov_loc_center(0,beam,gate[0])),minind1)
		dlon = min(abs(lons-fov_loc_center(1,beam,gate[0])),minind2)
		dist = sqrt(dlat^2 + dlon^2)

		if dist le 1.1 then $
			yvalues[i] = ydata[minind1,minind2,i] $
		else $
			yvalues[i] = !values.f_nan

		if yvalues[i] eq 0. then $
			yvalues[i] = !values.f_nan
	endfor
endif else begin
	for i=0, n_elements(tmp)-1 do begin
		map_inds = where(map_no eq map_no[bm_inds[tmp[i]]], nc)

		dist = min(sqrt((lats[map_inds]-fov_loc_center(0,beam,gate[0]))^2 + (lons[map_inds]-fov_loc_center(1,beam,gate[0]))^2), minind)

		xvalues[i] = xdata[map_inds[minind]]
		if dist le 1 then $	
			yvalues[i] = ydata[map_inds[minind]] $
		else $
			yvalues[i] = !values.f_nan
	endfor
endelse


ninds = where(yvalues eq -1.0, nc, ncomplement=gc)
if gc eq 0L then begin
	prinfo, 'No valid data found.'
	return
endif
if nc ne 0L then $
	yvalues[ninds] = !values.f_nan

if ~keyword_set(yrange) then $
	_yrange = [0,max(yvalues, /nan)] $
else $
	_yrange = yrange

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
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xrange=xrange, yrange=_yrange, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	color=get_foreground(), title=title

; overplot data
oplot, xvalues, yvalues, $
	thick=linethick, color=linecolor, linestyle=linestyle, psym=psym, min_value=exclude[0], max_value=exclude[1]

; "return" the date/time of the plotted scan
startjul = xvalues[0]
if keyword_set(medianf) then $
	athreshold = median_info.thresh

end
