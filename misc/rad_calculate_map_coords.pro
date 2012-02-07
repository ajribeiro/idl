pro rad_calculate_map_coords, ids=ids, names=names, $
	jul=jul, date=date, time=time, $
	coords=coords, nbeams=nbeams, nranges=nranges, $
	xrange=xrange, yrange=yrange, rotate=rotate, $
	fringe=fringe

common radarinfo

nids = n_elements(ids)
nnms = n_elements(names)

if nids lt 1 and nnms lt 1 then begin
	prinfo, 'Must gives IDS or NAMES.'
	return
endif

if ~keyword_set(coords) then $
	coords = get_coordinates()

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

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

if nnms gt 0 then begin
	ids = intarr(nnms)
	for i=0, nnms-1 do begin
		tmp = where(network[*].code[0] eq strlowcase(names[i]),count)
		if count eq 0 then begin
			prinfo, 'Could not find station '+strupcase(names[i])+'.'
			return
		endif
		ids[i] = network[tmp].id
	endfor
	nids = n_elements(ids)
endif

; put some padding around the edges
if n_elements(fringe) eq 0 then $
	fringe = 2.

xmin =  90.
xmax = -90.
ymin =  90.
ymax = -90.

; loop through all stations to find the 
; center longitude
for i=0, nids-1 do begin
	tmp = where(network[*].id eq ids[i], count)
	if count eq 0 then begin
		prinfo, 'Could not find station '+strupcase(names[i])+'.'
		return
	endif
	site = RadarYMDHMSGetSite(network[tmp], year, mm, dd, hh, ii, ss)
	if coords eq 'geog' then begin
		rad_lat = site.geolat
		rad_lon = site.geolon
	endif else begin
		tmp = cnvcoord(site.geolat, site.geolon, 1.)
		rad_lat = tmp[0]
		; we'll convert that to MLT later, if needed
		rad_lon = tmp[1]
	endelse
	_nbeams = ( keyword_set(nbeams) ? nbeams : site.maxbeam )
	_nranges = ( keyword_set(nranges) ? nranges : site.maxrange )
	rad_define_beams, ids[i], $
		_nbeams, _nranges, $
		year, yrsec, $
		coords=_coords, /normal, fov_loc_full=fov_loc_full
	alat = [reform(fov_loc_full[0,*,*,*], 4*(_nbeams+1)*(_nranges+1)), rad_lat]
	alon = [reform(fov_loc_full[1,*,*,*], 4*(_nbeams+1)*(_nranges+1)), rad_lon]
	if in_mlt then $
		alon = mlt(replicate(year, n_elements(alon)), replicate(yrsec, n_elements(alon)), alon)
	tmp = calc_stereo_coords(alat, alon, mlt=in_mlt)
	_x1 = tmp[0,*]
	_y1 = tmp[1,*]
	axmin = min(_x1, xminind, max=axmax, SUBSCRIPT_Max=xmaxind)
	aymin = min(_y1, max=aymax)
	if axmin lt xmin then $
		xmin = axmin
	if aymin lt ymin then $
		ymin = aymin
	if axmax gt xmax then $
		xmax = axmax
	if aymax gt ymax then $
		ymax = aymax
endfor

; in MLT coords, we want the 0 MLT always be at the bottom
; no so rotation - only zooming in on the FoV
if in_mlt then begin
	rotate = 0.
	xrange = [xmin, xmax] + [-1.,1.]*fringe
	yrange = [ymin, ymax] + [-1.,1.]*fringe
	return
endif

; calculate the angle needed to rotate FoV into the
; center
rotate = -atan((xmax+xmin)/2., -(ymax+ymin)/2.)*!radeg

; rotate everything so that the center longitude
; is at 0 and then find the extend of the 
; window
xmin =  90.
xmax = -90.
ymin =  90.
ymax = -90.

for i=0, nids-1 do begin
	tmp = where(network[*].id eq ids[i], count)
	if count eq 0 then begin
		prinfo, 'Could not find station '+strupcase(names[i])+'.'
		return
	endif
	site = RadarYMDHMSGetSite(network[tmp], year, mm, dd, hh, ii, ss)
	if coords eq 'geog' then begin
		rad_lat = site.geolat
		rad_lon = site.geolon
	endif else begin
		tmp = cnvcoord(site.geolat, site.geolon, 1.)
		rad_lat = tmp[0]
		rad_lon = tmp[1]
	endelse
	_nbeams = ( keyword_set(nbeams) ? nbeams : site.maxbeam )
	_nranges = ( keyword_set(nranges) ? nranges : site.maxrange )
	rad_define_beams, ids[i], $
		_nbeams, _nranges, $
		year, yrsec, $
		coords=_coords, /normal, fov_loc_full=fov_loc_full
	alat = [reform(fov_loc_full[0,*,*,*], 4*(_nbeams+1)*(_nranges+1)), rad_lat]
	alon = [reform(fov_loc_full[1,*,*,*], 4*(_nbeams+1)*(_nranges+1)), rad_lon]
	tmp = calc_stereo_coords(alat, alon, mlt=in_mlt)
	_x1 = cos(rotate*!dtor)*tmp[0,*] - sin(rotate*!dtor)*tmp[1,*]
	_y1 = sin(rotate*!dtor)*tmp[0,*] + cos(rotate*!dtor)*tmp[1,*]
	axmin = min(_x1, max=axmax)
	aymin = min(_y1, max=aymax)
	if axmin lt xmin then $
		xmin = axmin
	if aymin lt ymin then $
		ymin = aymin
	if axmax gt xmax then $
		xmax = axmax
	if aymax gt ymax then $
		ymax = aymax
endfor

xrange = [xmin, xmax] + [-1.,1.]*fringe
yrange = [ymin, ymax] + [-1.,1.]*fringe

end