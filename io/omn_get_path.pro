;+ 
; NAME: 
; OMN_GET_PATH
;
; PURPOSE: 
; This function returns the global path to OMNI data files, 
; depending on the year.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = OMN_GET_PATH(Year)
;
; INPUTS:
; Year: The year for which the path to the data will be returned.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
function omn_get_path, year

if n_params() ne 1 or ~keyword_set(year) then begin
	prinfo, 'Must give year.'
	return, ''
endif

path = GETENV('OMN_DATA_PATH')
if strlen(path) lt 1 then begin
	prinfo, 'Environment variable OMN_DATA_PATH must be set'
	return, ''
endif

pos = strpos(path, '%YEAR%')
path = strmid(path, 0, pos)+string(year,format='(I4)')+strmid(path, pos+6)

return, path

end
