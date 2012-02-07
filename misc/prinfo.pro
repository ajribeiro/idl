;+ 
; NAME: 
; PRINFO
; 
; PURPOSE: 
; This procedure prints information to the standard output, i.e. the window
; in which IDL runs. The message is prefaced by the procedure/function in which PRINFO was
; called and is shorted if it is longer than
; GETENV('RAD_DISPLAY_CHAR_WIDTH').
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; PRINFO, Message
;
; INPUTS:
; Str_message: A string containing the message you want to display.
;
; OPTIONAL INPUTS:
; Filename: Use this input to supply a filename is messages like "File not found:
; somedir/someotherdir/somefilename.dat".
;
; KEYWORD PARAMETERS:
; FORCE: Set this to prevent message shortening.
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
; Written by: Lasse Clausen, 2009
;-
pro prinfo, str_message, filename, force=force

if n_params() lt 1 then begin
	prinfo, 'Must give Str_message.'
	return
endif

routs = scope_traceback()
nrouts = n_elements(routs)
if nrouts lt 2 then $
	caller = (strsplit(routs[nrouts-1], ' ',/extract))[0] $
else $
	caller = (strsplit(routs[nrouts-2], ' ',/extract))[0]
pre_message = '% '+caller+': '

if n_params() lt 2 then $
	filename = ''

pnum = strlen(pre_message)
snum = strlen(str_message)
fnum = strlen(filename)
cnum = fix(getenv('RAD_DISPLAY_CHAR_WIDTH'))

mnum = pnum+snum+fnum

if mnum gt cnum and ~keyword_set(force) then begin
	if fnum gt 0 then begin
		rnum = cnum-(pnum+snum+5)
		tot_message = pre_message+str_message+$
			strmid(filename,0,floor(rnum/3.))+'[...]'+strmid(filename, fnum-ceil(rnum*2./3.))
	endif else begin
		rnum = cnum-(pnum+5)
		tot_message = pre_message+$
			strmid(str_message,0,floor(rnum/3.))+'[...]'+strmid(str_message, snum-ceil(rnum*2./3.))
	endelse
endif else if mnum lt cnum then begin
	tot_message = pre_message+strjoin(replicate(' ',((cnum-mnum)/2) > 1))+str_message+filename
endif else $
	tot_message = pre_message+str_message+filename

print, tot_message

end

; verizon
; 301 282 0539
; 747726585
; 888 762 3585
