;+
; NAME: 
; GBM_GET_POS
;
; PURPOSE: 
; This procedure returns the geodetic or geomagnetic latitudes of ground-based
; magnetometer stations. Default is geodetic coordinates.
; 
; CATEGORY: 
; Ground-Based Magnetometers
; 
; CALLING SEQUENCE:  
; Result = GBM_GET_POS(Stats)
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
function gbm_get_pos, stats, longitude=longitude, coords=coords, $
	date=date, time=time, long=long, jul=jul, $
    get=get, all=all, $
		carisma=carisma, image=image, greenland=greenland, $
		samnet=samnet, antarctica=antarctica, intermagnet=intermagnet, $
		gima=gima, japmag=japmag, maccs=maccs, samba=samba, nipr=nipr, $
		gbm_themis=gbm_themis

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return, -1
endif

gbm_read_pos, suppstats, supplats, supplons, chains=chains, coords=coords, $
	date=date, time=time, long=long, jul=jul
inds = -1

if keyword_set(get) then begin
    if keyword_set(carisma) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !CARISMA) : [inds, where(chains eq !CARISMA)] )
    if keyword_set(image) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !IMAGE) : [inds, where(chains eq !IMAGE)] )
    if keyword_set(greenland) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !GREENLAND) : [inds, where(chains eq !GREENLAND)] )
    if keyword_set(samnet) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !SAMNET) : [inds, where(chains eq !SAMNET)] )
    if keyword_set(antarctica) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !ANTARCTICA) : [inds, where(chains eq !ANTARCTICA)] )
    if keyword_set(gima) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !GIMA) : [inds, where(chains eq !GIMA)] )
    if keyword_set(japmag) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !JAPMAG) : [inds, where(chains eq !JAPMAG)] )
    if keyword_set(samba) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !SAMBA) : [inds,  where(chains eq !SAMBA)] )
    if keyword_set(intermagnet) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !INTERMAGNET) : [inds, where(chains eq !INTERMAGNET)] )
    if keyword_set(maccs) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !MACCS) : [inds, where(chains eq !MACCS)] )
    if keyword_set(nipr) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !NIPR ) : [inds,where(chains eq !NIPR)] ) 
    if keyword_set(gbm_themis) then $
    	inds = ( inds[0] eq -1 ? where(chains eq !GBM_THEMIS ) : [inds,where(chains eq !GBM_THEMIS)] ) 
    if keyword_set(all) then $
			inds = indgen(n_elements(chains))
    if inds[0] eq -1 then $
			return, -1.
;		help, inds
    stats = suppstats[inds]
    longitude = supplons[inds]
    latitude = supplats[inds]
;		stop
endif else begin
    nn = n_elements(stats)
		if nn lt 1 then begin
				prinfo, 'No station names given. Give station names or set GET keyword.'
				return, -1.
		endif
    longitude = replicate(-1., nn)
    latitude = replicate(-1., nn)
    for i=0, nn-1 do begin
        tmp = where(strupcase(stats[i]) eq strupcase(suppstats))
        if tmp[0] ne -1 then begin
        	longitude[i] = supplons[tmp[0]]
        	latitude[i] = supplats[tmp[0]]
        endif
    endfor
endelse

return, latitude

end 
