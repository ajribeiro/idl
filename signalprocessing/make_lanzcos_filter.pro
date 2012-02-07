;+ 
; NAME: 
; MAKE_LANZCOS_FILTER
; 
; PURPOSE: 
; This procedure returns a Lanzcos squared filter to be used for filtering
; time series data in the time domain. Don't use this function unless you know what
; you are doing. You should use the FILTER_DATA function.
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
