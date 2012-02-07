;+ 
; NAME: 
; NUMSTR
; 
; PURPOSE: 
; This function takes converts value-type variables into
; string type variables.
; 
; CATEGORY: 
; Misc.
; 
; CALLING SEQUENCE: 
; Result = NUMSTR(value_in, [decimal])
;
; PARAMETERS:
; value_in: Any type of number to be converted to string-type.
;
; decimal: Number of decimal places used in output string.  If this
; parameter is omitted, a string of an integer will be returned.  Standard
; rounding rules apply.
;
; OUTPUTS:
; This function returns a string type of value_in.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Nathaniel A. Frissell, 12 October 2009
; Updated 19 July 2011
FUNCTION NUMSTR,value_in,decimal
value = value_in
;dimensions = SIZE(value_in,/DIMENSIONS)

IF N_ELEMENTS(decimal) EQ 0 THEN decimal = 0
IF (decimal EQ 0) THEN BEGIN
    value  = LONG(value)
    format$ = '(I)'
ENDIF ELSE BEGIN
    value  = DOUBLE(value)
    format$ = '(D25.' + STRTRIM(STRING(decimal),1) + ')'
ENDELSE
    value$ = STRTRIM(STRING(value,FORMAT=format$),1)

;value$ = REFORM(value$,dimensions)

RETURN,value$
END
