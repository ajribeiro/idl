;+ 
; NAME: 
; IGRF_PLOT_MAP
;
; PURPOSE: 
; This function plots magnetic field strength, sip and declination
; 
; CATEGORY: 
; Ionospheric models
; 
; CALLING SEQUENCE:
; IGRF_PLOT_MAP, date, lati=lati, longi=longi, alti=alti, panel=panel
;
; INPUTS:
; DATE: YYYYMMDD
;
; KEYWORD PARAMETERS:
; PARAM: 'field', 'dip', 'dec', 'dipdec'. Default ['field','dip','dec']
;
; LATI: latitude boundaries. Default [-90,90]
;
; LONGI: longitude boundaries. Default [-180,180]
;
; ALTI: altitude value in km. Default 300km
;
; PANEL: panel number (3 elements vector: [x_pos, y_pos, npanels])
; i.e., the top left corner panel on a 4 panel display is [0,0,4]
; i.e., the bottom right corner panel on a 4 panel display is [1,1,4]
; if the panel keyword is set, param can only be ONE of the possible choices.
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
; Use of Namefield
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY:
; Written by Sebastien de Larquier, March 2011
;-
pro		igrf_plot_map, date, param=param, $
			lati=lati, longi=longi, alti=alti, $
			panel=panel, no_title=no_title, overplot=overplot, $
			latdel=latdel, londel=londel

if ~keyword_set(param) then $
	param = ['field','dip','dec']

; Position if not provided
if ~keyword_set(alti) then $
	alti = 300.
if ~keyword_set(lati) then $
	lati = [-90.,90.]
if ~keyword_set(longi) then $
	longi = [-180.,180.]

; Call igrf_run
nlats = 90
nlons = 180
dlat = (lati[1]-lati[0])/nlats
dlon = (longi[1]-longi[0])/nlons
lat = lati[0] + findgen(nlats)*dlat
lon = longi[0] + findgen(nlons)*dlon
igrf_run, date, param=0, lati=lati, longi=longi, alti=alti, $
		farr=farr, diparr=diparr, decarr=decarr

; Calculates grid
if ~keyword_set(latdel) then $
	latdel = 30.
if ~keyword_set(londel) then $
	londel = 60.
xtickv = lon[0] + findgen(ceil(abs(longi[1]-longi[0])/londel))*londel
ytickv = lat[0] + findgen(ceil(abs(lati[1]-lati[0])/latdel))*latdel

; plot maps
if keyword_set(panel) then begin
	if n_elements(param) gt 1 then $
		stop, 'if using the panel keyword, param can only have one value'
	ymaps = round(sqrt(panel[2]))
	xmaps = round(panel[2]/float(ymaps))
	charsize = get_charsize(xmaps, ymaps)
endif else begin
	panel = [0,0,n_elements(param)]
	ymaps = round(sqrt(panel[2]))
	xmaps = round(panel[2]/float(ymaps))
	charsize = get_charsize(xmaps, ymaps)
	if ~keyword_set(overplot) then $
		clear_page
endelse

xmap = panel[0]
ymap = panel[1]
position = define_panel(xmaps, ymaps, xmap, ymap, /bar, with_info=with_info)
bpos = define_cb_position(position, /vertical, gap=0.01, width=0.02)
if ~keyword_set(no_title) then $
	title = 'IGRF-11'
MAP_SET, /cylindrical, title=title, /noerase, charsize=charsize, $
	position=position, limit=[lati[0],longi[0],lati[1],longi[1]]

for np=0,n_elements(param)-1 do begin
	; Field strength
	if strcmp(param[np],'field') then begin
		scale = [20.,60.]
		legend = 'Magnetic field strength [10!E3!NnT]'
		for nlat=1,nlats-1 do begin
			slat = lat[nlat]-dlat/2.
			blat = lat[nlat]+dlat/2.
			for nlon=1,nlons-1 do begin
				slong = lon[nlon]-dlon/2.
				blong = lon[nlon]+dlon/2.
				
		; col = bytscl(dec[nlon,nlat], min=scale[0], max=scale[1], top=252) + 1
				col = get_color_index(farr[nlat,nlon]*1e6, param='power', scale=scale, colorsteps=250.)
				
		; finally plot the point
				POLYFILL,[slong,slong,blong,blong], [slat,blat,blat,slat], $
					COL=col,NOCLIP=0
			endfor
		endfor

		MAP_CONTINENTS, /coast, /NOERASE
		MAP_GRID, charsize=charsize, color=255., $
			latdel=latdel, londel=londel
		plot, [0,0], /nodata, position=position, xcharsize=charsize, xtickv=xtickv, $
			xticklen=0.000001, ycharsize=charsize, ytickv=ytickv, yticklen=0.000001, $
			xrange=longi, yrange=lati, xstyle=1, ystyle=1, $
			xticks=n_elements(xtickv), yticks=n_elements(ytickv)
		plot_colorbar, /vert, charthick=2, /bar, /continuous, /no_rotate, $
			scale=scale, position=bpos, charsize=charsize, $
			legend=legend, level_format='(f4.1)', nlevels=4
	endif

	; Field dip
	if strcmp(param[np],'dip') then begin
		dlabel = -90.+findgen(19)*10.
		contour, transpose(diparr), lon, lat, $
			c_charsize=.5, $
			/overplot, c_labels=dlabel, $
			levels=dlabel, c_thick=(dlabel eq 0.)*2.
	endif

	; Field dec
	if strcmp(param[np],'dec') then begin
		scale = [-60.,60.]
		legend = 'declination [!Eo!N]'
		for nlat=1,nlats-1 do begin
			slat = lat[nlat]-dlat/2.
			blat = lat[nlat]+dlat/2.
			for nlon=1,nlons-1 do begin
				slong = lon[nlon]-dlon/2.
				blong = lon[nlon]+dlon/2.
				
		; col = bytscl(dec[nlon,nlat], min=scale[0], max=scale[1], top=252) + 1
				col = get_color_index(decarr[nlat,nlon], scale=scale, colorsteps=250.)
				
		; finally plot the point
				POLYFILL,[slong,slong,blong,blong], [slat,blat,blat,slat], $
					COL=col,NOCLIP=0
			endfor
		endfor

		MAP_CONTINENTS, /coast, /NOERASE
		MAP_GRID, charsize=charsize, color=255., $
			latdel=latdel, londel=londel
		plot, [0,0], /nodata, position=position, xcharsize=charsize, xtickv=xtickv, $
			xticklen=0.000001, ycharsize=charsize, ytickv=ytickv, yticklen=0.000001, $
			xrange=longi, yrange=lati, xstyle=1, ystyle=1, $
			xticks=n_elements(xtickv), yticks=n_elements(ytickv)
		plot_colorbar, /vert, charthick=2, /bar, /continuous, $
			scale=scale, position=bpos, charsize=charsize, $
			legend=legend, level_format='(f5.1)', nlevels=4
	endif

	; Field dip+dec
	if strcmp(param[np],'dipdec') then begin
		scale = [-60.,60.]
		legend = 'declination [!Eo!N]'
		for nlat=1,nlats-1 do begin
			slat = lat[nlat]-dlat/2.
			blat = lat[nlat]+dlat/2.
			for nlon=1,nlons-1 do begin
				slong = lon[nlon]-dlon/2.
				blong = lon[nlon]+dlon/2.
				
		; col = bytscl(dec[nlon,nlat], min=scale[0], max=scale[1], top=252) + 1
				col = get_color_index(decarr[nlat,nlon], scale=scale, colorsteps=250., param='power')
				
				
		; finally plot the point
				POLYFILL,[slong,slong,blong,blong], [slat,blat,blat,slat], $
					COL=col,NOCLIP=0
			endfor
		endfor
		dlabel = -90.+findgen(19)*10.
		contour, transpose(diparr), lon, lat, $
			c_charsize=.5, $
			/overplot, c_labels=dlabel, $
			levels=dlabel, c_thick=(dlabel eq 0.)*2.

		MAP_CONTINENTS, /coast, /NOERASE
		MAP_GRID, charsize=charsize, color=255., $
			latdel=latdel, londel=londel
		plot, [0,0], /nodata, position=position, xcharsize=charsize, xtickv=xtickv, $
			xticklen=0.000001, ycharsize=charsize, ytickv=ytickv, yticklen=0.000001, $
			xrange=longi, yrange=lati, xstyle=1, ystyle=1, $
			xticks=n_elements(xtickv), yticks=n_elements(ytickv)
		plot_colorbar, /vert, charthick=2, /bar, /continuous, $
			scale=scale, position=bpos, charsize=charsize, $
			legend=legend, level_format='(f5.1)', nlevels=4, /no_rotate
	endif

	; prepare the next panel if necessary
	if np lt n_elements(param)-1 then begin
		position = define_panel(/next,/bar)
		bpos = define_cb_position(position, /vertical, gap=0.01, width=0.02)
		title = 'IGRF-11'
		MAP_SET, /cylindrical, title=title, /noerase, charsize=charsize, $
			position=position, limit=[lati[0],longi[0],lati[1],longi[1]]
	endif
endfor

end
