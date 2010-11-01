;+
; NAME:
; RAD_FIT_PLOT_RTI
;
; PURPOSE:
; This procedure plots a series of Range-Time plots on a page. With
; title, color bar.
;
; CATEGORY:
; Graphics
;
; CALLING SEQUENCE:
; RAD_FIT_PLOT_RTI
;
; KEYWORD PARAMETERS:
; ALL: If set, all beams (0-16) are plotted in seperate panels.
;
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
; BEAMS: Set this keyword to a scalar or array of beam numbers to plot.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'mag', 'geo', 'range' and 'gate'.
; Default is 'gate'.
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
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; NO_TITLE: Set this keyword to surpress plotting of a title.
;
; GROUND: Set this keyword to a velocity value and all velocities
; -ground <= vel <= ground will be colored in gray.
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
pro rad_fit_plot_rti, date=date, time=time, long=long, $
	param=param, beams=beams, all=all, channel=channel, scan_id=scan_id, $
	coords=coords, yrange=yrange, scale=scale, $
	freq_band=freq_band, silent=silent, $
	charthick=charthick, charsize=charsize, $
	no_title=no_title, ground=ground

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

if ~keyword_set(time) then $
	time = [0000,2400]

if keyword_set(all) then $
	beams = indgen(16)

if n_elements(beams) eq 0 then $
	beams = rad_get_beam()

if ~keyword_set(param) then $
	param = get_parameter()

if n_elements(param) gt 1 then begin
	npanels = n_elements(param)
	if n_elements(beams) gt 1 then begin
		prinfo, 'Cannot set multiple beams and multiple params.'
		return
	endif
endif else $
	npanels = n_elements(beams)

; calculate number of panels per page
xmaps = floor(sqrt(npanels)) > 1
ymaps = ceil(npanels/float(xmaps)) > 1

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

; for plots of less than 4 beams
; always stack them
if n_elements(beams) lt 4 then begin
	ymaps = npanels
	xmaps = 1
endif

; clear output area
clear_page

; loop through panels
for b=0, npanels-1 do begin

	ascale = 0

	if n_elements(param) gt 1 then begin
		aparam = param[b]
		abeam = beams[0]
		if keyword_set(scale) then $
			ascale = scale[b*2:b*2+1]
	endif else begin
		aparam = param[0]
		abeam = beams[b]
		if keyword_set(scale) then $
			ascale = scale
	endelse

	xmap = b mod xmaps
	ymap = b/xmaps

	first = 0
	if xmap eq 0 then $
		first = 1

	last = 0
	if ymap eq ymaps-1 then $
		last = 1

	; plot an rti panel for each beam
	rad_fit_plot_rti_panel, xmaps, ymaps, xmap, ymap, /bar, $
		date=date, time=time, long=long, $
		param=aparam, beam=abeam, channel=channel, scan_id=scan_id, $
		coords=coords, yrange=yrange, scale=ascale, $
		freq_band=freq_band, silent=silent, $
		charthick=charthick, charsize=charsize, $
		/with_info, last=last, first=first, ground=ground

	if n_elements(param) gt 1 then begin
		;only plot tfreq noise panel once
		if b eq 0 then begin
			if ~keyword_set(no_title) then $
				rad_fit_plot_rti_title, xmaps, ymaps, xmap, ymap, /bar, $
					charthick=charthick, charsize=charsize, $
					freq_band=freq_band, beam=abeam, /with_info
			rad_fit_plot_scan_id_info_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=.7, $
				beam=abeam, channel=channel, /with_info
			rad_fit_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=.7, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first
			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, $
				yticks=2, yminor=5, yrange=[0,5], charsize=.7, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first
		endif
		plot_colorbar, xmaps, ymaps, xmap, ymap, scale=ascale, param=aparam, /with_info, ground=ground
	endif else begin
		if ~keyword_set(no_title) then $
			rad_fit_plot_rti_title, xmaps, ymaps, xmap, ymap, /bar, $
				charthick=charthick, charsize=charsize, $
				freq_band=freq_band, beam=abeam, /with_info
		; plot noise and tfreq info panel
		if ymap eq 0 then begin
			rad_fit_plot_scan_id_info_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=.7, $
				beam=abeam, channel=channel, /with_info
			rad_fit_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=.7, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first
			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, $
				yticks=2, yminor=5, yrange=[0,5], charsize=.7, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first
		endif
	endelse

endfor

; plot a title and colorbar for all panels

if (*rad_fit_info[data_index]).fitex then $
	fitstr = 'fitEX'

if (*rad_fit_info[data_index]).fitacf then $
	fitstr = 'fitACF'

if (*rad_fit_info[data_index]).fit then $
	fitstr = 'fit'

if n_elements(param) gt 1 then $
	rad_fit_plot_title, 'SUPERDARN PARAMETER PLOT', (*rad_fit_info[data_index]).name+': ('+fitstr+')', scan_id=scan_id $
else $
	rad_fit_plot_title, scan_id=scan_id, param=param[0]
if n_elements(param) eq 1 then begin
	plot_colorbar, xmaps, 1, xmaps-1, 0, scale=ascale, param=param[0], /with_info, ground=ground
endif
end
