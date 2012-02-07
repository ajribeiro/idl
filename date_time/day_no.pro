;+ 
; NAME: 
; DAY_NO 
; 
; PURPOSE: 
; This function calculates the Day Of Year (doy) from a given date.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; Result = DAY_NO(Date)
; 
; INPUTS: 
; Date: If Date has less than 5 digits it is interpreted as a year. If it has 
; more than 5 digits, it is interpreted as a date in YYYYMMDD format. Can be an array.
; 
; OPTIONAL INPUTS: 
; Month: If Date is the year, set this to the month. Can be an array.
;
; Day: If Date is the year, set this to the day. Can be an array.
; 
; OUTPUTS: 
; This function returns the Doy Of Year (doy) of a given date.
;
; KEYWORD PARAMETERS:
; SILENT: Set this keyword to surpress warnings but not error messages.
; 
; EXAMPLE: 
; In leap years, March 1st is the 61st day of the year, in non-leap years it
; is the 60th day.
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
; print, day_no(20040301)
;    61.0000
; print, day_no(20030301)
;    60.0000
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
; Modified by Lasse Clausen, Jan, 29 2010 to accept array input
;-
function day_no, date, month, day, silent=silent

if n_params() eq 0 then begin
	prinfo, 'Must give Date.'
	return, -1
endif

y_inds = where(alog10(date) lt 5., yn, complement=d_inds, ncomplement=dn)
if yn ne 0L and dn ne 0L then begin
	prinfo, 'You must not mix date formats.'
	return, -1
endif

_date = long(date)

if dn ne 0L then begin
	_year = _date/10000L
	_month = (_date - _year*10000L)/100L
	_day = (_date - _year*10000L - (_month)*100L)
endif

if yn ne 0L then begin
	if n_elements(month) ne yn then begin
		prinfo, 'Month must have same size as Year.'
		return, -1
	endif
	inds = where(month lt 1 or month gt 12, cc)
	if cc gt 0L then begin
		prinfo, 'MONTH out of bounds.'
		return, -1
	endif
	if n_elements(day) ne yn then begin
		prinfo, 'Day must have same size as Year.'
		return, -1
	endif
	inds = where(day lt 1 or day gt 31, cc)
	if cc gt 0L then begin
		prinfo, 'DAY out of bounds.'
		return, -1
	endif
	_year = date
	_month = month
	_day = day
endif

doys = fix(julday(_month, _day, _year, 0.) - julday(1, 1, _year, 0.))+1

return, doys

end
