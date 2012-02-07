pro rt_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, $
	yrange=yrange, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, panel_position=panel_position, $
	last=last, first=first, with_info=with_info, info=info, no_title=no_title

common rt_data_blk

if n_params() lt 4 then begin
	if ~keyword_set(silent) and ~keyword_set(position) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	if rt_info.nrecs eq 0L then begin
		if ~keyword_set(silent) then begin
			prinfo, 'No data'
		endif
		return
	endif
	caldat, rt_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sjul = rt_info.sjul
fjul = rt_info.fjul
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
	_ytitle = 'Frequency [MHz]' $
else $
	_ytitle = ytitle

if ~keyword_set(ytickformat) then $
	_ytickformat = '' $
else $
	_ytickformat = ytickformat

if ~keyword_set(ytickname) then $
	_ytickname = '' $
else $
	_ytickname = ytickname

if ~keyword_set(position) then begin
	if keyword_set(info) then begin
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, /with_info, no_title=no_title)
		position = [position[0], position[3]+0.03, $
			position[2], position[3]+0.07]
	endif else if keyword_set(panel_position) then $
		position = [panel_position[0], panel_position[3]+0.03, panel_position[2], panel_position[3]+0.07] $
	else $
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info, no_title=no_title)
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

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

if ~keyword_set(yrange) then $
	yrange = get_default_range('tfreq')

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
	charthick=charthick, charsize=(keyword_set(info) ? .6 : 1.)*charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	xrange=xrange, yrange=yrange, $
	color=get_foreground()

; get data
xtag = 'juls'
ytag = 'tfreq'
if ~tag_exists(rt_data, xtag) then begin
	prinfo, 'Parameter '+xtag+' does not exist in RT_DATA.'
	return
endif
if ~tag_exists(rt_data, ytag) then begin
	prinfo, 'Parameter '+ytag+' does not exist in RT_DATA.'
	return
endif
dd = execute('xdata = rt_data.'+xtag)
dd = execute('ydata = rt_data.'+ytag)

; select data to plot
; must fit beam, channel, scan_id, time (roughly)
;
; check first whether data is available for the user selection
; then find data to actually plot
txdata = xdata
juls_inds = where(txdata ge sjul-10.d/1440.d and txdata le fjul+10.d/1440.d, cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for time '+format_time(time)
	return
endif
txdata = 0

; overplot data
oplot, xdata, ydata, $
	thick=linethick, color=linecolor, linestyle=linestyle, psym=psym

end
