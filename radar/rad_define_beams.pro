;+ 
; NAME: 
; RAD_DEFINE_BEAMS
;
; PURPOSE: 
; This procedure calculates the position of beam/gate cells using the
; RBPOS function from the RST. It returns the values in FOV_LOC_FULL and 
; FOV_LOC_CENTER.
;
; INPUTS:
; Id: The numeric station id, usually found in rad_fit/raw_info.id.
;
; Nbeams: The number of beams to calculate, usually found in rad_fit/raw_info.nbeams
;
; Ngates: The number of gates to calculate, usually found in rad_fit/raw_info.ngates
;
; Bmsep: The separation between beams, usually found in rad_fit/raw_info.bmsep.
;
; Year: Set this to the year for which to calculate the cell position.
; Sometimes, radar parameters change, hence you need to specify which date
; you are interested in.
;
; Yrsec: The number of seconds since Jan 1st, 00:00:00 of the year you are
; interested in. Sometimes, radar parameters change, hence you need to 
; specify which date you are interested in. You can use TimeYMDHMStoYrsec of the RST
; to calculate this value.
;
; KEYWORD PARAMETERS:
; COORDS: Set this keyword to a valid coordinate system (see SET_COORDINATES).
; If none if provided, the currently loaded coordinate system is used.
;
; NORMAL: Set this keyword to force the folowing values: LAGRF = 1200. and SMSEP = 300.
;
; LAGRF0: Some value, if set, it overrides the /NORMAL keyword.
;
; SMSEP0: Some value, if set, it overrides the /NORMAL keyword.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; FOV_LOC_FULL: Set this keyword to a named variable which will contain the locations
; of the four corners of each radar cell.
;
; FOV_LOC_CENTER: Set this keyword to a named variable which will contain the locations
; of the center of each radar cell.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding the currently loaded radar data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Steve Milan's DEFINE_BEAMS.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_define_beams, id, nbeams, ngates, bmsep, year, yrsec, $
	coords=coords, height=height, $
	normal=normal, silent=silent, lagfr0=lagfr0, smsep0=smsep0, $
	fov_loc_full=fov_loc_full, fov_loc_center=fov_loc_center

common radarinfo
;common rad_data_blk

if n_params() lt 6 then begin
	prinfo, 'Must give radar id, nbeams and ngates, bmsep, year and yrsec.'
	return
endif

;prinfo, strjoin(string([id, nbeams, ngates, bmsep, year, yrsec]), ',')

if ~keyword_set(height) then $
	height = 300.

; if no external coordinate system was set
; use the one from the USER_PREFS common block
if ~keyword_set(coords) then $
	coord_system = get_coordinates() $
else $
	coord_system = coords

case coord_system of
	'rang': cflag=0
	'geog': cflag=1
	'magn': cflag=2
	'gate': cflag=3
	else : begin
		prinfo, 'Incorrect coordinate system type: '+coord_system
		return
	end
endcase

if id lt 1 then begin
	prinfo, 'Station ID is invalid: '+string(id)
	return
endif

if ~keyword_set(normal) and ~keyword_set(lagfr0) and ~keyword_set(smsep0) then begin
	prinfo, 'Setting NORMAL keyword.'
	normal = 1
endif

; set up some default values
IF KEYWORD_SET(normal) THEN BEGIN
	_lagfr0 = 1200.
	_smsep0 = 300.
ENDIF

; explicitly setting the keyword overrides /NORMAL
if keyword_set(lagfr0) then $
	_lagfr0 = lagfr0

if keyword_set(smsep0) then $
	_smsep0 = smsep0

fov_loc_center = make_array(2, nbeams+1, ngates+1)
fov_loc_full = make_array(2, 4, nbeams+1, ngates+1)
	
; Determine range
IF cflag EQ 0 THEN BEGIN
	height2 = 300.0^2
	rxrise  = 100.
	b = FINDGEN(nbeams+1)-0.5
	g = FINDGEN(ngates+1)-0.5
	FOR m=0,nbeams DO BEGIN
		FOR n=0,ngates DO BEGIN
			ang   = (b[m]-3.5)*bmsep*!dtor
			range = (_lagfr0 - rxrise + n*_smsep0)*0.150
			IF rad_get_scatterflag() EQ 1 THEN BEGIN
				IF range GT 600.0 THEN BEGIN
					hdistance = SQRT(range*range/4.0-height2)
					distance = !RE*ASIN(hdistance/!RE)
				ENDIF ELSE $
					distance=0.0
			ENDIF ELSE $
			distance=range
			fov_loc_center[0,m,n] = range;*SIN(ang)
			fov_loc_center[1,m,n] = range*COS(ang)
		ENDFOR
	ENDFOR
ENDIF

; Determine latitude and longitude positions	
IF cflag EQ 1 OR cflag EQ 2 THEN BEGIN
	; Use rbpos library - check that not SPEAR radar
	IF id NE 128 THEN BEGIN
		FOR m=0,nbeams DO BEGIN
			if arg_present(fov_loc_full) then begin
				pos = rbpos(indgen(ngates+1)+1, beam=m, lagfr=_lagfr0, smsep=_smsep0, $
					height=height, station=id, geo=(cflag EQ 1), year=year, yrsec=yrsec)
				fov_loc_full[*,0,m,*] = pos[0:1,0,0,*]
				fov_loc_full[*,1,m,*] = pos[0:1,1,0,*]
				fov_loc_full[*,2,m,*] = pos[0:1,1,1,*]
				fov_loc_full[*,3,m,*] = pos[0:1,0,1,*]
			endif
			if arg_present(fov_loc_center) then begin
				pos = rbpos(indgen(ngates+1)+1, beam=m, lagfr=_lagfr0, smsep=_smsep0, $
					height=height, station=id, geo=(cflag EQ 1), /center, year=year, yrsec=yrsec)
				fov_loc_center[0,m,*] = pos[0,*]
				fov_loc_center[1,m,*] = pos[1,*]
			endif
		ENDFOR
	ENDIF
ENDIF

; Determine gate numbers
IF cflag EQ 3 THEN BEGIN
	FOR m=0,nbeams DO $
		fov_loc_center[0,m,0:ngates] = FINDGEN(ngates+1)
ENDIF

end
