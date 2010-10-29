;+
; NAME: 
; GET_DEFAULT_RANGE
; 
; PURPOSE: 
; This function returns the default range for some parameters, like the variables
; in RAD_FIT_DATA, OMN_DATA and DST_DATA. 
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; Result = GET_DEFAULT_RANGE(Parameter)
;
; INPUTS:
; Parameter: A parameter.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
function get_default_range, parameter

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
	return, [0,100] $
else if strcmp(strlowcase(parameter), 'tfreq') then $
	return, [8,18] $
else if strcmp(strlowcase(parameter), 'noise') then $
	return, [0,5] $
else if strcmp(strlowcase(parameter), 'npoints') then $
	return, [1e1,1e3] $
else if strcmp(strlowcase(parameter), 'potential') then $
	return, [0,1e2] $
else if strcmp(strlowcase(parameter), 'gate') then begin
	; get index for current data
	data_index = rad_fit_get_data_index()
	if data_index eq -1 then $
		return, [0,75]
	return, [0,(*rad_fit_info[data_index]).ngates]
endif else if strcmp(strlowcase(parameter), 'rang') then $
	return, [0,5000] $
else if strcmp(strlowcase(parameter), 'geog') then $
	return, [30,60] $
else if strcmp(strlowcase(parameter), 'magn') then $
	return, [30,60] $
else if strcmp(strlowcase(parameter), 'dst_index') then $
	return, [-100,20] $
else if strcmp(strlowcase(parameter), 'kp_index') then $
	return, [0,6] $
else if strcmp(strlowcase(parameter), 'aur_index') then $
	return, [-500,500] $
else if strcmp(strlowcase(parameter), 'bx_gse') then $
	return, [-10,10] $
else if strcmp(strlowcase(parameter), 'by_gse') then $
	return, [-10,10] $
else if strcmp(strlowcase(parameter), 'bz_gse') then $
	return, [-10,10] $
else if strcmp(strlowcase(parameter), 'by_gsm') then $
	return, [-10,10] $
else if strcmp(strlowcase(parameter), 'bz_gsm') then $
	return, [-10,10] $
else if strcmp(strlowcase(parameter), 'bt') then $
	return, [0,10] $
else if strcmp(strlowcase(parameter), 'ex_gse') then $
	return, [-5,5] $
else if strcmp(strlowcase(parameter), 'ey_gse') then $
	return, [-5,5] $
else if strcmp(strlowcase(parameter), 'ez_gse') then $
	return, [-5,5] $
else if strcmp(strlowcase(parameter), 'ey_gsm') then $
	return, [-5,5] $
else if strcmp(strlowcase(parameter), 'ez_gsm') then $
	return, [-5,5] $
else if strcmp(strlowcase(parameter), 'et') then $
	return, [0,10] $
else if strcmp(strlowcase(parameter), 'brad') then $
	return, [-60,60] $
else if strcmp(strlowcase(parameter), 'bazm') then $
	return, [-40,40] $
else if strcmp(strlowcase(parameter), 'bfie') then $
	return, [0,200] $
else if strcmp(strlowcase(parameter), 'vx_gse') then $
	return, [-800,300] $
else if strcmp(strlowcase(parameter), 'vy_gse') then $
	return, [-100,100] $
else if strcmp(strlowcase(parameter), 'vz_gse') then $
	return, [-100,100] $
else if strcmp(strlowcase(parameter), 'vt') then $
	return, [300,800] $
else if strcmp(strlowcase(parameter), 'np') then $
	return, [0,20] $
else if strcmp(strlowcase(parameter), 'pd') then $
	return, [0,20] $
else if strcmp(strlowcase(parameter), 'beta') then $
	return, [0,40] $
else if strcmp(strlowcase(parameter), 'tpr') then $
	return, [0,1e6] $
else if strcmp(strlowcase(parameter), 'ma') then $
	return, [0,50] $
else if strcmp(strlowcase(parameter), 'asi') then $
	return, [2e3,3e4] $
else if strcmp(strlowcase(parameter), 'cone_angle') then $
	return, [0,90] $
else if strcmp(strlowcase(parameter), 'clock_angle') then $
	return, [-180,180] $
else $
	prinfo, 'Unknown parameter: '+parameter, /force

return, [0,0]

end
