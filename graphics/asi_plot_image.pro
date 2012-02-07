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
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
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
