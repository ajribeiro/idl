;+ 
; NAME: 
; CALC_STEREO_COORDS 
; 
; PURPOSE: 
; This function converts from geographic/geomagnetic coordinates 
; (lat and lon in degrees)
; to cartesian coords with the origin at the north geographic pole
; and +ve x pointing toward 90degE and +ve y pointing toward 
; 180degE. Intended for use when converting from geograghic coords
; to the plotting coordinate frame in a polar plot.
; 
; CATEGORY: 
; Map/Coordinates
; 
; CALLING SEQUENCE: 
; Result = CALC_STEREO_COORDS(Lat,Lon)
; 
; INPUTS: 
; Lat: The latitude of the point to convert.
;
; Lon: The longitude of the point to convert.
;
; KEYWORD PARAMETERS: 
; MLT: Set this keyword to indicate that the value for Lon is in Magnetic 
; Local Time (MLT). Default is for the longitude to be in degrees.
; 
; OUTPUTS: 
; This function returns a 2-element array containing plot position in cartesian
; x and y coords.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by: Jim Wild, 25/10/00.
; Added vector support, Hohoho, Lasse Clausen, 12/21/2009
;-
FUNCTION CALC_STEREO_COORDS, lat, lon, mlt=mlt

nn = n_elements(lat)
hemisphere = replicate(1., nn)
inds = where(lat LT 0.0, cc)
if ~keyword_set(mlt) and cc gt 0L then $
	hemisphere[inds] = -1.

;IF (lat LT 0.0) AND NOT KEYWORD_SET(mlt) then $
;	hemisphere=-1. $
;ELSE $
;	hemisphere=1.

IF KEYWORD_SET(mlt) THEN $
	_lon = lon*15.0 $
else $
	_lon = lon

x =  (90.-ABS(lat))*SIN(_lon*!pi/180.)
y = -(90.-ABS(lat))*COS(_lon*!pi/180.)*hemisphere

RETURN, reform(transpose([[x],[y]]))

END
