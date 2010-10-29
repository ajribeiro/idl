;+ 
; NAME: 
; RAD_RAW_GET_PATH
;
; PURPOSE: 
; This function returns the global path to dat/rawacf data files, 
; depending on the year and the 3-letter radar code.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = RAD_RAW_GET_PATH(Year, Radar)
;
; INPUTS:
; Radar: The 3-letter radar code.
;
; Year: The year for which the path to the data will be returned.
;
; KEYWORD PARAMETERS:
; OLDDAT: Set this keyword to return the path to dat files.
;
; RAWACF: Set this keyword to return the path to rawacf files.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
function rad_raw_get_path, year, radar, olddat=olddat, rawacf=rawacf

common radarinfo

if n_params() ne 2 or ~keyword_set(radar) or ~keyword_set(year) then begin
	prinfo, 'Must give year and radar code.'
	return, ''
endif

if alog10(year) ge 4 then begin
	prinfo, 'Year must be of format YYYY.'
	return, ''
endif

if ~keyword_set(rawacf) and ~keyword_set(olddat) then $
	rawacf = 1

if keyword_set(rawacf) then $
	fitstr = 'rawacf'
if keyword_set(olddat) then $
	fitstr = 'dat'

path = GETENV('RAD_RAW_DATA_PATH')
if strlen(path) lt 1 then begin
	prinfo, 'Environment variable RAD_RAW_DATA_PATH must be set'
	return, ''
endif

pos = strpos(path, '%RCODE%')
path = strmid(path, 0, pos)+radar+strmid(path, pos+7)

pos = strpos(path, '%RAW%')
path = strmid(path, 0, pos)+fitstr+strmid(path, pos+5)

pos = strpos(path, '%YEAR%')
path = strmid(path, 0, pos)+string(year,format='(I4)')+strmid(path, pos+6)

return, path

end
