;+ 
; NAME: 
; FORMAT_TIME 
; 
; PURPOSE: 
; This function formats a numeric time as a string.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; Result = FORMAT_TIME(Time)
; 
; INPUTS: 
; Time: A scalar or 2-element vector holding the time (range) in HHII format.
;
; KEYWORD PARAMETERS:
; LONG: Set this keyword to indicate that the input time (range) is given in 
; HHIISS format.
; 
; OUTPUTS: 
; This function returns a string version of the input time. If the input is 
; a 2-element vector, the times in the output string are seperated by a dash
; '-'.
; 
; EXAMPLE: 
; time = [2300,0400]
; print, ftime(time)
;   2300-0400
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
function format_time, time, long=long

if n_params() eq 0 then begin
	prinfo, 'Must give Time.'
	return, -1
endif

len = (keyword_set(long) ? '6' : '4')

if n_elements(time) eq 2 then $
	return, string(time[0], format='(I0'+len+')')+'-'+$
		string(time[1], format='(I0'+len+')')

if n_elements(time) eq 1 then $
	return, string(time[0], format='(I0'+len+')')

prinfo, 'Input array must be scalar or 2-element vector.'
return, ''
end
