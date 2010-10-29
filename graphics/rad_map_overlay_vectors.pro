;+
; NAME: 
; RAD_MAP_OVERLAY_VECTORS
;
; PURPOSE: 
; This procedure overlays velocity vectors from a map file on a map.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_OVERLAY_VECTORS
;
; KEYWORD PARAMETERS:
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; TIME: A 2-element vector giving the time range to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; INDEX: The index number of the map to plot. If not set, that map with the timestamp closest
; to the gien input date will be plotted.
;
; NORTH: Set this keyword to plot the convection pattern for the northern hemisphere.
;
; SOUTH: Set this keyword to plot the convection pattern for the southern hemisphere.
;
; HEMISPHERE: Set this to 1 for the northern and to -1 for the southern hemisphere.
;
; COORDS: Set this to a string containing the name of the coordinate system to plot the map in.
; Allowable systems are geographic ('geog'), magnetic ('magn') and magnetic local time ('mlt').
;
; SCALE: Set this keyword to a 2-element vector containing the minimum and maximum velocity 
; used for coloring the vectors.
;
; MODEL: Set this keyword to include velocity vectors added by the model.
;
; MERGE: Set this keyword to plot velocity vectors
;
; TRUE: Set this keyword to plot velocity vectors
;
; LOS: Set this keyword to plot velocity vectors
;
; IGNORE_BND: Set this keyword to ignore the HM boundary. If this keyword is NOT set, 
; velocity vectors below the HM boundary will be drawn in gray.
;
; GRAD: Set this keyword to plot velocity vectors calculated from the ExB drift using the coefficients
; of the potential.
;
; FACTOR: Set this keyword to alter the length of vectors.
;
; SIZE: Set this keyword to adjust thickness of vector and size of dot.
;
; RADAR_IDS: Set this keyword to a numeric id or an array of numeric ids 
; of a radar to only plot vectors originating from that radar.
;
; SILENT: Set this kewyword to surpress warning messages.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding map data.
;
; MODIFICATION HISTORY: 
; Based on Adrian Grocott's OVERLAY_VECTORS.
; Written by Lasse Clausen, Dec, 22 2009
;-
pro rad_map_overlay_vectors, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, scale=scale, ignore_bnd=ignore_bnd, $
	model=model, merge=merge, true=true, los=los, grad=grad, $
	factor=factor, size=size, radar_ids=radar_ids, $
	silent=silent

common rad_data_blk
common recent_panel
common radarinfo

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'mlt') and ~strcmp(coords, 'magn') then begin
	prinfo, 'Coordinate system must be MLT or MAGN, setting to MLT'
	coords = 'mlt'
endif

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

if rad_map_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for map date.'
	caldat, (*rad_map_data[int_hemi]).sjuls[0], month, day, year
	date = year*10000L + month*100L + day
endif
parse_date, date, year, month, day

if n_elements(time) lt 1 then $
	time = 0000

if n_elements(time) gt 1 then begin
	if ~keyword_set(silent) then $
		prinfo, 'TIME must be a scalar, selecting first element: '+string(time[0], format='(I4)')
	time = time[0]
endif
sfjul, date, time, jul, long=long

; calculate index from date and time
if n_elements(index) eq 0 then $
	dd = min( abs( (*rad_map_data[int_hemi]).mjuls-jul ), index) $
else $
	dd = 0.

; check if time distance is not too big
if dd*1440.d gt 60. then $
	prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

if ~keyword_set(scale) then begin
	scale = get_default_range('velocity')
	scale -= min(scale)
endif

; get longitude shift
lon_shft = (*rad_map_data[int_hemi]).lon_shft[index]

utsec = (jul - julday(1, 1, year, 0, 0))*86400.d
; calculate lon_shft, i.e. shift magnetic longitude into mlt coordinates
if coords eq 'mlt' then $
	lon_shft += mlt(year, utsec, 0.)*15.

; get boundary data
bnd = (*(*rad_map_data[int_hemi]).bvecs[index])
num_bnd = (*rad_map_data[int_hemi]).bndnum[index]

if ~keyword_set(size) then $
	size = 1.

if ~keyword_set(factor) then $
	factor = 480. $
else $
	factor = factor*480.

if ~keyword_set(radar_ids) then $
	r_ids = [0] $
else $
	r_ids = radar_ids

if ~keyword_set(los) and ~keyword_set(merge) and ~keyword_set(grad) and ~keyword_set(true) then $
	grad = 1

if keyword_set(merge) then $
	vecs = rad_map_calc_merge_vecs(int_hemi, index, indeces=indeces) $
else if keyword_set(true) then $
	vecs = rad_map_calc_true_vecs(int_hemi, index) $
else if keyword_set(los) then $
	vecs = rad_map_calc_los_vecs(int_hemi, index) $
else if keyword_set(grad) then $
	vecs = rad_map_calc_grad_vecs(int_hemi, index)

; get color preferences
foreground  = get_foreground()
color_steps = 100.
ncolors     = get_ncolors()
bottom      = get_bottom()

; Set color bar and levels
cin = FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps

real_nvec  = (*rad_map_data[int_hemi]).vcnum[index]
model_nvec = (*rad_map_data[int_hemi]).modnum[index]
st_ids     = (*(*rad_map_data[int_hemi]).gvecs[index])[*].st_id
ncols = 5

if keyword_set(merge) then begin
	real_nvec = (vecs.real.pos[0,0] eq -9999.9 ? 0 : n_elements(vecs.real.pos[0,*]))
	st_ids = st_ids[indeces]
	ncols = 6
endif

IF keyword_set(model) THEN BEGIN
	vdata = make_array(ncols, real_nvec+model_nvec, /float, value=-9999.9)
	vdata[0:1,real_nvec:real_nvec+model_nvec-1] = vecs.model.pos
	vdata[2:3,real_nvec:real_nvec+model_nvec-1] = vecs.model.vectors
	npdat = real_nvec+model_nvec
ENDIF ELSE BEGIN
	vdata = make_array(ncols, real_nvec>1, /float, value=-9999.9)
	npdat = real_nvec
ENDELSE

IF real_nvec GT 0 THEN BEGIN
	vdata[0:1, 0:real_nvec-1] = vecs.real.pos
	vdata[2:3, 0:real_nvec-1] = vecs.real.vectors
	if keyword_set(merge) then $
		vdata[4:5, 0:real_nvec-1]   = st_ids $
	else $
		vdata[4, 0:real_nvec-1]   = st_ids
ENDIF

; plot radar positions
; that provides an easy view of who
; contributed data.
load_usersym, /circle
uids = st_ids[uniq(st_ids[sort(st_ids)])]
for i=0, n_elements(uids)-1 do begin
	caldat, jul, mm, dd, yy, hh, ii, ss
	rtmp = radargetradar(network, uids[i])
	site = radarymdhmsgetsite(rtmp, yy, mm, dd, hh, ii, ss)
	ttt = cnvcoord(site.geolat, site.geolon, 0.)
	mlat = ttt[0]
	mlon = ttt[1]
	if coords eq 'mlt' then $
		mlon = mlt(year, utsec, mlon)
	tt = calc_stereo_coords(mlat, mlon, mlt=(coords eq 'mlt'))
	plots, tt[0], tt[1], psym=1, thick=3, noclip=0
	plots, tt[0], tt[1], psym=8, noclip=0, symsize=0.6

	astring = strupcase(rtmp.code[0])
	; shift the label for FHW a little to the left
	; so that it doesn't interfere with FHE
	; same for sto, bks and ksr
	align = 0.
	offset = [.5,-3.]
		if (rtmp.id eq 8 or rtmp.id eq 13 or rtmp.id eq 16 or rtmp.id eq 33 or rtmp.id eq 204 or rtmp.id eq 206) then begin
			offset[0] = -.5
		align = 1.
	endif
	xyouts, tt[0]+offset[0], tt[1]+offset[1], astring, charthick=10., $
		charsize=charsize, orientation=orientation, noclip=0, align=align, color=get_white()
	xyouts, tt[0]+offset[0], tt[1]+offset[1], astring, charthick=2., $
		charsize=charsize, orientation=orientation, noclip=0, align=align
endfor

; load circle 
load_usersym, /circle

;vdata(0,*)=gmlong  vdata(1,*)=gmlat  vdata(2,*)=magnitude  vdata(3,*)=azimuth  vdata(4,*)=radar_id
if npdat gt 0 then begin
  FOR i=0, npdat-1 DO BEGIN

    if r_ids[0] ne 0 then begin
			if keyword_set(merge) then begin
				dd = where(r_ids eq vdata[4,i] or r_ids eq vdata[5,i], cc)
				if cc eq 0 then $
					continue
			endif else begin
				dd = where(r_ids eq vdata[4,i], cc)
				if cc eq 0 then $
					continue
			endelse
		endif

		lat = vdata[0,i]
		lon = vdata[1,i]
		; check if vector lies underneath boundary
		; if so, plot it gray
		vec_col = cin[(MAX(where(lvl le ((vdata[2,i] > scale[0]) < scale[1]))) > 0)]
		if ~keyword_set(ignore_bnd) then begin
			nearest_bnd = 5*round(lon/5.)
			dd = min(abs(bnd[*].lon-nearest_bnd), minind)
			IF abs(lat) LT abs(bnd[minind].lat) THEN $
				vec_col = get_gray()
		endif

		if coords eq 'mlt' then $
			plon = (lon+lon_shft)/15. $
		else $
			plon = (lon+lon_shft)
		lon_rad = (lon + lon_shft)*!dtor
		tmp = calc_stereo_coords(lat, plon, mlt=(coords eq 'mlt'))
		x_pos_vec = tmp[0]
		y_pos_vec = tmp[1]

		vec_azm = vdata[3,i]*!dtor + ( hemisphere lt 0. ? !pi : 0. )
		vec_len = factor*vdata[2,i]/!re/1e3 ;*hemisphere

		; Find latitude of end of vector
		vec_lat = asin( $
			( $
				( sin(lat*!dtor)*cos(vec_len) + $
					cos(lat*!dtor)*sin(vec_len)*cos(vec_azm) $
				) < 1. $
			) > (-1.) $
		)*!radeg

		; Find longitude of end of vector
		delta_lon = ( $
			atan( sin(vec_azm)*sin(vec_len)*cos(lat*!dtor), cos(vec_len) - sin(lat*!dtor)*sin(vec_lat*!dtor) ) $
		)

		if coords eq 'mlt' then $
			vec_lon = (lon_rad + delta_lon)*!radeg/15. $
		else $
			vec_lon = (lon_rad + delta_lon)*!radeg

		; Find x and y position of end of vectors
		tmp = calc_stereo_coords(vec_lat, vec_lon, mlt=(coords eq 'mlt'))
		new_x = tmp[0]
		new_y = tmp[1]

		oplot, [x_pos_vec], [y_pos_vec], psym=8, $
			symsize=1.5*0.3*sqrt(size), color=get_background(), noclip=0
		oplot, [x_pos_vec,new_x], [y_pos_vec,new_y],$
			thick=2.5*1.5*size, COLOR=get_background(), noclip=0
		oplot, [x_pos_vec], [y_pos_vec], psym=8, $
			symsize=0.3*sqrt(size), color=vec_col, noclip=0
		oplot, [x_pos_vec,new_x], [y_pos_vec,new_y],$
			thick=1.5*size, COLOR=vec_col, noclip=0

  ENDFOR
ENDIF

xyouts, !x.crange[1]-.05*(!x.crange[1]-!x.crange[0]), !y.crange[0]+.05*(!y.crange[1]-!y.crange[0]), $
	strtrim(string(real_nvec),2)+' pts', align=1, charsize=.75*get_charsize(rxmaps, rymaps)

end
