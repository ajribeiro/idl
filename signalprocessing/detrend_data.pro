;+ 
; NAME: 
; DETREND_DATA
; 
; PURPOSE: 
; This procedure subtracts a linear trend from a time series. If
; the time series contains NaNs, DETREND_DATA will not do anything.
; 
; CATEGORY: 
; Signalprocessing
; 
; CALLING SEQUENCE: 
; Result = DETREND_DATA( Yy )
;
; INPUTS:
; Yy: An 1-D array holding the data to be detrended. If no x values
; are given, these data are assumed to be spaced equally.
;
; OPTIONAL INPUTS:
; Xx: The x values for the Y values. Give these if the y values
; are not sample evenly.
;
; KEYWORD PARAMETERS:
; MEAN: Set this keyword to only subtract the mean value, not a linear trend.
;
; SILENT: Set this keyword to surpress warning messages.
;
; PARAMS: Set this to a named variable which will contain the 
; fitting parameters m and c as in y = mx + c upon completion.
; 
; EXAMPLE:
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
function detrend_data, yy, xx, mean=_mean, silent=silent, params=params

if keyword_set(_mean) then $
	return, (yy - mean(yy, /nan))

if total(finite(yy)) ne n_elements(yy) then begin
	if ~keyword_set(silent) then $
		prinfo, 'Time series contains NaN. Cannot detrend.'
	return, yy
endif

if n_params() eq 1 then $
	xx=findgen(n_elements(yy))

params = linfit(xx, yy, yfit=nyy, /double)
return, yy-nyy

end
