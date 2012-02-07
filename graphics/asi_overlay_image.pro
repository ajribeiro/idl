;+ 
; NAME: 
; ASI_OVERLAY_IMAGE
; 
; PURPOSE: 
; This procedure overlays All-Sky Imager data on a map.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; ASI_OVERLAY_IMAGE
;
; KEYWORD PARAMETERS:
; DATE: A scalar giving the date of the image to overlay,
; in YYYYMMDD format.
;
; TIME: A scalar giving the time of the image to overlay, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'mag' and 'geo'.
; Default is 'mag'.
;
; SCALE: Set this keyword to a 2-element vector which contains the 
; upper and lower limit of the data range.
;
; MIN_ELEVATION: Set this keyword to the minimum elevation of the imager
; data to plot.
;
; JUL: Use this keyword instead of the date and time keyword to specify the
; time of the image to overplot.
;
; IMAGE: Set this keyword to a 2D array of brightness values. ASI_OVERLAY_IMAGE
; will then overlay these values rather than those loaded in the ASI_DATA_BLK.
;
; LATS: The latitudes of each pixel in IMAGE. Must have the same size as IMAGE.
; You only need to specify these if you are using the IMAGE keyword and the 
; The brightness data is from a different All-Sky Imager site than the one for which
; data is loaded.
;
; LONS: The latitudes of each pixel in IMAGE. Must have the same size as IMAGE.
; You only need to specify these if you are using the IMAGE keyword and the 
; The brightness data is from a different All-Sky Imager site than the one for which
; data is loaded.
;
; ELEVATION: The elevation angle of each pixel in IMAGE. Must have the same size as IMAGE.
; You only need to specify these if you are using the IMAGE keyword and the 
; The brightness data is from a different All-Sky Imager site than the one for which
; data is loaded.
;
; ALTITUDE: The altitude onto which to project the auroral image. Default is 110 km.
;
; ROTATE: Set this keyword to a number of degree by which to rotate the 
; location of the image counter-clockwise. This is a useful parameter when
; you want to center things on a map.
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
pro asi_overlay_image, date=date, time=time, long=long, coords=coords, scale=scale, $
	min_elevation=min_elevation, jul=jul, $
	image=image, lats=lats, lons=lons, elevation=elevation, altitude=altitude, $
	rotate=rotate, no_plot=no_plot

common asi_data_blk

if ~keyword_set(date) then begin
	if asi_info.nrecs gt 0 then begin
		caldat, asi_data.juls[0], mm, dd, yy, hh, ii, ss
		date = yy*10000L + mm*100L + dd
	endif else $
		return
endif

if ~n_elements(time) then $
	time = 1200

if ~keyword_set(jul) then $
	sfjul, date, time, jul, long=long

if ~keyword_set(coords) then $
	coords = get_coordinates()

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if ~keyword_set(min_elevation) then $
	min_elevation = 10.

if ~keyword_set(scale) then $
	scale = get_default_range('asi')

if ~keyword_set(altitude) then $
	altitude = 110.

if ~keyword_set(no_plot) then $
	no_plot = 0

if ~keyword_set(image) then begin
	dd = min(abs(asi_data.juls-jul), minind)
	if dd*86400.d gt 60. then begin
		prinfo, 'Found image, however it is '+string(dd*86400.d)+ ' seconds away from given time.'
		return
	endif
	image = reform(asi_data.images[minind,*,*])
endif

if ~ptr_valid(asi_info.cal_struc) then begin
	prinfo, 'No calibration data found for ASI data. Try calling THM_LOAD_ASI_CAL.'
	return
endif
_cal_struc = (*asi_info.cal_struc[0])

aind = where( $
	_cal_struc.vars[*].name eq $
	'thg_'+asi_info.datatype+'_'+asi_info.site+'_alti', cc)
if cc ne 1 then begin
	prinfo, 'Cannot find altitude data in calibration.'
	return
endif
dd = min(abs( (*_cal_struc.vars[aind].dataptr)/1e3 - altitude), alt_ind)
if dd gt 10. then $
	prinfo, 'Found calibration for altitude, however it is '+string(dd)+ 'km off.'

if ~keyword_set(lons) or ~keyword_set(lats) then begin
	loind = where( $
		_cal_struc.vars[*].name eq $
		'thg_'+asi_info.datatype+'_'+asi_info.site+'_glon', cc)
	if cc ne 1 then begin
		prinfo, 'Cannot find glon data in calibration.'
		return
	endif
	lons = reform( (*_cal_struc.vars[loind].dataptr)[alt_ind,*,*] )
	laind = where( $
		_cal_struc.vars[*].name eq $
		'thg_'+asi_info.datatype+'_'+asi_info.site+'_glat', cc)
	if cc ne 1 then begin
		prinfo, 'Cannot find glat data in calibration.'
		return
	endif
	lats = reform( (*_cal_struc.vars[laind].dataptr)[alt_ind,*,*] )

	if coords eq 'magn' or coords eq 'mlt' then begin
		year = date/10000L
		utsec = (jul - julday(1,1,year,0))*86400.d
		for h=0, asi_info.height do begin
			for w=0, asi_info.width do begin
				if ~finite(lats[w, h]) or ~finite(lons[w, h]) then $
					continue
				tmp = cnvcoord(lats[w, h], lons[w, h], altitude)
				if coords eq 'mlt' then $
					tmp[1] = mlt(year, utsec, tmp[1])
				lats[w, h] = tmp[0]
				lons[w, h] = tmp[1]
			endfor
		endfor
	endif
endif

if ~keyword_set(elevation) then begin
	eind = where( $
		_cal_struc.vars[*].name eq $
		'thg_'+asi_info.datatype+'_'+asi_info.site+'_elev', cc)
	if cc ne 1 then begin
		prinfo, 'Cannot find elevation data in calibration.'
		return
	endif
	elevation = (*_cal_struc.vars[eind].dataptr)
endif

; get color preferences
foreground  = get_foreground()
ncolors     = get_ncolors()
bottom      = get_bottom()

; scale image
cimage = bytscl(image, min=scale[0], max=scale[1], top=(ncolors - bottom - 1), $
	/nan) + bottom

for h=0, asi_info.height-1 do begin
	for w=0, asi_info.width-1 do begin
		if ~finite(lats[w, h]) || ~finite(lons[w, h]) || $
			~finite(lats[w+1, h]) || ~finite(lons[w+1, h]) || $
			~finite(lats[w+1, h+1]) || ~finite(lons[w+1, h+1]) || $
			~finite(lats[w, h+1]) || ~finite(lons[w, h+1]) then $
			continue
		if elevation[w,h] lt min_elevation then $
			continue
		p1 = calc_stereo_coords(lats[w, h], lons[w, h], mlt=(coords eq 'mlt'))
		p2 = calc_stereo_coords(lats[w+1, h], lons[w+1, h], mlt=(coords eq 'mlt'))
		p3 = calc_stereo_coords(lats[w+1, h+1], lons[w+1, h+1], mlt=(coords eq 'mlt'))
		p4 = calc_stereo_coords(lats[w, h+1], lons[w, h+1], mlt=(coords eq 'mlt'))
		xx = [p1[0],p2[0],p3[0],p4[0]]
		yy = [p1[1],p2[1],p3[1],p4[1]]
		if n_elements(rotate) ne 0 then begin
			_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
			_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
			xx = _x1
			yy = _y1
		endif
		tt = where(no_plot eq cimage[w,h], cc)
		if cc eq 0 then $
			polyfill, xx, yy, color=cimage[w,h], noclip=0
	endfor
endfor

end
