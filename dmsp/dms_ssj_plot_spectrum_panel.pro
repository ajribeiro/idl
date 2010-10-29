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
	electrons=electrons, ions=ions, mark_interval=mark_interval

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
		scale = [3, 8]
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
juls = xdata[jinds[0:cc-1L]]
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

