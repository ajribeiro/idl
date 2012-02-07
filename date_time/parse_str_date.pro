;+ 
; NAME: 
; PARSE_STR_DATE 
; 
; PURPOSE: 
; This procedure converts a string date in MMMYYYY or YYYYMMDD format into the 
; numeric YYYYMMDD format.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; PARSE_STR_DATE, Strdate
; 
; INPUTS: 
; Strdate: The date in MMMYYYY or YYYYMMDD format of data type string - where 
; MMM are the first three letters of the name of a month. This can be a scalar
; or a 2-element vector.
; 
; OPTIONAL OUTPUTS: 
; Date: The date in numeric YYYYMMDD format.
; 
; EXAMPLE: 
; strdate = ['jan2004','jun2005']
; parse_str_date,strdate,date
; print, date
;         20040101        20050601
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
pro parse_str_date, strdate, date

if n_params() lt 1 then begin
	prinfo, 'Must give Strdate.'
	date = 0
	return
endif

months = ['jan','feb','mar','apr','may','jun',$
	'jul','aug','sep','oct','nov','dec']

if n_elements(strdate) eq 2 then begin
	parse_str_date, strdate[0], sdate
	parse_str_date, strdate[1], fdate
	if n_elements(sdate) eq 2 and n_elements(fdate) eq 2 then $
		date = [sdate[0], fdate[1]] $
	else $
		date = [sdate, fdate]
	return
endif

if strlen(strdate) eq 7 then begin
	month = strlowcase(strmid(strdate, 0, 3))
	year = fix(strmid(strdate, 3, 4))
endif else if strlen(strdate) eq 6 then begin
	month = months[fix(strmid(strdate, 0, 2))-1]
	year = fix(strmid(strdate, 2, 4))
endif else if strlen(strdate) eq 9 then begin
	day = fix(strmid(strdate, 0, 2))
	month = strlowcase(strmid(strdate, 2, 3))
	year = fix(strmid(strdate, 5, 4))
	dd = where(months eq month, mm)
	if mm eq 0 then begin
		prinfo, 'Invalid STRDATE format (month): '+strdate, /force
		return
	endif
	date = year*10000L + (dd+1)*100L + day
	return
endif else if strlen(strdate) eq 11 then begin
	day = fix(strmid(strdate, 0, 2))
	month = strlowcase(strmid(strdate, 3, 3))
	year = fix(strmid(strdate, 7, 4))
	dd = where(months eq month, mm)
	if mm eq 0 then begin
		prinfo, 'Invalid STRDATE format (month): '+strdate, /force
		return
	endif
	date = year*10000L + (dd+1)*100L + day
	return
endif else if strlen(strdate) eq 8 then begin
	date = long(strdate)
	return
endif else begin
	prinfo, 'Invalid STRDATE format (length): '+strdate, /force
	return
endelse

if year lt 1900 or year gt 2020 then begin
	prinfo, 'Invalid STRDATE format (year): '+strdate, /force
	return
endif

dd = where(months eq month, mm)
if mm eq 0 then begin
	prinfo, 'Invalid STRDATE format (month): '+strdate, /force
	return
endif
days = days_in_month(dd+1, year=year)

date = [year*10000L+(dd+1)*100L+1, year*10000L+(dd+1)*100L+days]

end
