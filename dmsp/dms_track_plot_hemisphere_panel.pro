pro dms_track_plot_hemisphere_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, xtitle=xtitle, $
	xrange=xrange, xticks=xticks, $
	xminor=xminor, $
	xtickname=xtickname, position=position, panel_position=panel_position, $
	last=last, first=first, bar=bar, with_info=with_info, no_title=no_title

common dms_data_blk

if dms_ssj_info.nrecs eq 0L then begin
	if ~keyword_set(silent) then $
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
if ~keyword_set(position) then begin
	tposition = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info, no_title=no_title)
	position = [tposition[0], tposition[3]+0.005, tposition[2], tposition[3]+0.025]
endif
if keyword_set(panel_position) then $
	position = [panel_position[0], panel_position[3]+0.005, panel_position[2], panel_position[3]+0.02]

if ~keyword_set(date) then begin
	caldat, dms_ssj_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0,2400]

sfjul, date, time, sjul, fjul, long=long

if ~keyword_set(xrange) then $
	xrange = [sjul,fjul]

if ~keyword_set(xstyle) then $
	xstyle = 1

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

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(charthick) then $
	charthick = 1.

if ~keyword_set(xticks) then $
	xticks = get_xticks(sjul, fjul, xminor=_xminor)

if keyword_set(xminor) then $
	_xminor = xminor

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

; get data
xtag = 'juls'
ytag = 'hemi'
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
xdata = xdata[jinds]
ydata = ydata[jinds]

; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	xstyle=5, ystyle=5, $
	xrange=xrange, yrange=[0,1], $
	color=get_foreground()

uhemis = [0L, uniq(ydata)]
nn = n_elements(uhemis)
if uhemis[nn-1] ne cc-1L then $
	uhemis = [uhemis, cc-1L]
nn = n_elements(uhemis)
for i=0L, nn-2L do begin
	xx = [xdata[uhemis[i]], xdata[uhemis[i+1]], xdata[uhemis[i+1]], xdata[uhemis[i]], xdata[uhemis[i]]]
	yy = [0, 0, 1, 1, 0]
	polyfill, xx, yy, color=80-(1 + ydata[uhemis[i+1]])*30
endfor

; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=1, xtitle=_xtitle, ytitle=' ', $
	xticks=xticks, xminor=_xminor, yticks=1, yminor=1, $
	xrange=xrange, yrange=[0,1], $
	xtickformat=_xtickformat, $
	xticklen=-0.04, $
	xtickname=_xtickname, ytickname=replicate(' ', 60), $
	color=get_foreground()

; print information
xyouts, !x.crange[0], 1.4, 'F'+string(dms_ssj_info.sat,format='(I02)')+': '+format_date(date, /hum), color=get_foreground(), $
	charsize=.7*charsize, charthick=1.5*charthick, $
	align = 0.
xmiddle = (!x.crange[1]+!x.crange[0])/2.d
xoff = .03d*(!x.crange[1]-!x.crange[0])
xyouts, xmiddle+xoff, 1.4, 'blue: Northern Hemisphere', color=20, charsize=.7*charsize, charthick=1.5*charthick, $
	align = 0.
xyouts, xmiddle-xoff, 1.4, 'green: Southern Hemisphere', color=80, charsize=.7*charsize, charthick=1.5*charthick, $
	align = 1.

end