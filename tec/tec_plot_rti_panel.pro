;+
; NAME:
; TEC_PLOT_RTI_PANEL
;
; PURPOSE:
; This procedure plots the range-time intensity of a TEC
; parameter in a panel.
;
; CATEGORY:
; Graphics
;
; CALLING SEQUENCE:
; TEC_PLOT_RTI_PANEL
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
; the RTI panel.
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
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'mag', 'geo', 'range' and 'gate'.
; Default is 'gate'.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size.
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
; XTICKFORMAT: Set this keyword to a format code to use for formatting of
; the time axis labels. See IDL documentation for LABEL_DATE.
;
; YTICKFORMAT: Set this to a format code to use for the y axis tick labels.
;
; POSITION: Set this keyword to a 4-element vector holding the normalized
; coordinates of the ouput panel. Use this to override internal positioning.
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
; Based on Steve Milan's PLOT_RTI.
; Written by Lasse Clausen, Nov, 24 2009
; Modified by Evan Thomas, April, 8 2011
;-
pro tec_plot_rti_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	param=param, beam=beam, medianf=medianf, $
	coords=coords, yrange=yrange, scale=scale, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, $
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, athreshold=athreshold, $
	last=last, first=first, with_info=with_info, no_title=no_title, $
	title=title, startjul=startjul, name=name, rscale=rscale, sun=sun

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

if ~keyword_set(coords) then $
	coords = get_coordinates()

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

if n_elements(ytitle) eq 0 then $
	_ytitle = get_default_title(coords) $
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

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(yrange) then $
	yrange = get_default_range(coords)

if ~keyword_set(xticks) then $
	xticks = get_xticks(sjul, fjul, xminor=_xminor)

if keyword_set(xminor) then $
	_xminor = xminor

; Determine maximum width to plot scan - to decide how big a 'data gap' has to
; be before it really is a data gap.  Default to 5 minutes
if ~keyword_set(max_gap) then $
	max_gap = 5.

ajul = (sjul+fjul)/2.d
caldat, ajul, mm, dd, year, hh, ii, ss
yrsec = (ajul-julday(1,1,year,0,0,0))*86400.d


ind = where(network[*].code[0] eq name, cc)
if cc eq 0 then begin
		prinfo, 'Radar '+name+' not found.'
	return
endif

site = radarymdhmsgetsite(network[ind], year, mm, dd, hh, ii, ss)
check_struc = size(site)

if check_struc[2] ne 8 then begin
	prinfo,'This radar did not exist for the loaded date.'
	startjul=0
	return
endif

id = network[ind].id
nbeams = site.maxbeam
ngates = site.maxrange
bmsep = site.bmsep

; set up coordinate system for plot
plot, [0,0], /nodata, xstyle=5, ystyle=5, $
	yrange=yrange, xrange=xrange, position=position

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
		if ~keyword_set(silent) then $
			prinfo, 'Parameter '+xtag+' does not exist in TEC_DATA.'
		return
	endif
	if ~tag_exists(tec_data, ytag) then begin
		if ~keyword_set(silent) then $
			prinfo, 'Parameter '+ytag+' does not exist in TEC_DATA.'
		return
	endif
	s = execute('xdata = tec_data.'+xtag)
	s = execute('ydata = tec_data.'+ytag)
endelse

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
yvalues=fltarr(n_elements(tmp),ngates)
xvalues=dblarr(n_elements(tmp))
lat_ind=intarr(n_elements(tmp),ngates)
lon_ind=intarr(n_elements(tmp),ngates)

; get color preferences
foreground  = get_foreground()
color_steps = get_colorsteps()
ncolors     = get_ncolors()
bottom      = get_bottom()

if keyword_set(medianf) then begin
	for i=0, n_elements(tmp)-1 do begin
		map_inds = where(map_no eq map_no[bm_inds[tmp[i]]], nc)
		
		xvalues[i] = xdata[map_inds[0]]

		; cycle through ranges
		for r=0,ngates-2 do begin
			if fov_loc_center(0,beam,r) gt 84.0 then $
				continue
		
			dlat = min(abs(lats-fov_loc_center(0,beam,r)),minind1)
			dlon = min(abs(lons-fov_loc_center(1,beam,r)),minind2)
			dist = sqrt(dlat^2 + dlon^2)

			if dist le 1.1 then $
				yvalues[i,r] = ydata[minind1,minind2,i] $
			else $
				yvalues[i,r] = -1.

			lat_ind[i,r] = minind1
			lon_ind[i,r] = minind2

			if yvalues[i,r] eq 0. then $
				yvalues[i,r] = -1.
		endfor
	endfor
endif else begin
	for i=0, n_elements(tmp)-1 do begin
		map_inds = where(map_no eq map_no[bm_inds[tmp[i]]], nc)

		xvalues[i] = xdata[map_inds[0]]
		; cycle through ranges
		FOR r=0, ngates-1 DO BEGIN

;		if fov_loc_center[0,beam,r+1] lt yrange[0] or fov_loc_center[0,beam,r] gt yrange[1] then $
;			continue

			dist = min(sqrt((lats[map_inds]-fov_loc_center(0,beam,r))^2 + (lons[map_inds]-fov_loc_center(1,beam,r))^2), minind)

			if dist le 1 then $	
				yvalues[i,r] = ydata[map_inds[minind]] $
			else $
				yvalues[i,r] = -1.
		ENDFOR
	endfor
endelse

; Set color bar and levels
if ~keyword_set(scale) then $
	_scale = [0,round(max(yvalues))] $
else $
	_scale = scale

cin =    FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = _scale[0]+FINDGEN(color_steps)*(_scale[1]-_scale[0])/color_steps

 rad_define_beams, id, nbeams, $
 	ngates, year, yrsec, coords=coords, $
 	/normal, fov_loc_full=fov_loc_full, fov_loc_center=fov_loc_center

for i=0, n_elements(tmp)-1 do begin
	; cycle through ranges
	FOR r=0, ngates-1 DO BEGIN
		caldat,xvalues[i],smonth,sday,syear,shour,sminute,ssecond

		stime = 10000*shour+100*(sminute-2)+(ssecond-30)
		ftime = 10000*shour+100*(sminute+2)+(ssecond+30)

		sfjul,date,[stime,ftime],start_time,end_time,/long

		; only plot points with real data in it
		IF yvalues[i,r] ne -1. THEN BEGIN

			; get color
			color_ind = (MAX(where(lvl le ((yvalues[i,r] > _scale[0]) < _scale[1]))) > 0)
			col = cin[color_ind]

			; finally plot the point
			POLYFILL,[start_time,start_time,end_time,end_time], $
					[fov_loc_center[0,beam,r],fov_loc_center[0,beam,r+1], $
						fov_loc_center[0,beam,r+1],fov_loc_center[0,beam,r]], $
					COL=col,NOCLIP=0
		ENDIF
	ENDFOR
endfor

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

; "over"plot axis
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=charsize, $
	yrange=yrange, xrange=xrange, $
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	color=get_foreground(), title=title, $
	xticklen=-!p.ticklen, yticklen=-!p.ticklen

; "return" the date/time of the plotted scan and scale used
startjul = xvalues[0]
rscale = _scale
if keyword_set(medianf) then $
	athreshold = median_info.thresh

end
