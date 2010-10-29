;+ 
; NAME: 
; FORMAT_JULDATE 
; 
; PURPOSE: 
; This function formats a julian day as a human readable string.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; Result = FORMAT_JULDATE(Juldate)
; 
; INPUTS: 
; Juldate: The Julian days to be converted into strings. Can be a scalar
; or an array.
;
; KEYWORD PARAMETERS:
; TIME: Set this keyword to format the string as HH:II:SS.
;
; SHORT_TIME: Set this keyword to format the string as HH:II.
; 
; EVEN_SHORTER_TIME: Set this keyword to format the string as HHII.
; 
; DATE: Set this keyword to format the string as DD/MM/YYYY.
; 
; REDOX: Set this keyword to format the string as YYYYMMDD HHII.
;
; SHORT_DATE: Set this keyword to format the string as YYYYMMDD.
; 
; OUTPUTS: 
; This function returns a human redable string version of the input Julian day. 
; The format is chosen according to the keywords, default is 
; DD/MM/YYYY HH:II:SS.SSS
; 
; EXAMPLE: 
; jul = julday(12,24,1965,23,5,34)
; print, format_juldate(jul)
;   24/Dec/1965 23:05:34.000
; print, format_juldate(jul, /redox)
;   19651224 2305
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2007.
;-
function format_juldate, juldate, time=time, date=date, short_time=short_time,$
    even_shorter_time=even_shorter_time, short_date=short_date, redox=redox

nn = n_elements(juldate)
month_names = ['Jan','Feb','Mar','Apr','May','Jun',$
	'Jul','Aug','Sep','Oct','Nov','Dec']

if keyword_set(even_shorter_time) then begin
    caldat, juldate, month, day, year, hour, minute, second
    arr = transpose(reform([hour, minute], nn, 2))
    form_dates = string(arr, $
    	format='(I02,I02)')
endif else if keyword_set(short_time) then begin
    caldat, juldate, month, day, year, hour, minute, second
    arr = transpose(reform([hour, minute], nn, 2))
    form_dates = string(arr, $
    	format='(I02,":",I02)')
endif else if keyword_set(time) then begin
    caldat, juldate, month, day, year, hour, minute, second
    arr = transpose(reform([hour, minute, second], nn, 3))
    form_dates = string(arr, $
    	format='(I02,":",I02,":",I02)')
endif else if keyword_set(date) then begin
	caldat, juldate, month, day, year, hour, minute, second
	days = string(day, format='(I02)')
	months = month_names[month-1]
	years = string(year, format='(I04)')
	arr = transpose(reform([days, months, years], nn, 3))
	form_dates = string(arr, $
		format='(A2,"/",A3,"/",A4)')
endif else if keyword_set(short_date) then begin
	caldat, juldate, month, day, year, hour, minute, second
	days = string(day, format='(I02)')
	months = string(month, format='(I02)')
	years = string(year, format='(I04)')
	arr = transpose(reform([years, months, days], nn, 3))
	form_dates = string(arr, $
		format='(A4,A2,A2)')
endif else if keyword_set(redox) then begin
	caldat, juldate, month, day, year, hour, minute
	days = string(day, format='(I02)')
	months = string(month, format='(I02)')
	years = string(year, format='(I04)')
	hours = string(hour, format='(I02)')
	minutes = string(minute, format='(I02)')
	arr = transpose(reform([years, months, days, hours, minutes], nn, 5))
	form_dates = string(arr, $
		format='(A4,A2,A2," ",A2,A2)')
endif else begin
	caldat, juldate, month, day, year, hour, minute, second
	days = string(day, format='(I02)')
	months = month_names[month-1]
	years = string(year, format='(I04)')
	hours = string(hour, format='(I02)')
	minutes = string(minute, format='(I02)')
	seconds = string(second, format='(F04.1)')
	arr = transpose(reform([days, months, years, hours, minutes, seconds], nn, 6))
	form_dates = string(arr, $
		format='(A2,"/",A3,"/",A4," ",A2,":",A2,":",A4)')
endelse
return, form_dates

end
