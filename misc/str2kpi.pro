;+ 
; NAME: 
; STR2KPI 
; 
; PURPOSE: 
; This function converts string Kp index values like 3- or 2+ into numeric
; values. 3- corresponds to 3-1/3 = 2.66 and 2+ is 2+1/3 = 2.33
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; Result = STR2KPI(Kpi)
; 
; INPUTS: 
; Kpi: A scalar or array of type string.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Feb, 24 2010
;-
function str2kpi, kpis

_kpis = strtrim(kpis, 2)
ipart = strmid(_kpis, 0, 1)
spart = strmid(_kpis, 1, 1)

m = where(spart eq '-', cc)
if cc gt 0L then $
	spart[m] = '-.33'

n = where(spart eq 'o', cc)
if cc gt 0L then $
	spart[n] = '.0'

p = where(spart eq '+', cc)
if cc gt 0L then $
	spart[p] = '.33'

ret = float(ipart) + float(spart)

return, ret

end