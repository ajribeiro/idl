;+ 
; NAME: 
; RAD_GRD_GET_PATH
;
; PURPOSE: 
; This function returns the global path to grd data files, 
; depending on the year and the hemisphere.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = RAD_GRD_GET_PATH(Year, Hemisphere)
;
; INPUTS:
; Hemisphere: Set this to 1 for the northern and -1 for the southern hemisphere.
;
; Year: The year for which the path to the data will be returned.
;
; KEYWORD PARAMETERS:
; APLGRD: Set this keyword to return the path to standard APL grid files.
;
; GRDEX: Set this keyword to return the path to grdex files.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
function rad_grd_get_path, year, hemisphere, grdex=grdex, aplgrd=aplgrd, vtgrd=vtgrd

if n_params() ne 2 or ~keyword_set(hemisphere) or ~keyword_set(year) then begin
	prinfo, 'Must give year and hemisphere.'
	return, ''
endif

if hemisphere ge 0 then $
	str_hemi = 'north' $
else $
	str_hemi = 'south'

if ~keyword_set(aplgrd) and ~keyword_set(grdex) and ~keyword_set(vtgrd) then $
	grdex = 1

if keyword_set(grdex) then $
	str_grd = 'grdex' $
else if keyword_set(aplgrd) then $
	str_grd = 'grd' $
else if keyword_set(vtgrd) then $
	str_grd = 'vtgrd'

path = GETENV('RAD_GRD_DATA_PATH')
if strlen(path) lt 1 then begin
	prinfo, 'Environment variable RAD_GRD_DATA_PATH must be set'
	return, ''
endif

pos = strpos(path, '%HEMISPHERE%')
path = strmid(path, 0, pos) + str_hemi + strmid(path, pos+12)

pos = strpos(path, '%GRD%')
path = strmid(path, 0, pos) + str_grd + strmid(path, pos+5)

pos = strpos(path, '%YEAR%')
path = strmid(path, 0, pos) + string(year,format='(I4)') + strmid(path, pos+6)

return, path

end
