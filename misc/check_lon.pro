;+
; NAME: 
; CHECK_LON
;
; PURPOSE: 
; This function wraps all angles such that they fall within the given range.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE:
; Result = CHECK_LON(Lon, Minlon, Maxlon)
;
; INPUTS:
; Lon: An array holding the longitudes to check.
;
; Minlon: The lower boundary longitude.
;
; Maxlon: The upper boundary longitude.
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Dec, 11 2009
;-
function check_lon, lon, minlon, maxlon

nlon = lon

q = where(lon lt minlon, qc)
if (qc ne 0) then nlon[q] = nlon[q] + 360.

q = where(lon gt maxlon, qc)
if (qc ne 0) then nlon[q] = nlon[q] - 360.

if (min(lon) lt minlon or max(lon) gt maxlon) then begin
  print,' Invalid longitude = ',min(lon),max(lon)
  stop
endif

return, nlon

END
