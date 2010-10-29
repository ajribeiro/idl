;+ 
; NAME: 
; RAD_FIT_PLOT_LTI_PANEL
; 
; PURPOSE: 
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
;
; INPUTS:
; Latitude: The geographic or magnetic latitude at which to plot 
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
; RANGE: Set this keyword to specify the range number from which to plot
; the time series. ***Removed***
;
; COORDS: Set this keyword to specify coordinate system of the latitude 
; you want to plot.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
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
; LINESTYLE: Set this keyword to change the style of the line.
; Default is 0 (solid).
;
; LINECOLOR: Set this keyword to a color index to change the color of the line.
; Default is black.
;
; LINETHICK: Set this keyword to change the thickness of the line.
; Default is 1.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
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
; LAST: Set this keyword to indicate that this is the last panel in a column,
; hence XTITLE and XTICKNAMES will be set.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_RTI.
; Written by Lasse Clausen, Nov, 24 2009
; Edited by Evan Thomas to plot by latitude, Feb, 2 2010
;-
pro rad_fit_plot_lti_panel, latitude, xmaps, ymaps, xmap, ymap,  $
	date=date, time=time, long=long, $
	param=param, channel=channel, scan_id=scan_id, $
	xrange=xrange, scale=scale, coords=coords, $
	freq_band=freq_band, silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	xtickname=xtickname, ytickname=ytickname, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	position=position, $
	last=last, first=first, with_info=with_info

common rad_data_blk

if n_elements(latitude) eq 0 then begin
	prinfo, 'Must give latitude'
	return
endif

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

if ~keyword_set(freq_band) then $
	freq_band = [3.0, 30.0]

if n_params() lt 5 then begin
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
yrange = [sjul, fjul]

if ~keyword_set(xtitle) then $
	_xtitle = 'Beam' $
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
	_ytitle = 'Time UT' $
else $
	_ytitle = ytitle

if ~keyword_set(ytickformat) then $
	_ytickformat = 'label_date' $
else $
	_ytickformat = ytickformat

if ~keyword_set(ytickname) then $
	_ytickname = '' $
else $
	_ytickname = ytickname

if ~keyword_set(scan_id) then $
	scan_id = -1

if n_elements(channel) eq 0 and scan_id eq -1 then begin
	if n_elements(rad_fit_info.scan_ids) eq 2 then $
		channel = 1 $
	else $
		channel = 0
endif else if n_elements(channel) ne 0 then begin
	if channel eq 0 and n_elements(rad_fit_info.scan_ids) eq 2 then $
		channel = 1
	if (channel eq 1 or channel eq 2) and n_elements(rad_fit_info.scan_ids) eq 1 then begin
		prinfo, 'Only one scan id available, changing to channel A.'
		channel = 0
	endif
endif

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(coords) then $
	coords = get_coordinates()

if coords ne 'magn' and coords ne 'geog' then $
	prinfo, 'Invalid coordinate system in use.'

if ~keyword_set(scale) then begin
	if strcmp(get_parameter(), param) then $
		scale = get_scale() $
	else $
		scale = get_default_range(param)
endif

if ~keyword_set(xrange) then $
	xrange = [0,16]

if ~keyword_set(yticks) then $
	yticks = get_xticks(sjul, fjul, xminor=_yminor)

if keyword_set(yminor) then $
	_yminor = yminor

if ~keyword_set(xticks) then $
	xticks = 4

; Determine maximum width to plot scan - to decide how big a 'data gap' has to
; be before it really is a data gap.  Default to 5 minutes
if ~keyword_set(max_gap) then $
	max_gap = 5.

; set up coordinate system for plot
plot, [0,0], /nodata, xstyle=5, ystyle=5, $
	xrange=xrange, yrange=yrange, position=position

; get data
xtag = 'juls'
ytag = param
if ~tag_exists(rad_fit_data, xtag) then begin
	if ~keyword_set(silent) then $
		prinfo, 'Parameter '+xtag+' does not exist in RAD_FIT_DATA.'
	return
endif
if ~tag_exists(rad_fit_data, ytag) then begin
	if ~keyword_set(silent) then $
		prinfo, 'Parameter '+ytag+' does not exist in RAD_FIT_DATA.'
	return
endif
s = execute('xdata = rad_fit_data.'+xtag)
s = execute('ydata = rad_fit_data.'+ytag)

; select data to plot
; must fit yrange (beams), channel, scan_id, time (roughly) and frequency
;
; check first whether data is available for the user selection
; then find data to actually plot
txdata = xdata
tchann = rad_fit_data.channel
ttfreq = rad_fit_data.tfreq
tscani = rad_fit_data.scan_id
;tbeam  = rad_fit_data.beam
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
;tbeam  = tbeam[scch_inds]
juls_inds = where(txdata ge sjul-10.d/1440.d and txdata le fjul+10.d/1440.d, cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for beam '+string(beam)+$
			' and time '+format_time(time)
	return
endif
txdata = 0
ttfreq = ttfreq[juls_inds]
;tbeam  = tbeam[juls_inds]
tfre_inds = where(ttfreq*0.001 ge freq_band[0] and ttfreq*0.001 le freq_band[1], cc)
if cc eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data found for beam '+string(beam)+$
			' and channel '+string(_channel)+' and time '+format_time(time) + $
			' and freq. band '+string(freq_band)
	return
endif
ttfreq = 0

; get color preferences
foreground  = get_foreground()
color_steps = get_colorsteps()
ncolors     = get_ncolors()
bottom      = get_bottom()

; and some user preferences
scatterflag = rad_get_scatterflag()

; Set color bar and levels
cin =    FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps
IF param EQ 'velocity' THEN $
	cin = ROTATE(cin, 2)

; Select appropriate range gate to plot according to latitude
set_coordinates, coords
rad_define_beams

nbeams = rad_fit_info.nbeams
ngates = rad_fit_info.ngates
olddelta = 100.
gate = indgen(nbeams+1)

for i=0,nbeams do begin
	for j=0,ngates do begin		
		delta = abs(latitude - rad_fit_info.fov_loc_center[0,i,j])
		if delta lt olddelta then begin
			gate(i) = j 
			olddelta = delta 
		endif
		if delta gt olddelta then break
	endfor
	if olddelta gt 10 then $
		prinfo, 'Range gate outside acceptable limits on beam '+string(i)
	olddelta = 100
endfor

;print, gate(*)

; cycle through beams
for b=xrange[0], xrange[1] do begin

	; get indeces of data to plot
	if n_elements(channel) ne 0 then begin
		data_inds = where(rad_fit_data.beam eq b and $
			rad_fit_data.channel eq channel and $
			rad_fit_data.juls ge sjul-10.d/1440.d and $
			rad_fit_data.juls le fjul+10.d/1440.d and $
			rad_fit_data.tfreq*0.001 ge freq_band[0] and $
			rad_fit_data.tfreq*0.001 le freq_band[1], $
			ndata_inds)
	endif else if scan_id ne -1 then begin
		data_inds = where(rad_fit_data.beam eq b and $
			rad_fit_data.scan_id eq scan_id and $
			rad_fit_data.juls ge sjul-10.d/1440.d and $
			rad_fit_data.juls le fjul+10.d/1440.d and $
			rad_fit_data.tfreq*0.001 ge freq_band[0] and $
			rad_fit_data.tfreq*0.001 le freq_band[1], $
			ndata_inds)
	endif
	; overplot data
	; Cycle through data to plot
	FOR d=0L, ndata_inds-2L DO BEGIN
		IF ydata[data_inds[d],gate(b)] ne 10000. THEN BEGIN
			start_time = xdata[data_inds[d]]
			end_time = MIN( [xdata[data_inds[d+1]], start_time+max_gap/1440.d] )
			IF ~( (rad_fit_data.gscatter[data_inds[d],gate(b)] EQ 0 AND scatterflag EQ 1) OR $
				(rad_fit_data.gscatter[data_inds[d],gate(b)] NE 0 AND scatterflag EQ 2)) THEN BEGIN
				color_ind = (MAX(where(lvl le ((ydata[data_inds[d],gate(b)] > scale[0]) < scale[1]))) > 0)
				IF param EQ 'velocity' AND scatterflag EQ 3 AND $
					rad_fit_data.gscatter[data_inds[d],gate(b)] EQ 1 THEN $
						col = get_gray() $
				ELSE $
					col = cin[color_ind]
				POLYFILL, rad_fit_data.beam[data_inds[d]]+[0,1,1,0], $
					[start_time,start_time,end_time,end_time], $
					COL=col,NOCLIP=0
			ENDIF
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
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xrange=xrange, yrange=yrange, $
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=_yminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	color=get_foreground()

; returned the actually used scan_id
if scan_id eq -1 then $
	scan_id = rad_fit_info.scan_ids[(channel-1) > 0]

end
