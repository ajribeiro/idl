;+ 
; NAME: 
; GET_XTICKS 
; 
; PURPOSE: 
; This function returns an appropriate number of major ticks on the x axis
; depending on the time interval
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; Result = GET_XTICKS(Sjul, Fjul)
; 
; INPUTS:
; Sjul: If the JUL_TO_DATE keyword is set, this variable contains the 
; Julian day number which will be converted to a numeric date and time.
;
; Fjul: If the JUL_TO_DATE keyword is set, this variable contains the 
; Julian day number which will be converted to a numeric date and time.
; Date and Time will then contain ranges, i.e. be 2-element vectors.
; 
; OUTPUTS:
; This function returns an appropriate number of xticks.
; 
; KEYWORD PARAMETERS:
; XMINOR: Set this keyword to a named variable that will contain an
; appropriate number of minor xticks.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
function get_xticks, sjul, fjul, xminor=xminor

if n_params() eq 1 then begin
	if n_elements(sjul) ne 2 then begin
		prinfo, 'Either give SJUL and FJUL or SJUL must be a 2-element vector.'
		return, 0
	endif
	_sjul = sjul[0]
	_fjul = sjul[1]
endif else begin
	_sjul = sjul
	_fjul = fjul
endelse

; difference in minutes
diff = (_fjul-_sjul)*1440.d

if diff lt 0.d then begin
	prinfo, 'SJUL must be less than FJUL'
	return, 0
endif
;print, diff, 31.*1440.d

if diff le 10.d then begin
	xminor = 6
	return, round(diff)
endif else if diff le 30.d then begin
	xminor = 5
	return, round(diff)/5
endif else if diff le 60.d then begin
	xminor = 5
	return, round(diff)/10
endif else if diff le 3.*60.d then begin
	xminor = 3
	return, round(diff)/30
endif else if diff le 6.*60.d then begin
	xminor = 4
	return, round(diff)/60
endif else if diff le 16.*60.d then begin
	xminor =  4
	return, round(diff)/120
endif else if diff le 24.*60.d then begin
	xminor =  4
	return, round(diff)/240
endif else if diff le 7200.d then begin
	xminor =  6
	return, round(diff)/720
endif else if diff le 31.*1440.d then begin
	xminor =  12
	return, round(diff)/1440
endif else begin
	xminor =  1
	return, round(diff)/30.3/1440.
endelse

end
