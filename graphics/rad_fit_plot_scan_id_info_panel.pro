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
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2009.
;-
pro rad_fit_plot_scan_id_info_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	beam=beam, channel=channel, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, $ 
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, $
	xtickname=xtickname, $
	position=position, panel_position=panel_position, $
	first=first, last=last, with_info=with_info, no_title=no_title

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
	position = [tposition[0], tposition[3]+0.005, tposition[2], tposition[3]+0.025]
endif
if keyword_set(panel_position) then $
	position = [panel_position[0], panel_position[3]+0.005, panel_position[2], panel_position[3]+0.02]

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
	_ytitle = ' ' $
else $
	_ytitle = ytitle

if n_elements(channel) eq 0 then $
	channel = (*rad_fit_info[data_index]).channels[0]

yrange = [0,1]

if ~keyword_set(xstyle) then $
	xstyle = 1

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

; check if format is sardines.
; if yes, loose the x axis information
; unless it is given
fmt = get_format(sardines=sd, tokyo=ty)
if ~keyword_set(last) then begin
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
endif
	
; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=1, yminor=1, $
	xrange=xrange, yrange=[0,1], $
	xtickformat=_xtickformat, $
	xtickname=_xtickname, ytickname=replicate(' ', 60), $
	color=get_foreground()

uscanids = uniq(ydata)
nn = n_elements(uscanids)
oplot, replicate(xdata[0], 2), [0,1], color=linecolor, thick=linethick, linestyle=linestyle
xyouts, xdata[0], 0.1, strtrim(string(ydata[0]),2), /data, charsize=charsize, charthick=charthick
if nn gt 1 then begin
	for i=0L, nn-1L do begin
		oplot, replicate(xdata[(uscanids[i]+1L) < (nbeam_inds-1L)], 2), [0,1], $
			color=linecolor, thick=linethick, linestyle=linestyle
		xyouts, xdata[(uscanids[i]+1L) < (nbeam_inds-1L)], 0.1+(i mod 2)*.5, $
			strtrim(string(ydata[(uscanids[i]+1L) < (nbeam_inds-1L)]),2), /data, $
			charsize=charsize, charthick=charthick
	endfor
endif

end
