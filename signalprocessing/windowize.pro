;+ 
; NAME: 
; WINDOWIZE
; 
; PURPOSE: 
; This function takes time-series data and organizes it into an array of vectors each with a specified time duration (window length).  This function is designed to work with CALC_DYNFFT in order to calculate dynamic spectra.  As such, this function incorporates certain signal processing function that are useful for this type of analysis.  This includes the ability to detrend and apply a Hanning Window to each vector of windowed data.
; 
; CATEGORY: 
; Signalprocessing
; 
; CALLING SEQUENCE: 
; result = WINDOWIZE( dataStruct [, windowLength] [, DETREND=detrend] [, NOHANNING=noHanning] [, EPOCHTIME=epochTime])
;
; INPUTS:
; dataStruct:  A data structure containing a time vector and a data vector.  The structure
; should have the form of:
;       dataStruct = {time:timeVector, data:dataVector} 
; dataStruct.time is assumed to be in units of days (for Julian Days) unless the EPOCHTIME
; keyword is set.  Also, all data input into this routine should be regularly sampled in time.
;
; OUTPUTS:
; This function returns a data structure of the following form:
;       result = {time:time, data:data, delta:dt}
;       
;       result.time:  Time vector in same units as the input.  Each time in this vector is
;               the center of a data vector time window.
;       result.data:  Two-dimensional array containing the orginal data split into windows.
;               The first dimension corresponds with time, and the second dimension corresponds
;               with the data.
;       result.delta: Time resolution in seconds of the original data set.
;       result.winTime: Vector of relative time for each window in original time units.
;
; OPTIONAL INPUTS:
; WINDOWLENGTH: Set this keyword to set the length of the time window in seconds over which 
; to compute each FFT.  Default of WINDOWLENGTH = 600 s.
;
; KEYWORD PARAMETERS:
; DETREND: Set this keyword to the degree polynomial to fit and then subtract from each set
; of windowed data.  By default, this is set to DETREND=1 which corresponds to a linear fit/
; detrending.  Set DETREND=0 to remove the average; set DETREND=-1 to disable detrending.
;
; NOHANNING: Set this keyword to disable the application of a Hanning window to each vector of
; windowed data.  Hanning windows are needed for proper FFT computation.
;
; EPOCHTIME: Set this keyword to indicate that the input time vector is in units of seconds,
; not days.
;
; EXAMPLE: 
; 
;
; MODIFICATION HISTORY: 
; Written by: Nathaniel Frissell, 2011
;-
FUNCTION WINDOWIZE,dataStruct_in,windowLength,DETREND=detrend,NOHANNING=noHanning,EPOCHTIME=epochTime,STEPLENGTH=stepLength

timeVec         = dataStruct_in.time
dataVec         = dataStruct_in.data

startTime       = timeVec[0]
timeVec         = timeVec - startTime

IF ~KEYWORD_SET(windowLength)   THEN windowLength = 600.
IF ~KEYWORD_SET(stepLength)     THEN stepLength = windowLength / 2.
;Convert time vector to seconds if given in units of days (i.e. Julian Time).
IF ~KEYWORD_SET(epochTime)      THEN timeVec    = timeVec * 86400.D
IF ~KEYWORD_SET(detrend)        THEN detrend    = 0

;Determine time resolution of data.
timeShift       = SHIFT(timeVec,1)
dt              = ABS(timeShift - timeVec)
dt              = dt[1:*]
delt            = FLOAT(TOTAL(dt)) / N_ELEMENTS(dt)

nCol    = FLOOR(windowLength/delt)
nDp     = N_ELEMENTS(timeVec) - nCol    ;Number of Data Points
nDpStep = FLOOR(stepLength / delt)
IF nDpStep EQ 0 THEN nDpStep = 1        ;Step cannot be equal to zero.
nRow    = FLOOR(nDp / nDpStep)
IF KEYWORD_SET(noHanning) THEN han = 1. ELSE han = HANNING(nCol,/DOUBLE)
dataArr    = FLTARR(nCol,nRow)
timeVecNew = FLTARR(nRow)
winTime = windowLength * (FINDGEN(nCol)/(nCol-1) - 0.5)
FOR winI = 0,nRow-1 DO BEGIN
    winStart = winI * nDpStep 
    dataRow = dataVec[winStart:winStart+nCol-1] 
    IF  detrend GE 0 THEN BEGIN
        result  = POLY_FIT(FINDGEN(N_ELEMENTS(dataRow)),dataRow,detrend,YFIT=yfit)
    ENDIF ELSE yfit = 0
    dataArr[*,winI] = han * (dataRow - yfit)    ;Apply a Hanning window.
    timeVecNew[winI]= timeVec[winStart] + windowLength / 2.
ENDFOR
;timeVec = timeVec[FLOOR(nCol/2.):nRow-1 + FLOOR(nCol/2.)]
timeVec = timeVecNew

;Convert time back to Julian Days if needed.
IF ~KEYWORD_SET(epochTime)      THEN BEGIN
    timeVec    = timeVec  / 86400.D
    winTime     = winTime / 86400.D
ENDIF

timeVec = timeVec + startTime
RETURN,{time:timeVec,data:TRANSPOSE(dataArr),delta:delt,winTime:winTime}
END

