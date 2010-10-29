;+ 
; NAME: 
; FORMAT_DATE 
; 
; PURPOSE: 
; This function formats a numeric date as a string.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; Result = FORMAT_DATE(Date)
; 
; INPUTS: 
; Date: The date to be formated in YYYYMMDD format. Can be a scalar or a 
; 2-element vector representing a range of dates.
; 
; OUTPUTS: 
; This function returns a string version of the input date. If the input is 
; a 2-element vector, the dates in the output string are seperated by a dash
; '-'.
; 
; EXAMPLE: 
; date = 20060212
; help, date
;   DATE            LONG      =     20070312
; help, fdate(date)
;   <Expression>    STRING    = '20070312'
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
function format_date, date, human=human, dmsp=dmsp

month_names = ['Jan','Feb','Mar','Apr','May','Jun',$
	'Jul','Aug','Sep','Oct','Nov','Dec']

if n_params() eq 0 then begin
	prinfo, 'Must give Date.'
	return, -1
endif

if size(date, /type) eq 7 then begin
	return, date
endif

if n_elements(date) eq 1 then begin
	if keyword_set(human) then $
		return, string(date mod 100, format='(I02)')+'/'+month_names[(date mod 10000L)/100L-1]+'/'+string(date/10000L,format='(I4)')
	if keyword_set(dmsp) then $
		return, string(date/10000L,format='(I4)')+strlowcase(month_names[(date mod 10000L)/100L-1])+string(date mod 100, format='(I02)')
	return, string(date, format='(I8)')
endif else if n_elements(date) eq 2 then begin
	if keyword_set(human) then $
		return, $
			string(date[0] mod 100, format='(I02)')+'/'+month_names[(date[0] mod 10000L)/100L-1]+'/'+string(date[0]/10000L,format='(I4)') + '-' + $
			string(date[1] mod 100, format='(I02)')+'/'+month_names[(date[1] mod 10000L)/100L-1]+'/'+string(date[1]/10000L,format='(I4)')
	if keyword_set(dmsp) then $
		return, $
			string(date[0]/10000L,format='(I4)')+strlowcase(month_names[(date[0] mod 10000L)/100L-1])+string(date[0] mod 100, format='(I02)') + '-' + $
			string(date[1]/10000L,format='(I4)')+strlowcase(month_names[(date[1] mod 10000L)/100L-1])+string(date[1] mod 100, format='(I02)')
	return, string(date[0], format='(I8)')+'-'+string(date[1], format='(I8)')
endif else $
	return, ''
end
