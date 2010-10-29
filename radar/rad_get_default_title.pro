;+ 
; NAME: 
; RAD_GET_DEFAULT_TITLE
; 
; PURPOSE: 
; This function returns a default title for some radar parameters. 
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; RAD_GET_DEFAULT_TITLE, Parameter
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
function rad_get_default_title, parameter

prinfo, 'Deprecated.'
return, 0

; check input
if n_params() ne 1 then begin
	prinfo, 'Must give Parameter.'
	return, ''
endif

if strcmp(strlowcase(parameter), 'power') then $
	return, 'Power [dB]' $
else if strcmp(strlowcase(parameter), 'velocity') then $
	return, textoidl('Velocity [m s^{-1}]') $
else if strcmp(strlowcase(parameter), 'width') then $
	return, textoidl('Spec. Width [m s^{-1}]') $
else if strcmp(strlowcase(parameter), 'gate') then $
	return, 'Gate' $
else if strcmp(strlowcase(parameter), 'rang') then $
	return, 'Range [km]' $
else if strcmp(strlowcase(parameter), 'geog') then $
	return, textoidl('geog. Latitude [\circ]') $
else if strcmp(strlowcase(parameter), 'magn') then $
	return, textoidl('magn. Latitude [\circ]') $
else $
	prinfo, 'Unknown radar parameter: '+parameter, /force

return, ''

end
