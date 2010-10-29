;+
; NAME: 
; RAD_GET_DEFAULT_RANGE
; 
; PURPOSE: 
; This function returns the default range for some radar parameters. 
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; Result = RAD_GET_DEFAULT_RANGE(Parameter)
;
; INPUTS:
; Parameter: A radar parameter.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
function rad_get_default_range, parameter

prinfo,'Deprecated'
return

common rad_data_blk

; check input
if n_params() ne 1 then begin
	prinfo, 'Must give Parameter.'
	return, ''
endif

if strcmp(strlowcase(parameter), 'power') then $
	return, [0,30] $
else if strcmp(strlowcase(parameter), 'velocity') then $
	return, [-500,500] $
else if strcmp(strlowcase(parameter), 'width') then $
	return, [-100,100] $
else if strcmp(strlowcase(parameter), 'gate') then $
	return, [0,rad_fit_info.ngates] $
else if strcmp(strlowcase(parameter), 'rang') then $
	return, [0,5000] $
else if strcmp(strlowcase(parameter), 'geog') then $
	return, [30,60] $
else if strcmp(strlowcase(parameter), 'magn') then $
	return, [30,60] $
else $
	prinfo, 'Unknown radar parameter: '+parameter, /force

return, ''

end
