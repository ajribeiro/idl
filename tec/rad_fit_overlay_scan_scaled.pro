;+ 
; NAME: 
; RAD_FIT_OVERLAY_SCAN_SCALED
; 
; PURPOSE: 
; This procedure overlays a certain radar scan on a stereographic polar map.
; NOTE: This procedure is only used for tec_four_plot.pro
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_OVERLAY_SCAN_SCALED
;
; OPTIONAL INPUTS:
; Scan_number: The number of the scan to overlay. Set to -1 if you want to
; choose the scan number by providing a date/time via the JUL keyword.
;
; KEYWORD PARAMETERS:
; JUL: Set this to a julian day number to select the scan to plot as that
; nearest to this date/time. Can be used instead of a combination of DATE/TIME.
;
; DATE: A scalar or 2-element vector giving the date range, 
; in YYYYMMDD or MMMYYYY format. Can be used in combination with TIME
; instead of JUL.
;
; TIME: The time range for which to read data. Must be a 2-element vector in 
; HHII format, or HHIISS format if the LONG keyword is set. If TIME is not set
; the default value [0000,2400] is assumed. Can be used in combination with DATE
; instead of JUL.
;
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn', 'geog', and 'mlt'.
; Default is 'magn'.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; SCAN_STARTJUL: Set this to a named variable that will contain the
; julian day number of the plotted scan.
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
; EXCLUDE: Set to a 2-element array giving the lower and upper velocity limit 
; to plot.
;
; FIXED_LENGTH: Set this keyword to a velocity value such that all vectors will be drawn
; with a lentgh correponding to that value, however they will still be color-coded
; according to their actual velocity value.
;
; SYMSIZE: Size of the symbols used to mark the radar position.
;
; SCAN_STARTJUL: Set this keyword to a named variable that will contain the
; timestamp of the first beam in teh scan as a julian day.
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
; Modified by Evan Thomas, Oct, 14 2011
;-
pro rad_fit_overlay_scan_scaled, scan_number, coords=coords, time=time, date=date, jul=jul, $
	param=param, scale=scale, channel=channel, scan_id=scan_id, $
	freq_band=freq_band, rotate=rotate, $
;	force_data=force_data, force_id=force_id, $
	force_fov_loc_center=force_fov_loc_center, force_fov_loc_full=force_fov_loc_full, $
	scan_startjul=scan_startjul, $
	vector=vector, factor=factor, exclude=exclude, $
	fixed_length=fixed_length, fixed_color=fixed_color, symsize=symsize, thick=thick, silent=silent, $
	annotate=annotate, charsize=charsize, charthick=charthick, charcolor=charcolor, $
	orientation=orientation, offset=offset, ground=ground, $
	no_plot_gnd_scatter=no_plot_gnd_scatter, sc_values=sc_values

common radarinfo
common rad_data_blk

if ~keyword_set(param) then $
	param = get_parameter()

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	return

if ~is_valid_parameter(param) then begin
	prinfo, 'Invalid plotting parameter: '+param
	return
endif

if ~keyword_set(freq_band) then $
	freq_band = [3.0, 30.0]

if ~keyword_set(symsize) then $
	symsize = .5

if ~keyword_set(thick) then $
	thick = !p.thick

if ~keyword_set(factor) then $
	factor = 480. $
else $
	factor = factor*480.

if ~keyword_set(exclude) then $
	exclude = [-20000.,20000.]

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

if (*rad_fit_info[data_index]).nrecs eq 0L then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data in index '+string(data_index)
		rad_fit_info
	endif
	return
endif

if n_params() eq 0 then $
	scan_number = -1
if scan_number eq -1 then begin
	if ~keyword_set(date) then begin
		caldat, (*rad_fit_info[data_index]).sjul, mm, dd, yy
		date = yy*10000L + mm*100L + dd
	endif
	if n_elements(time) eq 0 then $
		time = 1200
	if ~keyword_set(jul) then $
		sfjul, date, time, jul
	scan_number = rad_fit_find_scan(jul, channel=channel, $
		scan_id=scan_id)
	if scan_number eq -1L then $
		return
endif

aa = time/10
bb = time/100
ones = time-aa*10
tens = (time-bb*100-ones)/10

if ones eq 1 or ones eq 6 then $
	_jul = jul - 1/1440. $
else if ones eq 2 or ones eq 7 then $
	_jul = jul - 2/1440. $
else if ones eq 3 or ones eq 8 then $
	_jul = jul - 3/1440. $
else if ones eq 4 or ones eq 9 then $
	_jul = jul - 4/1440. $
else $
	_jul = jul

scans = rad_fit_find_scan([_jul,_jul+4/1440.])
nscans = n_elements(scans)
print,scans
if nscans lt 2 then $
	return

; Initialise data arrays
varr = rad_fit_get_scan(scan_number, groundflag=grnd, $
	param=param, channel=channel, scan_id=scan_id, $
	scan_startjul=jul,/silent)

sz = size(varr, /dim)
radar_beams = sz[0]
radar_gates = sz[1]

varr_arr = fltarr(radar_beams,radar_gates,nscans)
grnd_arr = intarr(radar_beams,radar_gates,nscans)
for ii=0,nscans-1 do begin
	varr_arr[*,*,ii] = rad_fit_get_scan(scans[ii], groundflag=_grnd, $
		param=param, channel=channel, scan_id=scan_id, $
		scan_startjul=jul,/silent)
	grnd_arr[*,*,ii] = _grnd
endfor

if n_elements(varr) lt 2 then $
	return

if ~keyword_set(ground) then $
	ground = -1

if ~keyword_set(orientation) then $
	orientation = 0.

if ~keyword_set(charsize) then $
	charsize = !p.charsize

if ~keyword_set(charthick) then $
	charthick = !p.charthick

if ~keyword_set(charcolor) then $
	charcolor = get_foreground()

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
	scale = get_default_range(param)

; get color preferences
foreground  = get_foreground()
color_steps = get_colorsteps()
ncolors     = get_ncolors()
bottom      = get_bottom()

; and some user preferences
scatterflag = rad_get_scatterflag()

; Set color bar and levels
;cin =    FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
;lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps
;IF param EQ 'velocity' then begin
;	if strcmp(get_colortable(), 'bluewhitered', /fold) or strcmp(get_colortable(), 'leicester', /fold) or strcmp(get_colortable(), 'default', /fold) THEN $
;		cin = ROTATE(cin, 2)
;	if strcmp(get_colortable(), 'aj', /fold) or strcmp(get_colortable(), 'bw', /fold) or strcmp(get_colortable(), 'whitered', /fold) THEN $
;		cin = shift(cin, color_steps/2)
;endif

; array for the positions of the corners
xx = fltarr(4)
yy = fltarr(4)

if (keyword_set(vector) and ~keyword_set(force_fov_loc_center)) or $
	(~keyword_set(vector) and ~keyword_set(force_fov_loc_full)) then begin

	; define beam and gate positions for radar
	if n_elements(channel) ne 0 then begin
		scan_beams = WHERE((*rad_fit_data[data_index]).beam_scan EQ scan_number and $
			(*rad_fit_data[data_index]).channel eq channel, $
			no_scan_beams)
	endif else if scan_id ne -1 then begin
		scan_beams = WHERE((*rad_fit_data[data_index]).beam_scan EQ scan_number and $
			(*rad_fit_data[data_index]).scan_id eq scan_id, $
			no_scan_beams)
	endif
	;print, (*rad_fit_info[data_index]).id, (*rad_fit_info[data_index]).nbeams, $
	;	(*rad_fit_info[data_index]).ngates, year, yrsec, _coords, $
	;	(*rad_fit_data[data_index]).lagfr[scan_beams[0]], $
	;	(*rad_fit_data[data_index]).smsep[scan_beams[0]]
	rad_define_beams, (*rad_fit_info[data_index]).id, (*rad_fit_info[data_index]).nbeams, $
		(*rad_fit_info[data_index]).ngates, year, yrsec, coords=_coords, $
		lagfr0=(*rad_fit_data[data_index]).lagfr[scan_beams[0]], $
		smsep0=(*rad_fit_data[data_index]).smsep[scan_beams[0]], $
		fov_loc_full=fov_loc_full, fov_loc_center=fov_loc_center

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
	txlat = ( coords eq 'geog' ? (*rad_fit_info[data_index]).glat : (*rad_fit_info[data_index]).mlat )
	txlon = ( coords eq 'geog' ? (*rad_fit_info[data_index]).glon : (*rad_fit_info[data_index]).mlon )
	if in_mlt then $
		txlon = mlt(year, yrsec, txlon)
endif

; take median value over 5 scans, if at least 3 measurements are present
count = intarr(radar_beams,radar_gates,nscans)
for b=0, radar_beams-1 do begin
	for r=0, radar_gates-1 do begin
		for ii=0,nscans-1 do begin
			if varr_arr[b,r,ii] NE 10000 and grnd_arr[b,r,ii] NE 1 then $
				count[b,r,ii] = 1
		endfor
	endfor
endfor

for b=0, radar_beams-1 do begin
	for r=0, radar_gates-1 do begin
		sum = total(count[b,r,*])
		if sum ge 0.5*nscans then begin
			inds = where(count[b,r,*] eq 1)
			varr[b,r] = median(varr_arr[b,r,inds],/even)
			grnd[b,r] = 0
		endif else begin
			varr[b,r] = 10000
			grnd[b,r] = 1
		endelse
	endfor
endfor

; Plot data
for b=0, radar_beams-1 do begin
;for b=2, 3-1 do begin
	for r=0, radar_gates-1 do begin
		IF varr[b,r] NE 10000 THEN BEGIN
			; skip points below and above user set range
			if varr[b,r] lt exclude[0] or varr[b,r] gt exclude[1] then $
				continue
			; skip oints depending on ground scatter flag - if we're plotting velocity
			IF ~((grnd[b,r] EQ 0 AND scatterflag EQ 1) OR (grnd[b,r] NE 0 AND scatterflag EQ 2)) THEN BEGIN
				;color_ind = (MAX(where(lvl le ((varr[b,r] > scale[0]) < scale[1]))) > 0)
				IF param EQ 'velocity' AND ( ( scatterflag EQ 3 AND $
					grnd[b,r] EQ 1 ) or abs(varr[b,r]) lt ground ) THEN begin
					if keyword_set(no_plot_gnd_scatter) then begin
						continue
					endif
					col = get_gray()
				endif ELSE $
					col = get_color_index(varr[b,r], param=param, scale=scale, sc_values=sc_values)
				if n_elements(fixed_color) gt 0 then $
						col = fixed_color
				;print, b, r, varr[b, r], grnd[b, r]
				; plot points as little flags
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
					vec_len = (n_elements(fixed_length) gt 0 ? $
						factor*abs(fixed_length/!re/1e3) : factor*abs(varr[b,r]/!re/1e3) )
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
					IF varr[b,r] LT 0 THEN BEGIN
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
					; Scale size of power symbols according to magnitude
					if param eq 'power' then begin
						if varr[b,r] le 10.0 then $
							factor = 1.0 $
						else if varr[b,r] le 20.0 then $
							factor = 1.5 $
						else $
							factor = 2.0
					endif
					oplot, [x_pos_vec], [y_pos_vec], psym=8, $
						symsize=symsize*factor, color=col, noclip=0
				;plot points as filled rectangles
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
		ENDIF
	ENDFOR
ENDFOR

; plot radar position
if strcmp(coords, 'geog') then begin
	lat = (*rad_fit_info[data_index]).glat
	lon = (*rad_fit_info[data_index]).glon
endif else if strcmp(coords, 'magn') then begin
	lat = (*rad_fit_info[data_index]).mlat
	lon = (*rad_fit_info[data_index]).mlon
endif else if strcmp(coords, 'mlt') then begin
	lat = (*rad_fit_info[data_index]).mlat
	lon = mlt(year, yrsec, (*rad_fit_info[data_index]).mlon)
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
plots, xx, yy, psym=8, symsize=.6, color=get_foreground(), $
	noclip=0
plots, xx, yy, psym=1, symsize=1., thick=5, color=get_foreground(), $
	noclip=0

if keyword_set(annotate) then begin
	id = (*rad_fit_info[data_index]).id
	tmp = where(network[*].id eq id)
	astring = strupcase(network[tmp].code[0])
	; shift the label for FHW a little to the left
	; so that it doesn't interfere with FHE
	; same for sto, bks and ksr
	align = 0.
	if n_elements(offset) eq 2 then $
		_offset = offset $
	else $
		_offset = [.5, -.3]
 	if (id eq 8 or id eq 13 or id eq 16 or id eq 33 or id eq 204 or id eq 206) $
		and ~keyword_set(offset) then begin
		_offset = [-.5, -.3]
		align = 1.
	endif
	nxoff = _offset[0]*cos(orientation*!dtor) - _offset[1]*sin(orientation*!dtor)
	nyoff = _offset[0]*sin(orientation*!dtor) + _offset[1]*cos(orientation*!dtor)
	xyouts, xx+nxoff, yy+nyoff, astring, charthick=5.*charthick, $
		charsize=charsize, orientation=orientation, noclip=0, align=align, color=get_white()
	xyouts, xx+nxoff, yy+nyoff, astring, charthick=charthick, $
		charsize=charsize, orientation=orientation, noclip=0, color=charcolor, align=align
endif

; "return" the date/time of the plotted scan
scan_startjul = jul

END
