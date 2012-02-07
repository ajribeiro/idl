;+
; NAME: 
; OVERLAY_GBM
;
; PURPOSE: 
; This procedure plots a marker at the geodetic/geomagnetic position of the specified
; ground-baed magnetometers on a panel created by MAP_PLOT_PANEL.
; 
; CATEGORY: 
; Graphics/Ground-Based Magnetometers
; 
; CALLING SEQUENCE:  
; OVERLAY_GBM, Stats
;
; INPUTS:
; Stats: A scalar or vector of type string containing the stations abbreviation.
;
; KEYWORD PARAMETERS:
; COORDS: Set this keyword to a string indicating the coordinate system in which to plot the position of the station.
;
; DATE: Set this keyword to the date for which you want to overlay the GBMs. Use this
; keyword together with TIME instead of the JUL keyword.
; This keyword only applies when using Magnetic Local Time coordinates.
;
; TIME: Set this keyword to the time for which you want to overlay the GBMs. Use this
; keyword together with DATE instead of the JUL keyword.
; This keyword only applies when using Magnetic Local Time coordinates.
;
; JUL: Set this keyword to the Julian Day Number to use for the plotting of the GBMs. Use this
; keyword together instead of the DATE and TIME keyword.
; This keyword only applies when using Magnetic Local Time coordinates.
;
; HEMISPHERE: Set this to 1 to plot the northern hemisphere stations, -1 for the southern hemisphere.
; Northern is default.
;
; ANNOTATE: Set this keyword to put the stations abbreviation next to its marker.
;
; GBM_CHARSIZE: Set this keyword to the size with which to plot the stations abbreviation. Only comes into effect 
; if ANNOTATE is set.
;
; GBM_CHARTHICK: Set this keyword to the thickness with which to plot the stations abbreviation. 
; Only comes into effect if ANNOTATE is set.
;
; GBM_CHARCOLOR: Set this keyword to the color index with which to plot the stations abbreviation. 
; Only comes into effect if ANNOTATE is set.
;
; CHAIN: Set this keyword to a numeric value specifying the chain of which to plot the GBMs.
;
; CARISMA: Set this keyword to overlay all stations belonging to the CARISMA array.
;
; IMAGE: Set this keyword to overlay all stations belonging to the IMAGE array.
;
; GREENLAND: Set this keyword to overlay all stations belonging to the GREENLAND array.
;
; ANTARCTICA: Set this keyword to overlay all stations belonging to the ANTARCTICA array.
;
; SAMNET: Set this keyword to overlay all stations belonging to the SAMNET array.
;
; SAMBA: Set this keyword to overlay all stations belonging to the SAMBA array.
;
; GIMA: Set this keyword to overlay all stations belonging to the GIMA array.
;
; JAPMAG: Set this keyword to overlay all stations belonging to the JAPMAG array.
;
; INTERMAGNET: Set this keyword to overlay all stations belonging to the INTERMAGNET array.
;
; MACCS: Set this keyword to overlay all stations belonging to the MACCS array.
;
; NIPR: Set this keyword to overlay all stations belonging to the NIPR array.
;
; GBM_THEMIS: Set this keyword to overlay all stations belonging to the Themis GBM array.
;
; COLOR: Set this to the color index to use for the marker.
;
; BACKGROUND: Set this keyword to a color index to use as a background for the annotations. Only comes into effect 
; if ANNOTATE is set.
;
; GBM_ORIENTATION: Set this keyword to an angle in degree by which to rotate the annotations anti-clockwise. Only 
; comes into effect if ANNOTATE is set.
;
; ROTATE: Set this keyword to a number of degree by which to rotate the GBM
; clockwise. Make sure that you give the same number of degrees to
; MAP_PLOT_PANEL and all other plotting routines.
;
; SYMSIZE: Set this keyword to the size to use for the marker.
;
; OFFSETS: Set this keyword to a 2-element vector or 2xnstats array to use as offsets between the 
; marker and the annotation. In degree. Defualt is [0.5, -0.5].
;
; SILENT: Set this keyword to surpress warning messages.
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
; Written by Lasse Clausen, Dec, 4 2009
;-
pro overlay_gbm, stats, coords=coords, date=date, time=time, jul=jul, $
	hemisphere=hemisphere, annotate=annotate, $
	gbm_charsize=gbm_charsize, gbm_charthick=gbm_charthick, gbm_charcolor=gbm_charcolor, $
	chain=chain, all=all, $
	carisma=carisma, image=image, greenland=greenland, $
	samnet=samnet, antarctica=antarctica, intermagnet=intermagnet, $
	gima=gima, japmag=japmag, maccs=maccs, samba=samba, nipr=nipr, $
	gbm_themis=gbm_themis, color=color, $
	background=background, gbm_orientation=gbm_orientation, $
	rotate=rotate, symsize=symsize, offsets=offsets, silent=silent

common rad_data_blk

if ~keyword_set(coords) then $
	coords = get_coordinates()
	
if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return
endif

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if strcmp(strlowcase(coords), 'mlt') then $
	_coords = 'magn' $
else $
	_coords = coords

if ~keyword_set(hemisphere) then $
	hemisphere = 1.

if n_elements(color) eq 0 then $
	color = get_foreground()

if ~keyword_set(gbm_orientation) then $
	gbm_orientation = 0.

if ~keyword_set(gbm_charsize) then $
	gbm_charsize = !p.charsize

if ~keyword_set(gbm_charthick) then $
	gbm_charthick = !p.charthick

if ~keyword_set(gbm_charcolor) then $
	gbm_charcolor = get_foreground()

if ~keyword_set(symsize) then $
	symsize = 1.

if ~keyword_set(chain) then $
	chain = -1

if ~keyword_set(carisma) then $
	carisma = (chain eq !CARISMA ? 1 : 0)

if ~keyword_set(image) then $
	image = (chain eq !IMAGE ? 1 : 0)

if ~keyword_set(greenland) then $
	greenland = (chain eq !GREENLAND ? 1 : 0)

if ~keyword_set(samnet) then $
	samnet = (chain eq !SAMNET ? 1 : 0)

if ~keyword_set(antarctica) then $
	antarctica = (chain eq !ANTARCTICA ? 1 : 0)

if ~keyword_set(gima) then $
	gima = (chain eq !GIMA ? 1 : 0)

if ~keyword_set(japmag) then $
	japmag = (chain eq !JAPMAG ? 1 : 0)

if ~keyword_set(samba) then $
	samba = (chain eq !SAMBA ? 1 : 0)

if ~keyword_set(intermagnet) then $
	intermagnet = (chain eq !INTERMAGNET ? 1 : 0)

if ~keyword_set(maccs) then $
	maccs = (chain eq !MACCS ? 1 : 0)

if ~keyword_set(nipr) then $
	nipr = (chain eq !NIPR ? 1 : 0)

if ~keyword_set(gbm_themis) then $
	gbm_themis = (chain eq !GBM_THEMIS ? 1 : 0)

if carisma eq 0 and image eq 0 and greenland eq 0 and samnet eq 0 and $
	antarctica eq 0 and gima eq 0 and japmag eq 0 and samba eq 0 and $
	intermagnet eq 0 and maccs eq 0 and nipr eq 0 and gbm_themis eq 0 and ~keyword_set(stats) and ~keyword_set(all) then begin
	prinfo, 'Must give some magnetometer names or set keywords.'
	return
endif

if ~keyword_set(stats) then begin
	lats = gbm_get_pos(stats, /get, longitude=lons, coords=_coords, all=all, $
		carisma=carisma, image=image, greenland=greenland, $
		samnet=samnet, antarctica=antarctica, intermagnet=intermagnet, $
		gima=gima, japmag=japmag, maccs=maccs, samba=samba, nipr=nipr, $
		gbm_themis=gbm_themis)
	; stations to kick out, because they are in the other hemisphere
	lats = hemisphere*lats
	sinds = where(lats ge 0.0, cc)
	if cc eq 0 then begin
		prinfo, 'No stations found is hemisphere.'
		return
	endif
	lats = hemisphere*lats[sinds]
	lons = lons[sinds]
	stats = stats[sinds]
	nstats = cc
endif else begin
	lats = gbm_get_pos(stats, longitude=lons, coords=_coords)
	nstats = n_elements(stats)
endelse

if keyword_set(offsets) then begin
	if n_elements(offsets) eq 2 then $
		_offsets = rebin(offsets, 2, nstats) $
	else if n_elements(offsets) eq 2*nstats then $
		_offsets = offsets $
	else begin
		prinfo, 'OFFSETS must be 2-element vector or 2xnstats element array.'
		return
	endelse
endif else $
	_offsets = rebin([.5,-.5], 2, nstats)

if strcmp(strlowcase(coords), 'mlt') then begin
	mlt = 1
	if ~keyword_set(jul) then begin
		if ~keyword_set(time) then $
			time = 1200
		if keyword_set(date) then begin
			sfjul, date, time, jul
		endif else begin
			if ~keyword_set(silent) then $
				prinfo, 'No JUL given, trying for scan date.'
			if rad_fit_info.nrecs gt 0L then $
				jul = rad_fit_data.juls[0] $
			else begin
				prinfo, 'No data loaded.'
				return
			endelse
		endelse
	endif
	caldat, jul, mm, dd, year
	ut_sec = (jul-julday(1,1,year,0,0,0))*86400.d
	for i=0, nstats-1 do begin
		lons[i] = mlt(year,ut_sec,lons[i])
	endfor
endif else $
	mlt = 0

if n_elements(background) ne 0 and keyword_set(annotate) then begin
	for i=0, nstats-1 do begin
		ppos = calc_stereo_coords(lats[i], lons[i], mlt=mlt)
		nxoff = _offsets[0,i]*cos(gbm_orientation*!dtor) - _offsets[1,i]*sin(gbm_orientation*!dtor)
		nyoff = _offsets[0,i]*sin(gbm_orientation*!dtor) + _offsets[1,i]*cos(gbm_orientation*!dtor)
		pos = convert_coord(ppos[0]+nxoff, ppos[1]+nyoff, /data, /to_normal)
		astring = stats[i]
		xyouts, 0, 0, astring, charthick=gbm_charthick, charsize=-gbm_charsize, $
			width=strwidth, noclip=0
		tmp = convert_coord([0,0],[0,!d.y_ch_size],/device,/to_normal)
		strheight = gbm_charsize*(tmp[1,1]-tmp[1,0])
		xx = pos[0]+[0.0, 0.0, strwidth, strwidth, 0.0]
		yy = pos[1]+[-0.005,strheight,strheight,-0.005,-0.005,-0.005]
		if n_elements(rotate) ne 0 then begin
			_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
			_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
			xx = _x1
			yy = _y1
		endif
		;if keyword_set(rotate) then $
		;	swap, xx, yy, /right
		polyfill, xx, yy, noclip=0, /norm, color=background
	endfor
endif

load_usersym, /circle

for i=0, nstats-1 do begin ;0 do $ ;
	ppos = calc_stereo_coords(lats[i], lons[i], mlt=mlt)
	xx = ppos[0]
	yy = ppos[1]
	if n_elements(rotate) ne 0 then begin
		_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
		_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
		xx = _x1
		yy = _y1
	endif
	;if keyword_set(rotate) then $
	;	swap, xx, yy, /right
	plots, xx, yy, noclip=0, symsize=symsize, $
		color=get_background(), psym=8
	plots, xx, yy, noclip=0, symsize=.7*symsize, color=color, psym=8
	if keyword_set(annotate) then begin
		astring = strupcase(stats[i])
		nxoff = _offsets[0,i]*cos(gbm_orientation*!dtor) - _offsets[1,i]*sin(gbm_orientation*!dtor)
		nyoff = _offsets[0,i]*sin(gbm_orientation*!dtor) + _offsets[1,i]*cos(gbm_orientation*!dtor)
		align = 0.
		xyouts, xx+nxoff, yy+nyoff, astring, charthick=5.*gbm_charthick, $
			charsize=gbm_charsize, orientation=gbm_orientation, noclip=0, align=align, color=get_white()
		xyouts, xx+nxoff, yy+nyoff, astring, charthick=gbm_charthick, $
			charsize=gbm_charsize, orientation=gbm_orientation, noclip=0, color=gbm_charcolor, align=align
	endif
endfor

end
