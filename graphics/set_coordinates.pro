;+ 
; NAME: 
; SET_COORDINATES
; 
; PURPOSE: 
; This function sets the currently active coordinate system. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_COORDINATES, Coordinates
;
; INPUTS:
; Coordinates: A value to use as the currently active coordinate system.
;
; COMMON BLOCKS:
; USER_PREFS: The common block holding user preferences.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro set_coordinates, coordinates

common user_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Coordinates.'
	return
endif

if size(coordinates, /type) ne 7 then begin
	prinfo, 'Coordinates must of type string.'
	return
endif

if strcmp(coordinates, 'rang') then $
	up_coordinates = coordinates $
else if strcmp(coordinates, 'gate') then $
	up_coordinates = coordinates $
else if strcmp(coordinates, 'magn') then $
	up_coordinates = coordinates $
else if strcmp(coordinates, 'geog') then $
	up_coordinates = coordinates $
else if strcmp(coordinates, 'mlt') then $
	up_coordinates = coordinates $
else $
	prinfo, 'Unknown coordinate system: '+coordinates, /force

end
