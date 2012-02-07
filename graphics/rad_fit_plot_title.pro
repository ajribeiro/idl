;+ 
; NAME: 
; RAD_FIT_PLOT_TITLE
; 
; PURPOSE: 
; This procedure plots a generall title on the top of a page.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_TITLE
;
; OPTIONAL INPUTS:
; Title: A string used as the title, default is SUPERDARN PARAMETER PLOT.
;
; Subtitle: A string used as the subtitle, default radar name: parameter.
;
; KEYWORD PARAMETERS:
; NO_DATE: Set this keyword to surpress plotting of date/time information.
;
; SCAN_ID: Set this keyword to the numeric scan id to plot in the title.
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
pro rad_fit_plot_title, title, subtitle, no_date=no_date, $
	scan_id=scan_id, param=param, $
	date=date, time=time

common rad_data_blk

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	return

if n_elements(title) eq 0 then $
	title = ''

if n_elements(subtitle) eq 0 then $
	subtitle = ''

if strlen(title) eq 0 then $
	title = 'SUPERDARN PARAMETER PLOT'

if ~keyword_set(param) then $
	param = get_parameter()

fitstr = 'N/A'
if (*rad_fit_info[data_index]).fitex then $
	fitstr = 'fitEX'

if (*rad_fit_info[data_index]).fitacf then $
	fitstr = 'fitACF'

if (*rad_fit_info[data_index]).fit then $
	fitstr = 'fit'

if (*rad_fit_info[data_index]).filtered then $
	filterstr = 'filtered ' $
else $
	filterstr = ''

if strlen(subtitle) eq 0 then begin
	if (*rad_fit_info[data_index]).nrecs gt 0L then $
		subtitle = (*rad_fit_info[data_index]).name+': '+param+' ('+filterstr+fitstr+')' $
	else $
		subtitle = 'No data loaded.'
endif

if keyword_set(no_date) then begin
	right_title = ''
	right_subtitle = ''
endif else begin
	if keyword_set(date) and keyword_set(time) then $
		sfjul, date, time, sjul, fjul $
	else begin
		sjul = (*rad_fit_info[data_index]).sjul
		fjul = (*rad_fit_info[data_index]).fjul
	endelse
	sfjul, sdate, stime, sjul, /jul_to
	sfjul, fdate, ftime, fjul, /jul_to
	if ftime eq 0 then $
		fdate = sdate
	right_title = ''
	right_subtitle = format_juldate(sjul, /date)
	if sdate ne fdate and ftime gt 5 then $
		right_subtitle += ' - '+format_juldate(fjul, /date)
endelse

plot_title, title, subtitle, top_right_title=right_title, top_right_subtitle=right_subtitle

end
