;+ 
; NAME: 
; OVERLAY_FOV
; 
; PURPOSE: 
; This procedure overlays SuperDARN field-of-views on a stereographic map grid produced by 
; MAP_PLOT_PANEL.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
;
; KEYWORD PARAMETERS:
; COORDS: Set this keyword to the coordinates in which to overlay the fields-of-view.
;
; DATE: Set this keyword to the date for which you want to overlay the FoV. Use this
; keyword together with TIME instead of the JUL keyword.
; This keyword only applies when using Magnetic Local Time coordinates.
;
; TIME: Set this keyword to the time for which you want to overlay the FoV. Use this
; keyword together with DATE instead of the JUL keyword.
; This keyword only applies when using Magnetic Local Time coordinates.
;
; JUL: Set this keyword to the Julian Day Number to use for the plotting of the fields-of-view. Use this
; keyword together instead of the DATE and TIME keyword.
; This keyword only applies when using Magnetic Local Time coordinates.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; FOV_LINESTYLE: Set this keyword to change the style of the field-of-view line.
; Default is 0 (solid).
;
; FOV_LINECOLOR: Set this keyword to a color index to change the color of the field-of-view line.
; Default is black.
;
; FOV_LINETHICK: Set this keyword to change the thickness of the field-of-view line.
; Default is 1.
;
; FOV_FILLCOLOR: Set this keyword to a color index to change the color of the filling
; of the field-of-view. Default is black.
;
; NAMES: Set this to a scalar or array holding radar codes of radars of which
; the fov will be plotted.
;
; IDS: Set this to a scalar or array holding numeric ids of radars of which
; the fov will be plotted.
; 
; MARK_REGION: Set this to a nstat x 4-element vector holding information about
; the region to mark in each radar fov. nstat is the number of fovs to plot,
; i.e. the number of elements of IDS or NAMES. The 4 elements of the vector are
; start_beam, end_beam, start_gate, end_gate.
;
; NO_FILL: Set this keyword to surpress filling of the FoV with gray.
;
; ROTATE: Set this keyword to a number of degree by which to rotate the FoV
; clockwise. Make sure that you give the same number of degrees to
; MAP_PLOT_PANEL and all other plotting routines.
;
; MYOPIC: Set this keyword to plot a FoV in myopic mode. This is a special mode 
; developed for higher spatial resolution. The distance to the first gate in myopic
; mode if  60km (as opposed to 180km in normal mode) and the range gate length is 
; 15km (instead of 45km in normal mode).
;
; PROJECT_TO_OTHER_HEMI: Set this keyword to project the FoV along a magnetic field
; model into the other hemisphere.
;
; EXTERNAL_MODEL: Set this to a string specifying the external magnetic field 
; model used for the tracing of the FoV into the other hemipshere. Can be
; 'none', 't89', 't96', 't01', or 't04s' (default: none).
;
; INTERNAL_MODEL: Set this to a string specifying the internal magnetic field
; model used for the tracing of the FoV into the other hemisphere. Can be
; 'dipole', or 'igrf' (default: igrf).
;
; PARAMS: Parameter input for the external field model.
; If using t89 then it should be a single Kp value, 
; if using t96,t01,t04s it should be a 10
; element array or a 1x10 element array. See the documentation
; for the Tsyganenko models to see what parameters must be passed.
;
; ANNOTATE: Set this keyword to label the radar position with 
; the 3-letter radar code.
;
; CHARSIZE: Set this keyword to the character size used for the 
; annotation of the radar. Only takes effect if ANNOTATE is set.
;
; CHARTHICK: Set this keyword to the character thickness used for the 
; annotation of the radar. Only takes effect if ANNOTATE is set.
;
; CHARCOLOR: Set this keyword to the character color used for the 
; annotation of the radar. Only takes effect if ANNOTATE is set.
;
; ORIENTATION: Set this keyword to a value in degrees by which to rotate
; the radar label clockwise. Only takes effect if ANNOTATE is set.
;
; OFFSETS: This keyword determines the offset of the radar label from
; the radar position, in x and y direction. Default is [.5, -.5]. Set 
; this either to a 2-elements vector that will be used for all radars
; or a Nx2 elements array where N is the number of radar FoVs to plot.
;
; NBEAMS: Set this keyword to override the maximum beam number given in the NETWORK
; structure (i.e., the value in the hardware file).
;
; NRANGES: Set this keyword to override the maximum range gate number given in the NETWORK
; structure (i.e., the value in the hardware file).
;
; GRID: Set this keyword to plot grid lines within the FoV, every 4 beams and
; every 10 range gates.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's OVERLAY_POLAR_COAST.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro overlay_fov, coords=coords, date=date, time=time, jul=jul, $
	silent=silent, $
	names=names, ids=ids, $
	mark_region=mark_region, rotate=rotate, myopic=myopic, $
	no_fill=no_fill, $
	fov_linestyle=fov_linestyle, fov_linecolor=fov_linecolor, $
	fov_linethick=fov_linethick, fov_fillcolor=fov_fillcolor, $
	project_to_other_hemi=project_to_other_hemi, external_model=external_model, internal_model=internal_model, param=param, $
	annotate=annotate, charsize=charsize, charthick=charthick, charcolor=charcolor, orientation=orientation, offsets=offsets, $
	nbeams=nbeams, nranges=nranges, grid=grid, height=height

common radarinfo
common rad_data_blk

if ~keyword_set(fov_linethick) then $
	fov_linethick = 3

if n_elements(fov_linestyle) eq 0 then $
	fov_linestyle = 0

if n_elements(fov_linecolor) eq 0 then $
	fov_linecolor = get_foreground()

if n_elements(fov_fillcolor) eq 0 then $
	fov_fillcolor = get_gray()

if ~keyword_set(coords) then $
	coords = get_coordinates()

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

if n_elements(height) eq 0 then $
	height = 300.

; we need this later
if coords eq 'mlt' then begin
	in_mlt = !true
	_coords = 'magn'
endif else begin
	_coords = coords
	in_mlt = !false
endelse

; check for jul, date and time keyword no matter what
; just to calculate jul
; might be needed for MLT or tracing
if ~keyword_set(jul) then begin
	if ~keyword_set(time) then $
		time = 1200
	if keyword_set(date) then $
		sfjul, date, time, jul
endif
if ~keyword_set(jul) then begin
	if in_mlt then begin
		prinfo, 'Need to set JUL or DATE/TIME keyword when using MLT coordinate system.'
		return
	endif
	jul = julday(1,1,2020)
endif
caldat, jul, mm, dd, year
yrsec = (jul-julday(1,1,year,0,0,0))*86400.d
s = TimeYrsecToYMDHMS(year, mm, dd, hh, ii, ss, yrsec)

;print, year, mm, dd, hh, ii, ss, yrsec
;return
;if in_mlt then begin
;	if ~keyword_set(jul) then begin
;		prinfo, 'Need to set JUL or DATE/TIME keyword when using MLT coordinate system.'
;		return
;	endif
	; get ut seconds after Jan 1 year for mlt calculation
;	caldat, jul, mm, dd, year
;	yrsec = (jul-julday(1,1,year,0,0,0))*86400.d
;endif else begin
	; need this for the site selection in the hardware file
	; simply select latest site
;	year = 2020
;	yrsec = 1L
;endelse

if ~keyword_set(internal_model) then $
	internal_model = 'igrf'

if ~keyword_set(external_model) then $
	external_model = 't96'

if ~keyword_set(param) then begin
	par = fltarr(10)
	if external_model eq 't89' then $
		par[0] = 2.
	if external_model eq 't96' then begin
		par[0] = 2.
		par[1] = -10.
		par[2] = 0.001
		par[3] = 0.001
	endif
endif else $
	par = param

if strlowcase(external_model) eq 'none' then $
	rlim = 100.*!re $
else $
	rlim = 40.*!re

if keyword_set(names) and keyword_set(ids) then begin
	prinfo, 'You can only specify names OR ids'
	return
endif

if ~keyword_set(names) and ~keyword_set(ids) then $
	ids = (*rad_fit_info[rad_fit_get_data_index()]).id

if keyword_set(names) then begin
	radar_infos = make_array(n_elements(names), 7, /float)
	for i=0, n_elements(names)-1 do begin
		tmp = where(network[*].code[0] eq strlowcase(names[i]),count)
		if count eq 0 then begin
			prinfo, 'Could not find station '+strupcase(names[i])+'.'
			return
		endif
		site = RadarYMDHMSGetSite(network[tmp], year, mm, dd, hh, ii, ss)
		;if site.tval eq 0L then $
		;	site = network[tmp].site[0]
		;radar_infos[i,0] = network[tmp].id
		;radar_infos[i,1] = tmp
		;radar_infos[i,2] = network[tmp].site[(network[tmp].snum-1) > 0].maxrange
		;radar_infos[i,3] = ( keyword_set(nbeams) ? nbeams : network[tmp].site[(network[tmp].snum-1) > 0].maxbeam )
		;radar_infos[i,4] = network[tmp].site[(network[tmp].snum-1) > 0].bmsep
		;radar_infos[i,5] = network[tmp].site[(network[tmp].snum-1) > 0].geolat
		;radar_infos[i,6] = network[tmp].site[(network[tmp].snum-1) > 0].geolon
		radar_infos[i,0] = network[tmp].id
		radar_infos[i,1] = tmp
		radar_infos[i,2] = ( keyword_set(nranges) ? nranges : site.maxrange )
		radar_infos[i,3] = ( keyword_set(nbeams) ? nbeams : site.maxbeam )
		radar_infos[i,4] = site.bmsep
		radar_infos[i,5] = site.geolat
		radar_infos[i,6] = site.geolon
	endfor
	ids = reform(radar_infos[*,0])
endif else if keyword_set(ids) then begin
	radar_infos = make_array(n_elements(ids), 7, /float)
	for i=0, n_elements(ids)-1 do begin
		tmp = where(network[*].id eq ids[i],count)
		if count eq 0 then begin
			prinfo, 'Could not find id '+string(ids[i])+'.'
			return
		endif
		site = RadarYMDHMSGetSite(network[tmp], year, mm, dd, hh, ii, ss)
		;if site.tval eq 0L then $
		;	site = network[tmp].site[0]
		;radar_infos[i,0] = network[tmp].id
		;radar_infos[i,1] = tmp
		;radar_infos[i,2] = network[tmp].site[(network[tmp].snum-1) > 0].maxrange
		;radar_infos[i,3] = ( keyword_set(nbeams) ? nbeams : network[tmp].site[(network[tmp].snum-1) > 0].maxbeam )
		;radar_infos[i,4] = network[tmp].site[(network[tmp].snum-1) > 0].bmsep
		;radar_infos[i,5] = network[tmp].site[(network[tmp].snum-1) > 0].geolat
		;radar_infos[i,6] = network[tmp].site[(network[tmp].snum-1) > 0].geolon
		radar_infos[i,0] = network[tmp].id
		radar_infos[i,1] = tmp
		radar_infos[i,2] = ( keyword_set(nranges) ? nranges : site.maxrange )
		radar_infos[i,3] = ( keyword_set(nbeams) ? nbeams : site.maxbeam )
		radar_infos[i,4] = site.bmsep
		radar_infos[i,5] = site.geolat
		radar_infos[i,6] = site.geolon
	endfor
endif
nstats = n_elements(ids)

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
	_offsets = rebin([.5,-3.], 2, nstats)

; check the time is set if tracing
if keyword_set(project_to_other_hemi) and ~keyword_set(jul) then begin
	prinfo, 'Must give JUL or DATE/TIME keyword for field line trace.'
	return
endif

; convert radar position if neccessary
for i=0, nstats-1 do begin
	if keyword_set(project_to_other_hemi) then begin
		if internal_model eq 'dipole' then begin
			tmp = cnvcoord(radar_infos[i,5], radar_infos[i,6], 0.5)
			tmp[0] = -tmp[0]
			if _coords eq 'geog' then $
				tmp = cnvcoord(tmp[0], tmp[1], tmp[2], /geo)
			radar_infos[i,5] = tmp[0]
			radar_infos[i,6] = tmp[1]
		endif else begin
			_lat = radar_infos[i,5]
			_lon = radar_infos[i,6]
			_x = (!re+200.)*cos(_lon*!dtor)*cos(_lat*!dtor)
			_y = (!re+200.)*sin(_lon*!dtor)*cos(_lat*!dtor)
			_z = (!re+200.)*sin(_lat*!dtor)
			in_arr = [ [_x], [_y], [_z] ]
			if _lat gt 0 then $
				_south = 1 $
			else $
				_south = 0
			tarr = [(jul - julday(1,1,1970,0))*86400.d]
			trace2iono, tarr, in_arr, out_arr, $
				in_coord='geo', out_coord='geo', $
				external=external_model, internal=internal_model, $
				par=par, south=_south, rlim=rlim, /km
			if n_elements(out_arr) lt 2 then $
				return
			if sqrt(total((out_arr/!re)^2)) gt 2. then begin
				radar_infos[i,5] = !values.f_nan
				radar_infos[i,6] = !values.f_nan
			endif else begin
				xyz_to_polar, out_arr/!re, mag=alt, theta=glat, phi=glon
				if _coords eq 'magn' then begin
					tmpp = cnvcoord(glat, glon, .5)
					radar_infos[i,5] = tmpp[0]
					radar_infos[i,6] = tmpp[1]
				endif else begin
					radar_infos[i,5] = glat
					radar_infos[i,6] = glon
				endelse
			endelse
		endelse
	endif else begin
		if _coords eq 'magn' then begin
			tmp = cnvcoord(radar_infos[i,5], radar_infos[i,6], 0.5)
			radar_infos[i,5] = tmp[0]
			radar_infos[i,6] = tmp[1]
		endif
	endelse
endfor

_lagfr0 = 1200.
_smsep0 = 300.
if keyword_set(myopic) then begin
	_lagfr0 = 1200./3.
	_smsep0 = 300./3.
endif

; get a local copy of all the fovs in the
; right coordinate system. it's cumbersome but
; we need that because we want the overlaying
; of several fovs to go right
plot_fov = make_array(nstats, 2, $
	max(radar_infos[*,3])+1, max(radar_infos[*,2])+1, /float)

; loop through stations
for i=0, nstats-1 do begin
;	print, ids[i], radar_infos[i,3], radar_infos[i,2], radar_infos[i,4], year, yrsec, _coords
	rad_define_beams, ids[i], radar_infos[i,3], radar_infos[i,2], radar_infos[i,4], year, yrsec, coords=_coords, $
		lagfr0=_lagfr0, smsep0=_smsep0, fov_loc_center=fov_loc_center, height=height
;	print, fov_loc_center
	; fill local array
	for b=0, radar_infos[i,3] do begin
		for r=0, radar_infos[i,2] do begin
			lat = fov_loc_center[0,b,r]
			lon = fov_loc_center[1,b,r]
			if keyword_set(project_to_other_hemi) then begin
				if internal_model eq 'dipole' then begin
					if _coords ne 'magn' then begin
						tmpp = cnvcoord(lat, lon, 200.)
						_lat = tmpp[0]
						_lon = tmpp[1]
					endif else begin
						_lat = lat
						_lon = lon
					endelse
					_lat = -_lat
					if _coords ne 'magn' then begin
						tmpp = cnvcoord(_lat, _lon, 200., /geo)
						lat = tmpp[0]
						lon = tmpp[1]
					endif else begin
						lat = _lat
						lon = _lon
					endelse
					lon = in_mlt ? mlt(year, yrsec, lon) : lon
					plot_fov[i,*,b,r] = calc_stereo_coords(lat,lon,mlt=in_mlt)
				endif else begin
					if _coords eq 'magn' then begin
						tmpp = cnvcoord(lat, lon, 200., /geo)
						_lat = tmpp[0]
						_lon = tmpp[1]
					endif else begin
						_lat = lat
						_lon = lon
					endelse
					_x = (!re+200.)*cos(_lon*!dtor)*cos(_lat*!dtor)
					_y = (!re+200.)*sin(_lon*!dtor)*cos(_lat*!dtor)
					_z = (!re+200.)*sin(_lat*!dtor)
					in_arr = [ [_x], [_y], [_z] ]
					if _lat gt 0 then $
						_south = 1 $
					else $
						_south = 0
					tarr = [(jul - julday(1,1,1970,0))*86400.d]
					trace2iono, tarr, in_arr, out_arr, $
						in_coord='geo', out_coord='geo', $
						external=external_model, internal=internal_model, $
						par=par, south=_south, rlim=rlim, /km
					if sqrt(total((out_arr/!re)^2)) gt 2. then begin
	;					print, out_arr[0]/!re, out_arr[1]/!re, out_arr[2]/!re
						plot_fov[i,*,b,r] = replicate(!values.f_nan, 2)
					endif else begin
						xyz_to_polar, out_arr/!re, mag=alt, theta=glat, phi=glon
						if _coords eq 'magn' then begin
							tmpp = cnvcoord(glat, glon, 200.)
							lat = tmpp[0]
							lon = tmpp[1]
						endif else begin
							lat = glat
							lon = glon
						endelse
						lon = in_mlt ? mlt(year, yrsec, lon) : lon
						plot_fov[i,*,b,r] = calc_stereo_coords(lat,lon,mlt=in_mlt)
					endelse
				endelse
			endif else begin
				lon = in_mlt ? mlt(year, yrsec, lon) : lon
				plot_fov[i,*,b,r] = calc_stereo_coords(lat,lon,mlt=in_mlt)
			endelse
		endfor
	endfor
endfor

; reset no_fill in case FOV contains
; NaNs (from field line trace)
nana = where(~finite(plot_fov), nnan)
if nnan gt 1 then begin
	no_fill = 1
endif

;- need to loop through the things to get the overlaying right
;- first the grey background
if ~keyword_set(no_fill) then begin

	; load a lighter gray for the fovs
	idx = get_gray()
	tvlct, rr, gg, bb, /get
	tvlct, 220, 220, 220, idx

	for i=0, nstats-1 do begin
		;- plot full fov
		xx = [reform(plot_fov[i,0,0,0:radar_infos[i,2]]), $
			reform(plot_fov[i,0,0:radar_infos[i,3],radar_infos[i,2]]), $
			reverse(reform(plot_fov[i,0,radar_infos[i,3],0:radar_infos[i,2]])), $
			reverse(reform(plot_fov[i,0,0:radar_infos[i,3],0])), $
			plot_fov[i,0,0,0] $
		]
		yy = [reform(plot_fov[i,1,0,0:radar_infos[i,2]]), $
			reform(plot_fov[i,1,0:radar_infos[i,3],radar_infos[i,2]]), $
			reverse(reform(plot_fov[i,1,radar_infos[i,3],0:radar_infos[i,2]])), $
			reverse(reform(plot_fov[i,1,0:radar_infos[i,3],0])), $
			plot_fov[i,1,0,0] $
		]

		if n_elements(rotate) ne 0 then begin
			_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
			_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
			xx = _x1
			yy = _y1
		endif
		;if keyword_set(rotate) then $
		;	swap, xx, yy, /right

		polyfill, xx, yy, color=fov_fillcolor, noclip=0
	endfor
	
	; get the old grey back
	tvlct, rr[idx], gg[idx], bb[idx], idx

endif

;- then the ranges and beams to be marked.
if keyword_set(mark_region) then begin
	rsize = size(mark_region)
	rnn = n_elements(mark_region)
	mr_crap = !false
	if rnn mod 4 ne 0 then begin
		prinfo, 'Number of elements in MARK_REGION must be a multiple of 4: [start_beam,end_beam,start_range,end_range].'
		mr_crap = !true
	endif
	if rnn/4. ne nstats then begin
		prinfo, 'Number of regions in MARK_REGION must be the same as that in FOVS.'
		mr_crap = !true
	endif
	if ~mr_crap then begin
		;- fill regions
		for i=0, nstats-1 do begin
			aregion = mark_region[*,i]
			;print, aregion[0] ge 0
			;print, aregion[1] ge 0
			;print, aregion[1] gt aregion[0]
			;print, aregion[2] ge 0
			;print, aregion[3] ge 0
			;print, aregion[3] gt aregion[2]
			;print, aregion[0] lt rad_fit_info.nbeams
			;print, aregion[1] lt rad_fit_info.nbeams
			;print, aregion[2] le rad_fit_info.ngates
			;print, aregion[3] le rad_fit_info.ngates
			if aregion[0] ge 0 and aregion[1] ge 0 and aregion[1] gt aregion[0] and $
				aregion[2] ge 0 and aregion[3] ge 0 and aregion[3] gt aregion[2] and $
				aregion[0] le radar_infos[i,3] and aregion[1] le radar_infos[i,3] and $
				aregion[2] le radar_infos[i,2] and aregion[3] le radar_infos[i,2] then begin
				xx = [reform(plot_fov[i,0,aregion[0],aregion[2]:aregion[3]]), $
					reverse(reform(plot_fov[i,0,aregion[1],aregion[2]:aregion[3]])),$
					plot_fov[i,0,aregion[0],aregion[2]]]
				yy = [reform(plot_fov[i,1,aregion[0],aregion[2]:aregion[3]]), $
					reverse(reform(plot_fov[i,1,aregion[1],aregion[2]:aregion[3]])), $
					plot_fov[i,1,aregion[0],aregion[2]]]

				if n_elements(rotate) ne 0 then begin
					_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
					_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
					xx = _x1
					yy = _y1
				endif
				;if keyword_set(rotate) then $
				;	swap, xx, yy, /right

				polyfill, xx, yy, color=fov_fillcolor, noclip=0
			endif else $
				prinfo, 'Something is wrong in MARK_REGION [start_beam,end_beam,start_range,end_range]: '+strjoin(string(aregion)), /forc
		endfor
		;- then the outside
		for i=0, nstats-1 do begin
			aregion = mark_region[*,i]
			if aregion[0] ge 0 and aregion[1] ge 0 and aregion[1] gt aregion[0] and $
				aregion[2] ge 0 and aregion[3] ge 0 and aregion[3] gt aregion[2] and $
				aregion[0] lt radar_infos[i,3] and aregion[1] lt radar_infos[i,3] and $
				aregion[2] lt radar_infos[i,2] and aregion[3] lt radar_infos[i,2] then begin
				xx = [reform(plot_fov[i,0,aregion[0],aregion[2]:aregion[3]]), $
					reverse(reform(plot_fov[i,0,aregion[1],aregion[2]:aregion[3]])),$
					plot_fov[i,0,aregion[0],aregion[2]]]
				yy = [reform(plot_fov[i,1,aregion[0],aregion[2]:aregion[3]]), $
					reverse(reform(plot_fov[i,1,aregion[1],aregion[2]:aregion[3]])), $
					plot_fov[i,1,aregion[0],aregion[2]]]

				if n_elements(rotate) ne 0 then begin
					_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
					_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
					xx = _x1
					yy = _y1
				endif
				;if keyword_set(rotate) then $
				;	swap, xx, yy, /right

				oplot, xx, yy, color=fov_linecolor, thick=fov_linethick, linestyle=fov_linestyle, $
					noclip=0
			endif
		endfor
	endif
endif

for i=0, nstats-1 do begin
;- plot full fov

	if keyword_set(grid) then begin
		for b=1, radar_infos[i,3]/4-1 do begin
			xx = reform(plot_fov[i,0,b*4,0:radar_infos[i,2]])
			yy = reform(plot_fov[i,1,b*4,0:radar_infos[i,2]])
			if n_elements(rotate) ne 0 then begin
				_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
				_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
				xx = _x1
				yy = _y1
			endif
			oplot, xx, yy, noclip=0, thick=2.*fov_linethick, color=get_background()
			oplot, xx, yy, color=get_gray(), thick=.3*fov_linethick, linestyle=fov_linestyle, $
				noclip=0
		endfor
		for r=1, radar_infos[i,2]/10-1 do begin
			xx = reform(plot_fov[i,0,0:radar_infos[i,3],r*10])
			yy = reform(plot_fov[i,1,0:radar_infos[i,3],r*10])
			if n_elements(rotate) ne 0 then begin
				_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
				_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
				xx = _x1
				yy = _y1
			endif
			oplot, xx, yy, noclip=0, thick=2.*fov_linethick, color=get_background()
			oplot, xx, yy, color=get_gray(), thick=.3*fov_linethick, linestyle=fov_linestyle, $
				noclip=0
		endfor
	endif

	xx = [reform(plot_fov[i,0,0,0:radar_infos[i,2]]), $
		reform(plot_fov[i,0,0:radar_infos[i,3],radar_infos[i,2]]), $
		reverse(reform(plot_fov[i,0,radar_infos[i,3],0:radar_infos[i,2]])), $
		reverse(reform(plot_fov[i,0,0:radar_infos[i,3],0])), $
		plot_fov[i,0,0,0] $
	]
	yy = [reform(plot_fov[i,1,0,0:radar_infos[i,2]]), $
		reform(plot_fov[i,1,0:radar_infos[i,3],radar_infos[i,2]]), $
		reverse(reform(plot_fov[i,1,radar_infos[i,3],0:radar_infos[i,2]])), $
		reverse(reform(plot_fov[i,1,0:radar_infos[i,3],0])), $
		plot_fov[i,1,0,0] $
	]

	if n_elements(rotate) ne 0 then begin
		_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
		_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
		xx = _x1
		yy = _y1
	endif
	;if keyword_set(rotate) then $
	;	swap, xx, yy, /right

	oplot, xx, yy, noclip=0, thick=3.*fov_linethick, color=get_background()
	oplot, xx, yy, color=fov_linecolor, thick=fov_linethick, linestyle=fov_linestyle, $
		noclip=0

	load_usersym, /circle
	;- plot the radar position
	if in_mlt then begin
		radar_infos[i,6] = mlt(year, yrsec, radar_infos[i,6])
	endif
	tmp = calc_stereo_coords(radar_infos[i,5],radar_infos[i,6],mlt=in_mlt)
	rxx = tmp[0]
	ryy = tmp[1]
	if n_elements(rotate) ne 0 then begin
		_x1 = cos(rotate*!dtor)*rxx - sin(rotate*!dtor)*ryy
		_y1 = sin(rotate*!dtor)*rxx + cos(rotate*!dtor)*ryy
		rxx = _x1
		ryy = _y1
	endif
	;if keyword_set(rotate) then $
	;	swap, rxx, ryy, /right
	plots, rxx, ryy, psym=1, thick=3, noclip=0
	plots, rxx, ryy, psym=8, noclip=0, symsize=0.6

	if keyword_set(annotate) then begin
		tmp = where(network[*].id eq radar_infos[i,0])
		astring = strupcase(network[tmp].code[0])
		; shift the label for FHW a little to the left
		; so that it doesn't interfere with FHE
		; same for sto, bks and ksr
		align = 0.
 		if (radar_infos[i,0] eq 8 or radar_infos[i,0] eq 13 or radar_infos[i,0] eq 16 or radar_infos[i,0] eq 33 or radar_infos[i,0] eq 204 or radar_infos[i,0] eq 206) and ~keyword_set(offsets) then begin
			_offsets[0,i] = -.5
			align = 1.
		endif
		nxoff = _offsets[0,i]*cos(orientation*!dtor) - _offsets[1,i]*sin(orientation*!dtor)
		nyoff = _offsets[0,i]*sin(orientation*!dtor) + _offsets[1,i]*cos(orientation*!dtor)
		xyouts, rxx+nxoff, ryy+nyoff, astring, charthick=10.*charthick, $
			charsize=charsize, orientation=orientation, noclip=0, align=align, color=get_white()
		xyouts, rxx+nxoff, ryy+nyoff, astring, charthick=2.*charthick, $
			charsize=charsize, orientation=orientation, noclip=0, color=charcolor, align=align
	endif

endfor

end
