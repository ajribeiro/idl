;+ 
; NAME: 
; GBM_PLOT_PANEL
; 
; PURPOSE: 
; This procedure plots the time series of a GBM in a panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; GBM_PLOT_PANEL
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
; values are 'bx_geo', 'by_geo', 'bz_geo', and 'bt'. Default is 'bx_geo'.
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
; LAST: Set this keyword to indicate that this is the last panel in a column,
; hence XTITLE and XTICKNAMES will be set.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2009.
;-
pro gbm_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	param=param, $
	yrange=yrange, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, $
	first=first, last=last, with_info=with_info, no_title=no_title, $
	detrend=detrend

common gbm_data_blk
	
if gbm_info.nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if ~keyword_set(param) then $
	param = 'bx_mag'

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
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
	caldat, gbm_data.juls[0], month, day, year
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

; get data
xtag = 'juls'
ytag = param
if ~tag_exists(gbm_data, xtag) then begin
	prinfo, 'Parameter '+xtag+' does not exist in GBM_DATA.'
	return
endif
if ~tag_exists(gbm_data, ytag) then begin
	prinfo, 'Parameter '+ytag+' does not exist in GBM_DATA.'
	return
endif
dd = execute('xdata = gbm_data.'+xtag)
dd = execute('ydata = gbm_data.'+ytag)

; select data to plot
; must fit beam, channel, scan_id, time (roughly) and frequency
juls_inds = where(xdata ge sjul-10.d/1440.d and xdata le fjul+10.d/1440.d, cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for time '+format_time(time)
	return
endif

; get indeces of data to plot
data_inds = where(gbm_data.juls ge sjul-1.d/1440.d and $
		gbm_data.juls le fjul+1.d/1440.d, $
		ndata_inds)

ydata = ydata[data_inds]
xdata = xdata[data_inds]

if keyword_set(detrend) then begin
	ydata = detrend(ydata)
	sstr = textoidl('10^3')
	pp = strpos(_ytitle, sstr)
	if pp ne -1 then begin
		_ytitle = strmid(_ytitle, 0, pp)+strmid(_ytitle, pp+strlen(sstr)+1)
	endif
endif

if ( param eq 'bz_mag' or param eq 'bx_mag' or param eq 'bt_mag' ) and ~keyword_set(detrend) then $
	ydata /= 1e3

if ~keyword_set(yrange) then begin
	if strcmp(get_parameter(), param) then $
		yrange = get_scale() $
	else $
		yrange = [min(ydata),max(ydata)]
endif

; check if format is sardines.
; if yes, loose the x axis information
; unless it is given
fmt = get_format(sardines=sd, tokyo=ty)
if sd and ~keyword_set(last) then begin
	if ~keyword_set(xtitle) then $
		_xtitle = ' '
	if n_elements(xtickformat) eq 0 then $
		_xtickformat = ''
	if n_elements(xtickname) eq 0 then $
		_xtickname = replicate(' ', 60)
endif
if ty and ~keyword_set(first) then begin
	if ~keyword_set(ytitle) then $
		_ytitle = ' '
	if n_elements(ytickformat) eq 0 then $
		_ytickformat = ''
	if n_elements(ytickname) eq 0 then $
		_ytickname = replicate(' ', 60)
endif

; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xrange=xrange, yrange=yrange, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	color=get_foreground()

; overplot data
oplot, xdata, ydata, $
	thick=linethick, color=linecolor, linestyle=linestyle, psym=psym

end
