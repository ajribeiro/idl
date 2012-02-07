;+ 
; NAME: 
; CNVCOORD
;
; PURPOSE:
; This function converts geographic to AACGM geomagnetic coordinates, and vice-versa.  It is a wrapper to the RST AACGM IDL library.
; By default, the year 2000 IGRF coefficients are loaded.  Please see AACGM_LOAD_COEF to load other coefficients.  Also, please note that 
; the radius of the Earth Re = 6371.2 km in these routines.
;
; CATEGORY:
; Misc.
; 
; CALLING SEQUENCE:
; result = CNVCOORD(latitude, longitude, altitude, GEO=geo)
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; latitude: measured in degrees, positive is North.
;
; longitude: measured in degrees, positive is West.
;
; altitude: Height above Earth's surface, measured in kilometers.  You should set this to 100 km (height of the ionosphere) for most radar applications.
;
; KEYWORD PARAMETERS:
; GEO:  Set this keyword to convert geomagnetic coordinates into geographic coordinates.
;
; MODIFICATION HISTORY:
; Help section added by Nathaniel Frissell, July 18, 2011.
;-
function CNVCOORD, latitude, longitude, altitude, geo=geo

	ret_val = AACGMConvert(latitude, longitude, altitude, out_lat, out_lon, out_alt, geo=geo)
	if ret_val ne 0 then $
		return, [-1., -1., -1.]
	return, transpose([[out_lat], [out_lon], [out_alt]])

end

