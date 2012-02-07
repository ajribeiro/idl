;+ 
; NAME: 
; RAD_FIT_FIND_SCAN
; 
; PURPOSE: 
; This function returns the scan number(s) of the scan closest to the given date.
; 
; CATEGORY:  
; Radar
; 
; CALLING SEQUENCE: 
; Result = RAD_FIT_FIND_SCAN(Juls)
;
; INPUTS:
; Juls: A scalar specifying the julian date to which the number of the closest 
; scan will be found. It can also be a 2-element vector specifying the date/time 
; range between which all scan numbers will be returned.
;
; KEYWORD PARAMETERS:
; CHANNEL: Set this keyword to the channel in which you want to find the scan.
;
; SCAN_ID: Set this keyword to the numeric scan id where you want to find the scan.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
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
; Based on Steve Milan's GO.
; Written by Lasse Clausen, Nov, 24 2009
;-
function rad_fit_find_scan, juls, channel=channel, scan_id=scan_id

common rad_data_blk

if n_elements(juls) eq 0 then begin
	prinfo, 'Must give Juls.'
	return, -1L
endif

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	return, -1L

if (*rad_fit_info[data_index]).nrecs lt 1 then begin
	prinfo, 'No data in index '+string(data_index)
	return, -1L
endif

if ~keyword_set(scan_id) then $
	scan_id = -1

if n_elements(channel) eq 0 and scan_id eq -1 then $
		channel = (*rad_fit_info[data_index]).channels[0]

if n_elements(channel) ne 0 then begin
	inds = WHERE((*rad_fit_data[data_index]).channel eq channel, $
		cc)
endif else if scan_id ne -1 then begin
	inds = WHERE((*rad_fit_data[data_index]).scan_id eq scan_id, $
		cc)
endif
if cc eq 0 then begin
	prinfo, 'No scan information.'
	return, -1L
endif

; find minimum distance between provided juls
; and beam times
smin = min( abs( (*rad_fit_data[data_index]).juls[inds]-juls[0]), sminind)

if n_elements(juls) gt 1 then $
	fmin = min( abs( (*rad_fit_data[data_index]).juls[inds]-juls[1]), fminind) $
else begin
	fmin = 0.d
	fminind = sminind
endelse

; check if distance is "reasonable"
; i.e. within 5 minutes
if smin*1440.d gt 5. then $
	prinfo, 'Found scan but it is '+$
		strtrim(string(smin*1440.d),2)+' mins away from given date.'

; check if distance is "reasonable"
; i.e. within 5 minutes
if fmin*1440.d gt 5. then $
	prinfo, 'Found scan but it is '+$
		strtrim(string(fmin*1440.d),2)+' mins away from given date.'

tmp = ((*rad_fit_data[data_index]).beam_scan[inds])[sminind:fminind]

return, tmp[uniq(tmp, sort(tmp))]

end
