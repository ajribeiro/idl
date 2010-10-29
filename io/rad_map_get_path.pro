;+ 
; NAME: 
; RAD_MAP_GET_PATH
;
; PURPOSE: 
; This function returns the global path to map potential data files, 
; depending on the year and the hemisphere.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = RAD_MAP_GET_PATH(Year, Hemisphere)
;
; INPUTS:
; Hemisphere: Set this to 1 for the northern and -1 for the southern hemisphere.
;
; Year: The year for which the path to the data will be returned.
;
; KEYWORD PARAMETERS:
; APLMAP: Set this keyword to return the path to standard APL map files.
;
; MAPEX: Set this keyword to return the path to mapex files.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
function rad_map_get_path, year, hemisphere, aplmap=aplmap, mapex=mapex

if n_params() ne 2 or ~keyword_set(hemisphere) or ~keyword_set(year) then begin
	prinfo, 'Must give year and hemisphere.'
	return, ''
endif

if hemisphere ge 0 then $
	str_hemi = 'north' $
else $
	str_hemi = 'south'

if ~keyword_set(aplmap) and ~keyword_set(mapex) then $
	mapex = 1

if keyword_set(aplmap) then $
	mapex = 0

path = GETENV('RAD_MAP_DATA_PATH')
if strlen(path) lt 1 then begin
	prinfo, 'Environment variable RAD_MAP_DATA_PATH must be set'
	return, ''
endif

pos = strpos(path, '%HEMISPHERE%')
path = strmid(path, 0, pos)+str_hemi+strmid(path, pos+12)

pos = strpos(path, '%MAP%')
path = strmid(path, 0, pos)+(mapex eq 1 ? 'mapex' : 'map')+strmid(path, pos+5)

pos = strpos(path, '%YEAR%')
path = strmid(path, 0, pos)+string(year,format='(I4)')+strmid(path, pos+6)

return, path

end
