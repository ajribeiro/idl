pro insert_copyright, filename=filename, dir=dir, silent=silent

if ~keyword_set(filename) and ~keyword_set(dir) then begin
	prinfo, 'Must provide filename of directory.'
	return
endif

if keyword_set(dir) then begin
	if ~file_test(dir) then begin
		prinfo, 'Input directory does not exist: '+dir
		return
	endif
	filename = file_search(dir, '*.pro')
endif

tmp = where(strlen(filename) gt 0L, nfiles)
if nfiles lt 1 then begin
	prinfo, 'No files found.'
	return
endif

nwl = string(13b)+string(10b)

copynotice = $
'; COPYRIGHT:' + nwl + $
'; Non-Commercial Purpose License' + nwl + $
'; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University' + nwl + $
'; All rights reserved.' + nwl + $
'; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT' + nwl + $
'; software and its associated documentation (“Software”). You should carefully read the' + nwl + $
'; following terms and conditions before using this software. Your use of this Software' + nwl + $
'; indicates your acceptance of this license agreement and all terms and conditions.' + nwl + $
'; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-' + nwl + $
'; Commercial Purpose means the use of the Software solely for research. Non-' + nwl + $
'; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or' + nwl + $
'; in any way in connection with a product or service which is sold, offered for sale,' + nwl + $
'; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this' + nwl + $
'; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the' + nwl + $
'; following terms of this license.' + nwl + $
'; Copies and Modifications' + nwl + $
'; You must include the above copyright notice and this license on any copy or modification' + nwl + $
'; of this compilation. Each time you redistribute this Software, the recipient automatically' + nwl + $
'; receives a license to copy, distribute or modify the Software subject to these terms and' + nwl + $
'; conditions. You may not impose any further restrictions on this Software or any' + nwl + $
'; derivative works beyond those restrictions herein.' + nwl + $
'; You agree to use your best efforts to provide Virginia Polytechnic Institute and State' + nwl + $
'; University (Virginia Tech) with any modifications containing improvements or' + nwl + $
'; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and' + nwl + $
'; distribute such modifications under the terms of this license. You agree to notify' + nwl + $
'; Virginia Tech of any inquiries you have for commercial use of the Software and/or its' + nwl + $
'; modifications and further agree to negotiate in good faith with Virginia Tech to license' + nwl + $
'; your modifications for commercial purposes. Notices, modifications, and questions may' + nwl + $
'; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.' + nwl + $
'; Commercial Use' + nwl + $
'; If you desire to use the software for profit-making or commercial purposes, you agree to' + nwl + $
'; negotiate in good faith a license with Virginia Tech prior to such profit-making or' + nwl + $
'; commercial use. Virginia Tech shall have no obligation to grant such license to you, and' + nwl + $
'; may grant exclusive or non-exclusive licenses to others. You may contact Stephen' + nwl + $
'; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.' + nwl + $
'; Governing Law' + nwl + $
'; This agreement shall be governed by the laws of the Commonwealth of Virginia.' + nwl + $
'; Disclaimer of Warranty' + nwl + $
'; Because this software is licensed free of charge, there is no warranty for the program.' + nwl + $
'; Virginia Tech makes no warranty or representation that the operation of the software in' + nwl + $
'; this compilation will be error-free, and Virginia Tech is under no obligation to provide' + nwl + $
'; any services, by way of maintenance, update, or otherwise.' + nwl + $
'; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”' + nwl + $
'; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR' + nwl + $
'; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED' + nwl + $
'; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS' + nwl + $
'; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF' + nwl + $
'; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,' + nwl + $
'; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR' + nwl + $
'; CORRECTION.' + nwl + $
'; Limitation of Liability' + nwl + $
'; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY' + nwl + $
'; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE' + nwl + $
'; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,' + nwl + $
'; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR' + nwl + $
'; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS' + nwl + $
'; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED' + nwl + $
'; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE' + nwl + $
'; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY' + nwl + $
'; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.' + nwl + $
'; Use of Name' + nwl + $
'; Users will not use the name of the Virginia Polytechnic Institute and State University nor' + nwl + $
'; any adaptation thereof in any publicity or advertising, without the prior written consent' + nwl + $
'; from Virginia Tech in each case.' + nwl + $
'; Export License' + nwl + $
'; Export of this software from the United States may require a specific license from the' + nwl + $
'; United States Government. It is the responsibility of any person or organization' + nwl + $
'; contemplating export to obtain such a license before exporting.' + nwl + $
';'

for f=0, nfiles-1 do begin
	line = ''
	in_comment = !false
	doc_found  = !false
	cr_printed = !false
	openr, ilun, filename[f], /get_lun
	ofile = file_dirname(filename[f])+'/cp.tmp'
	openw, olun, ofile, /get_lun
	while ~EOF(ilun) do begin
		readf, ilun, line
		if strpos(line, ';-') ne -1 and in_comment ne -1 then begin
			in_comment = !false
			printf, olun, line
		endif else if strpos(line, ';+') ne -1 then begin
			in_comment = !true
			doc_found  = !true
			printf, olun, line
		endif else if strpos(line, '; EXAMPLE') ne -1 and in_comment then begin
			printf, olun, line
			while !true do begin
				readf, ilun, line
				if strlen(line) le 3 then begin
					printf, olun, line
					printf, olun, copynotice
					cr_printed = !true
					break
				endif
				printf, olun, line
			endwhile
		endif else if strpos(line, '; COPYRIGHT') ne -1 and in_comment then begin
			while !true do begin
				readf, ilun, line
				if strlen(line) le 3 then begin
					break
				endif
			endwhile
		endif else begin
			printf, olun, line
		endelse
	endwhile
	free_lun, ilun
	free_lun, olun
	if in_comment then $
		print, filename[f]+': File has no closing comment tag.'
	if ~doc_found then $
		print, filename[f]+': File has no documentation.' $
	else if ~cr_printed then $
		print, filename[f]+': Copyright not printed.' $
	else begin
		; file_copy, filename[f], filename[f]+'.bkp', /overwrite
		file_copy, ofile, filename[f], /overwrite
		if ~keyword_set(silent) then $
			print, filename[f]+': Copyright inserted.'
	endelse
	file_delete, ofile
endfor

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
end
