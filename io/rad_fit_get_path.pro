;+ 
; NAME: 
; RAD_FIT_GET_PATH
;
; PURPOSE: 
; This function returns the global path to fit/fitacf/fitex data files, 
; depending on the year and the 3-letter radar code.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = RAD_FIT_GET_PATH(Year, Radar)
;
; INPUTS:
; Radar: The 3-letter radar code.
;
; Year: The year for which the path to the data will be returned.
;
; KEYWORD PARAMETERS:
; FITACF: Set this keyword to return the path to fitacf files.
;
; FITEX: Set this keyword to return the path to fitex files.
;
; OLDFIT: Set this keyword o return the path to "old" fit files.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
function rad_fit_get_path, year, radar, fitacf=fitacf, fitex=fitex, oldfit=oldfit

common radarinfo

if n_params() ne 2 or ~keyword_set(radar) or ~keyword_set(year) then begin
	prinfo, 'Must give year and radar code.'
	return, ''
endif

if alog10(year) ge 4 then begin
	prinfo, 'Year must be of format YYYY.'
	return, ''
endif

if ~keyword_set(fitacf) and ~keyword_set(fitex) and ~keyword_set(oldfit) then $
	fitex = 1

if keyword_set(fitacf) then $
	fitstr = 'fitacf'
if keyword_set(fitex) then $
	fitstr = 'fitex'
if keyword_set(oldfit) then $
	fitstr = 'fit'

path = GETENV('RAD_FIT_DATA_PATH')
if strlen(path) lt 1 then begin
	prinfo, 'Environment variable RAD_FIT_DATA_PATH must be set'
	return, ''
endif

pos = strpos(path, '%RCODE%')
path = strmid(path, 0, pos)+radar+strmid(path, pos+7)

pos = strpos(path, '%FIT%')
path = strmid(path, 0, pos)+fitstr+strmid(path, pos+5)

pos = strpos(path, '%YEAR%')
path = strmid(path, 0, pos)+string(year,format='(I4)')+strmid(path, pos+6)

return, path

end
