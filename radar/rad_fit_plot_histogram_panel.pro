pro rad_fit_plot_histogram_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	all=all, beam=beam, tfreq=tfreq, scan_id=scan_id, $
	param=param, scale=scale, binsize=binsize, $
	position=position, with_info=with_info, bar=bar, $
	charthick=charthick, charsize=charsize, $ 
	xrange=xrange, yrange=yrange, ylog=ylog, $
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	silent=silent, $
	last=last, first=first

common rad_data_blk

if rad_fit_info.nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if ~keyword_set(param) then $
	param = get_parameter()

if ~is_valid_parameter(param) then begin
	prinfo, 'Invalid plotting parameter: '+param
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
if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info)

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, rad_fit_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(xtitle) then $
	_xtitle = get_default_title(param) $
else $
	_xtitle = xtitle

if ~keyword_set(xtickformat) then $
	_xtickformat = '' $
else $
	_xtickformat = xtickformat

if ~keyword_set(xtickname) then $
	_xtickname = '' $
else $
	_xtickname = xtickname

if ~keyword_set(ytitle) then $
	_ytitle = 'Counts' $
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

if ~keyword_set(scale) then begin
	if strcmp(get_parameter(), param) then $
		scale = get_scale() $
	else $
		scale = get_default_range(param)
endif

if ~keyword_set(xrange) then $
	xrange = scale

if ~keyword_set(yrange) then $
	yrange = [1,1e6]

if ~keyword_set(binsize) then $
	binsize = 2.

if ~keyword_set(beam) and ~keyword_set(tfreq) and ~keyword_set(scan_id) then $
	all = 1

nbeams = 16.
nfreqs = 9
nbins = (scale[1]-scale[0])/binsize

ytag = param
if ~tag_exists(rad_fit_data, ytag) then begin
	if ~keyword_set(silent) then $
		prinfo, 'Parameter '+ytag+' does not exist in RAD_FIT_DATA.'
	return
endif
s = execute('ydata = rad_fit_data.'+ytag)

; set up coordinate system for plot
plot, [0,0], /nodata, xstyle=5, ystyle=5, $
	yrange=yrange, xrange=xrange, position=position, ylog=ylog

if keyword_set(beam) then begin
	hist = make_array(nbins, nbeams, value=0.001, /float)
	for b=0, nbeams-1 do begin
		binds = where(rad_fit_data.beam eq b, nn)
		if nn lt 10 then $
			continue
		data = ydata[binds, *]
		data = float(reform(data, n_elements(data)))
		hist[*,b] += histogram(data, min=scale[0], max=scale[1], nbins=nbins, loc=loc)
		oplot, loc, hist[*,b], color=get_ncolors()/nbeams*b, psym=10
	endfor
endif

if keyword_set(tfreq) then begin
	hist = make_array(nbins, nfreqs, value=0.001, /float)
	for f=0, nfreqs-1 do begin
		finds = where(rad_fit_data.tfreq/1e3 ge 7.5+f and rad_fit_data.tfreq/1e3 lt 8.5+f, nn)
		if nn lt 10 then $
			continue
		data = ydata[finds, *]
		data = float(reform(data, n_elements(data)))
		hist[*,f] += histogram(data, min=scale[0], max=scale[1], nbins=nbins, loc=loc)
		oplot, loc, hist[*,f], color=get_ncolors()/nfreqs*f, psym=10
	endfor
endif

if keyword_set(scan_id) then begin
	hist = make_array(nbins, nfreqs, value=0.001, /float)
	for s=0, n_elements(rad_fit_info.scan_ids)-1 do begin
		ascan = rad_fit_info.scan_ids[s]
		sinds = where(rad_fit_data.scan_id eq ascan, nn)
		if nn lt 10 then $
			continue
		data = ydata[sinds, *]
		data = float(reform(data, n_elements(data)))
		hist[*,s] += histogram(data, min=scale[0], max=scale[1], nbins=nbins, loc=loc)
		oplot, loc, hist[*,s], color=get_ncolors()/n_elements(scan_ids)*s, psym=10
	endfor
	line_legend, [position[2]-.1, position[1]], string(rad_fit_info.scan_ids,format='(I6)'), $
		color=get_ncolors()/n_elements(rad_fit_info.scan_ids)*indgen(n_elements(rad_fit_info.scan_ids)), charsize=.5
endif

if keyword_set(all) then begin
	hist = make_array(nbins, value=0.001, /float)
	data = float(reform(ydata, n_elements(ydata)))
	hist += histogram(data, min=scale[0], max=scale[1], nbins=nbins, loc=loc)
	oplot, loc, hist, psym=10
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

; "over"plot axis
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=charsize, $ 
	yrange=yrange, xrange=xrange, $
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	color=get_foreground()

end