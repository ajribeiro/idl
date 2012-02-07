;+ 
; NAME: 
; GET_XTICKS 
; 
; PURPOSE: 
; This function returns an appropriate number of major ticks on the x axis
; depending on the time interval
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; Result = GET_XTICKS(Sjul, Fjul)
; 
; INPUTS:
; Sjul: If the JUL_TO_DATE keyword is set, this variable contains the 
; Julian day number which will be converted to a numeric date and time.
;
; Fjul: If the JUL_TO_DATE keyword is set, this variable contains the 
; Julian day number which will be converted to a numeric date and time.
; Date and Time will then contain ranges, i.e. be 2-element vectors.
; 
; OUTPUTS:
; This function returns an appropriate number of xticks.
; 
; KEYWORD PARAMETERS:
; XMINOR: Set this keyword to a named variable that will contain an
; appropriate number of minor xticks.
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
; Written by Lasse Clausen, Nov, 24 2009
;-
function get_xticks, sjul, fjul, xminor=xminor

if n_params() eq 1 then begin
	if n_elements(sjul) ne 2 then begin
		prinfo, 'Either give SJUL and FJUL or SJUL must be a 2-element vector.'
		return, 0
	endif
	_sjul = sjul[0]
	_fjul = sjul[1]
endif else begin
	_sjul = sjul
	_fjul = fjul
endelse

; difference in minutes
diff = (_fjul-_sjul)*1440.d

if diff lt 0.d then begin
	prinfo, 'SJUL must be less than FJUL'
	return, 0
endif
;print, diff, 31.*1440.d

if diff le 10.d then begin
	xminor = 6
	return, round(diff)
endif else if diff le 30.d then begin
	xminor = 5
	return, round(diff)/5
endif else if diff le 60.d then begin
	xminor = 5
	return, round(diff)/10
endif else if diff le 3.*60.d then begin
	xminor = 3
	return, round(diff)/30
endif else if diff le 6.*60.d then begin
	xminor = 4
	return, round(diff)/60
endif else if diff le 16.*60.d then begin
	xminor =  4
	return, round(diff)/120
endif else if diff le 24.*60.d then begin
	xminor =  4
	return, round(diff)/240
endif else if diff le 7200.d then begin
	xminor =  6
	return, round(diff)/720
endif else if diff le 31.*1440.d then begin
	xminor =  12
	return, round(diff)/1440
endif else begin
	xminor =  1
	return, round(diff)/30.3/1440.
endelse

end
