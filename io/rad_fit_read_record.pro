;+ 
; NAME: 
; RAD_FIT_READ_RECORD
;
; PURPOSE: 
; This procedure reads one record of data from an opened fitacf file. It is essentially FitExternalRead.
; This is used to force external - i.e. fast - record reading instead of doing it in IDL.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RAD_FIT_READ_RECORD, Unit, Lib
;
; INPUTS:
; Unit: The file unit of the open fitacf file.
;
; Lib: The path to the C routine that does the reading (usually from the
; environment variable LIB_FITIDL).
;
; OPTIONAL OUTPUTS:
; Prm: A named variable that will become a structure holding information about the scan data.
;
; Fit: A named variable that will become a structure holding the scan data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on FitExternalRead.
; Written by Lasse Clausen, Nov, 24 2009
;-
function rad_fit_read_record, unit, lib, prm, fit, native=native

if keyword_set(native) then $
	s = fitnativeread(unit, prm, fit) $
else $
	  s = CALL_EXTERNAL(lib,'FitIDLRead', $
                  unit,prm,fit)
;	s = fitnativeread(unit, prm, fit)

  return, s
end