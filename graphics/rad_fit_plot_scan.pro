;+ 
; NAME: 
; RAD_FIT_PLOT_SCAN
; 
; PURPOSE: 
; This procedure plots a stereographic map grid and overlays coast
; lines and a scan of the currently loaded radar data. This routine will call
; RAD_FIT_PLOT_SCAN_PANEL multiple times if need be.
;
; The scan that will be plot is either chosen by its number (set keyword
; SCAN_NUMBER), the date and time closest to an available scan 
; (set DATE and TIME keywords) or the Juliand Day in SCAN_STARTJUL.
;
; NSCANS then determines how many sequential scan plots are put on one page.
; 
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_SCAN
;
; KEYWORD PARAMETERS:
; DATE: A scalar giving the date to plot, in YYYYMMDD format.
;
; TIME: A scalar giving the time to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn' and 'geog'.
;
; XRANGE: Set this keyword to change the range of the x axis.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; SCAN_STARTJUL: Set this to a Julian Day determining the scan to plot.
;
; SCAN_NUMBER: Set this to a numer specifying the scan to plot.
;
; NSCANS: Set this to the number of sequential scans to plot. Default is 1.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; NO_FILL: Set this keyword to surpress filling of land masses and lakes with colors.
;
; NO_TITLE: Set this keyword to omit individual titles for the plots.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_POLAR.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_fit_plot_scan, date=date, time=time, long=long, $
	param=param, scale=scale, channel=channel, scan_id=scan_id, $
	scan_startjul=scan_startjul, nscans=nscans, $
	coords=coords, xrange=xrange, yrange=yrange, $
	charthick=charthick, charsize=charsize, $
	scan_number=scan_number, vector=vector, $
	freq_band=freq_band, silent=silent, no_fill=no_fill, no_title=no_title, no_fov=no_fov, $
	rotate=rotate, south=south

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

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, (*rad_fit_data[data_index]).juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if n_elements(time) eq 0 then $
	time = 1200
sfjul, date, time, sjul, fjul, long=long

if n_elements(time) eq 1 then begin
	if ~keyword_set(nscans) then $
		nscans=1
	scans = rad_fit_find_scan(sjul, channel=channel, scan_id=scan_id)
	scans += findgen(nscans)
endif else if n_elements(time) eq 2 then begin
	if keyword_set(nscans) then begin
		prinfo, 'When using TIME as 2-element vector, you must NOT provived NSCANS.'
		return
	endif
	scans = rad_fit_find_scan([sjul, fjul], channel=channel, scan_id=scan_id)
	nscans = n_elements(scans)
endif

if ~keyword_set(param) then $
	param = get_parameter()

; if scan_number is set, use that instead of the
; one just found by using date and time
if n_elements(scan_number) gt 0 then begin
	if scan_number ne -1 then begin
		scans = scan_number
		nscans = 1
	endif
endif
npanels = nscans

nparams = n_elements(param)
if nparams gt 1 then begin
	if nscans gt 1 then begin
		prinfo, 'If multiple params are set, nscans must be scalar.'
		return
	endif
	npanels = nparams
endif

; calculate number of panels per page
xmaps = floor(sqrt(npanels)) > 1
ymaps = ceil(npanels/float(xmaps)) > 1

; take into account format of page
; if landscape, make xmaps > ymaps
fmt = get_format(landscape=ls)
if ls then begin
	if ymaps gt xmaps then begin
		tt = xmaps
		xmaps = ymaps
		ymaps = tt
	endif
; if portrait, make ymaps > xmaps
endif else begin
	if xmaps gt ymaps then begin
		tt = ymaps
		ymaps = xmaps
		xmaps = tt
	endif
endelse

; for multiple parameter fan plots
; always stack horizontally them
if nparams gt 1 then begin
	xmaps = npanels
	ymaps = 1
endif

; clear output area
clear_page

ascale = 0

; loop through panels
for s=0, npanels-1 do begin

	if nparams gt 1 then begin
		aparam = param[s]
		ascan = scans[0]
		if keyword_set(scale) then $
			ascale = scale[s*2:s*2+1]
	endif else begin
		aparam = param[0]
		ascan = scans[s]
		if keyword_set(scale) then $
			ascale = scale
	endelse

	xmap = s mod xmaps
	ymap = s/xmaps

	ytitle = ' '
	if xmap eq 0 then $
		ytitle = ''

	xtitle = ' '
	if ymap eq ymaps-1 then $
		xtitle = ''

	; plot an fan panel for each scan/parameter
	rad_fit_plot_scan_panel, xmaps, ymaps, xmap, ymap, $
		date=date, time=time, long=long, coords=coords, $
		param=aparam, xrange=xrange, yrange=yrange, scale=ascale, $
		scan_number=ascan, channel=channel, scan_id=scan_id, $
		scan_startjul=scan_startjul, no_fill=no_fill, $
		freq_band=freq_band, silent=silent, $
		charthick=charthick, charsize=charsize, vector=vector, no_fov=no_fov, $
		rotate=rotate, south=south

	if nparams gt 1 then $
		plot_colorbar, xmaps, ymaps, xmap, ymap, param=aparam, scale=ascale, /square, /horizontal

	if ~keyword_set(no_title) and $
		n_elements(scan_id) gt 0 and n_elements(scan_startjul) gt 0 then $
			rad_fit_plot_scan_title, xmaps, ymaps, xmap, ymap, $
				scan_id=scan_id, scan_startjul=scan_startjul, aspect=1., /bar

endfor

rad_fit_plot_title, scan_id=scan_id
if nparams eq 1 then $
	plot_colorbar, 1, 1, 0, 0, scale=scale, param=aparam

end
