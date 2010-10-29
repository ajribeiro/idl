;+ 
; NAME: 
; SET_PARAMETER
; 
; PURPOSE: 
; This procedure sets the currently active parameter. 
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; SET_PARAMETER, Parameter
;
; INPUTS:
; Parameter: A parameter.
;
; COMMON BLOCKS:
; USER_PREFS: The common block holding user preferences.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro set_parameter, parameter

common user_prefs

; check input
if n_params() ne 1 then begin
	prinfo, 'Must give Parameter'
	return
endif

if size(parameter, /type) ne 7 then begin
	prinfo, 'Parameter must of type string.'
	return
endif

if is_valid_parameter(parameter) then begin
	up_parameter = strtrim(strlowcase(parameter),2)
	set_scale, get_default_range(parameter)
endif else $
	prinfo, 'Unknown parameter: '+parameter, /force

end
