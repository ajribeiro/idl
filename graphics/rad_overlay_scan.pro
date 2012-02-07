;+ 
; NAME: 
; RAD_OVERLAY_SCAN
; 
; PURPOSE: 
; This procedure overlays a scan of any data on a stereographic polar map.
; This procedure is essentially like RAD_FIT_OVERLAY_SCAN, however here
; you provide the data to overlay in a [nbeams, nranges] array. It thus
; enables you to overlay *any* data within the field of view of a radar.
;
; CATEGORY:
; Graphics
;
; CALLING SEQUENCE:
; RAD_OVERLAY_SCAN, Data, Id
;
; INPUTS:
; Data: A [nbeams, nranges] array holding the data to overlay on the map.
;
; OPTIONAL INPUTS:
; Id: The numeric id of the radar into which field-of-view the data is placed.
; You can set the NAME keyword instead if you'd rather define the radar by
; its 3-letter code.
;
; KEYWORD PARAMETERS:
; NAME: The 3-letter code of the radar which field-of-view to use. Use this
; keyword instead of the numeric Id.
;
; JUL: Set this to a julian day number used to plot the map. Only necessary
; if coordinate system is MLT.
; Can be used instead of a combination of DATE/TIME.
;
; DATE: A scalar giving the date used to plot the map in YYYYMMDD format. Only necessary
; if coordinate system is MLT. Can be used in combination with TIME
; instead of JUL.
;
; TIME: The time used to plot the map HHII format, or HHIISS format if the LONG keyword is set. Only necessary
; if coordinate system is MLT. If TIME is not set
; the default value 1200 is assumed. Can be used in combination with DATE
; instead of JUL.
;
; LONG: Set this keyword to indicate that the Time value is in HHIISS
; format rather than HHII format.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn', 'geog', and 'mlt'.
; Default is 'magn'.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; ROTATE: Set this keyword to a number of degree to rotate the scan by.
;
; FORCE_FOV_LOC_FULL: Set this keyword to an array containing the locations
; of the four corners of each radar cell. Use this to overwrite the output 
; of RAD_DEFINE_BEAMS
;
; FORCE_FOV_LOC_CENTER: Set this keyword to an array containing the locations
; of the center of each radar cell. Use this to overwrite the output 
; of RAD_DEFINE_BEAMS
;
; VECTOR: Set this keyword to plot colored vectors 
; (like in the map potential plots)
; instead of colored polygons.
;
; FACTOR: Set this keyword to alter the length of vectors - only valid
; when plotting vectors.
;
; SIZE: Set this keyword to adjust thickness of vector and size of dot - only valid
; when plotting vectors.
;
; FIXED_LENGTH: Set this keyword to a velocity value such that all vectors will be drawn
; with a lentgh correponding to that value, however they will still be color-coded
; according to their actual velocity value.
;
; SYMSIZE: Size of the symbols used to mark the radar position.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; ANNOTATE: Set this keyword to annotate the radar position with its 3 letter code.
;
; CHARSIZE: Set this keyword to the font size to use for the radar label. You
; need to set the ANNOTATE keyword for this to have any effect.
;
; CHARTHICK: Set this keyword to the font thickness to use for the radar label. You
; need to set the ANNOTATE keyword for this to have any effect.
;
; CHARCOLOR: Set this keyword to the font color to use for the radar label. You
; need to set the ANNOTATE keyword for this to have any effect.
;
; ORIENTATION: Set this keyword to the orientation to use for the radar label. 
; See also documentation of XYOUTS. You
; need to set the ANNOTATE keyword for this to have any effect.
;
; OFFSET: Set this keyword to the offset of the radar label relative to the radar position in degree.
; Default is [0.5, -0.5]. You
; need to set the ANNOTATE keyword for this to have any effect.
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
; Based on Steve Milan's .
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_overlay_scan, data, id, name=name, $
	coords=coords, time=time, date=date, jul=jul, $
	scale=scale, rotate=rotate, $
	force_fov_loc_center=force_fov_loc_center, force_fov_loc_full=force_fov_loc_full, $
 	vector=vector, factor=factor, size=size, $
	fixed_length=fixed_length, symsize=symsize, silent=silent, $
	annotate=annotate, charsize=charsize, charthick=charthick, charcolor=charcolor, orientation=orientation, offset=offset, $
	ground=ground, no_plot_gnd_scatter=no_plot_gnd_scatter, color_rotate=color_rotate

common radarinfo
common rad_data_blk

if n_params() lt 1 then begin
	prinfo, 'Must give [nbeams, nranges] array of data.'
	return
endif

if ~keyword_set(coords) then $
	coords = get_coordinates()

if coords eq 'mlt' then begin
	if  ~keyword_set(jul) and ~keyword_set(date) and ~keyword_set(time) then begin
		prinfo, 'Must give JUL or DATE/TIME keyword when plotting in MLT coordinates.'
		return
	endif
endif

if keyword_set(jul) then $
	sfjul, date, time, jul, /jul_to_date
if ~keyword_set(date) and ~keyword_set(time) then begin
	date = 20300101
	time = 1200
endif
sfjul, date, time, jul
parse_date, date, yr, mn, dy
parse_time, time, hr, mt

if n_params() eq 1 then begin
	if ~keyword_set(name) then begin
		prinfo, 'Must give Id parameter or NAME keyword.'
		return
	endif else begin
		ind = where(network[*].code[0] eq name, ic)
		if ic ne 1 then begin
			prinfo, 'Radar not found in radar.dat: '+name
			return
		endif
		id = network[ind].id
	endelse
endif
radar = radargetradar(network, id)
site = radarymdhmsgetsite(radar, yr, mn, dy, hr, mt, 0)

if size(site, /type) eq 3 then begin
	prinfo, 'Cannot find site at given date: '+radar.name+' at '+strjoin(strtrim(string([yr, mn, dy, hr, mt, 0]),2),'-')
	return
endif

if ~keyword_set(symsize) then $
	symsize = .8

if ~keyword_set(size) then $
	size = 1.

if ~keyword_set(factor) then $
	factor = 480. $
else $
	factor = factor*480.

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

if ~keyword_set(orientation) then $
	orientation = 0.

if ~keyword_set(charsize) then $
	charsize = 1.

if ~keyword_set(charthick) then $
	charthick = !p.charthick

if ~keyword_set(charcolor) then $
	charcolor = get_foreground()

if ~keyword_set(ground) then $
	ground = -1e31

; we need this later
if coords eq 'mlt' then begin
	in_mlt = !true
	_coords = 'magn'
endif else begin
	_coords = coords
	in_mlt = !false
endelse

; get time
caldat, jul, mm, dd, year
yrsec = (jul-julday(1,1,year,0,0,0))*86400.d

if ~keyword_set(scale) then $
	scale = get_scale()

; get color preferences
foreground  = get_foreground()
color_steps = get_colorsteps()
ncolors     = get_ncolors()
bottom      = get_bottom()

; and some user preferences
scatterflag = rad_get_scatterflag()

; Set color bar and levels
cin =    FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps
IF keyword_set(color_rotate) then begin
	if strcmp(get_colortable(), 'bluewhitered', /fold) or strcmp(get_colortable(), 'leicester', /fold) or strcmp(get_colortable(), 'default', /fold) THEN $
		cin = ROTATE(cin, 2)
	if strcmp(get_colortable(), 'aj', /fold) or strcmp(get_colortable(), 'bw', /fold) or strcmp(get_colortable(), 'whitered', /fold) THEN $
		cin = shift(cin, color_steps/2)
endif

; array for the positions of the corners
xx = fltarr(4)
yy = fltarr(4)

; get array size
sz = size(data, /dim)
radar_gates = sz[1]
radar_beams = sz[0]

if ~keyword_set(force_fov_loc_center) and ~keyword_set(force_fov_loc_full) then begin

	rad_define_beams, id, radar_beams, $
		radar_gates, yr, yrsec, coords=_coords, $
		/normal, fov_loc_full=fov_loc_full, fov_loc_center=fov_loc_center

endif else begin

	fov_loc_full = force_fov_loc_full
	fov_loc_center = force_fov_loc_center

endelse

; get radar position for vector plotting
if keyword_set(vector) then begin
	; load circle 
	load_usersym, /circle
	; reference position
	; for azimuth calculation
	txlat = site.geolat ; ( coords eq 'geog' ? (*rad_fit_info[data_index]).glat : (*rad_fit_info[data_index]).mlat )
	txlon = site.geolon ; ( coords eq 'geog' ? (*rad_fit_info[data_index]).glon : (*rad_fit_info[data_index]).mlon )
	if coords eq 'magn' or in_mlt then begin
		tmp = cnvcoord(txlat, txlon, 1.)
		txlat = tmp[0]
		txlon = tmp[1]
	endif
	if in_mlt then $
		txlon = mlt(year, yrsec, txlon)
endif


; Plot data
for b=0, radar_beams-1 do begin
	for r=0, radar_gates-1 do begin
		IF data[b,r] NE 10000 THEN BEGIN
			color_ind = (MAX(where(lvl le ((data[b,r] > scale[0]) < scale[1]))) > 0)
			if abs(data[b,r]) lt ground then begin
				if keyword_set(no_plot_gnd_scatter) then $
					continue
				col = get_gray()
			endif ELSE $
				col = cin[color_ind]
			if keyword_set(vector) then begin
				lat = fov_loc_center[0,b,r]
				lon = ( in_mlt ? $
					mlt(year, yrsec, fov_loc_center[1,b,r]) : $
						fov_loc_center[1,b,r] )
				tmp = calc_stereo_coords(lat,lon,mlt=in_mlt)
				x_pos_vec = tmp[0]
				y_pos_vec = tmp[1]
				; calculate the azimuth
				; by taking the bearing from
				; the current scatter point to the 
				; radar - and then minus
				dlon = (lon - txlon)*( in_mlt ? 15. : 1. )
				ty = sin(dlon*!dtor)*cos(txlat*!dtor)
				tx = cos(lat*!dtor)*sin(txlat*!dtor) - $
					sin(lat*!dtor)*cos(txlat*!dtor)*cos(dlon*!dtor)
				vec_azm = atan(ty, -tx); + !pi
				vec_azm = atan(-ty, tx); + !pi
				vec_len = (keyword_set(fixed_length) ? $
					factor*abs(fixed_length/!re/1e3) : factor*abs(data[b,r]/!re/1e3) )
				; Find latitude of end of vector
				coLat = (90. - lat)*!dtor
				cos_coLat = (COS(vec_len)*COS(coLat) + $
					SIN(vec_len)*SIN(coLat)*COS(vec_azm) < 1.) > (-1.)
				vec_coLat = ACOS(cos_coLat)
				vec_lat = 90.-vec_coLat*!radeg
				; Find longitude of end of vector
				cos_dLon = ((COS(vec_len) - $
					COS(vec_coLat)*COS(coLat))/(SIN(vec_coLat)*SIN(coLat)) < 1.) > (-1.)
				delta_lon = ACOS(cos_dLon)
				IF vec_azm LT 0 THEN $
					delta_lon = -delta_lon
				vec_lon = (lon*( in_mlt ? 15. : 1. )*!dtor + delta_lon)*!radeg
				; Find x and y position of end of vectors
				tmp = calc_stereo_coords(vec_lat, vec_lon)
				new_x = tmp[0]
				new_y = tmp[1]
				IF data[b,r] LT 0 THEN BEGIN
					new_x = 2*x_pos_vec - new_x
					new_y = 2*y_pos_vec - new_y
				ENDIF
				if n_elements(rotate) ne 0 then begin
					_x1 = cos(rotate*!dtor)*x_pos_vec - sin(rotate*!dtor)*y_pos_vec
					_y1 = sin(rotate*!dtor)*x_pos_vec + cos(rotate*!dtor)*y_pos_vec
					x_pos_vec = _x1
					y_pos_vec = _y1
					_x1 = cos(rotate*!dtor)*new_x - sin(rotate*!dtor)*new_y
					_y1 = sin(rotate*!dtor)*new_x + cos(rotate*!dtor)*new_y
					new_x = _x1
					new_y = _y1
				endif
				oplot, [x_pos_vec], [y_pos_vec], psym=8, $
					symsize=1.5*0.3*sqrt(size), color=get_background(), noclip=0
				oplot, [x_pos_vec,new_x], [y_pos_vec,new_y],$
					thick=2.5*1.5*size, COLOR=get_background(), noclip=0
				oplot, [x_pos_vec], [y_pos_vec], psym=8, $
					symsize=0.3*sqrt(size), color=col, noclip=0
				oplot, [x_pos_vec,new_x], [y_pos_vec,new_y],$
					thick=1.5*size, COLOR=col, noclip=0
			endif else begin
				; Convert polar coordinates (latitude and longitude) to cartesian coords
				for p=0, 3 do begin
					lat = fov_loc_full[0,p,b,r]
					lon = in_mlt ? $
						mlt(year, yrsec, fov_loc_full[1,p,b,r]) : $
							fov_loc_full[1,p,b,r]
					tmp = calc_stereo_coords(lat,lon,mlt=in_mlt)
					xx[p] = tmp[0]
					yy[p] = tmp[1]
				endfor
				if n_elements(rotate) ne 0 then begin
					_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
					_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
					xx = _x1
					yy = _y1
				endif
				POLYFILL, xx, yy, COL=col, NOCLIP=0
			endelse
		ENDIF
	ENDFOR
ENDFOR

; plot radar position
if strcmp(coords, 'geog') then begin
	lat = site.geolat
	lon = site.geolon
endif else if strcmp(coords, 'magn') then begin
	tmp = cnvcoord(site.geolat, site.geolon, 0.1)
	lat = tmp[0]
	lon = tmp[1]
endif else if strcmp(coords, 'mlt') then begin
	tmp = cnvcoord(site.geolat, site.geolon, 0.1)
	lat = tmp[0]
	lon = mlt(year, yrsec, tmp[1])
endif else begin
	lat = 0.
	lon = 0.
endelse
tmp = calc_stereo_coords(lat,lon,mlt=in_mlt)
xx = tmp[0]
yy = tmp[1]
if n_elements(rotate) ne 0 then begin
	_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
	_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
	xx = _x1
	yy = _y1
endif
load_usersym, /circle
plots, xx, yy, psym=8, symsize=.6*symsize, color=get_foreground(), $
	noclip=0
plots, xx, yy, psym=1, symsize=symsize, thick=3, color=get_foreground(), $
	noclip=0

if keyword_set(annotate) then begin
	tmp = where(network[*].id eq id)
	astring = strupcase(network[tmp].code[0])
	; shift the label for FHW a little to the left
	; so that it doesn't interfere with FHE
	; same for sto, bks and ksr, cvw
	align = 0.
	if n_elements(offset) eq 2 then $
		_offset = offset $
	else $
		_offset = [.5, -.3]
	if (id eq 8 or id eq 13 or id eq 16 or id eq 33 or id eq 204 or id eq 206) and ~keyword_set(offset) then begin
		_offset = [-.5, -.3]
		align = 1.
	endif
	nxoff = _offset[0]*cos(orientation*!dtor) - _offset[1]*sin(orientation*!dtor)
	nyoff = _offset[0]*sin(orientation*!dtor) + _offset[1]*cos(orientation*!dtor)
	xyouts, xx+nxoff, yy+nyoff, astring, charthick=10.*charthick, $
		charsize=charsize, orientation=orientation, noclip=0, align=align, color=get_white()
	xyouts, xx+nxoff, yy+nyoff, astring, charthick=2.*charthick, $
		charsize=charsize, orientation=orientation, noclip=0, color=charcolor, align=align
endif

END
