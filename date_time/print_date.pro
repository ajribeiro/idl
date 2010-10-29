;+ 
; NAME: 
; PRINT_DATE 
; 
; PURPOSE: 
; This function prints a human readable version of a julian day. The standard
; format is DD/MM/YYYY HH:II:SS.SSS.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; PRINT_DATE, Juldate
; 
; INPUTS: 
; Juldate: The Julian days to be printed. Can be a scalar
; or an array.
; 
; EXAMPLE: 
; jul = julday(12,24,1965,23,5,34)
; print_date(jul)
;   24/12/1965 23:05:34.000
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2007.
;-
pro print_date, juldate

for i=0L, n_elements(juldate)-1L do begin
    caldat, juldate[i], month, day, year, hour, minute, second

    print, day, month, year, hour, minute, second, $
    	format='(I02,"/",I02,"/",I04," ",I02,":",I02,":",F06.3)'
endfor

end
