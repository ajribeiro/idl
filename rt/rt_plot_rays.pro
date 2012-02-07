;+
; NAME:
; RT_PLOT_RAYS
;
; PURPOSE:
; This procedure plots the ray paths, magnetic field lines, and orthogonality zones.
; PREREQUISITE: RT_RUN
;
; CATEGORY:
; Graphics
;
; CALLING SEQUENCE:
; RT_PLOT_RAYS, time, blines=blines, refl=refl, gates=gates
;
; INPUTS:
; TIME: time of your raytracing run for which you want to plot the ray paths
;
; KEYWORD PARAMETERS:
; BLINES: set this keyword to plot the magnetic field lines
;
; REFL: set this keyword to show the orthogonality areas
;
; GATES: set this keyword to plot markers every 10 range gates
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
PRO	rt_plot_rays, time, date=date, beam=beam, blines=blines, refl=refl, gates=gates, hm=hm, $
			rthick=rthick, ps=ps, scale=scale, scatter=scatter, gscatter=gscatter, dirname=dirname

common rt_data_blk

help, rt_info, /st, output=infout
if n_elements(infout) le 2 then begin
	print, 'No data present'
	return
endif

Rav = 6370.

if ~keyword_set(rthick) then $
	rthick = 1

if ~keyword_set(beam) then begin
	nbeams = n_elements(rt_data.beam[0,*])
	ib = 0
	beam = rt_data.beam[0,ib]
endif
binds = where(rt_data.beam[0,*] eq beam)
ib = binds[0]

; Retrieve raytracing parameters from structure
radar = rt_info.name
beam	= beam
caldat, rt_data.juls, month, day, year, hours, minutes
tdate 	= year*10000L + month*100L + day

parse_time, time, hour, minute
if ~keyword_set(date) then $
	date = tdate[0]
timeind = where(tdate eq date and hours eq hour and minutes eq minute)
if timeind[0] ge n_elements(rt_data.juls) or timeind[0] lt 0 then begin
	print, 'No data present'
	return
endif
juls = julday(month[timeind], day[timeind], year[timeind], hours[timeind], minutes[timeind])

; Test for data availability
rt_read_rays, date, radar, time, radpos=radpos, thtpos=thtpos, grppth=grppth, raysteps=raysteps, code=code, dirname=dirname
if ~code then $
	return

; If data is present, limit it to selected beam
radpos = reform(radpos[ib,*,*])
thtpos = reform(thtpos[ib,*,*])
grppth = reform(grppth[ib,*,*])
raysteps = reform(raysteps[ib,*])

; Open postscript if desired
if keyword_set(ps) then begin
	ps_open, '~/Desktop/ray_'+radar+STRTRIM(beam,2)+'_'+STRTRIM(date,2)+'_'+ $
		STRTRIM(STRING(time,format='(I04)'),2)+rt_info.timez+'.ps', /no_init
endif

; Adjust parameters for current device
if strcmp(strlowcase(!D.NAME),'ps') then begin
	charsize = 1.
	position = [.08,.2,.88,.8]
	bpos = [.895,.15,.91,.55]
endif else begin
	WINDOW, xsize=1100, ysize=500
	charsize = 2.
	position = [.08,.2,.88,.8]
	bpos = [.895,.15,.91,.75]
endelse

; Generate plotting area
maxr = 2000.
maxh = 500.
tht0 = maxr/Rav/2.
xmin = -(Rav + maxh) * sin (tht0)
xmax = (Rav + maxh) * sin (tht0)
xran = [xmin, xmax*1.01]
ymin = Rav * cos (tht0)
ymax = Rav + maxh
yran = [ymin, ymax*1.01]
plot, xran, yran, /nodata, xstyle=5, ystyle=5, /iso, position=position


;*****************************************************************************
; Electron densities
;*****************************************************************************
;- colorbar for e densities
loadct, 0, file='/tmp/colors2.tbl'
if ~keyword_set(scale) then $
	scale = [10., 12.]
dens_range = scale
charthick = 2

; latitude/longitude distribution (expressed as angle from radar with Earth center)
thetaNe = findgen(n_elements(rt_data.edens[timeind,ib,0,*]))*2500./Rav/n_elements(rt_data.edens[timeind,ib,0,*])

; Altitude distribution (step adjusted for #elements with fixed 500km altitude range starting at 60km)
altsNe = 60. + findgen(n_elements(rt_data.edens[0,ib,*,0]))*500./n_elements(rt_data.edens[0,ib,*,0])

; Electron densities
edens = reform(rt_data.edens[timeind,ib,*,*])
edens = alog10(edens)

nalt = n_elements(altsNe)
ntht = n_elements(thetaNe)
dn = 1
for i=0,ntht-1-dn,dn do begin
	if thetaNe[i] lt maxr/Rav then begin
		for j=0,nalt-1-dn,dn do begin
			if altsNe[j+dn] le maxh and thetaNe[i+dn] le maxr/Rav then begin
				xx = [(Rav+altsNe[j])*sin(-tht0 + thetaNe[i]), (Rav+altsNe[j])*sin(-tht0 + thetaNe[i+dn]), $
					(Rav+altsNe[j+dn])*sin(-tht0 + thetaNe[i+dn]), (Rav+altsNe[j+dn])*sin(-tht0 + thetaNe[i])]

				yy = [(Rav+altsNe[j])*cos(-tht0 + thetaNe[i]), (Rav+altsNe[j])*cos(-tht0 + thetaNe[i+dn]), $
					(Rav+altsNe[j+dn])*cos(-tht0 + thetaNe[i+dn]), (Rav+altsNe[j+dn])*cos(-tht0 + thetaNe[i])]

				col = bytscl(edens[j,i], min=dens_range[0], max=dens_range[1], top=251) + 3b

				polyfill, xx, yy, color=col, noclip=0
			endif
		endfor
	endif
endfor


;*****************************************************************************
;- plot rays
;*****************************************************************************
loadct, 0
nrays = n_elements(radpos[*,0])
hmax = 0.
cc = 0
for nr=0,nrays-1,10 do begin
	nrsteps = raysteps[nr]
	for ns=1,nrsteps-1 do begin
		xx = [radpos[nr,ns-1]*1e-3*sin(-tht0 + thtpos[nr,ns-1]), $
					radpos[nr,ns]*1e-3*sin(-tht0 + thtpos[nr,ns])]
		yy = [radpos[nr,ns-1]*1e-3*cos(-tht0 + thtpos[nr,ns-1]), $
					radpos[nr,ns]*1e-3*cos(-tht0 + thtpos[nr,ns])]
		if thtpos[nr,ns] lt maxr/Rav then $
			oplot, xx, yy, thick=rthick, color=100
        endfor
	; finds ray touching ground and max reflection altitude
	if min(radpos[nr,2:nrsteps-1]*1e-3) le Rav+0.1 and max(radpos[nr,2:nrsteps-1]*1e-3) gt hmax then begin
		hmax = max(radpos[nr,2:nrsteps-1]*1e-3)
		indmax = [nr, where(radpos[nr,2:nrsteps-1]*1e-3 eq hmax)]
		cc = cc + 1
	endif
endfor

; Plot highest reflecting ray
if keyword_set(hm) and cc gt 0 then begin
	nr = indmax[0]
	for ns=1,raysteps[nr]-1 do begin
		xx = [radpos[nr,ns-1]*1e-3*sin(-tht0 + thtpos[nr,ns-1]), $
					radpos[nr,ns]*1e-3*sin(-tht0 + thtpos[nr,ns])]
		yy = [radpos[nr,ns-1]*1e-3*cos(-tht0 + thtpos[nr,ns-1]), $
					radpos[nr,ns]*1e-3*cos(-tht0 + thtpos[nr,ns])]
		if thtpos[nr,ns] lt maxr/Rav then $
			oplot, xx, yy, thick=rthick*2, color=100
	endfor
endif


;*****************************************************************************
;- add reflection in red if perp to Blines
;*****************************************************************************
loadct, 3
if keyword_set(refl) then begin
	load_usersym, /circle
	; Set tolerance (in degree) for how much deviation from perfect aspect condition is allowed
	tol = 1.

	; latitude/longitude distribution (expressed as angle from radar with Earth center)
	ndip = n_elements(rt_data.dip[timeind,ib,0,*])
	thtdip = findgen(ndip)*2500./Rav/ndip

	; Set minimum theta step to consider constant B vector
	dtht = mean(thtdip[1:ndip-1]-thtdip[0:ndip-2])

	for nr=0,nrays-1 do begin
		nrsteps = raysteps[nr]
		for ns=1,nrsteps-1 do begin
			if grppth[nr,ns-1] gt 180e3 and thtpos[nr,ns] lt maxr/Rav and radpos[nr,ns]*1e-3 gt Rav+80. then begin

				; Calculate k vector
				kx = radpos[nr,ns]*sin(thtpos[nr,ns]-thtpos[nr,ns-1])
				kz = radpos[nr,ns]*cos(thtpos[nr,ns]-thtpos[nr,ns-1]) - radpos[nr,ns-1]
				kvect = sqrt( kx^2. + kz^2. )

				; Position of the current ray step in the plotting frame
				xx = [radpos[nr,ns-1]*1e-3*sin(-tht0 + thtpos[nr,ns-1]), $
							radpos[nr,ns]*1e-3*sin(-tht0 + thtpos[nr,ns])]
				zz = [radpos[nr,ns-1]*1e-3*cos(-tht0 + thtpos[nr,ns-1]), $
							radpos[nr,ns]*1e-3*cos(-tht0 + thtpos[nr,ns])]

				; Middle of the step: position and index in B grid
				midtht = (thtpos[nr,ns]-thtpos[nr,ns-1])/2. + thtpos[nr,ns-1]
				diff = min(midtht-thtdip, thtind, /abs)

				; Dip and declination at this position
				middip = rt_data.dip[timeind,ib,0,thtind]
				middec = rt_data.dip[timeind,ib,1,thtind]

				; calculate vector magnetic field
				Bx = cos(-middip*!dtor) * cos(rt_data.azim[timeind[0],ib]*!dtor - middec*!dtor)
				Bz = sin(-middip*!dtor)

				; calculate cosine of aspect angle
				cos_aspect = (Bx*kx + Bz*kz)/kvect

				if abs(cos_aspect) le cos(!pi/2. - tol*!dtor) then begin
					plots, xx, zz, color=0, thick=1
; 					print, nr*.1+10., ns-1, (grppth[nr,ns-1]*1e-3-180.)/45., radpos[nr,ns-1]*1e-3-Rav
				endif

			endif
		; end ray steps loop
		endfor
	; end rays loop
	endfor
endif


;*****************************************************************************
;- plot range gates
;*****************************************************************************
loadct, 0
if keyword_set(gates) then begin
	load_usersym, /circle
	dgates = 5*45.
	rgates = 180. + findgen(20)*dgates
	for nr=0,nrays-1 do begin
		nrsteps = raysteps[nr]
		ng = 0
		for ns=1,nrsteps-1 do begin
			if grppth[nr,ns]*1e-3 gt rgates[ng] and thtpos[nr,ns] lt maxr/Rav then begin
				xx = [radpos[nr,ns-1]*1e-3*sin(-tht0 + thtpos[nr,ns-1]), $
							radpos[nr,ns]*1e-3*sin(-tht0 + thtpos[nr,ns])]
				yy = [radpos[nr,ns-1]*1e-3*cos(-tht0 + thtpos[nr,ns-1]), $
							radpos[nr,ns]*1e-3*cos(-tht0 + thtpos[nr,ns])]
				xg = (rgates[ng] - grppth[nr,ns-1]*1e-3)/(grppth[nr,ns]*1e-3 - grppth[nr,ns-1]*1e-3) $
							*(xx[1]-xx[0]) + xx[0]
				yg = (rgates[ng] - grppth[nr,ns-1]*1e-3)/(grppth[nr,ns]*1e-3 - grppth[nr,ns-1]*1e-3) $
							*(yy[1]-yy[0]) + yy[0]
				plots, xg, yg, color=255, thick=1, psym=8, symsize=.1
				ng = ng + 1
			endif
		endfor
	endfor
endif


;*****************************************************************************
;- plot magnetic field lines
;*****************************************************************************
if keyword_set(blines) then begin
	loadct, 7
	; Calculates angle between ray direction (i.e., beam azimuth) and magnetic field declination
	rel_az = rt_data.azim[timeind[0],ib]*!dtor - rt_data.dip[timeind[0],ib,1,*]*!dtor
	; Calculates apparent dip angle in the plane of ray propagation
	dipa = -atan( tan(rt_data.dip[timeind[0],ib,0,*]*!dtor) / cos(rel_az) )
	; latitude/longitude distribution (expressed as angle from radar with Earth center)
	thtdip = findgen(n_elements(rt_data.dip[timeind[0],ib,0,*]))*2500./Rav/n_elements(rt_data.dip[timeind[0],ib,0,*])

	; Goes through the available dip angle values to plot 10 lines
	ntht = 0
	nblines = 0
	while ntht lt n_elements(thtdip)-1 and thtdip[ntht]+dtht le maxr/Rav do begin
		if dipa[0] lt 0. then $
			alt = maxh $
		else $
			alt = 0.
		dalt = 0.
		; Altitude loop for a given line
		while alt le maxh and alt ge 0. and ntht lt n_elements(thtdip)-1 and thtdip[ntht]+dtht le maxr/Rav do begin
			; local slope of the field line
			dtht = abs(thtdip[1]-thtdip[0])
			dalt = (Rav + alt) * (cos(abs(dipa[ntht]))/cos(abs(dipa[ntht]) - dtht) - 1. )
			if alt+dalt lt 0. then begin
				dalt = -alt
				dtht = abs(dipa[ntht]) - acos( (Rav+alt)/(Rav+alt+dalt) * cos(abs(dipa[ntht])) )
			endif
			if alt+dalt gt maxh then begin
				dalt = maxh - alt
				dtht = abs(dipa[ntht]) - acos( (Rav+alt)/(Rav+alt+dalt) * cos(abs(dipa[ntht])) )
			endif
; 			print, nblines, alt, dalt, dtht*!radeg
			xx = [(alt + Rav)*sin(-tht0 + thtdip[ntht]), $
						(alt + dalt + Rav)*sin(-tht0 + thtdip[ntht]+dtht)]
			yy = [(alt + Rav)*cos(-tht0 + thtdip[ntht]), $
						(alt + dalt + Rav)*cos(-tht0 + thtdip[ntht]+dtht)]
			oplot, xx, yy, color=200, thick=2.
			; Move on to the next position and corresponding altitude
			ntht = ntht + 1
			alt = alt + dalt
		endwhile
		; Move on to the next line, spaced so that we fit 10 lines
		nblines = nblines + 1
		ntht = nblines*round(n_elements(thtdip)/10.)
	endwhile

endif


;*****************************************************************************
;- plot scattering volume
;*****************************************************************************
if keyword_set(scatter) then begin
	alt = rt_data.altitude[timeind,ib,*]
	thtscat = rt_data.grange[timeind,ib,*]/Rav
	xx = (alt + Rav)*sin(-tht0 + thtscat)
	yy = (alt + Rav)*cos(-tht0 + thtscat)
	plots, xx,yy, psym=4, thick=2, symsize=1, color=255
endif

if keyword_set(gscatter) then begin
    gscat = where(rt_data.gscatter[timeind,ib,*] eq 1b and rt_data.grange[timeind,ib,*] le 2000., cc)
    if cc gt 0 then begin
        thtscat = rt_data.grange[timeind,ib,gscat]/Rav
        xx = (Rav + 1.)*sin(-tht0 + thtscat)
        yy = (Rav + 1.)*cos(-tht0 + thtscat)
        plots, xx, yy, thick=8
    endif
endif

;*****************************************************************************
; Axis and formating
;*****************************************************************************
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
xyouts, .5 * (xmin + xmax), ymax + .2*(ymax - ymin), $
	STRMID(format_juldate(rt_data.juls[timeind]),0,17), $
	align=0.5, charsize=charsize, charthick=charthick
; Radar info
subtitle = '(IRI-2011) - Radar: '+rt_info.name+', Beam '+STRTRIM(beam,2)+', Freq. '+$
	STRTRIM(string(rt_data.tfreq[timeind],format='(F5.2)'),2)+' MHz'
xyouts, .5 * (xmin + xmax), ymax + .1*(ymax - ymin), $
	subtitle, align=0.5, charsize=charsize, charthick=charthick

; Color bar
loadct, 0, file='/tmp/colors2.tbl'
plot_colorbar, /vert, charthick=charthick, /continuous, $
	nlevels=4, scale=dens_range, position=bpos, charsize=charsize, $
	legend='Log!I10!N(Electron Density [m!E-3!N])', /no_rotate, $
	level_format='(F4.1)', /keep_first_last_label


if keyword_set(ps) then $
	ps_close, /no_init


END
