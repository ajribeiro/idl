;+
; NAME:
; RT_PLOT_EDENS
;
; PURPOSE:
; This procedure plots electron densities only with 3 options
; 	- DAY (default): use this option to plot electron density variation during the day of the run
; 	- DAYN : use this option to plot index of refraction variation during the day of the run
;		- RAY : use this option to plot the electron density along the ray paths at a specific time
;		- DIFF : use this option to plot the difference in electron densities at two times along the ray paths
;
; CATEGORY:
; Graphics
;
; CALLING SEQUENCE:
; RT_PLOT_EDENS, time=time, day=day, ray=ray, diff=diff, ps=ps
;
; INPUTS:
; TIME: time of your raytracing run for which you want to plot the ray paths
;
; KEYWORD PARAMETERS:
; PARAM: day, ray or diff (only one).
;
; TIME: one element if 'RAY' chosen, or 2 elemnts if 'DIFF' chosen.
;
; KEYWORDS:
;
; COMMON BLOCKS:
; RT_DATA_BLK
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
; Written by Sebastien de Larquier, Nov.2010
;-
PRO	rt_plot_edens, time=time, date=date, param=param, scale=scale, ps=ps, nosun=nosun, beam=beam

common rt_data_blk

if ~keyword_set(param) then $
	param = 'day'

if ~keyword_set(beam) then begin
	nbeams = n_elements(rt_data.beam[0,*])
	beam = rt_data.beam[0,round(nbeams/2.)-1]
endif
binds = where(rt_data.beam[0,*] eq beam)
b = binds[0]

if n_elements(param) gt 1 then begin
	prinfo, 'Only one parameter permitted'
	return
endif

Rav = 6370.

; Retrieve raytracing parameters from structure
radar = rt_info.name
caldat, rt_data.juls[*,b], month, day, year, hours, minutes
tdate 	= year*10000L + month*100L + day

; Controls values of time depending on chosen plot parameter
if ~keyword_set(time) then begin
	case param of
		'day': 	time = hours[0]*100L + minutes[0]
		'dayn': time = hours[0]*100L + minutes[0]
		'daydiff': time = hours[0]*100L + minutes[0]
		'ray': 	begin
						if ~keyword_set(time) then begin
							time = hours[0]*100L + minutes[0]
							prinfo, 'No time provided, trying for start time: '+STRTRIM(time, 2)
						endif else $
							time = time[0]
						end
		'diff':	begin
						if ~keyword_set(time) then begin
							time = hours[0]*100L + minutes[0]
							prinfo, 'No time provided, trying for start and end time: '+$
								STRTRIM(time[0], 2)+'-'+STRTRIM(time[1], 2)
						endif
						if n_elements(time) ne 2 then begin
							prinfo, 'Incorect number of elements in TIME for this parameter '+param
							return
						endif
						end
		else:	prinfo, 'Invalid parameter'
	endcase
endif
parse_time, time, hour, minute, fhour, fminute
if n_elements(time eq 1) then begin
	fhour = hour
	fminute = minute
endif
if ~keyword_set(date) then $
	date = tdate[0]

; Selects proper index in run (initial and final if DIFF is used)
timeind = where(tdate eq date and hours eq hour and minutes eq minute)
ftimeind = where(tdate eq date and hours eq fhour and minutes eq fminute, cc)
if cc eq 0 then $
	ftimeind = where(hours eq fhour and minutes eq fminute, cc)
juls = julday(month[timeind], day[timeind], year[timeind], hours[timeind], minutes[timeind])
fjuls = julday(month[ftimeind], day[ftimeind], year[ftimeind], hours[ftimeind], minutes[ftimeind])


; Open postscript if desired
if keyword_set(ps) then begin
	ps_open, '~/Desktop/ray_'+radar+STRTRIM(beam,2)+'_'+STRTRIM(date,2)+'_'+ $
		STRTRIM(STRING(time[0],format='(I04)'),2)+rt_info.timez+'_'+param+'.ps', /no_init
	clear_page
endif

; Adjust parameters for current device
if strcmp(strlowcase(!D.NAME),'ps') then begin
	charsize = 1.
	position = [.08,.2,.88,.8]
	bpos = [.895,.18,.91,.55]
	if strcmp(param,'day') or strcmp(param,'dayn') or strcmp(param,'daydiff') then begin
		position = [.08,.2,.88,.6]
		bpos = [.895,.2,.91,.6]
	endif
endif else begin
	WINDOW, xsize=1100, ysize=500
	charsize = 2.
	position = [.08,.2,.88,.8]
	bpos = [.895,.18,.91,.75]
endelse

; Set color scale
if ~keyword_set(scale) then begin
	case param of
		'ray': dens_range = [10., 12.]
		'diff': dens_range = [0.5, 1.5]
		'daydiff': dens_range = [0.5, 1.5]
		'day': dens_range = [.1, 5.]
		'dayn': dens_range = [.0, 1.]
	endcase
endif else $
	dens_range = scale

; Altitude distribution (step adjusted for #elements with fixed 500km altitude range starting at 60km)
alts = 60. + findgen(n_elements(rt_data.edens[0,b,*,0]))*500./n_elements(rt_data.edens[0,b,*,0])

; Which latitude/longitude index to plot for vertical electron profile (default is middle)
thtindex = n_elements(rt_data.edens[0,b,0,*])/2L
	
;- colorbar for e densities
bottom = 2
ncolors = 245
top = bottom + ncolors
set_bottom, bottom
set_colorsteps, ncolors
charthick = 2


;*****************************************************************************
; Plot for param DAY
;*****************************************************************************
if strcmp(param, 'day') or strcmp(param, 'dayn') or strcmp(param, 'daydiff') then begin
	; Find sunrise, noon and sunset
	rad_calc_sunset, date, rt_info.name, beam, rt_info.ngates, $
		risetime=risetime, settime=settime, solnoon=solnoon
	
	; Number of time steps
	nt = n_elements(rt_data.juls[*,b])-1

	; Plot layout
	yran = [0., 500.]
	xran = [rt_info.sjul, rt_info.fjul]
	plot, xran, yran, /nodata, xstyle=5, ystyle=5, position=position
	
	; Fill plot
	for i=0,nt-1 do begin
		for j=0,n_elements(rt_data.edens[0,b,*,0])-1 do begin
			if alts[j] lt yran[1] then begin
				xx = [rt_data.juls[i,b], rt_data.juls[i+1,b], $
							rt_data.juls[i+1,b], rt_data.juls[i,b]]
				yy = [alts[j], alts[j], alts[j+1], alts[j+1]]

				col = bytscl((rt_data.edens[i,b,j,thtindex])*1e-11, min=dens_range[0], max=dens_range[1], top=top) + byte(bottom)
				if strcmp(param, 'dayn') then begin
					nrefl = sqrt(1 - 80.5e-12*(rt_data.edens[i,b,j,thtindex])/rt_data.tfreq[i,b])
					col = bytscl(nrefl, min=dens_range[0], max=dens_range[1], top=top) + byte(bottom)
				endif
				if strcmp(param, 'daydiff') then begin
					noonjul = min(rt_data.juls[*,b] - solnoon[round(rt_info.ngates/2.)], noonind, /abs)
					caldat, rt_data.juls[noonind,b], nmonth, nday, nyear, nhr, nmn
					redens = rt_data.edens[i,b,j,thtindex]/rt_data.edens[noonind[0],j]
					col = bytscl(redens, min=dens_range[0], max=dens_range[1], top=top) + byte(bottom)
				endif
				
				polyfill, xx, yy, color=col, noclip=0
			endif
		endfor
	endfor

	if ~keyword_set(nosun) then begin
		; plot sunrise/sunset/solar noon
			oplot, [risetime[round(rt_info.ngates/2.)], risetime[round(rt_info.ngates/2.)]], yran, $
					linestyle=2, thick=3
			oplot, [settime[round(rt_info.ngates/2.)], settime[round(rt_info.ngates/2.)]], yran, $
					linestyle=2, thick=3
			oplot, [solnoon[round(rt_info.ngates/2.)], solnoon[round(rt_info.ngates/2.)]], yran, $
					linestyle=2, thick=3
	endif

	xticks = get_xticks(rt_info.sjul, rt_info.fjul, xminor=_xminor)
	plot, [0,0], /nodata, position=position, $
		charthick=charthick, charsize=charsize, $
		yrange=yran, xrange=xran, $
		xstyle=1, ystyle=1, xtitle='Time (UT)', ytitle='Altitude [km]', $
		xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
		xtickformat='label_date', ytickformat=_ytickformat, $
		xtickname=_xtickname, ytickname=_ytickname

	; Date and time
	titledate = format_juldate(rt_data.juls[timeind,b], /date)
	xyouts, .5 * (xran[0] + xran[1]), yran[1] + .05*(yran[1] - yran[0]), $
		titledate, align=0.5, charsize=charsize, charthick=charthick
endif


;*****************************************************************************
; Plot for param RAY or DIFF
;*****************************************************************************
maxr = 2000.
maxh = 500.
if ~strcmp(param, 'day') and ~strcmp(param, 'dayn') and ~strcmp(param, 'daydiff') then begin
	tht0 = maxr/Rav/2.
	xmin = -(Rav + maxh) * sin (tht0)
	xmax = (Rav + maxh) * sin (tht0)
	xran = [xmin, xmax*1.01]
	ymin = Rav * cos (tht0)
	ymax = Rav + maxh
	yran = [ymin, ymax*1.01]
	plot, xran, yran, /nodata, xstyle=5, ystyle=5, /iso, position=position

	; latitude/longitude distribution (expressed as angle from radar with Earth center)
	thetaNe = findgen(n_elements(rt_data.edens[timeind,b,0,*]))*2500./Rav/n_elements(rt_data.edens[timeind,b,0,*])

	; Electron densities
	edens = reform(rt_data.edens[timeind,b,*,*])
	if strcmp(param,'diff') then begin
		fedens = rt_data.edens[ftimeind,b,*,*]
		edens = fedens/edens
	endif else $
		edens = alog10(edens)

	nalt = n_elements(alts)
	ntht = n_elements(thetaNe)
	dn = 1
	for i=0,ntht-1-dn,dn do begin
		if thetaNe[i] lt maxr/Rav then begin
			for j=0,nalt-1-dn,dn do begin
				if alts[j+dn] le maxh and thetaNe[i+dn] le maxr/Rav then begin
					xx = [(Rav+alts[j])*sin(-tht0 + thetaNe[i]), (Rav+alts[j])*sin(-tht0 + thetaNe[i+dn]), $
						(Rav+alts[j+dn])*sin(-tht0 + thetaNe[i+dn]), (Rav+alts[j+dn])*sin(-tht0 + thetaNe[i])]

					yy = [(Rav+alts[j])*cos(-tht0 + thetaNe[i]), (Rav+alts[j])*cos(-tht0 + thetaNe[i+dn]), $
						(Rav+alts[j+dn])*cos(-tht0 + thetaNe[i+dn]), (Rav+alts[j+dn])*cos(-tht0 + thetaNe[i])]

					col = bytscl(edens[j,i], min=dens_range[0], max=dens_range[1], top=top) + byte(bottom)

					polyfill, xx, yy, color=col, noclip=0
				endif
			endfor
		endif
	endfor

; Axis and formating
	;- plot graph limits
	; Left and right axis
	oplot, [-Rav*sin(tht0),xmin], [ymin, (Rav+maxh)*cos(tht0)], thick=2
	oplot, [Rav*sin(tht0),xmax], [ymin, (Rav+maxh)*cos(tht0)], thick=2
	; Top and bottom axis
	thetas = -tht0 + findgen(101)*(2.*tht0)/100.
	oplot, Rav*sin(thetas), Rav*cos(thetas), thick=2
	oplot, (Rav+maxh)*sin(thetas), (Rav+maxh)*cos(thetas), thick=2

	; Altitude markers (grid)
	vline = 100.
	for nl=0,3 do begin
		xx = (Rav+vline)*sin(thetas)
		yy = (Rav+vline)*cos(thetas)
		ang = tht0 * !radeg
		oplot, xx, yy, thick=2, linestyle=2
		xyouts, xx[0]*1.01, yy[0], STRTRIM(string(vline,format='(I3)'),2), align=1., $
			charsize=charsize, charthick=charthick, orientation=ang
		vline += 100.
	endfor
	; Axis title
	xyouts, xmin*1.12, .5 * (ymin + ymax), $
			'Altitude [km]', alignment = .7, orientation = ang+90., $
			charthick=charthick, charsize=charsize

	; Range markers (grid)
	hline = 0.
	for nl=0,4 do begin
		xx = [Rav*sin(-tht0 + hline/Rav),(Rav+maxh)*sin(-tht0 + hline/Rav)]
		yy = [Rav*cos(-tht0 + hline/Rav), (Rav+maxh)*cos(-tht0 + hline/Rav)]
		ang = -(-tht0 + hline/Rav) * !radeg
		oplot, xx, yy, thick=2, linestyle=2
		xyouts, xx[0], yy[0]-.1*(ymax-ymin), STRTRIM(string(hline,format='(I4)'),2), align=0.5, $
			charsize=charsize, charthick=charthick, orientation=ang
		hline += 500.
	endfor
	; Axis title
	xyouts, .5 * (xmin + xmax), ymin - .1 * (ymax - ymin), 'Range [km]', $
		alignment=.5, charthick=charthick, charsize=charsize

	; Date and time
	case param of
		'ray': titledate = STRMID(format_juldate(rt_data.juls[timeind]),0,17)
		'diff': titledate = STRMID(format_juldate(rt_data.juls[ftimeind]),0,17)+'/'+$
							format_juldate(rt_data.juls[timeind],/short_time)+' UT'
	endcase
	xyouts, .5 * (xmin + xmax), ymax + .1*(ymax - ymin), $
		titledate, align=0.5, charsize=charsize, charthick=charthick
endif


; Color bar
case param of
	'ray': 	titlelegend = 'Log!I10!N(Electron Density [m!E-3!N])'
	'diff': titlelegend = 'Electron density ratio'
	'day':	titlelegend = 'Electron Density [10!E11!Nm!E-3!N]'
	'dayn':	titlelegend = 'Index of refraction'
	'daydiff':	titlelegend = 'Electron density ratio'
endcase
plot_colorbar, /vert, charthick=charthick, /continuous, $
	nlevels=4, scale=dens_range, position=bpos, charsize=charsize, $
	legend=titlelegend, /no_rotate, $
	level_format='(F5.2)', /keep_first_last_label

; Page title
title = 'Ray-tracing results'
subtitle = 'Radar: '+rt_info.name+', Beam '+STRTRIM(beam,2)+', Freq. '+$
	STRTRIM(string(rt_data.tfreq[timeind,b],format='(F5.2)'),2)+' MHz'
plot_title, title, subtitle


if keyword_set(ps) then $
	ps_close, /no_init


END