;+ 
; NAME: 
; RAD_FIT_OVERLAY_SCAN
; 
; PURPOSE: 
; This procedure overlays a certain radar scan on a stereographic polar map.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_OVERLAY_SCAN
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
; LONG: Set this keyword to indicate that the Time value is in HHIISS
; format rather than HHII format.
;
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn', 'geog', 'range' and 'gate'.
; Default is 'gate'.
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
; FORCE_DATA: Set this keyword to a [nb, ng] array holding the scan data to plot.
; this overrides the internal scan finding procedures. nb is the number of beams,
; ng is the number of gates.
;
; FOV_LOC_FULL: Set this keyword to an array containing the locations
; of the four corners of each radar cell. Use this to overwrite the output 
; of RAD_DEFINE_BEAMS
;
; FOV_LOC_CENTER: Set this keyword to an array containing the locations
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
; MODIFICATION HISTORY: 
; Based on Steve Milan's .
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_fit_overlay_scan, scan_number, coords=coords, time=time, date=date, jul=jul, $
	param=param, scale=scale, channel=channel, scan_id=scan_id, $
	freq_band=freq_band, rotate=rotate, $
	force_data=force_data, force_fov_loc_center=force_fov_loc_center, force_fov_loc_full=force_fov_loc_full, $
	scan_startjul=scan_startjul, $
	vector=vector, factor=factor, size=size, exclude=exclude, $
	fixed_length=fixed_length, symsize=symsize, silent=silent, $
	annotate=annotate, charsize=charsize, charthick=charthick, charcolor=charcolor, orientation=orientation, offset=offset

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
	symsize = .8

if ~keyword_set(size) then $
	size = 1.

if ~keyword_set(factor) then $
	factor = 480. $
else $
	factor = factor*480.

if ~keyword_set(exclude) then $
	exclude = [-2000.,2000.]

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

if (*rad_fit_info[data_index]).nrecs eq 0L and ~keyword_set(force_data) then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data in index '+string(data_index)
		rad_fit_info
	endif
	return
endif

; Allow the user to pass their own data array
IF KEYWORD_SET(force_data) THEN begin
	varr = force_data
	grnd = byte(force_data)
	grnd[*,*] = 0b
	if keyword_set(jul) then $
		sfjul, date, time, jul, /jul_to_date
	if ~keyword_set(date) then begin
		prinfo, 'Must give date when using FORCE_DATA keyword.'
		return
	endif
	if ~keyword_set(time) then begin
		prinfo, 'Must give time when using FORCE_DATA keyword.'
		return
	endif
	sfjul, date, time, jul
endif else begin
	if n_params() eq 0 then $
		scan_number = -1
	if scan_number eq -1 then begin
		if ~keyword_set(date) then begin
			caldat, (*rad_fit_info[data_index]).sjul, mm, dd, yy
			date = yy*10000L + mm*100L + dd
		endif
		if ~keyword_set(time) then $
			time = 1200
		if ~keyword_set(jul) then $
			sfjul, date, time, jul
		scan_number = rad_fit_find_scan(jul, channel=channel, $
			scan_id=scan_id)
		if scan_number eq -1L then $
			return
	endif
	; Initialise data arrays
	varr = rad_fit_get_scan(scan_number, groundflag=grnd, $
		param=param, channel=channel, scan_id=scan_id, $
		scan_startjul=jul)
	if n_elements(varr) lt 2 then $
		return
endelse
sz = size(varr, /dim)
radar_gates = sz[1]
radar_beams = sz[0]

if ~keyword_set(orientation) then $
	orientation = 0.

if ~keyword_set(charsize) then $
	charsize = 1.

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
IF param EQ 'velocity' then begin
	if strcmp(get_colortable(), 'bluewhitered', /fold) or strcmp(get_colortable(), 'leicester', /fold) THEN $
		cin = ROTATE(cin, 2) $
	else $
		cin = shift(cin, color_steps/2)
endif

; array for the positions of the corners
xx = fltarr(4)
yy = fltarr(4)

if (keyword_set(vector) and ~keyword_set(force_fov_loc_center)) or $
	(~keyword_set(vector) and ~keyword_set(force_fov_loc_full)) then begin

	; define beam and gate positions for radar
;	if (*rad_fit_info[data_index]).fov_coords ne coords or $
;		~ptr_valid((*rad_fit_info[data_index]).fov_loc_full) or $
;		~ptr_valid((*rad_fit_info[data_index]).fov_loc_center) then begin
		if n_elements(channel) ne 0 then begin
			scan_beams = WHERE((*rad_fit_data[data_index]).beam_scan EQ scan_number and $
				(*rad_fit_data[data_index]).channel eq channel, $
				no_scan_beams)
		endif else if scan_id ne -1 then begin
			scan_beams = WHERE((*rad_fit_data[data_index]).beam_scan EQ scan_number and $
				(*rad_fit_data[data_index]).scan_id eq scan_id, $
				no_scan_beams)
		endif
		rad_define_beams, (*rad_fit_info[data_index]).id, (*rad_fit_info[data_index]).nbeams, $
			(*rad_fit_info[data_index]).ngates, (*rad_fit_info[data_index]).bmsep, year, yrsec, coords=_coords, $
			lagfr0=(*rad_fit_data[data_index]).lagfr[scan_beams[0]], smsep0=(*rad_fit_data[data_index]).smsep[scan_beams[0]], $
			fov_loc_full=fov_loc_full, fov_loc_center=fov_loc_center
		; delete old pointers otherwise they stay in memory
;		if ptr_valid((*rad_fit_info[data_index]).fov_loc_full) then $
;			ptr_free, (*rad_fit_info[data_index]).fov_loc_full
;		if ptr_valid((*rad_fit_info[data_index]).fov_loc_center) then $
;			ptr_free, (*rad_fit_info[data_index]).fov_loc_center
		; put new ones in
;		(*rad_fit_info[data_index]).fov_loc_full = ptr_new(fov_loc_full)
;		(*rad_fit_info[data_index]).fov_loc_center =  ptr_new(fov_loc_center)
;		(*rad_fit_info[data_index]).fov_coords = _coords
;	endif else begin
;		fov_loc_full = (*(*rad_fit_info[data_index]).fov_loc_full)
;		fov_loc_center = (*(*rad_fit_info[data_index]).fov_loc_center)
;	endelse

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

; Plot data
for b=0, radar_beams-1 do begin
	for r=0, radar_gates-1 do begin
		IF varr[b,r] NE 10000 THEN BEGIN
			IF ~((grnd[b,r] EQ 0 AND scatterflag EQ 1) OR (grnd[b,r] NE 0 AND scatterflag EQ 2)) THEN BEGIN
				color_ind = (MAX(where(lvl le ((varr[b,r] > scale[0]) < scale[1]))) > 0)
				IF param EQ 'velocity' AND scatterflag EQ 3 AND $
					grnd[b,r] EQ 1 THEN $
					col = get_gray() $
				ELSE $
					col = cin[color_ind]
				if keyword_set(vector) then begin
					if varr[b,r] lt exclude[0] or varr[b,r] gt exclude[1] then $
						continue
					lat = fov_loc_center[0,b,r]
					lon = ( in_mlt ? $
						mlt(year, yrsec, reform(fov_loc_center[1,b,r])) : $
							reform(fov_loc_center[1,b,r]) )
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
plots, xx, yy, psym=8, symsize=.6*symsize, color=get_foreground(), $
	noclip=0
plots, xx, yy, psym=1, symsize=symsize, thick=3, color=get_foreground(), $
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
	if (id eq 8 or id eq 13 or id eq 16 or id eq 33 or id eq 204) and ~keyword_set(offset) then begin
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

; "return" the date/time of the plotted scan
scan_startjul = jul

END