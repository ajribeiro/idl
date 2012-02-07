;+
; NAME:
; iri_plot_map
;
; PURPOSE:
; This function plots ionospheric parameters:
; 	- electron densities at a given altitude
; 	- NmF2
; 	- hmF2
;
; CATEGORY:
; Ionospheric models
;
; CALLING SEQUENCE:
; iri_plot_map, date, time, ut=ut, param=param, $
;				lati=lati, longi=longi, $
; 			alti=alti, stereo=stereo, coords=coords, $
; 			ps=ps, scale=scale
;
; INPUTS:
; DATE: YYYYMMDD
;
; TIME: HHMM
;
; KEYWORD PARAMETERS:
; ALTI: Altitude [km] at which to compute electron densities. Default 300km
;
; COORDS: 'geog', 'mag', 'mlt'. Only used when the STEREO keyword is set.
; Default is 'geog'.
;
; HEMISPHERE: Only used with STEREO keyword. North = 1, South = -1.
; Default is 1.
;
; LATI: latitude boundaries. Default [-90,90]
;
; LONGI: longitude boundaries. Default [-180,180]
;
; LOG: set this keyword to plot electron densities in log scale
;
; PARAM: 'nel', 'hmf2', 'nmf2', 'tec'
;
; PS: set this keyword to create a postscript on your desktop (calls ps_open and ps_close)
;
; SCALE: scale to plot the chosen parameter(s).
;
; STEREO: set this keyword to plot a stereographic projection instead of cylindrical projection
;
; UT: set this keyword to compute electron densities at UT time instead of LT
;
; PANEL: panel number (3 elements vector: [x_pos, y_pos, npanels])
; i.e., the top left corner panel on a 4 panel display is [0,0,4]
; i.e., the bottom right corner panel on a 4 panel display is [1,1,4]
; if the panel keyword is set, param can only be ONE of the possible choices.
;
; LATDEL: grid spacing in latitude
;
; LONDEL: grid spacing in longitude
;
; COMMON BLOCKS:
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
; Written by Sebastien de Larquier, Aug. 2011
pro iri_plot_map, date, time, ut=ut, param=param, $
			lati=lati, longi=longi, alti=alti, $
			stereo=stereo, hemisphere=hemisphere, coords=coords, $
			ps=ps, scale=scale, log=log, isotropic=isotropic, $
			panel=panel, no_title=no_title, overplot=overplot, no_bar=no_bar, $
			latdel=latde, londel=londel

base = '~/Desktop/'

; Position if not provided
if ~keyword_set(alti) then $
	alti = 300.
if ~keyword_set(lati) then $
	lati = [-90.,90.]
if ~keyword_set(longi) then $
	longi = [-180.,180.]
if ~keyword_set(coords) then $
	coords = 'geog'
if ~keyword_set(hemisphere) then $
	hemisphere = 1

; Default parameter to plot
if ~keyword_set(param) then $
	param = 'nel'

; Rotate map to solar local time if geographic coordinates and ut time
parse_date, date, year, month, day
parse_time, time, hour, minutes
dhour = hour + minutes/60.
if strcmp(coords,'geog') or strcmp(coords,'mlt') and keyword_set(ut) then $
	rotate = dhour*360./24. $
else $
	rotate = 0.
if keyword_set(ut) then begin
	STI = 'UT'
	clon = (dhour*360./24. + 180.) mod 360.
endif else begin
	STI = 'LT'
	clon = 0.
endelse

; Controls latitude and longitude if stereo projection
if keyword_set(stereo) then begin
	case hemisphere of
		-1: begin
			if lati[0] gt 0. or lati[1] gt 0. then $
				lati = [-80., -30.]
			lim = 90.+lati[1]
		end
		1: begin
			if lati[0] lt 0. or lati[1] lt 0. then $
				lati = [30., 80.]
			lim = 90.-lati[0]
		end
	endcase
endif

; Call iri_run
nlats = 90
nlons = 180
dlat = (lati[1]-lati[0])/nlats
dlon = (longi[1]-longi[0])/nlons
lat = lati[0] + findgen(nlats)*dlat
lon = longi[0] + findgen(nlons)*dlon
iri_run, date, time, ut=ut, param=0, lati=lati, longi=longi, alti=alti, $
		nel=nel, hmf2=hmf2, nmf2=nmf2, tec=tec

; Calculates grid
if ~keyword_set(latdel) then $
	latdel = 20.
if ~keyword_set(londel) then $
	londel = 30.
xtickv = lon[0] + findgen(ceil(abs(longi[1]-longi[0])/londel))*londel
ytickv = lat[0] + findgen(ceil(abs(lati[1]-lati[0])/latdel))*latdel

; Open postscript
if keyword_set(ps) then $
	ps_open, base+'IRI_'+STRTRIM(date,2)+'_'+STRTRIM(time,2)+'.ps', /no_init

; Initialize layout
if keyword_set(panel) then begin
	apanel = panel
	if n_elements(param) gt 1 then $
		stop, 'if using the panel keyword, param can only have one value'
	ymaps = round(sqrt(apanel[2]))
	xmaps = round(apanel[2]/float(ymaps))
	charsize = get_charsize(xmaps, ymaps)
endif else begin
	apanel = [0,0,n_elements(param)]
	ymaps = round(sqrt(apanel[2]))
	xmaps = round(apanel[2]/float(ymaps))
	charsize = get_charsize(xmaps, ymaps)
endelse
xmap = apanel[0]
ymap = apanel[1]
position = define_panel(xmaps, ymaps, xmap, ymap, /bar, /no_title)

; Create page
if ymaps gt 1 then $
	set_format, /portrait, /sardines, /tokyo $
else $
	set_format, /landscape
if ~keyword_set(overplot) and ~keyword_set(panel) then $
	clear_page
	
; Title
if ~keyword_set(no_title) then begin
	title = 'IRI - '+STRTRIM(month,2)+'/'+STRTRIM(day,2)+'/'+STRTRIM(year,2)+', ' $
		+STRTRIM(string(hour,format='(I02)'),2)+':'+STRTRIM(string(minutes,format='(I02)'),2)+STI
endif

; Calculate coordinates
if strcmp(coords, 'magn') or strcmp(coords, 'mlt') then begin
	tmp = CNVCOORD(lat,lon,[1.,1.,1.,1.,1.])
	lat = reform(tmp[0,*])
	lon = reform(tmp[1,*])
endif 
xx = fltarr(nlats+1,nlons+1)
yy = fltarr(nlats+1,nlons+1)
for ilon=0,nlons do begin
	xx[0:nlats-1,ilon] = lat + dlat/2.
	xx[nlats,ilon] = lat[nlats-1] + dlat
endfor
for ilat=0,nlats do begin
	yy[ilat,0:nlons-1] = lon - dlon/2.
	yy[ilat,nlons] = lon[nlons-1] + dlon/2.
endfor

; Recalculates and rotates coordinates if stereo
if keyword_set(stereo) then begin
	for ilon=0,nlons do begin
		tmp = calc_stereo_coords(xx[*,ilon],yy[*,ilon])
		x1 = tmp[0,*]
		y1 = tmp[1,*]
		xx[*,ilon] = cos(rotate*!dtor-hemisphere*!PI/2.)*x1 - sin(rotate*!dtor-hemisphere*!PI/2.)*y1
		yy[*,ilon] = sin(rotate*!dtor-hemisphere*!PI/2.)*x1 + cos(rotate*!dtor-hemisphere*!PI/2.)*y1
	endfor
endif

; Plot in the desired projection and coordinate system
for np=0,n_elements(param)-1 do begin

	if ~keyword_set(log) then $
		label_scale = '10!E11!N' $
	else $
		label_scale = 'log '
	
	if strcmp(param[np],'nmf2') then begin
		legend = 'NmF!I2!N ['+label_scale+'m!E-3!N]'
		if ~keyword_set(scale) then begin
			if keyword_set(log) then $
				fscale = [floor(min(alog10(nmf2*1e11))*10L)/10.,ceil(max(alog10(nmf2*1e11))*10L)/10.] $
			else $
				fscale = [floor(min(nmf2)*10.)/10.,ceil(max(nmf2)*10.)/10.]
		endif else $
			fscale = scale[*,np]
			
		if keyword_set(log) then $
			zdata = alog10(nmf2*1e11) $
		else $
			zdata = nmf2
	endif
	
	if strcmp(param[np],'nel') then begin
		legend = 'Nel ['+label_scale+'m!E-3!N]'
		if ~keyword_set(scale) then begin
			if keyword_set(log) then $
				fscale = [floor(min(alog10(nel*1e11))*10L)/10.,ceil(max(alog10(nel*1e11))*10L)/10.] $
			else $
				fscale = [floor(min(nel*10.))/10.,ceil(max(nel*10.))/10.]
		endif else $
			fscale = scale[*,np]
			
		if keyword_set(log) then $
			zdata = alog10(nel*1e11) $
		else $
			zdata = nel
	endif
	
	if strcmp(param[np],'hmf2') then begin
		legend = 'hmF!I2!N [km]'
		if ~keyword_set(scale) then $
			fscale = [fix(min(hmf2)/10L)*10.,fix(max(hmf2)/10L)*10.] $
		else $
			fscale = scale[*,np]
		
		zdata = hmf2
	endif

	if strcmp(param[np],'tec') then begin
		legend = 'TEC [TEC units]'
		if ~keyword_set(scale) then $
			fscale = [min(tec),max(tec)] $
		else $
			fscale = scale[*,np]

		zdata = tec
	endif

	; Initialize map panel, label=2
	bpos = define_cb_position(position, /vertical, gap=0.01, width=0.01)
	if ~keyword_set(stereo) then begin
		MAP_SET, 0, clon, 0, /cylindrical, /noerase, charsize=charsize, $
			position=position, title=title, isotropic=isotropic, $
			limit=[lati[0],longi[0],lati[1],longi[1]]
	endif else begin
		map_plot_panel, position=position, isotropic=isotropic, hemisphere=hemisphere, $
			date=date, coords=coords, xrange=[-lim,lim], yrange=[-lim,lim], $
			rotate=rotate, /no_fill, /no_coast, /no_grid, /no_label, title=title
	endelse

	; Plot parameter
	for ilat=0,nlats-2 do begin
		for ilon=0,nlons-1 do begin
			col = bytscl(zdata[ilat,ilon], min=fscale[0], max=fscale[1], top=250) + 2
			
			; finally plot the point
			polyfill, [yy[ilat,ilon], yy[ilat+1,ilon], yy[ilat+1,ilon+1], yy[ilat,ilon+1]], $
					[xx[ilat,ilon], xx[ilat+1,ilon], xx[ilat+1,ilon+1], xx[ilat,ilon+1]], $
					col=col
		endfor
	endfor

	;  Overplots continents and grid
	if ~keyword_set(stereo) then begin
		MAP_CONTINENTS, /coast, /NOERASE
		MAP_GRID, charsize=charsize, color=255., $
			latdel=latdel, londel=londel
		plot, [0,0], /nodata, position=position, xcharsize=charsize, xtickv=xtickv, $
			xticklen=0.000001, ycharsize=charsize, ytickv=ytickv, yticklen=0.000001, $
			xrange=longi, yrange=lati, xstyle=1, ystyle=1, $
			xticks=n_elements(xtickv), yticks=n_elements(ytickv)
	endif else begin
		map_plot_panel, position=position, isotropic=isotropic, hemisphere=hemisphere, $
			date=date, coords=coords, xrange=[-lim,lim], yrange=[-lim,lim], $
			rotate=rotate, /no_fill, grid_linecolor=0, coast_linecolor=0
	endelse
	if ~keyword_set(no_bar) then begin
		plot_colorbar, /vert, charthick=2, /bar, /continuous, /no_rotate, $
			scale=fscale, position=bpos, charsize=charsize, $
			legend=legend, level_format='(F4.1)', nlevels=4
	endif
	
	; prepare the next panel if necessary
	if np lt n_elements(param)-1 then begin
		position = define_panel(/next,/bar)
		title = 0
	endif
; end plotting
endfor

; Close postscript
if keyword_set(ps) then $
	ps_close, /no_init



end