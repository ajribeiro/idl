;+ 
; NAME: 
; AUR_GET_PATH
;
; PURPOSE: 
; This function returns the global path to AU/AL/AE/AO/ASY_H/ASY_D/SYM_D/SYM_H index data files, 
; depending on the year.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = AUR_GET_PATH(Year)
;
; INPUTS:
; Year: The year for which the path to the data will be returned.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
function aur_get_path, year

if n_params() ne 1 or ~keyword_set(year) then begin
	prinfo, 'Must give year.'
	return, ''
endif

path = GETENV('AUR_DATA_PATH')

pos = strpos(path, '%YEAR%')
path = strmid(path, 0, pos)+string(year,format='(I4)')+strmid(path, pos+6)

return, path

end
