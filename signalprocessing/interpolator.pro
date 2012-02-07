;+ 
; NAME: 
; INTERPOLATOR
; 
; PURPOSE: 
; This function takes in a set of time series data of arbitrary time resolution and regularity and returns a set of regularly spaced data at specified time resolution.
;
; CATEGORY: 
; Signalprocessing
; 
; CALLING SEQUENCE: 
; result = INTERPOLATOR(dataStruct [, delta] [, EPOCHTIME=epochTime])
;
; INPUTS:
; dataStruct:  A data structure containing a time vector and a data vector.  The structure
; should have the form of:
;       dataStruct = {time:timeVector, data:dataVector} 
; dataStruct.time is assumed to be in units of days (for Julian Days) unless the EPOCHTIME
; keyword is set.
;
; OUTPUTS:
; This function returns a data structure of the following form:
;       result = {time:timeVector, data:dataVector} 
;       result = {time:time, data:data, delta:dt}
;       
;       result.time:  Time vector in same units as the input, but now evenly spaced with time
;               resolution delta.
;       result.data:  Data vector interpolated to time resolution delta.
;
; OPTIONAL INPUTS:
; DELTA: Desired time resolution in seconds.  If delta is not set, or if is set delta=0, the input
; is return unchanged.
;
; KEYWORD PARAMETERS:
; EPOCHTIME: Set this keyword to indicate that the input time vector is in units of seconds,
; not days.
;
; EXAMPLE: 
; 
; COPYRIGHT:
; MODIFICATION HISTORY: 
; Written by: Nathaniel Frissell, 2011
;-
FUNCTION INTERPOLATOR,dataStruct_in,delta,EPOCHTIME=epochTime

timeVec = dataStruct_in.time
dataVec = dataStruct_in.data

;Remove non-finite points like NaNs.
good = WHERE(FINITE(dataVec))
dataVec = dataVec[good]
timeVec = timeVec[good]

IF delta GT 0 THEN BEGIN
    ;Make time series start from 0.
    dataStart       = timeVec[0]
    timeVec         = timeVec - dataStart

    ;If dataArr_in is given in units of days (i.e. Julian Days), then convert time vector
    ;to seconds.
    IF ~KEYWORD_SET(epochTime) THEN timeVec = timeVec * 86400.D

    ;Create time vector in seconds for the duration of the timespan.
    ;Use a resolution equal to interp seconds.
    timeGrid        = FINDGEN((CEIL(MAX(timeVec))/delta))*delta

    ;Interpolate the data.
    dataGrid            = INTERPOL(dataVec,timeVec,timeGrid)

    ;If time was originally given in units of days, convert it back to that.
    IF ~KEYWORD_SET(epochTime) THEN timeGrid = timeGrid / 86400.D

    ;Update dataArr with the new data.
    timeVec             = timeGrid + dataStart
ENDIF ELSE BEGIN
    PRINFO,'Time resolution not set; no interpolation performed.'
    dataGrid            = dataVec 
ENDELSE

RETURN,{time:timeVec,data:dataGrid}
END

