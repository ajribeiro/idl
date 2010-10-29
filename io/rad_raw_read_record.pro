;+ 
; NAME: 
; RAD_RAW_READ_RECORD
;
; PURPOSE: 
; This procedure reads one record of data from an opened rawacf file. It is essentially RawExternalRead.
; This is used to force external - i.e. fast - record reading instead of doing it in IDL.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RAD_RAW_READ_RECORD, Unit, Lib
;
; INPUTS:
; Unit: The file unit of the open rawacf file.
;
; Lib: The path to the C routine that does the reading (usually from the
; environment variable LIB_RAWIDL).
;
; OPTIONAL OUTPUTS:
; Prm: A named variable that will become a structure holding information about the scan data.
;
; Fit: A named variable that will become a structure holding the scan data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on RawExternalRead.
; Written by Lasse Clausen, Apr, 8 2010
;-
function rad_raw_read_record, unit, lib, prm, raw

  s=CALL_EXTERNAL(lib,'RawIDLRead', $
                  unit,prm,raw)

  return, s
end