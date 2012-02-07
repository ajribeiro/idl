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
; of the y axis. Allowable inputs are 'magn', 'geog', 'rang' and 'gate'.
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
; EXCLUDE: Set this keyword to a 2-element vector to specify the lower and upper cutoff.
; Setting this to [0,30] will only plot values greater than 0 and smaller than 30.
;
; SUN: Set this keyword to overplot sunrise, sunset and solar noon times.
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
pro rad_fit_plot_rti, date=date, time=time, long=long, $
	param=param, beams=beams, all=all, channel=channel, scan_id=scan_id, $
	coords=coords, yrange=yrange, scale=scale, xticks=xticks, $
	freq_band=freq_band, silent=silent, $
	charthick=charthick, charsize=charsize, $
	no_title=no_title, ground=ground, exclude=exclude, sc_values=sc_values,$
	name=name, sun=sun, plot_empty=plot_empty

common rad_data_blk

if keyword_set(plot_empty) then begin
	rad_fit_plot_rti_empty, date=date, time=time, param=param, beams=beams, all=all, $
		coords=coords, yrange=yrange, scale=scale, xticks=xticks, $
		charthick=charthick, charsize=charsize, $
		no_title=no_title, ground=ground, sc_values=sc_values
	return
endif

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then begin
	prinfo, 'data_index is -1.'
	if keyword_set(plot_empty) then $
		rad_fit_plot_rti_empty, date=date, time=time, param=param, beams=beams, all=all, $
			coords=coords, yrange=yrange, scale=scale, xticks=xticks, $
			charthick=charthick, charsize=charsize, $
			no_title=no_title, ground=ground, sc_values=sc_values
	return
endif

if (*rad_fit_info[data_index]).nrecs eq 0L then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data in index '+string(data_index)
		rad_fit_info
	endif
	if keyword_set(plot_empty) then $
		rad_fit_plot_rti_empty, date=date, time=time, param=param, beams=beams, all=all, $
			coords=coords, yrange=yrange, scale=scale, xticks=xticks, $
			charthick=charthick, charsize=charsize, $
			no_title=no_title, ground=ground, sc_values=sc_values
	return
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, (*rad_fit_data[data_index]).juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then begin
  caldat, (*rad_fit_info[data_index]).sjul, mm, dd, yy, shh, sii
  caldat, (*rad_fit_info[data_index]).fjul, mm, dd, yy, fhh, fii
  time = [shh*100, ( (fhh+( fii lt 10 ? 0 : 1 )) < 24 )*100]
	;time = [0000,2400]
endif

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
	if n_elements(sc_values) gt 0 then begin
		prinfo, 'Cannot set SC_VALUES and multiple params.'
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

; set format to sardines
set_format, /sardines

; clear output area
clear_page

; set charsize of info panels smaller
ichars = (!d.name eq 'X' ? 1. : 1. ) * get_charsize(xmaps > 1, ymaps > 2)

beamstr = strjoin(string(beams, format='(I02)'), ', ')

; plot a title and colorbar for all panels

if (*rad_fit_info[data_index]).fitex then $
	fitstr = 'fitEX'

if (*rad_fit_info[data_index]).fitacf then $
	fitstr = 'fitACF'

if (*rad_fit_info[data_index]).fit then $
	fitstr = 'fit'

titlestr = (*rad_fit_info[data_index]).name + $
	' ('+fitstr+')'

rad_fit_plot_title, ' ', titlestr, scan_id=scan_id, date=date, time=time

if n_elements(param) eq 1 then begin
	plot_colorbar, xmaps, 1, xmaps-1, 0, scale=scale, param=param[0], /with_info, ground=ground, sc_values=sc_values
endif

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

	if n_elements(sc_values) gt 0 then $
		asc_values = sc_values $
	else $
		asc_values = 0

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
			rad_fit_plot_scan_id_info_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, /with_info
			rad_fit_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				/horizontal_ytitle, ystyle=9, $
				last=last, first=first
			rad_fit_plot_nave_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, linestyle=1, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $ 
				last=last, first=first, /rightyaxis, /horizontal_ytitle
			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				/horizontal_ytitle, /search, /rightyaxis, $
				last=last, first=first, linestyle=1
			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				/horizontal_ytitle, /sky, $
				last=last, first=first, title='Beam'+(n_elements(beams) gt 1 ? 's' : '')+' '+beamstr
		endif
		plot_colorbar, xmaps, ymaps, xmap, ymap, scale=ascale, param=aparam, /with_info, ground=ground, sc_values=sc_values
	endif else begin
		; plot noise and tfreq info panel
		if ymap eq 0 then begin
			rad_fit_plot_scan_id_info_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, /with_info
			rad_fit_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				/horizontal_ytitle, ystyle=9, $
				last=last, first=first
			rad_fit_plot_nave_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, linestyle=1, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first, /rightyaxis, /horizontal_ytitle
			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				/horizontal_ytitle, /search, /rightyaxis, $
				last=last, first=first, linestyle=1
			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, /bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				/horizontal_ytitle, /sky, $
				last=last, first=first, title='Beam'+(n_elements(beams) gt 1 ? 's' : '')+' '+beamstr
		endif
	endelse

	; plot an rti panel for each beam
	if aparam eq 'tec' then begin
		tec_read,date,time=time

		tec_plot_rti_panel, xmaps, ymaps, xmap, ymap, /bar, $
			date=date, time=time, name=name, long=long, $
			param=aparam, beam=abeam, $
			coords=coords, yrange=yrange, scale=ascale, $
			silent=silent, rscale=rscale, $
			charthick=charthick, charsize=charsize, sun=sun, $
			/with_info, last=last, first=first, startjul=startjul
	endif else $
		rad_fit_plot_rti_panel, xmaps, ymaps, xmap, ymap, /bar, $
			date=date, time=time, long=long, $
			param=aparam, beam=abeam, channel=channel, scan_id=scan_id, $
			coords=coords, yrange=yrange, scale=ascale, $
			freq_band=freq_band, silent=silent, xticks=xticks, $
			charthick=charthick, charsize=charsize, sun=sun, $
			/with_info, last=last, first=first, ground=ground, exclude=exclude, sc_values=asc_values

endfor

end
