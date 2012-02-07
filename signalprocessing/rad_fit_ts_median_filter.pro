;+ 
; NAME: 
; RAD_FIT_TS_MEDIAN_FILTER
; 
; PURPOSE: 
; This procedure applies a one-dimensional median filtering to time-series data currently stored
; in the RAD_FIT_DATA common block.
; 
; CATEGORY:  
; Signal Processing
; 
; CALLING SEQUENCE: 
; RAD_FIT_TS_MEDIAN_FILTER
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
; PARAM: Parameter to median filter.  If this keyword is omitted, the current parameter obtained from GET_PARAMETER() will be used.
;
; BEAMS: A scalar or 2-element vector of the beams to median filter.  If this keyword is omitted, all available beams will be filtered.
;
; GATES: A scalar or 2-element vector of the gates to median filter.  This keyword is ignored if the chosen parameter is not a function of range gate.  If this keyword is omitted, all available range gates will be filtered.
;
; INDEX:  RAD_DATA_INDEX to be used.  If none selected, the current index obtained from RAD_FIT_GET_DATA_INDEX() is used.
;
; WIDTH: The size of the one-dimensional neighborhood to be used by the median filter.  The value of this keyword is fed directly in to IDL's MEDIAN() function and has a default value of WIDTH=5.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE:
;
; COPYRIGHT:
; MODIFICATION HISTORY:
; Modified by Nathaniel Frissell, 25 July 2011
;-
PRO RAD_FIT_TS_MEDIAN_FILTER                                    $
;        ,DATE           = date                                  $
;        ,TIME           = time                                  $
;        ,LONG           = long                                  $
        ,PARAM          = param                                 $
        ,BEAMS          = beams_in                              $
        ,GATES          = gates_in                              $
        ,INDEX          = index                                 $
        ,WIDTH          = width

COMMON rad_data_blk
IF N_ELEMENTS(index) EQ 0 THEN index = RAD_FIT_GET_DATA_INDEX()
IF (index[0] EQ -1) THEN BEGIN
    IF ~KEYWORD_SET(silent) THEN BEGIN
        PRINFO, 'No data loaded.'
    ENDIF
    RETURN
ENDIF

IF ~KEYWORD_SET(date) THEN BEGIN
        date    = DBLARR(2)
	CALDAT, (*RAD_FIT_INFO[index]).sjul, mm, dd, yy
	date[0] = yy*10000L + mm*100L + dd

	CALDAT, (*RAD_FIT_INFO[index]).fjul, mm, dd, yy
	date[1] = yy*10000L + mm*100L + dd
ENDIF

IF ~KEYWORD_SET(time) THEN BEGIN
        time    = DBLARR(2)
	CALDAT, (*RAD_FIT_INFO[index]).sjul, mm, dd, yy, hh, min, ss
	time[0] = hh*100L + min; + ss

	CALDAT, (*RAD_FIT_INFO[index]).fjul, mm, dd, yy, hh, min, ss
	time[1] = hh*100L + min; + ss
        time    = LONG(time)
        long    = 0
ENDIF


IF ~KEYWORD_SET(param) THEN param = GET_PARAMETER()
param$ = '(*rad_fit_data[index]).'+param
s       = EXECUTE('paramData='+param$)

IF N_ELEMENTS(beams_in) NE 0 THEN beams = beams_in
IF N_ELEMENTS(beams) EQ 0 THEN beams = [0, (*rad_fit_info[index]).nBeams-1]
IF N_ELEMENTS(beams) EQ 1 THEN beams = [beams, beams]

IF N_ELEMENTS(gates_in) NE 0 THEN gates = gates_in
IF N_ELEMENTS(gates) EQ 0 THEN gates = [0, (*rad_fit_info[index]).nGates-1]
IF N_ELEMENTS(gates) EQ 1 THEN gates = [gates, gates]

IF N_ELEMENTS(width) EQ 0 THEN width = 5

IF SIZE(paramData,/N_DIMENSIONS) EQ 1 THEN BEGIN
    FOR nBm = beams[0],beams[1] DO BEGIN
        bmInx       = WHERE((*rad_fit_data[index]).beam EQ nBm)
        s = EXECUTE(param$+'[bmInx] = MEDIAN(paramData[bmInx],width)')
    ENDFOR ;Beam loop.
ENDIF ELSE BEGIN
    FOR nBm = beams[0],beams[1] DO BEGIN
        bmInx       = WHERE((*rad_fit_data[index]).beam EQ nBm)
        FOR nGt = gates[0],gates[1] DO BEGIN
            s = EXECUTE(param$+'[bmInx,nGt] = MEDIAN(paramData[bmInx,nGt],width)')
        ENDFOR ;Gate loop.
    ENDFOR ;Beam loop.
ENDELSE
(*rad_fit_info[index]).filtered=1
END
