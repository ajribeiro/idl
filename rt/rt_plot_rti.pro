;+ 
; NAME: 
; RT_PLOT_RTI
;
; PURPOSE: 
; This procedure creates range-time plot from raytracing data
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_PLOT_RTI
;
; INPUTS:
;
; OPTIONAL INPUTS:
; DATE
; TIME
; SCALE
; YRANGE
;
; TREND: set this keyword to overlay a trend curve on a power plot
;
; KEYWORDS:
;
; COMMON BLOCKS:
; RT_DATA_BLK
;
; EXAMPLE:
;	; Run the raytracing for august 2 2010 for Blackstone
;	; from 17 to 24 LT 
;	rt_run, 20100802, 'bks', time=[1700,2400], sti='LT'
;	; Plot results on range-time plot for the first 60 gates
;	rt_plot_rti, yrange=[0,60]
;
; MODIFICATION HISTORY:
; Based on Lasse Clausen, RAD_FIT_PLOT_RTI
; Modified by Sebastien de Larquier, Sept. 2010
;	Last modified 17-09-2010
;-
pro rt_plot_rti, date=date, time=time, $
	param=param, all=all, $
	coords=coords, yrange=yrange, scale=scale, $
	freq_band=freq_band, silent=silent, $
	charthick=charthick, charsize=charsize, $
	no_title=no_title, ground=ground, trend=trend
	
common	rt_data_blk

param = 'power'
beams = 0
if ~keyword_set(scale) then $
	 scale = [0,20]
if ~keyword_set(yrange) then $
	 yrange = [0,75]

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, rt_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then begin
	caldat, rt_info.sjul, mm, dd, yy, shr, smn
	caldat, rt_info.fjul, mm, dd, yy, fhr, fmn
	time = [shr*100L+smn, fhr*100L+fmn]
endif

if n_elements(param) gt 1 then begin
	npanels = n_elements(param)
	if n_elements(beams) gt 1 then begin
		prinfo, 'Cannot set multiple beams and multiple params.'
		return
	endif
endif else $
	npanels = 1

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
		if keyword_set(scale) then $
			ascale = scale[b*2:b*2+1]
	endif else begin
		aparam = param[0]
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
	
	; plot an rti panel
	rt_plot_rti_panel, xmaps, ymaps, xmap, ymap, /bar, $
		date=date, time=time, $
		param=param, trend=trend, $
		coords=coords, yrange=yrange, scale=ascale, $
		freq_band=freq_band, silent=silent, $
		charthick=charthick, charsize=charsize, $
		/with_info, last=last, first=first, ground=ground

	if n_elements(param) gt 1 then begin
		;only plot tfreq noise panel once
		if b eq 0 then begin
			rt_plot_rti_title, xmaps, ymaps, xmap, ymap, /bar, $
				charthick=charthick, charsize=charsize, $
				beam=abeam, /with_info
			rt_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, /info, $
				charthick=charthick, charsize=.7, $
				last=last, first=first
		endif
		plot_colorbar, xmaps, ymaps, xmap, ymap, scale=ascale, param=aparam, /with_info
	endif else begin
		if ymap eq 0 then begin
			rt_plot_rti_title, xmaps, ymaps, xmap, ymap, /bar, $
				charthick=charthick, charsize=charsize, $
				beam=abeam, /with_info
			rt_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, /info, $
				charthick=charthick, charsize=.7, $
				last=last, first=first
		endif
	endelse

endfor

; plot a title and colorbar for all panels

rt_plot_title

if n_elements(param) eq 1 then $
	plot_colorbar, xmaps, 1, xmaps-1, 0, scale=ascale, param=param[0], /with_info, ground=ground

end
