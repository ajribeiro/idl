;+ 
; NAME: 
; RAD_FIT_PLOT_TSR_STACK
; 
; PURPOSE: 
; This procedure plots a stack of series of time series plots on a page. With 
; title.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_TSR_STACK
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
; BEAMS: Set this keyword to a scalar or array of beam numbers to plot.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; YRANGE: Set this keyword to change the range of the y axis.
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
; Based on Steve Milan's PLOT_RTI.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_fit_plot_tsr_stack, date=date, time=time, long=long, $
	param=param, beams=beams, $
	channel=channel, scan_id=scan_id, $
	yrange=yrange, exclude=exclude, $
	freq_band=freq_band, silent=silent, $
	charthick=charthick, charsize=charsize, $
	no_title=no_title, gates=gates, offset=offset, no_zero=no_zero

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

if ~keyword_set(param) then $
	param = get_parameter()

;if ~is_valid_parameter(param) then begin
;	prinfo, 'Invalid plotting parameter: >'+strjoin(param,'<>')+'<'
;	return
;endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, (*rad_fit_data[data_index]).juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

if n_elements(beams) eq 0 then $
	beams = rad_get_beam()

nbeams = n_elements(beams)
nparams = n_elements(param)
npanels = max([nbeams, nparams])

if nparams gt 1 then begin
	if nbeams gt 1 then begin
		prinfo, 'If multiple params are set, beam must be scalar.'
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

; for multiple parameter plot
; always stack them
if nparams gt 1 then begin
	ymaps = npanels
	xmaps = 1
endif

; for plots of less than 4 beams
; always stack them
if npanels lt 4 then begin
	ymaps = npanels
	xmaps = 1
endif

; clear output area
clear_page

plot_colorbar, 1, 1, 0, 0, scale=[min(gates), max(gates)], /with_info, /no_ro, $
	legend='Gate'

ascale = 0

; loop through panels
for b=0, npanels-1 do begin

	if nparams gt 1 then begin
		aparam = param[b]
		abeam = beams[0]
		if keyword_set(yrange) then $
			ascale = yrange[b*2:b*2+1]
	endif else begin
		aparam = param[0]
		abeam = beams[b]
		if keyword_set(yrange) then $
			ascale = yrange
	endelse

	xmap = b mod xmaps
	ymap = b/xmaps

	first = 0
	if xmap eq 0 then $
		first = 1

	last = 0
	if ymap eq ymaps-1 then $
		last = 1

	if n_elements(param) gt 1 then begin
		;only plot tfreq noise panel once
		if b eq 0 then begin
			rad_fit_plot_scan_id_info_panel, xmaps, ymaps, xmap, ymap, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, /with_info, /legend, /bar
			rad_fit_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first, /bar
			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first, /bar
		endif
	endif else begin
		if ymap eq 0 then begin
			rad_fit_plot_scan_id_info_panel, xmaps, ymaps, xmap, ymap, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, /with_info, /legend, /bar
			rad_fit_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first, /bar
			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first, /bar
		endif
	endelse

	; plot an rti panel for each beam
	rad_fit_plot_tsr_stack_panel, xmaps, ymaps, xmap, ymap, $
		date=date, time=time, long=long, $
		param=aparam, beam=abeam, gates=gates, offset=offset, $
		channel=channel, scan_id=scan_id, $
		yrange=ascale, exclude=exclude, $
		freq_band=freq_band, silent=silent, no_zero=no_zero, $
		charthick=charthick, charsize=charsize, /with_info, $
		last=last, first=first, /bar

endfor

; plot a title for all panels
rad_fit_plot_title, scan_id=scan_id

end
