;+ 
; NAME: 
; AACGM_LOAD_COEF
;
; PURPOSE:
; This function loads a set of IGRF coefficients for use with the CNVCOORD() AACGM conversion function.
;
; CATEGORY:
; Misc.
; 
; CALLING SEQUENCE:
; AACGM_LOAD_COEF,year,SILENT=silent
;
; INPUTS:
; Year: Year of coefficient file to load.  Currently available years are:
;               1975, 1980, 1985, 1990, 1995, 2000, 2005
;       If a year without a coefficient file is entered, a warning will be given and the next available
;       previous coefficient will be used.
; d$aDate: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; KEYWORD PARAMETERS:
; SILENT: Set this keyword to disable notifications and warnings.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Nathaniel A. Frissell, July 19, 2011.
;-
PRO AACGM_LOAD_COEF,year,SILENT=silent
prefix$  = GETENV('AACGM_DAT_PREFIX')

valid_years = [1975, 1980, 1985, 1990, 1995, 2000, 2005]

test    = WHERE(year EQ valid_years)
IF test[0] EQ -1 THEN BEGIN
    IF year GE 2005 THEN year$ = '2005'
    IF (year GE 2000)*(year LT 2005) THEN year$ = '2000'
    IF (year GE 1995)*(year LT 2000) THEN year$ = '1995'
    IF (year GE 1990)*(year LT 1995) THEN year$ = '1990'
    IF (year GE 1985)*(year LT 1990) THEN year$ = '1985'
    IF (year GE 1980)*(year LT 1985) THEN year$ = '1980'
    IF (year LT 1980) THEN year$ = '1975'
ENDIF ELSE year$ = NUMSTR(year)

datFile$ = prefix$ + year$ + '.asc'

OPENR,unit,datFile$,/GET_LUN,/STDIO
c       = AACGMLoadCoef(unit)
FREE_LUN,unit

IF ~KEYWORD_SET(silent) THEN BEGIN
    IF test[0] EQ -1 THEN BEGIN 
        PRINT,'NOTICE: Coefficient file for ' + NUMSTR(year) + ' not available.'
        PRINT,'Using data for ' + year$ + ' instead.'
        PRINT,' '
    ENDIF

    IF c EQ 1 THEN BEGIN
        PRINT, 'IGRF Coefficients for the year ' + year$ + ' loaded successully.'
        PRINT, 'Coefficient file: ' + datFile$
    ENDIF ELSE BEGIN
        PRINT, 'WARNING: AN ERROR OCCURED.  Coefficients NOT loaded successfully.  Sorry.'
    ENDELSE
ENDIF   ;SILENT keyword.
END

