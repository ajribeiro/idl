;+ 
; NAME: 
; ASI_PLOT_IMAGE
; 
; PURPOSE: 
; This procedure plots one image or a series of images of the All-Sky Images data loaded in the
; ASI_DATA_BLK common block, if any, together with a title and a colorbar
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; ASI_PLOT_IMAGE
;
; KEYWORD PARAMETERS:
; DATE: A scalar or 2-element vector giving the time range from which to plot the images,
; in YYYYMMDD format.
;
; TIME: A scalar or 2-element vector giving the time range of the image to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; IMAGE_NUMBER: Set this to the sequence number of the image you want to plot
; rather than using the DATE and TIEM keywords.
;
; SCALE: Set this keyword to a 2-element vector which contains the 
; upper and lower limit of the data range.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size.
;
; XRANGE: Set this keyword to change the range of the x axis.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; STARTJUL: Set this to give the Julian Day of the first image
; to plot, rather than using the DATE and TIME keywords.
;
; NIMAGES: Set this to the number of images to plot on one page.
;
; DT: Set this to the sampling time of the images in ASI_DATA_BLK.
;
; INTERVAL: Set this to the time interval between subsequent plotted
; images - this is NOT the sampling time.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; DIFF: If set, the difference between the previous and the chosen image 
; is plotted.
;
; NO_TITLE: If this keyword is set, the panel size will be calculated without 
; leaving space for a big title on the page. Of course, this keyword only takes
; effect if you do not use the position keyword.
;
; EXAMPLE: 
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro asi_plot_image, date=date, time=time, long=long, $
	scale=scale, diff=diff, $
	startjul=startjul, nimages=nimages, dt=dt, interval=interval, $
	xrange=xrange, yrange=yrange, $
	charthick=charthick, charsize=charsize, $
	image_number=image_number, $
	silent=silent, no_title=no_title

common asi_data_blk
	
if asi_info.nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, asi_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if n_elements(time) eq 0 then $
	time = 1200
sfjul, date, time, sjul, fjul, long=long

; standard time step is 3 seconds
if ~keyword_set(dt) then $
	dt = 3.

; user provided plotting increment, in seconds
if ~keyword_set(interval) then $
	_interval = dt $
else $
	_interval = float(interval)

if n_elements(time) eq 1 then begin
	if ~keyword_set(nimages) then $
		nimages = 1
	smin = min( abs( asi_data.juls - sjul), images)
	; check if distance is "reasonable"
	; i.e. within 15 seconds
	if smin*86400.d gt 15. then $
		prinfo, 'Found image but it is '+$
			strtrim(string(smin*86400.d),2)+' secs away from given date.'
	images += findgen(nimages)*round(_interval/dt)
endif else if n_elements(time) eq 2 then begin
	if keyword_set(nimages) then $
		prinfo, 'When using TIME as 2-element vector, you must NOT provived NIMAGES.'
	smin = min( abs( asi_data.juls - sjul), simages)
	; check if distance is "reasonable"
	; i.e. within 15 seconds
	if smin*86400.d gt 15. then $
		prinfo, 'Found image but it is '+$
			strtrim(string(smin*86400.d),2)+' secs away from given date.'
	fmin = min( abs( asi_data.juls - fjul), fimages)
	; check if distance is "reasonable"
	; i.e. within 15 seconds
	if fmin*86400.d gt 15. then $
		prinfo, 'Found image but it is '+$
			strtrim(string(fmin*86400.d),2)+' secs away from given date.'
	images = simages + findgen(floor(float(fimages - simages)*dt/_interval))*round(_interval/dt)
	nimages = n_elements(images)
endif
npanels = nimages

; make gaps small
set_format, /tok, /sar

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

; clear output area
clear_page

ascale = 0

; loop through panels
for s=0, npanels-1 do begin

	aimage = images[s]
	if keyword_set(scale) then $
		ascale = scale

	xmap = s mod xmaps
	ymap = s/xmaps

	ytitle = ' '
	if xmap eq 0 then $
		ytitle = ''

	xtitle = ' '
	if ymap eq ymaps-1 then $
		xtitle = ''

	; plot an fan panel for each scan/parameter
	asi_plot_image_panel, xmaps, ymaps, xmap, ymap, $
		date=date, time=time, long=long, $
		xrange=xrange, yrange=yrange, scale=ascale, $
		image_number=aimage, $
		silent=silent, diff=(keyword_set(diff) ? s : 0), $
		charthick=charthick, charsize=charsize, /bar

	if ~keyword_set(no_title) then begin
		if aimage ge asi_info.nrecs then $
			continue
		plot_panel_title, xmaps, ymaps, xmap, ymap, $
			lefttitle=format_juldate(asi_data.juls[aimage], /time), $
			/bar, aspect=float(xrange[1]-xrange[0])/float(yrange[1]-yrange[0])
	endif
endfor

if images[0] ge asi_info.nrecs then $
	return
plot_title, 'ASI IMAGES', strupcase(asi_info.site), $
	top_right_title=format_juldate(asi_data.juls[images[0]], /date)
plot_colorbar, xmaps, 1, xmaps-1, 0, scale=scale, param='asi'

end
