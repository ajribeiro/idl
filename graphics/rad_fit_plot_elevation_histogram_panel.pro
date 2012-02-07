pro rad_fit_plot_elevation_histogram_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	param=param, beams=beams, allbeams=allbeams, $
	channel=channel, scan_id=scan_id, $
	normalize=normalize, no_model=no_model, $
	coords=coords, xrange=xrange, yrange=yrange, scale=scale, $
	freq_band=freq_band, silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, $
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, $
	last=last, first=first, with_info=with_info, no_title=no_title, $
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
	param = 'elevation'
if ~strcmp(param, 'elevation', /fold) and ~strcmp(param, 'phi0', /fold) then begin
	prinfo, 'PARAM must be "phi0" or "elevation".'
	return
endif

if n_elements(beams) eq 0 then $
	beams = rad_get_beam()
if keyword_set(allbeams) then $
	beams = indgen(16)
nbeams = n_elements(beams)

if ~keyword_set(coords) then $
	coords = 'gate'
if ~strcmp(coords, 'gate', /fold) and ~strcmp(coords, 'rang', /fold) then begin
	prinfo, 'COORDS must be "gate" or "rang".'
	return
endif

if ~keyword_set(freq_band) then $
	freq_band = get_default_range('tfreq')

if n_params() lt 4 and ~keyword_set(position) then begin
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

if n_elements(xtitle) eq 0 then $
	_xtitle = get_default_title(coords) $
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

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(yrange) then begin
	if strcmp(param, 'elevation', /fold) then $
		_yrange = [0,65] $
	else $
		_yrange = get_default_range(param)
endif else $
	_yrange = yrange

; get data
xtag = 'juls'
ytag = param
if ~tag_exists((*rad_fit_data[data_index]), xtag) then begin
	if ~keyword_set(silent) then $
		prinfo, 'Parameter '+xtag+' does not exist in RAD_FIT_DATA.'
	return
endif
if ~tag_exists((*rad_fit_data[data_index]), ytag) then begin
	if ~keyword_set(silent) then $
		prinfo, 'Parameter '+ytag+' does not exist in RAD_FIT_DATA.'
	return
endif
s = execute('xdata = (*rad_fit_data[data_index]).'+xtag)
s = execute('ydata = (*rad_fit_data[data_index]).'+ytag)

; select data to plot
; must fit beam, channel, scan_id, time (roughly) and frequency
;
; check first whether data is available for the user selection
; then find data to actually plot
beam_inds = where((*rad_fit_data[data_index]).beam eq beams[0], cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for beam '+string(beams[0])
endif
for b=1, nbeams-1 do begin
	tbeam_inds = where((*rad_fit_data[data_index]).beam eq beams[b], tcc)
	if tcc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No data found for beam '+string(beams[b])
	endif else begin
		beam_inds = [beam_inds, tbeam_inds]
		cc += tcc
	endelse
endfor
if cc eq 0 then $
	return
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
	if scan_id eq -1 then $
		return
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
juls_inds = where(txdata ge sjul and txdata le fjul, cc)
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
			' and channel '+string(channel)+' and time '+format_time(time) + $
			' and freq. band '+strjoin(string(freq_band,format='(F4.1)'),'-')
	return
endif
ttfreq = 0

; get indeces of data to plot
if n_elements(channel) ne 0 then begin
	beam_inds = where((*rad_fit_data[data_index]).beam eq beams[0] and $
		(*rad_fit_data[data_index]).channel eq channel and $
		(*rad_fit_data[data_index]).juls ge sjul and $
		(*rad_fit_data[data_index]).juls le fjul and $
		(*rad_fit_data[data_index]).tfreq*0.001 ge freq_band[0] and $
		(*rad_fit_data[data_index]).tfreq*0.001 le freq_band[1], $
		nbeam_inds)
	for b=1, nbeams-1 do begin
		tbeam_inds = where((*rad_fit_data[data_index]).beam eq beams[b] and $
			(*rad_fit_data[data_index]).channel eq channel and $
			(*rad_fit_data[data_index]).juls ge sjul and $
			(*rad_fit_data[data_index]).juls le fjul and $
			(*rad_fit_data[data_index]).tfreq*0.001 ge freq_band[0] and $
			(*rad_fit_data[data_index]).tfreq*0.001 le freq_band[1], $
			tnbeam_inds)
		if tnbeam_inds gt 0 then begin
			beam_inds = [beam_inds, tbeam_inds]
			nbeam_inds += tnbeam_inds
		endif
	endfor
endif else if scan_id ne -1 then begin
	beam_inds = where((*rad_fit_data[data_index]).beam eq beams[0] and $
		(*rad_fit_data[data_index]).scan_id eq scan_id and $
		(*rad_fit_data[data_index]).juls ge sjul and $
		(*rad_fit_data[data_index]).juls le fjul and $
		(*rad_fit_data[data_index]).tfreq*0.001 ge freq_band[0] and $
		(*rad_fit_data[data_index]).tfreq*0.001 le freq_band[1], $
		nbeam_inds)
	for b=1, nbeams-1 do begin
		tbeam_inds = where((*rad_fit_data[data_index]).beam eq beams[b] and $
			(*rad_fit_data[data_index]).scan_id eq scan_id and $
			(*rad_fit_data[data_index]).juls ge sjul and $
			(*rad_fit_data[data_index]).juls le fjul and $
			(*rad_fit_data[data_index]).tfreq*0.001 ge freq_band[0] and $
			(*rad_fit_data[data_index]).tfreq*0.001 le freq_band[1], $
			tnbeam_inds)
		if tnbeam_inds gt 0 then begin
			beam_inds = [beam_inds, tbeam_inds]
			nbeam_inds += tnbeam_inds
		endif
	endfor
endif

ajul = (sjul+fjul)/2.d
caldat, ajul, mm, dd, year
yrsec = (ajul-julday(1,1,year,0,0,0))*86400.d
rad_define_beams, (*rad_fit_info[data_index]).id, (*rad_fit_info[data_index]).nbeams, $
	(*rad_fit_info[data_index]).ngates, year, yrsec, coords=coords, $
	lagfr0=(*rad_fit_data[data_index]).lagfr[beam_inds[0]], smsep0=(*rad_fit_data[data_index]).smsep[beam_inds[0]], $
	fov_loc_full=fov_loc_full, fov_loc_center=fov_loc_center

xdata = reform(fov_loc_center[0, beams[0], 0:n_elements(ydata[0,*])-1])
min1 = min(xdata)
max1 = max(xdata)
bin1 = xdata[2]-xdata[1]
xdata = transpose(rebin(xdata, n_elements(xdata), nbeam_inds))
ydata = ydata[beam_inds, *]

min2 = float(_yrange[0])
max2 = float(_yrange[1])
bin2 = float(_yrange[1]-_yrange[0])/60.
ginds = where(ydata ne 10000., gc)
if gc eq 0 then begin
	prinfo, 'No real data found.'
	return
endif

xdata = xdata[ginds]
ydata = ydata[ginds]

hist = double(hist_2d(xdata, ydata, bin1=bin1, min1=min1, max1=max1, bin2=bin2, min2=min2, max2=max2))
sz = size(hist, /dim)
xvalues = min1 + findgen(sz[0]+1)*bin1
yvalues = min2 + findgen(sz[1]+1)*bin2
if keyword_set(normalize) then begin
	for x=0, sz[0]-1 do begin
		hist[x,*] = hist[x,*]/( total(hist[x,*]) > 1. )
	endfor
endif
inds = where(hist eq 0., ti)
if ti gt 0 then $
	hist[inds] = !values.f_nan

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

if ~keyword_set(scale) then $
	scale = [min(hist, /nan), max(hist, /nan)]

if ~keyword_set(xrange) then $
	xrange = [min1, max1]

draw_image, hist, xvalues, yvalues, position=position, $
	charthick=charthick, charsize=charsize, $
	yrange=_yrange, xrange=xrange, $
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	color=get_foreground(), title=title, range=scale;, no_plot=0

if strcmp(param, 'elevation', /fold) and ~keyword_set(no_model) then begin
	pxx = findgen(15)
	xx = 180. + pxx*45.
	if strcmp(coords, 'rang', /fold) then $
		pxx = xx
	altitudes = [90., 100., 110.]
	for a=0, n_elements(altitudes)-1 do begin
		yy = ( acos( -( (!re + altitudes[a])^2 - xx^2 - !re^2 ) / ( 2.*xx*!re ) ) - !pi/2. )*!radeg
		oplot, pxx, yy, thick=8, color=get_background()
		oplot, pxx, yy, thick=2, color=get_foreground(), linestyle=2
	endfor
endif


end