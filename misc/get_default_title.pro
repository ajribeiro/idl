;+ 
; NAME: 
; GET_DEFAULT_TITLE
; 
; PURPOSE: 
; This function returns a default title for some parameters. 
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; GET_DEFAULT_TITLE, Parameter
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
function get_default_title, parameter

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
else if strcmp(strlowcase(parameter), 'bx_gse') then $
	return, textoidl('Bx GSE [nT]') $
else if strcmp(strlowcase(parameter), 'by_gse') then $
	return, textoidl('By GSE [nT]') $
else if strcmp(strlowcase(parameter), 'bz_gse') then $
	return, textoidl('Bz GSE [nT]') $
else if strcmp(strlowcase(parameter), 'by_gsm') then $
	return, textoidl('By GSM [nT]') $
else if strcmp(strlowcase(parameter), 'bz_gsm') then $
	return, textoidl('Bz GSM [nT]') $
else if strcmp(strlowcase(parameter), 'bt') then $
	return, textoidl('Bt [nT]') $
else if strcmp(strlowcase(parameter), 'brad') then $
	return, textoidl('Br [nT]') $
else if strcmp(strlowcase(parameter), 'bazm') then $
	return, textoidl('Ba [nT]') $
else if strcmp(strlowcase(parameter), 'bfie') then $
	return, textoidl('Bf [nT]') $
else if strcmp(strlowcase(parameter), 'vx_gse') then $
	return, textoidl('Vx GSE [km s^{-1}]') $
else if strcmp(strlowcase(parameter), 'vy_gse') then $
	return, textoidl('Vy GSE [km s^{-1}]') $
else if strcmp(strlowcase(parameter), 'vz_gse') then $
	return, textoidl('Vz GSE [km s^{-1}]') $
else if strcmp(strlowcase(parameter), 'vt') then $
	return, textoidl('Vt [km s^{-1}]') $
else if strcmp(strlowcase(parameter), 'ex_gse') then $
	return, textoidl('Ex GSE [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'ey_gse') then $
	return, textoidl('Ey GSE [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'ez_gse') then $
	return, textoidl('Ez GSE [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'ey_gsm') then $
	return, textoidl('Ey GSM [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'ez_gsm') then $
	return, textoidl('Ez GSM [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'et') then $
	return, textoidl('Et [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'np') then $
	return, textoidl('n [cm^{-3}]') $
else if strcmp(strlowcase(parameter), 'pd') then $
	return, textoidl('pdyn [nPa]') $
else if strcmp(strlowcase(parameter), 'beta') then $
	return, textoidl('\beta') $
else if strcmp(strlowcase(parameter), 'tpr') then $
	return, textoidl('radial T [K]') $
else if strcmp(strlowcase(parameter), 'ma') then $
	return, textoidl('M_{A}') $
else if strcmp(strlowcase(parameter), 'asi') then $
	return, textoidl('Brightness') $
else if strcmp(strlowcase(parameter), 'bx_mag') then $
	return, textoidl('Bx MAG [10^3 nT]') $
else if strcmp(strlowcase(parameter), 'by_mag') then $
	return, textoidl('By MAG [nT]') $
else if strcmp(strlowcase(parameter), 'bz_mag') then $
	return, textoidl('Bz MAG [10^3 nT]') $
else if strcmp(strlowcase(parameter), 'bt_mag') then $
	return, textoidl('Bt [10^3 nT]') $
else if strcmp(strlowcase(parameter), 'cone_angle') then $
	return, textoidl('\theta_{xB} [\circ]') $
else if strcmp(strlowcase(parameter), 'clock_angle') then $
	return, textoidl('\phi [\circ]') $
else $
	prinfo, 'Unknown parameter: '+parameter, /force

return, ''

end
