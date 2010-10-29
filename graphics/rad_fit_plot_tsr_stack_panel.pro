;+ 
; NAME: 
; RAD_FIT_PLOT_TSR_STACK_PANEL
; 
; PURPOSE: 
; This procedure plots stacked time series of a radar parameter in a panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_TSR_STACK_PANEL
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
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; BEAM: Set this keyword to specify the beam number from which to plot
; the time series.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn', 'geog', 'range' and 'gate'.
; Default is 'gate'.
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
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2009.
;-
pro rad_fit_plot_tsr_stack_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	param=param, beam=beam, gates=gates, $
	channel=channel, scan_id=scan_id, $
	freq_band=freq_band, coords=coords, yrange=yrange, $
	silent=silent, bar=bar, offset=offset, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	linestyle=linestyle, linethick=linethick, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, exclude=exclude, $
	first=first, last=last, with_info=with_info, no_title=no_title, $
	title=title

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

if ~keyword_set(param) then $
	param = get_parameter()

if ~is_valid_parameter(param) then begin
	prinfo, 'Invalid plotting parameter: '+param
	return
endif

if n_elements(beam) eq 0 then $
	beam = rad_get_beam()

if n_elements(gates) eq 0 then $
	gates = indgen((*rad_fit_info[data_index]).ngates)
ngates = n_elements(gates)

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
	_ytitle = get_default_title(param) $
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
	channel = (*rad_fit_info[data_index]).channels[0]
endif

if ~keyword_set(psym) then $
	psym = -4

if ~keyword_set(symsize) then $
	symsize = .3

if n_elements(offset) eq 0 then $
	offset = 10.

if ~keyword_set(yrange) then begin
	if strcmp(get_parameter(), param) then $
		yrange = get_scale() $
	else $
		yrange = get_default_range(param)
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
	linethick = !p.thick

if ~keyword_set(xticks) then $
	xticks = get_xticks(sjul, fjul, xminor=_xminor)

if keyword_set(xminor) then $
	_xminor = xminor

if ~keyword_set(exclude) then $
	exclude = [-10000.,10000.]

; get data
xtag = 'juls'
ytag = param
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
ttfreq = (*rad_fit_data[data_index]).tfreq[beam_inds]
tscani = (*rad_fit_data[data_index]).scan_id[beam_inds]
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
juls_inds = where(txdata ge sjul-10.d/1440.d and txdata le fjul+10.d/1440.d, cc)
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
	beam_inds = where((*rad_fit_data[data_index]).beam eq beam and $
		(*rad_fit_data[data_index]).channel eq channel and $
		(*rad_fit_data[data_index]).juls ge sjul-10.d/1440.d and $
		(*rad_fit_data[data_index]).juls le fjul+10.d/1440.d and $
		(*rad_fit_data[data_index]).tfreq*0.001 ge freq_band[0] and $
		(*rad_fit_data[data_index]).tfreq*0.001 le freq_band[1], $
		nbeam_inds)
endif else if scan_id ne -1 then begin
	beam_inds = where((*rad_fit_data[data_index]).beam eq beam and $
		(*rad_fit_data[data_index]).scan_id eq scan_id and $
		(*rad_fit_data[data_index]).juls ge sjul-10.d/1440.d and $
		(*rad_fit_data[data_index]).juls le fjul+10.d/1440.d and $
		(*rad_fit_data[data_index]).tfreq*0.001 ge freq_band[0] and $
		(*rad_fit_data[data_index]).tfreq*0.001 le freq_band[1], $
		nbeam_inds)
endif
if nbeam_inds lt 1 then begin
	prinfo, 'No data found for beam '+string(beam)
	return
endif

ydata = ydata[beam_inds,*]
ninds = where(ydata eq 10000., nc, ncomplement=gc)
if gc eq 0L then begin
	prinfo, 'No valid data found.'
	return
endif
if nc ne 0L then $
	ydata[ninds] = !values.f_nan
 
xdata = xdata[beam_inds]

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

; adjust yrange
yrange = [yrange[0], yrange[1]+(ngates-1.)*offset]

; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xrange=xrange, yrange=yrange, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	color=get_foreground(), title=title

; overplot data
; cycle through ranges
FOR r=0, ngates-1 DO BEGIN
	yoff = (gates[r]-gates[0])*offset
	oplot, !x.crange, replicate(yoff, 2),color=get_ncolors()*r/float(ngates), linestyle=2
	oplot, xdata, ydata[*,gates[r]]+yoff, color=get_ncolors()*r/float(ngates), psym=psym, symsize=symsize, $
		thick=linethick, linestyle=linestyle, min_value=exclude[0]+yoff, max_value=exclude[1]+yoff
endfor

; returned the actually used scan_id
if scan_id eq -1 then $
	scan_id = (*rad_fit_info[data_index]).scan_ids[(channel-1) > 0]

end
