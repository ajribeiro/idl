;+ 
; NAME: 
; PARSE_TIME 
; 
; PURPOSE: 
; This procedure extracts hours, minutes and seconds from a numeric time in 
; HHII or HHIISS format.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; PARSE_TIME, Time
; 
; INPUTS: 
; Time: The time in HHII or HHIISS format of which the hour, minute and second 
; will be extracted. This can be a scalar
; or a 2-element vector.
; 
; OPTIONAL OUTPUTS:
; Shour: The hour of the input. If Time is a 2-element vector, this will be the
; hour of the first element.
;
; Sminute: The minute of the input. If Time is a 2-element vector, this will be the
; minute of the first element.
;
; Fhour: Only if Time is a 2-element vector, this will be the
; hour of the second element.
;
; Fminute: Only if Time is a 2-element vector, this will be the
; minute of the second element.
;
; Ssecond: The second of the input. If Time is a 2-element vector, this will be the
; second of the first element.
;
; Fsecond: Only if Time is a 2-element vector, this will be the
; second of the second element.
;
; KEYWORD PARAMETERS:
; LONG: Set this keyword to indicate that the input is in HHIISS format. Default is
; HHII format.
; 
; EXAMPLE:
; It is useful when you want to extract the specifics
; of a time range like [134500,214312]
; time = [134500,214312]
; parse_time, time, shour, sminute, fhour, fminute
; print, fhour
;    21
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro parse_time, time, shour, sminute, fhour, fminute, ssecond, fsecond, $
	long=long

shour   = -1
sminute = -1
ssecond = -1
fhour   = -1
fminute = -1
fsecond = -1

if n_params() lt 1 then begin
	prinfo, 'Must give Time.'
	return
endif

nn = n_elements(time)
if keyword_set(long) then $
	fac = 10000L $
else $
	fac = 100L

if size(time, /type) eq 7 then begin
	if nn eq 2 then begin
		nlen = strlen(time[0])
		if nlen eq 5 then begin
			shour = fix(strmid(time[0], 0, 2))
			sminute = fix(strmid(time[0], 3, 2))
		endif else if nlen eq 8 or nlen eq 10 then begin
			shour = fix(strmid(time[0], 0, 2))
			sminute = fix(strmid(time[0], 3, 2))
			ssecond = fix(strmid(time[0], 6, 2))
		endif else begin
			prinfo, 'No known format :'+time[0]
		endelse
		nlen = strlen(time[1])
		if nlen eq 5 then begin
			fhour = fix(strmid(time[1], 0, 2))
			fminute = fix(strmid(time[1], 3, 2))
		endif else if nlen eq 8 or nlen eq 10 then begin
			fhour = fix(strmid(time[1], 0, 2))
			fminute = fix(strmid(time[1], 3, 2))
			fsecond = fix(strmid(time[1], 6, 2))
		endif else begin
			prinfo, 'No known format :'+time
		endelse
	endif else if nn eq 1 then begin
		nlen = strlen(time)
		if nlen eq 5 then begin
			shour = fix(strmid(time, 0, 2))
			sminute = fix(strmid(time, 3, 2))
		endif else if nlen eq 8 or nlen eq 10 then begin
			shour = fix(strmid(time, 0, 2))
			sminute = fix(strmid(time, 3, 2))
			ssecond = fix(strmid(time, 6, 2))
		endif else begin
			prinfo, 'No known format :'+time
		endelse
	endif else begin
		prinfo, 'Input time must be scalar or 2-element vector.'
	endelse
	return
endif

if nn eq 2 then begin
	shour   = fix(time[0]/fac)
	sminute = fix(time[0] mod fac)/(fac/100L)
	ssecond = fix(time[0] mod (fac/100L))
	fhour   = fix(time[1]/fac)
	fminute = fix(time[1] mod fac)/(fac/100L)
	fsecond = fix(time[1] mod (fac/100L))
endif else if nn eq 1 then begin
	shour   = fix(time/fac)
	sminute = fix(time mod fac)/(fac/100L)
	ssecond = fix(time[0] mod (fac/100L))
endif else begin
	prinfo, 'Input time must be scalar or 2-element vector.'
endelse

end
