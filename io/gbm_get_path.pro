;+ 
; NAME: 
; GBM_GET_PATH
;
; PURPOSE: 
; This function returns the global path to gbm data files, 
; depending on the year and the 4-letter station code.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = GBM_GET_PATH(Year, Station)
;
; INPUTS:
; Station: The 4-letter station code.
;
; Year: The year for which the path to the data will be returned.
;
; KEYWORD PARAMETERS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
function gbm_get_path, year, station

if n_params() lt 2 or ~keyword_set(station) or ~keyword_set(year) then begin
	prinfo, 'Must give year and station code.'
	return, ''
endif

if alog10(year) ge 4 then begin
	prinfo, 'Year must be of format YYYY.'
	return, ''
endif

; check if station belongs to greenland chain
; they live in a different directory
grnld_stats = ['amk','atu','dmh','gdh','naq','nrd','sco','skt','stf','svs','thl','upn']
tmp = where(grnld_stats eq station, cc)
if cc eq 0 then begin
	path = GETENV('GBM_DATA_PATH')
	if strlen(path) lt 1 then begin
		prinfo, 'Environment variable GBM_DATA_PATH must be set'
		return, ''
	endif
endif else begin
	path = GETENV('GBM_GREENLAND_DATA_PATH')
	if strlen(path) lt 1 then begin
		prinfo, 'Environment variable GBM_GREENLAND_DATA_PATH must be set'
		return, ''
	endif
endelse

pos = strpos(path, '%STATION%')
path = strmid(path, 0, pos)+station+strmid(path, pos+9)

pos = strpos(path, '%YEAR%')
path = strmid(path, 0, pos)+string(year,format='(I4)')+strmid(path, pos+6)

return, path

end
