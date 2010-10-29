;+ 
; NAME: 
; ACE_SWE_GET_PATH
;
; PURPOSE: 
; This function returns the global path to ACE SWE data files, 
; depending on the year.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = ACE_SWE_GET_PATH(Year)
;
; INPUTS:
; Year: The year for which the path to the data will be returned.
;
; KEYWORD PARAMETERS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
function ace_swe_get_path, year

if n_params() lt 1 or ~keyword_set(year) then begin
	prinfo, 'Must give year.'
	return, ''
endif

if alog10(year) ge 4 then begin
	prinfo, 'Year must be of format YYYY.'
	return, ''
endif

path = GETENV('ACE_SWE_DATA_PATH')
if strlen(path) lt 1 then begin
	prinfo, 'Environment variable ACE_SWE_DATA_PATH must be set'
	return, ''
endif

pos = strpos(path, '%YEAR%')
path = strmid(path, 0, pos)+string(year,format='(I4)')+strmid(path, pos+6)

return, path

end
