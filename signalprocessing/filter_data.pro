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
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
FUNCTION filter_data, array, sample_period, lowpass_cutoff_period, highpass_cutoff_period, $
	lowpass_cutoff_frequency=lowpass_cutoff_frequency, highpass_cutoff_frequency=highpass_cutoff_frequency, $
	millihertz=millihertz

if keyword_set(millihertz) then $
	fac = 1000. $
else $
	fac = 1.

if keyword_set(lowpass_cutoff_frequency) then $
	lowpass_cutoff_period = fac/lowpass_cutoff_frequency $
else $
	lowpass_cutoff_frequency = 0.

if keyword_set(highpass_cutoff_frequency) then $
	highpass_cutoff_period = fac/highpass_cutoff_frequency $
else $
	highpass_cutoff_frequency = 0.

if n_elements(array) eq 0 and n_elements(sample_period) eq 0 and $
	n_elements(lowpass_cutoff_period) eq 0 and n_elements(highpass_cutoff_period) eq 0 then begin
	prinfo, 'You must give array, sample_period, lowpass_cutoff_period/lowpass_cutoff_frequency, and highpass_cutoff_period/highpass_cutoff_frequency.'
	return, array
endif

nn = n_elements(array)
if nn lt 3 then begin
	prinfo, 'Array must have more than 3 elements.'
	return, array
endif

if lowpass_cutoff_period gt 0. and highpass_cutoff_period gt 0. and lowpass_cutoff_period ge highpass_cutoff_period then begin
	prinfo, 'Cannot filter, high-pass filter cutoff freq is greater than low-pass filter cutoff freq.'
	return, array
endif

; detrending data
narray = detrend(array)

; Determine some stuff
sample_freq = 1.0/sample_period

; low-pass filter data
IF lowpass_cutoff_period gt sample_period THEN BEGIN
	filter = make_lanzcos_filter(lowpass_cutoff_period, sample_freq, /low)
	IF filter[0] ne -1 THEN $
		narray = CONVOL(narray,filter)
ENDIF

; high-pass filter data
IF highpass_cutoff_period gt sample_period THEN BEGIN
	filter = make_lanzcos_filter(highpass_cutoff_period, sample_freq, /high)
	IF filter[0] ne -1 THEN $
		narray = CONVOL(narray,filter)
ENDIF

RETURN,narray
END
