;+ 
; NAME: 
; CDF_EPOCH2JUL 
; 
; PURPOSE: 
; This functions converts CDFEpoch values to Julian days. 
; This is the inverse to JUL2CDF_EPOCH.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; Result = CDF_EPOCH2JUL(Cdf_epoch)
; 
; INPUTS: 
; Cdf_epoch: The CDFEpoch to be converted to Julian days. Either a scalar or
; an array.
; 
; OUTPUTS: 
; This function returns the Julian day of the input CDFEpoch.
; 
; EXAMPLE: 
; Use this function to convert CDFEpoch read from a CDF file to Julian days.
; help, data, /str
; ** Structure <2cca6a8>, 2 tags, length=207000, data length=207000, refs=1:
;    EPOCH__T1_PP_PEA
;                    DOUBLE    Array[1, 17250]
;    N_E_DEN__T1_PP_PEA
;                    FLOAT     Array[1, 17250]
; print, cdf_epoch2jul(data.epoch__t1_pp_PEA[0])
;        2454003.5
; jul = cdf_epoch2jul(data.epoch__t1_pp_PEA[0]) 
; caldat, jul, mm, dd, yy, hh, ii, ss
; print, mm, dd, yy, hh, ii, ss
;            9
;           25
;         2006
;            0
;            0
;        8.4840417
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2007
;-
function cdf_epoch2jul, cdf_epoch

nn = n_elements(cdf_epoch)
juls = make_array(nn, /double)

for i=0L, nn-1L do begin
    CDF_EPOCH, cdf_epoch[i], Year, Month, Day, Hour, Minute, Second, Milli, /BREAKDOWN_EPOCH
    juls[i] = julday(month, day, year, hour, minute, second+milli/1000.)
endfor

return, juls

end
