;+ 
; NAME: 
; PARSE_DATE 
; 
; PURPOSE: 
; This procedure extracts day, month and year from a numeric date in YYYYMMDD
; format.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; PARSE_DATE, Date
; 
; INPUTS: 
; Date: The date in YYYYMMDD format from which the day, month and year are
; extracted. Can be a 2-element vector for a date range.
; 
; KEYWORD PARAMETERS: 
; SILENT: Set this keyword to surpress warning messages.
;
; FIRST: Set this keyword to indicate that the day, month, year of the first
; element of the 2-element input vector is returned.
;
; MIDDLE: Set this keyword to indicate that the day, month, year of the average
; date of the 2-element input vector is returned.
;
; LAST: Set this keyword to indicate that the day, month, year of the last (second)
; element of the 2-element input vector is returned.
; 
; OPTIONAL OUTPUTS: 
; Year: A named variable that will contain the year of the input date.
;
; Month: A named variable that will contain the month of the input date.
;
; Day: A named variable that will contain the day of the input date.
;
; Doy: A named variable that will contain the day of year of the input date.
; 
; EXAMPLE: 
; date = 20060212
; parse_date, date, year, month, day
; print, year, month, day
;         2006           2          12
; date = [20040101,20050101]
; parse_date,date,year
; % PARSE_DATE:             DATE is 2-element vector. Taking first.
; print, year
;         2004
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
pro parse_date, date, year, month, day, doy, silent=silent, $
	first=first, middle=middle, last=last

if n_params() lt 1 then begin
	prinfo, 'Must give Date.'
	year = 0
	month = 0
	day = 0
	doy = 0
	return
endif

if ~keyword_set(first) and ~keyword_set(middle) and ~keyword_set(last) then $
	first = 1

if n_elements(date) eq 2 then begin

	if keyword_set(first) then begin
		if ~keyword_set(silent) then $
			prinfo, 'DATE is 2-element vector. Taking first.'
		year  = date[0]/10000L
		month = (date[0] mod 10000L)/100L
		day   = (date[0] mod 100L)
		doy   = day_no(year, month, day)
	endif else if keyword_set(middle) then begin
		if ~keyword_set(silent) then $
			prinfo, 'DATE is 2-element vector. Taking average.'
		syear  = date[0]/10000L
		smonth = (date[0] mod 10000L)/100L
		sday   = (date[0] mod 100L)
		fyear  = date[1]/10000L
		fmonth = (date[1] mod 10000L)/100L
		fday   = (date[1] mod 100L)
		caldat, (julday(smonth, sday, syear)+julday(fmonth, fday, fyear))/2.d, $
			month, day, year
		doy   = day_no(year, month, day)
	endif else begin
		if ~keyword_set(silent) then $
			prinfo, 'DATE is 2-element vector. Taking last.'
		year  = date[1]/10000L
		month = (date[1] mod 10000L)/100L
		day   = (date[1] mod 100L)
		doy   = day_no(year, month, day)
	endelse
endif else begin
	year  = date/10000L
	month = (date mod 10000L)/100L
	day   = (date mod 100L)
	doy   = day_no(year, month, day)
endelse

end
