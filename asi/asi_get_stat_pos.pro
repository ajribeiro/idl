;+
; NAME: 
; ASI_GET_STAT_POS
;
; PURPOSE: 
; This procedure returns the geodetic or geomagnetic latitudes of ground-based
; all-sky imager stations. Default is geodetic coordinates.
; 
; CATEGORY: 
; All-Sky Imager
; 
; CALLING SEQUENCE:  
; Result = ASI_GET_STAT_POS(Stats)
;
; OPTIONAL INPUTS:
; Stats: Set this to a named variable with the station abbreviations of 
; ground-based magnetometer stations for which the positions will be returned.
;
; KEYWORD PARAMETERS:
; LONGITUDE: Set this to a named variable that wil contain the longitudes of the specified
; stations.
;
; COORDS: Set this to a string specifying the coordinate system, either 'geog' or 'magn'. 
; Default is geodetic coordinates.
;
; GET: Set this keyword in conjunction with the chain or ALL keywords. If this keyword is set, 
; all positions of magnetometers belonging to the specified chain are returned, as well as their
; abbreviations in Stats.
;
; ALL: Set this keyword to return the positions of all supported magnetometers.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Dec, 4 2009
;-
function asi_get_stat_pos, stats, longitude=longitude, coords=coords, $
    get=get, all=all, themis=themis

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return, -1
endif

if strcmp(strlowcase(coords), 'geog') then $
	ioff = 0 $
else if  strcmp(strlowcase(coords), 'magn') then $
	ioff = 2 $
else begin
	prinfo, 'Coordinate system not supported: '+coords
	return, -1
endelse

asi_read_stat_pos, suppstats, supplats, supplons, chains=chains, coords=coords
inds = -1

if keyword_set(get) then begin
	if keyword_set(themis) then $
		inds = ( inds[0] eq -1 ? where(chains eq !ASI_THEMIS) : [inds, where(chains eq !ASI_THEMIS)] )
	if keyword_set(all) then $
		inds = indgen(n_elements(suppstats))
	if inds[0] eq -1 then $
		return, -1.
	stats = suppstats[inds]
	longitude = supplons[inds]
	return, supplats[inds]
endif else begin
	nn = n_elements(stats)
	if nn lt 1 then begin
		prinfo, 'No station names given. Give station names or set GET keyword.'
		return, -1.
	endif
	longitude = replicate(-1., nn)
	latitudes = replicate(-1., nn)
	for i=0, nn-1 do begin
		tmp = where(strupcase(stats[i]) eq suppstats)
		if tmp[0] ne -1 then begin
			longitude[i] = supplons[tmp[0]]
			latitudes[i] = supplats[tmp[0]]
		endif
	endfor
	return, latitudes
endelse

end
