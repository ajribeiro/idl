;+
; NAME: 
; GBM_READ_POS
;
; PURPOSE: 
; This procedure reads the geodetic or geomagnetic coordinates of all supported ground-based
; magnetometer stations from a file. Default is geodetic coordinates.
; 
; CATEGORY: 
; Ground-Based Magnetometers
; 
; CALLING SEQUENCE:  
; GBM_READ_POS 
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
; CHAINS: Set this keyword to named variable which will contain a number specifying the cahin to which the
; station belongs. Use the system variables !CARISMA, !IMAGE, !SAMNET, !GREENLAND, !ANTARCTICA, !GIMA, !JAPMAG,
; !SAMBA, !INTERMAGNET, !MACCS and !NIPR to find the right stations.
;
; COORDS: Set this to a string specifying the coordinate system, either 'geog' or 'magn'. 
; Default is geodetic coordinates.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Dec, 4 2009
;-
pro gbm_read_pos, suppstats, supplats, supplons, chains=chains, coords=coords, $
	date=date, time=time, long=long, jul=jul

if ~keyword_set(coords) then $
	coords = get_coordinates()
	
if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return
endif

if  strcmp(strlowcase(coords), 'mlt') then begin
	if ~keyword_set(date) and ~keyword_set(jul) then begin
		prinfo, 'Must give date or jul when using MLT.'
		return
	endif
	if ~keyword_set(time) then $
		time=1200
	if ~keyword_set(jul) then $
		sfjul, date, time, jul, long=long
endif

if strcmp(strlowcase(coords), 'geog') then $
	ioff = 0 $
else if  strcmp(strlowcase(coords), 'magn') then $
;	ioff = 2 $
	ioff = 0 $
else if  strcmp(strlowcase(coords), 'mlt') then $
;	ioff = 2 $
	ioff = 0 $
else begin
	prinfo, 'Coordinate system not supported: '+coords
	return
endelse

line = ''
count = 0
length = -1

filename = getenv("RAD_RESOURCE_PATH")+'/gbm_stations.dat'
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
    	if strcmp(line, '$CARISMA') then achain=!CARISMA else $
    	if strcmp(line, '$IMAGE') then achain=!IMAGE else $
    	if strcmp(line, '$GREENLAND') then achain=!GREENLAND else $
    	if strcmp(line, '$SAMNET') then achain=!SAMNET else $
    	if strcmp(line, '$ANTARCTICA') then achain=!ANTARCTICA else $
    	if strcmp(line, '$GIMA') then achain=!GIMA else $
    	if strcmp(line, '$JAPMAG') then achain=!JAPMAG else $
    	if strcmp(line, '$SAMBA') then achain=!SAMBA else $
    	if strcmp(line, '$INTERMAGNET') then achain=!INTERMAGNET else $
    	if strcmp(line, '$MACCS') then achain=!MACCS else $
    	if strcmp(line, '$NIPR') then achain=!NIPR else $
    	if strcmp(line, '$GBM_THEMIS') then achain=!GBM_THEMIS
    endif else begin
    	tmp = strsplit(line, ' ', /extract)
    	suppstats[count] = strupcase(strtrim(tmp[0]))
    	supplats[count] = float(tmp[1+ioff])
    	supplons[count] = float(tmp[2+ioff])
    	chains[count] = achain
    	count = count + 1
    endelse
;		print, count
endwhile
close, ilun
free_lun, ilun

if  strcmp(strlowcase(coords), 'magn') then begin
	for i=0, length-1 do begin
;		print, suppstats[i], supplats[i], supplons[i]
		tmp = cnvcoord(supplats[i], supplons[i], 1.)
		supplats[i] = tmp[0]
		supplons[i] = tmp[1]
	endfor
endif

if  strcmp(strlowcase(coords), 'mlt') then begin
	caldat, jul, mm, dd, yy
	for i=0, length-1 do begin
		tmp = cnvcoord(supplats[i], supplons[i], 1.)
		tmp[1] = mlt(yy, (jul-julday(1,1,yy,0))*86400.d, tmp[1])
		supplats[i] = tmp[0]
		supplons[i] = tmp[1]
	endfor
endif

end
