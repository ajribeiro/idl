;+
; NAME: 
; ASI_READ_STAT_POS
;
; PURPOSE: 
; This procedure reads the geodetic or geomagnetic coordinates of all supported ground-based
; All-sky imager stations from a file. Default is geodetic coordinates.
; 
; CATEGORY: 
; All-Sky Imager
; 
; CALLING SEQUENCE:  
; ASI_READ_STAT_POS 
;
; OPTIONAL OUTPUTS:
; Suppstats: Set this to a named variable which will contain the station abbreviations of 
; ground-based magnetometer stations.
;
; Supplats: Set this to a named variable which will contain the geodetic/geomagnetic latitudes of
; ground-based magnetometer stations. Depends on keyword CGM.
;
; Supplons: Set this to a named variable which will contain the geodetic/geomagnetic longitudes of
; ground-based magnetometer stations. Depends on keyword CGM.
;
; KEYWORD PARAMETERS:
; COORDS: Set this to a string specifying the coordinate system, either 'geog' or 'magn'. 
; Default is geodetic coordinates.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Dec, 4 2009
;-
pro asi_read_stat_pos, suppstats, supplats, supplons, chains=chains, coords=coords

if ~keyword_set(coords) then $
	coords = get_coordinates()
	
if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return
endif

if strcmp(strlowcase(coords), 'geog') then $
	ioff = 0 $
else if  strcmp(strlowcase(coords), 'magn') then $
;	ioff = 2 $
	ioff = 0 $
else begin
	prinfo, 'Coordinate system not supported: '+coords
	return
endelse

line = ''
count = 0
length = -1

filename = getenv("RAD_RESOURCE_PATH")+'/asi_stations.dat'
if ~file_test(filename) then begin
	prinfo, 'Cannot read station file: '+filename
	return
endif

; open file with station abbreviations, glat, glon, mlat and mlon
openr, ilun, filename, /get_lun
; read header
readf, ilun, line
; read number of stations in file
readf, ilun, length

suppstats = make_array(length, /string)
supplats = make_array(length, /float)
supplons = make_array(length, /float)
chains = make_array(length, /int)

while not(eof(ilun)) do begin
    readf, ilun, line
    if strpos(line, '$') ne -1 then begin
    	if strcmp(line, '$ASI_THEMIS') then achain=!ASI_THEMIS
    endif else begin
    	tmp = strsplit(line, ' ', /extract)
    	suppstats[count] = strupcase(strtrim(tmp[0]))
    	supplats[count] = float(tmp[1+ioff])
    	supplons[count] = float(tmp[2+ioff])
    	chains[count] = achain
    	count = count + 1
    endelse
endwhile
close, ilun
free_lun, ilun

if  strcmp(strlowcase(coords), 'magn') then begin
	for i=0, length-1 do begin
		tmp = cnvcoord(supplats[i], supplons[i], 1.)
		supplats[i] = tmp[0]
		supplons[i] = tmp[1]
	endfor
endif

end
