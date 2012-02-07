FUNCTION JUL2STRING,date_in

IF N_ELEMENTS(date_in) EQ 0 THEN BEGIN
    dateOut     = 0
ENDIF ELSE BEGIN
    date    = date_in
    dateSize= SIZE(date,/DIMENSIONS)
    IF ~KEYWORD_SET(dateSize) THEN dateSize=1
    dateOut = STRARR(dateSize)
    FOR ii = 0,N_ELEMENTS(date)-1 DO BEGIN
        dateOut[ii] = TIME_STRING(JUL2EPOCH(date[ii]))
    ENDFOR
ENDELSE

RETURN,dateOut
END
