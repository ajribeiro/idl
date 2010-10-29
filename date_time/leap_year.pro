;+ 
; NAME: 
; LEAP_YEAR 
; 
; PURPOSE: 
; This function determines whether a given year is a leap year.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; Result = LEAP_YEAR(Year)
; 
; INPUTS: 
; Year: The year. Can be a scalar or array.
; 
; OUTPUTS: 
; This function returns 1 (true) if the given year is a leap year, 0 (false)
; if it is not a leap year.
; 
; EXAMPLE: 
; print, leap_year(2004)
;    1
; print, leap_year(1900)
;    0
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
; Modified by Lasse Clausen, Jan, 27 2010: Made it cope with array input
;-
function leap_year, year

nn = n_elements(year)

leap = replicate(!false, nn)

lind = where((year mod 400) eq 0 or ( (year mod 4) eq 0 and (year mod 100) ne 0 ), cc)
if cc gt 0 then $
	leap[lind] = !true

return, reform(leap)

end
