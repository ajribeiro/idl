;+ 
; NAME: 
; DAYS_IN_MONTH 
; 
; PURPOSE: 
; This function returns the number of days in a given month.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; Result = DAYS_IN_MONTH( Month )
; 
; INPUTS: 
; Month: The month of which to return the number of days. Can be a scalar or vector, in numeric
; MM or string MMM format.
; 
; KEYWORD PARAMETERS: 
; YEAR: The year in numeric or string YYYY format.
; 
; EXAMPLE:
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
function days_in_month, month, year=year

if n_params() lt 1 then begin
	prinfo, 'Must give Month.'
	return, 0
endif

dim = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

str_month = ['jan','feb','mar','apr','may','jun',$
	'jul','aug','sep','oct','nov','dec']

nm = n_elements(month)
if size(month, /type) eq 7 then begin
	_month = intarr(nm)
	for i=0, nm-1 do $
		_month[i] = where(strcmp(str_month, month[i], /fold))+1 
endif else $
	_month = month

if keyword_set(year) then begin
	ny = n_elements(year)
	_year = year
endif else begin
	_year = 1993
	ny = 1
endelse

if nm gt ny then $
	_year = replicate(_year[0], nm) $
else if ny gt nm then $
	_month = replicate(_month[0], ny)

ret = dim[_month-1]
find = where(_month eq 2, cc)
if cc gt 0 then $
	ret[find] += leap_year(_year[find])

return, reform(ret)

end
