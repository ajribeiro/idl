;+ 
; NAME: 
; RAD_FIT_PLOT_BTI
; 
; PURPOSE: 
; This procedure plots a series of Beam-Time plots on a page. With 
; title, color bar.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_BTI
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
; RANGES: Set this keyword to a scalar or array of range gate numbers to plot.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; XRANGE: Set this keyword to change the range of the x axis.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; NO_TITLE: Set this keyword to surpress plotting of a title.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_RTI.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_fit_plot_bti, date=date, time=time, long=long, $
	param=param, ranges=ranges, channel=channel, scan_id=scan_id, $
	xrange=xrange, scale=scale, $
	freq_band=freq_band, silent=silent, $
	charthick=charthick, charsize=charsize, $
	no_title=no_title

common rad_data_blk

if rad_fit_info.nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, rad_fit_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

if n_elements(ranges) eq 0 then $
	ranges = 35;rad_get_beam()

if ~keyword_set(param) then $
	param = get_parameter()

if n_elements(param) gt 1 then begin
	npanels = n_elements(param)
	if n_elements(ranges) gt 1 then begin
		prinfo, 'Cannot set multiple beams and multiple params.'
		return
	endif
endif else $
	npanels = n_elements(ranges)

; calculate number of panels per page
if npanels gt 5 then begin
	ymaps = floor(sqrt(npanels)) > 1
	xmaps = ceil(npanels/float(ymaps)) > 1
endif else begin
	ymaps = 1
	xmaps = npanels
endelse

; take into account format of page
; if landscape, make xmaps > ymaps
fmt = get_format(landscape=ls, sardines=sd)
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

; for multiple parameter plot
; always stack them
if n_elements(param) gt 1 then begin
	ymaps = npanels
	xmaps = 1
endif

; clear output area
clear_page

ascale = 0

; loop through panels
for r=0, npanels-1 do begin

	if n_elements(param) gt 1 then begin
		aparam = param[r]
		arange = ranges[0]
		if keyword_set(scale) then $
			ascale = scale[r*2:r*2+1] $
		else $
			ascale = get_default_range(aparam)
	endif else begin
		aparam = param[0]
		arange = ranges[r]
		if keyword_set(scale) then $
			ascale = scale
	endelse

	xmap = r mod xmaps
	ymap = r/xmaps

	first = 0
	if xmap eq 0 then $
		first = 1

	last = 0
	if ymap eq ymaps-1 then $
		last = 1
	
	; plot an rti panel for each beam
	rad_fit_plot_bti_panel, xmaps, ymaps, xmap, ymap, /bar, $
		date=date, time=time, long=long, $
		param=aparam, range=arange, channel=channel, scan_id=scan_id, $
		xrange=xrange, scale=ascale, $
		freq_band=freq_band, silent=silent, $
		charthick=charthick, charsize=charsize, $
		last=last, first=first


	if n_elements(param) gt 1 then begin
		;only plot tfreq noise panel once
		if r eq 0 then begin
			if ~keyword_set(no_title) then $
				rad_fit_plot_bti_title, xmaps, ymaps, xmap, ymap, /bar, $
					charthick=charthick, charsize=charsize, $
					freq_band=freq_band, range=arange
;			rad_fit_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, /bar, $
;				date=date, time=time, long=long, $
;				charthick=charthick, $
;				yticks=2, yminor=3, yrange=[0,30], charsize=.7, $
;				beam=abeam, channel=channel, scan_id=scan_id, /info
;			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, /bar, $
;				date=date, time=time, long=long, $
;				charthick=charthick, $
;				yticks=2, yminor=5, yrange=[0,5], charsize=.7, $
;				beam=abeam, channel=channel, scan_id=scan_id, /info
		endif
		plot_colorbar, xmaps, ymaps, xmap, ymap, scale=ascale, param=aparam
	endif else begin
		if ~keyword_set(no_title) then $
			rad_fit_plot_bti_title, xmaps, ymaps, xmap, ymap, /bar, $
				charthick=charthick, charsize=charsize, $
				freq_band=freq_band, range=arange
		; plot noise and tfreq info panel
;		if ymap eq 0 then begin
;			rad_fit_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, /bar, $
;				date=date, time=time, long=long, $
;				charthick=charthick, $
;				yticks=2, yminor=3, yrange=[0,30], charsize=.7, $
;				beam=abeam, channel=channel, scan_id=scan_id, /info
;			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, /bar, $
;				date=date, time=time, long=long, $
;				charthick=charthick, $
;				yticks=2, yminor=5, yrange=[0,5], charsize=.7, $
;				beam=abeam, channel=channel, scan_id=scan_id, /info
;		endif
	endelse

endfor

; plot a title and colorbar for all panels
rad_fit_plot_title, scan_id=scan_id
if n_elements(param) eq 1 then $
	plot_colorbar, xmaps, 1, xmaps-1, 0, scale=ascale, param=param[0]

end
