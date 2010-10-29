;+ 
; NAME: 
; MAKE_LANZCOS_FILTER
; 
; PURPOSE: 
; This procedure returns a Lanzcos squared filter to be used for filtering
; time series data in the time domain. Don't use this function unless you know what
; you are doing. You should use the DATA_FILTER function.
; 
; CATEGORY: 
; Signalprocessing
; 
; CALLING SEQUENCE: 
; MAKE_LANZCOS_FILTER, Cutoff_period, Sample_period
;
; INPUTS:
; Cutoff_period: The value of the cutoff PERIOD. If a low-pass
; filter is requested, all frequencies above the cutoff will be
; removed. If a high-pass filter is requested, all frequencies
; below the cutoff are removed.
;
; Sample_freq: The sample FREQUENCY of the data to be filtered, i.e.
; the time step between measurements.
;
; KEYWORD PARAMETERS:
; HIGH: Set this keyword to return a high-pass filter.
;
; LOW: Set this keyword to return a low-pass filter.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
function make_lanzcos_filter, cutoff_period, sample_freq, high=high, low=low

if keyword_set(high) and keyword_set(low) then begin
	prinfo, 'You cannot set HIGH and LOW at the same time.'
	return, -1.
endif

if ~keyword_set(high) and ~keyword_set(low) then begin
	prinfo, 'You have to set either HIGH or LOW.'
	return, -1.
endif

; Determine some stuff
cutoff_freq  = 1.0/cutoff_period
nyquist_freq = sample_freq/2.0
no_nyquist   = cutoff_freq/nyquist_freq
filter_len   = 3.*cutoff_period*nyquist_freq

IF filter_len LT 3 THEN begin
	prinfo, 'Your input values are stupid.'
	return, -1.
endif

; Make Lanzcos squared filter
;N = filter_len
;fltr = FLTARR(2*N-1)
;fltr(N-1)=1.0
;FOR i=0,2*N-2 DO BEGIN
;	IF i NE N-1 THEN fltr(i)=(SIN(ABS(i-N+1)*!pi/(N-1))*(N-1)/(!pi*ABS(i-N+1)))^2
;ENDFOR

; Apply cutoff factor (down 6 dB at no_nyquist nyquists)
;IF no_nyquist GT 0 THEN BEGIN
;	FOR i=0,2*N-2 DO BEGIN
;		IF i NE N-1 THEN fltr(i)=fltr(i)*SIN((i-N+1)*!pi*no_nyquist)	$
;						/((i-N+1)*!pi*no_nyquist)
;	ENDFOR
;ENDIF

; total filter length
nn = 2.*filter_len - 1.

; Make Lanzcos squared filter
idx = findgen(nn) - filter_len + 1.

; avoid floating illegal operand message when dividing by 0
; the value in the filter will be overwritten anyway
idx[filter_len-1L] += 0.001
fltr = (SIN( ABS( idx )*!pi / (filter_len-1.) ) * (filter_len-1.) / ( !pi*ABS( idx ) ) )^2
; told you it will be overwritten
fltr[filter_len-1L] = 1.0

; Apply cutoff factor (down 6 dB at no_nyquist nyquists)
IF no_nyquist GT 0 THEN BEGIN
	fltr = fltr * SIN( idx*!pi*no_nyquist) / (idx*!pi*no_nyquist)
ENDIF
; told you it will be overwritten
fltr[filter_len-1L] = 1.0

; Determine normalization factor
norm = nn/TOTAL(fltr)

IF KEYWORD_SET(high) THEN BEGIN
	; Construct high pass filter
	fltr = -fltr*norm
	fltr[filter_len-1L] = fltr[filter_len-1L] + nn
ENDIF else IF KEYWORD_SET(low) THEN BEGIN
	; Construct low pass filter
	fltr = fltr*norm
ENDIF

; Normalise to length of filter
fltr = fltr/nn

RETURN, fltr

END