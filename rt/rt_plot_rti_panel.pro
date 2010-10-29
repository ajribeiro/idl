pro rt_plot_rti_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, $
	param=param, $
	coords=coords, yrange=yrange, scale=scale, $
	freq_band=freq_band, silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, ground=ground, trend=trend, $
	last=last, first=first, with_info=with_info, no_title=no_title
	
common	rt_data_blk

if ~keyword_set(coords) then $
	coords = get_coordinates()

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
	caldat, rt_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul
xrange = [sjul, fjul]

if ~keyword_set(xtitle) then $
	_xtitle = 'Time '+rt_info.timez $
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
	_ytitle = 'Gate' $
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

if ~keyword_set(ground) then $
	ground = -1

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(scale) then begin
	if strcmp(get_parameter(), param) then $
		scale = get_scale() $
	else $
		scale = get_default_range(param)
endif

if ~keyword_set(yrange) then $
	yrange = get_default_range(coords)

if ~keyword_set(xticks) then $
	xticks = get_xticks(sjul, fjul, xminor=_xminor)

if keyword_set(xminor) then $
	_xminor = xminor

; Determine maximum width to plot scan - to decide how big a 'data gap' has to
; be before it really is a data gap.  Default to 5 minutes
if ~keyword_set(max_gap) then $
	max_gap = 120.

; set up coordinate system for plot
plot, [0,0], /nodata, xstyle=5, ystyle=5, $
	yrange=yrange, xrange=xrange, position=position

; get data
xtag = 'juls'
ytag = param
s = execute('xdata = rt_data.'+xtag)
s = execute('ydata = rt_data.'+ytag)

; select data to plot
; must fit beam, channel, scan_id, time (roughly) and frequency
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

old_lagfr = 0
old_smsep = 0

; get color preferences
foreground  = get_foreground()
color_steps = get_colorsteps()
ncolors     = get_ncolors()
bottom      = get_bottom()

; Set color bar and levels
cin =    FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps
IF param EQ 'velocity' THEN $
	cin = shift(cin, color_steps/2)
;	cin = ROTATE(cin, 2)

; Add final elements for full plots
tsteps = n_elements(xdata)
xdata = [xdata, xdata[tsteps-1]+1]
range_fov = [rt_info.fov_loc_center, rt_info.fov_loc_center[tsteps-1]+1]

if keyword_set(trend) AND param eq 'power' then begin
	trendARR = dindgen(nbeam_inds-1L,2)
endif

; overplot data
; Cycle through beams to plot
FOR b=0, tsteps-1 DO BEGIN
	start_time = xdata[b]
	end_time = MIN( [xdata[b+1], start_time+max_gap/1440.d] )
; 	CALDAT, start_time, Month , Day , Year, Hour, min
; 	print, 'sart' , Year , Month , Day, Hour, min
; 	CALDAT, end_time, Month , Day , Year, Hour, min
; 	print, 'end' , Year , Month , Day, Hour, min
	; cycle through ranges
	FOR r=0, rt_info.ngates-1 DO BEGIN

		; only plot points with real data in it
		IF ydata[b,r] gt 0 THEN BEGIN

			; get color
			color_ind = (MAX(where(lvl le ((ydata[b,r] > scale[0]) < scale[1]))) > 0)
			col = cin[color_ind]
			
			; finally plot the point
			POLYFILL,[start_time,start_time,end_time,end_time], $
					[(rt_info.fov_loc_center)[r],(rt_info.fov_loc_center)[r+1], $
						(rt_info.fov_loc_center)[r+1], (rt_info.fov_loc_center)[r]], $
					COL=col,NOCLIP=0

		ENDIF
	ENDFOR

	; create trend over one beam index
	; average power trend over all range gate
	; use power as weighing function
	if keyword_set(trend) AND param eq 'power' then begin
		tr = findgen((*rad_fit_info[data_index]).ngates)
		trinds = where(ydata[beam_inds[b],*] ne 10000. AND tr[*] gt 10.)
		IF trinds[0] GE 0. THEN $
			trdata = ROUND(TOTAL(ydata[beam_inds[b],trinds]*tr[trinds])/TOTAL(ydata[beam_inds[b],trinds])) $
		ELSE $
			trdata = 0L

		; update trend array
		trendARR[b,0] = start_time
		trendARR[b,1] = fov_loc_center[0,beam,trdata]

; 		POLYFILL,[start_time,start_time,end_time,end_time], $
; 			[fov_loc_center[0,beam,trdata],fov_loc_center[0,beam,trdata+1], $
; 				fov_loc_center[0,beam,trdata+1],fov_loc_center[0,beam,trdata]], $
; 				COL=get_black(),NOCLIP=0
	endif

ENDFOR

if keyword_set(trend) AND param eq 'power' then begin
	oplot, trendARR[*,0], trendARR[*,1], thick=2, min_value=10, nsum=5, max_value=65
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
