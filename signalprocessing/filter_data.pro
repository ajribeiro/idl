;+ 
; NAME: 
; FILTER_DATA
; 
; PURPOSE: 
; This procedure filters a time series in the time domain using a Lanzcos squared filter. 
; This function works on periods, not frequencies! Hence the lower cutoff period will
; create a low pass filter and the lower cutoff period will be the smallest period 
; that will not be filtered.
; Don't use this function unless you know what you are doing.
; The data is detrended before the filter is applied.
; 
; CATEGORY: 
; Signalprocessing
; 
; CALLING SEQUENCE: 
; FILTER_DATA, Array, Sample_period, Low_cutoff_period, High_cutoff_period
;
; INPUTS:
; Array: An 1-D array holding the data to be filtered. This values in
; this array must be evenly sampled, i.e. the time step between measurements
; must be equal. If your data is not evenly sampled, try using IDL's INTERPOL.
;
; Sample_period: The sample period of the data to be filtered, i.e.
; the time step between measurements.
;
; Low_cutoff_period: The value of the lower cutoff period. Period!
; All frequencies above this cutoff will be
; removed. You can set this to 0 or a negative number in order
; to omit filtering of the higher frequencies. The value must 
; be higher that Sample_period.

; High_cutoff_period: The value of the higher cutoff period.  Period!
; All frequencies below the cutoff will be
; removed. You can set this to 0 or a negative number in order
; to omit filtering of the lower frequencies. The value must 
; be higher that Sample_period.
; 
; EXAMPLE:
; Say you have a time series sampled every 8 seconds and you would
; like to filter out all frequencies higher that 4 mHz (250 s),
; i.e. low-pass filter the data. You would then enter
;
; DaViT> filtered_array = filter_data( array, 8., 250., 0. )
;
; Alternatively, if you want to high-pass filter the data with
; a cutoff frequency of, say, 10 mHz, enter
;
; DaViT> filtered_array = filter_data( array, 8., 0., 100. )
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
FUNCTION filter_data, array, sample_period, low_cutoff_period, high_cutoff_period

if n_params() ne 4 then begin
	prinfo, 'You must give array, sample_period, low_cutoff_period, and high_cutoff_period.'
	return, array
endif

nn = n_elements(array)
if nn lt 3 then begin
	prinfo, 'Array must have more than 3 elements.'
	return, array
endif

if low_cutoff_period ge high_cutoff_period then begin
	prinfo, 'Cannot filter, high-pass filter cutoff freq is greater than low-pass filter cutoff freq.'
	return, array
endif

; detrending data
narray = detrend(array)

; Determine some stuff
sample_freq = 1.0/sample_period

; low-pass filter data
IF low_cutoff_period gt sample_period THEN BEGIN
	filter = make_lanzcos_filter(low_cutoff_period, sample_freq, /low)
	IF filter[0] ne -1 THEN $
		narray = CONVOL(narray,filter)
ENDIF

; high-pass filter data
IF high_cutoff_period gt sample_period THEN BEGIN
	filter = make_lanzcos_filter(high_cutoff_period, sample_freq, /high)
	IF filter[0] ne -1 THEN $
		narray = CONVOL(narray,filter)
ENDIF

RETURN,narray
END
