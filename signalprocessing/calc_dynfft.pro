;+ 
; NAME: 
; CALC_DYNFFT
; 
; PURPOSE: 
; This procedure computes the dynamic FFT of a set of time series data.
;
; The maximum frequency calculated is given by:
;       fMax = 1/(2*dt)
; where dt is the time resolution of the data.
;
; Regularly spaced data is required; see notes on INTERPOLATE keyword for some
; additional info regarding this.
; 
; CATEGORY: 
; Signalprocessing
; 
; CALLING SEQUENCE: 
; result = CALC_DYNFFT( dataStruct [, INTERPOLATE=interpolate] [, DETREND=detrend] [ WINDOWLENGTH=windowLength] [, MAGNITUDE=magnitude] [, PHASE=phase] [, NORMALIZE=normalize] [, EPOCHTIME=epochTime])
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
;       result = {time:time, freq:freq, fft:FFT}
;       
;       result.time: Time vector in same units as the input.  Each time in this vector is
;               the center of an FFT time window.
;       result.freq: Frequency vector in Hertz.  Note that above fMax = 1/(2*dt), computed
;               FFT values fold over into the the reverse of the negative spectrum.  See
;               IDL help for FFT command for details.
;       result.fft:  Two-dimensional array containing the results of the FFT computation.
;               The first dimension corresponds with time, and the second dimension corresponds
;               with frequency.  If the MAGNITUDE, PHASE, or NORMALIZE keywords are set, then 
;               result.fft will contain magnitude, phase, or normalized magnitudes, respectively,
;               rather than the complex FFT result.
;       result.winTime: Vector of relative time for each window in original time units.
;       result.windowedTimeSeries: Two-dimensional array containing the data just prior to the application of the FFT.
;               
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
; INTERPOLATE: Set this keyword to a time resolution in seconds to interpolate the input
; data.  Interpolation is required to place radar data onto a regular time grid before
; computing the FFT.  If INTERPOLATE is not set, a default value of 5 seconds is used.
; To disable interpolation (useful if data set is already uniform in time), set
; INTERPOLATE = -1.
;
; DETREND: Set this keyword to the degree polynomial to fit and then subtract from each set
; of windowed data.  By default, this is set to DETREND=1 which corresponds to a linear fit/
; detrending.  Set DETREND=0 to remove the average; set DETREND=-1 to disable detrending.
;
; WINDOWLENGTH: Set this keyword to set the length of the time window in seconds over which 
; to compute each FFT.  Default of WINDOWLENGTH = 600 s.
;
; MAGNITUDE: Set this keyword to return the unnormalized magnitude of the FFT.
;
; PHASE: Set this keyword to return the phase of the FFT in radians.
;
; NORMALIZE: Set this keyword to return the normalized magnitude of the FFT.
;
; EPOCHTIME: Set this keyword to indicate that the input time vector is in units of seconds,
; not days.
;
; EXAMPLE: 
; 
; COPYRIGHT:
; MODIFICATION HISTORY: 
; Written by: Nathaniel Frissell, 2011
;-
FUNCTION CALC_DYNFFT,dataStruct_in              $
    ,INTERPOLATE        = interpolate           $
    ,DETREND            = detrend               $
    ,WINDOWLENGTH       = windowlength          $
    ,MAGNITUDE          = magnitude             $
    ,PHASE              = phase                 $
    ,NORMALIZE          = normalize             $
    ,STEPLENGTH         = stepLength            $
    ,SCORE              = score                 $
    ,EPOCHTIME          = epochTime

IF ~KEYWORD_SET(interpolate)    THEN interpolate        = 5.
IF ~KEYWORD_SET(detrend)        THEN detrend            = 1.
IF ~KEYWORD_SET(windowlength)   THEN windowlength       = 600.
IF ~KEYWORD_SET(epochTime)      THEN epochTime          = 0

dataStruct      = dataStruct_in
dataStruct      = INTERPOLATOR(dataStruct,interpolate,EPOCHTIME=epochTime)
dataStruct      = WINDOWIZE(dataStruct,windowLength,DETREND=detrend,EPOCHTIME=epochTime,STEPLENGTH=stepLength)

nWinTime        = N_ELEMENTS(dataStruct.data[0,*])
freq            = INDGEN(nWinTime)/(nWinTime*dataStruct.delta)
datafft         = FFT(dataStruct.data,DIMENSION=2)

IF KEYWORD_SET(magnitude)||KEYWORD_SET(normalize) THEN dataFFT = ABS(dataFFT)
IF KEYWORD_SET(normalize)       THEN dataFFT            = dataFFT / MAX(dataFFT)
IF KEYWORD_SET(phase)           THEN dataFFT            = ATAN(dataFFT,/PHASE)

IF KEYWORD_SET(score) THEN BEGIN
    FOR kk=0,N_ELEMENTS(dataFFT[*,0])-1 DO BEGIN
        tmp = dataFFT[kk,*]
        tmp = ABS(tmp)/MAX(ABS(tmp))
        tmp = tmp - MEAN(tmp)
        dataFFT[kk,*] = tmp
    ENDFOR
ENDIF

RETURN, {time   : dataStruct.time               $
        ,freq   : freq                          $
        ,fft    : dataFFT                       $
        ,winTime: dataStruct.winTime            $
        ,windowedTimeSeries: dataStruct.data}
END
