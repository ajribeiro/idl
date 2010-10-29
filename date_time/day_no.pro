;+ 
; NAME: 
; DAY_NO 
; 
; PURPOSE: 
; This function calculates the Day Of Year (doy) from a given date.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; Result = DAY_NO(Date)
; 
; INPUTS: 
; Date: If Date has less than 5 digits it is interpreted as a year. If it has 
; more than 5 digits, it is interpreted as a date in YYYYMMDD format. Can be an array.
; 
; OPTIONAL INPUTS: 
; Month: If Date is the year, set this to the month. Can be an array.
;
; Day: If Date is the year, set this to the day. Can be an array.
; 
; OUTPUTS: 
; This function returns the Doy Of Year (doy) of a given date.
;
; KEYWORD PARAMETERS:
; SILENT: Set this keyword to surpress warnings but not error messages.
; 
; EXAMPLE: 
; In leap years, March 1st is the 61st day of the year, in non-leap years it
; is the 60th day.
; 
; print, day_no(20040301)
;    61.0000
; print, day_no(20030301)
;    60.0000
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
; Modified by Lasse Clausen, Jan, 29 2010 to accept array input
;-
function day_no, date, month, day, silent=silent

if n_params() eq 0 then begin
	prinfo, 'Must give Date.'
	return, -1
endif

y_inds = where(alog10(date) lt 5., yn, complement=d_inds, ncomplement=dn)
if yn ne 0L and dn ne 0L then begin
	prinfo, 'You must not mix date formats.'
	return, -1
endif

_date = long(date)

if dn ne 0L then begin
	_year = _date/10000L
	_month = (_date - _year*10000L)/100L
	_day = (_date - _year*10000L - (_month)*100L)
endif

if yn ne 0L then begin
	if n_elements(month) ne yn then begin
		prinfo, 'Month must have same size as Year.'
		return, -1
	endif
	inds = where(month lt 1 or month gt 12, cc)
	if cc gt 0L then begin
		prinfo, 'MONTH out of bounds.'
		return, -1
	endif
	if n_elements(day) ne yn then begin
		prinfo, 'Day must have same size as Year.'
		return, -1
	endif
	inds = where(day lt 1 or day gt 31, cc)
	if cc gt 0L then begin
		prinfo, 'DAY out of bounds.'
		return, -1
	endif
	_year = date
	_month = month
	_day = day
endif

doys = fix(julday(_month, _day, _year, 0.) - julday(1, 1, _year, 0.))+1

return, doys

end
