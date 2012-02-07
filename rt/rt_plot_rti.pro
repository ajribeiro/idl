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
;
; KEYWORDS PARAMETERS:
; PARAM: 'power' or 'elevation' or 'altitude' or 'valtitude'
;
; TREND: set this keyword to overlay a trend curve on a power plot
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
; Based on Lasse Clausen, RAD_FIT_PLOT_RTI
; Modified by Sebastien de Larquier, Sept. 2010
;	Last modified 17-09-2010
;-
pro rt_plot_rti, date=date, time=time, beams=beams, $
	param=param, all=all, sun=sun, $
	coords=coords, yrange=yrange, scale=scale, $
	freq_band=freq_band, silent=silent, ground=ground, $
	charthick=charthick, charsize=charsize, $
	no_title=no_title, trend=trend, ionos=ionos, grid=grid, $
	data=data, contour=contour, ps=ps

common	rt_data_blk

help, rt_info, /st, output=infout
if n_elements(infout) le 2 then begin
	print, 'No data present'
	return
endif

if ~keyword_set(param) then $
	param = 'power'

if ~keyword_set(beams) then $
	beams = rt_data.beam[0,*]

nparams = n_elements(param)
set_format, /sardines, /tokyo
set_bottom, 2
set_ncolors, 251

legend = param
for p=0,nparams-1 do begin
	case param[p] of
		'power': legend[p] = textoidl('Power [norm]')
		'elevation': legend[p] = textoidl('Elevation angle [\circ]')
		'altitude': legend[p] = textoidl('Reflection alt. [km]')
		'valtitude': legend[p] = textoidl('Virtual height [km]')
		'nr': legend[p] = textoidl('Refractive index')
		'off aspect': legend[p] = textoidl('off aspect [\circ]')
	else: print, 'Parameter '+param+' unknown'
	endcase
endfor

if ~keyword_set(scale) then begin
	scale = 0.*findgen(2*nparams)
	for p=0,nparams-1 do begin
		case param[p] of
			'power': scale[2*p:2*p+1]=[0.,1.]
			'elevation': scale[2*p:2*p+1]=[10.,35.]
			'altitude': scale[2*p:2*p+1] =[100.,500.]
			'valtitude': scale[2*p:2*p+1] =[100.,500.]
			'nr': scale[2*p:2*p+1] =[0.8,1.]
			'aspect': scale[2*p:2*p+1] =[0.,1.]
		else: print, 'Parameter '+param+' unknown'
		endcase
	endfor
endif

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
	b = 0
endif else begin
	npanels = n_elements(beams)
	p = 0
endelse

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
if keyword_set(ps) then $
	ps_open, '~/Desktop/rt_rti'+rt_info.name+'.ps', /no_init
clear_page

; loop through panels
for ipan=0,npanels-1 do begin
	; increment param or beams
	if n_elements(param) gt 1 then $
		p = ipan $
	else $
		b = ipan

	if strcmp(param[p],'altitude') or strcmp(param[p],'valtitude') then begin
		level_format = 0
		set_colorsteps, 250
	endif else if strcmp(param[p],'power') then begin
		level_format = '(f5.2)'
		set_colorsteps, 8
	endif else begin
		level_format = '(f5.2)'
		set_colorsteps, 250
	endelse

	ascale = 0

	if n_elements(param) gt 1 then begin
		aparam = param[p]
		if keyword_set(scale) then $
			ascale = scale[p*2:p*2+1]
	endif else begin
		aparam = param[0]
		if keyword_set(scale) then $
			ascale = scale
	endelse

	xmap = ipan mod xmaps
	ymap = ipan/xmaps

	first = 0
	if xmap eq 0 then $
		first = 1

	last = 0
	if ymap eq ymaps-1 then $
		last = 1

	if keyword_set(data) then begin
		rad_fit_calculate_elevation, date=date, time=time, jul=rt_info.sjul, $
			/overwrite, tdiff=-.324, phidiff=1, scan_boresite_offset=8, interfer_pos=[0., -59.4, -2.7]
		rad_fit_plot_rti_panel, xmaps, ymaps, xmap, ymap, /bar, $
			time=time, param=param[p], beam=beams[b], $
			coords=coords, yrange=yrange, scale=ascale, $
			freq_band=freq_band, silent=silent, $
			charthick=charthick, charsize=charsize, $
			/with_info, last=last, first=first
	endif

	; plot an rti panel
	rt_plot_rti_panel, xmaps, ymaps, xmap, ymap, /bar, $
		date=date, time=time, grid=grid, $
		param=param[p], trend=trend, sun=sun, beam=beams[b], $
		coords=coords, yrange=yrange, scale=ascale, $nr
		freq_band=freq_band, silent=silent, ground=ground, $
		charthick=charthick, charsize=charsize, $
		/with_info, last=last, first=first, ionos=ionos, $
		data=data, contour=contour

	if n_elements(param) gt 1 then begin
		;only plot tfreq noise panel once
		if b eq 0 then begin
			rt_plot_rti_title, xmaps, ymaps, xmap, ymap, /bar, $
				charthick=charthick, charsize=charsize, $
				beam=beams[b], /with_info
;			if p eq 0 then begin
;				rt_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, /bar, $
;					date=date, time=time, /info, $
;					charthick=charthick, charsize=.7, $
;					last=last, first=first
;			endif
		endif
		plot_colorbar, xmaps, ymaps, xmap, ymap, scale=ascale, param=param[p], /with_info, legend=legend[p], level_format=level_format
	endif else begin
		rt_plot_rti_title, xmaps, ymaps, xmap, ymap, /bar, $
			charthick=charthick, charsize=charsize, $
			beam=beams[b], /with_info
;		if npanels eq 1 then begin
;			rt_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, /bar, $
;				date=date, time=time, /info, $
;				charthick=charthick, charsize=.7, $
;				last=last, first=first
;		endif
	endelse

endfor

; plot a title and colorbar for all panels
rt_plot_title, param=param

if n_elements(param) eq 1 then $
	plot_colorbar, xmaps, 1, xmaps-1, 0, scale=ascale, param=param[0], /with_info, ground=ground, legend=legend, level_format=level_format


if keyword_set(ps) then $
	ps_close, /no_init

end
