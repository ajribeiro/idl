;+ 
; NAME: 
; LIST_COMMON 
; 
; PURPOSE: 
; This procedure lists all variables in a common block. It achieves that by 
; 1) using scope_varname function or for fuller description 2) parsing through 
; the output of help, names='*'
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; LIST_COMMON, Block_name
; 
; INPUTS: 
; Block_name: A string containing the name of the common block.
; 
; KEYWORD PARAMETERS: 
; FULL: Set this keyword to force a fuller description of the variables.
;
; LIST: Set this keyword to list all common blocks.
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
pro list_common, block_name, full=full, list=list

if keyword_set(list) then begin
	; get all variable names on $MAIN$ level
	help, names='*', output=out, level=1
	parsed_blocks = ''
	nparsed_blocks = 0
	nn = n_elements(out)
	; cycle through all variable names, looking 
	; for the opening parantheses which indicate
	; whether a variable belongs to a common block
	; if we find such a paratheses, we know we've
	; found a common block.
	for i=0L, nn-1L do begin
		if (pos=strpos(out[i], '(')) ne -1 then begin
			block_name = strmid(out[i], pos+1, strpos(out[i],')')-pos-1)
			inds = where(parsed_blocks eq block_name)
			if inds[0] eq -1 then begin
				if nparsed_blocks eq 0 then $
					parsed_blocks = block_name $
				else $
					parsed_blocks = [parsed_blocks, block_name]
				nparsed_blocks += 1
				if keyword_set(full) then $
					list_common, block_name $
				else $
					print, '  '+block_name
			endif
		endif
	endfor
	return
endif

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Block_name.'
	return
endif
if size(block_name, /type) ne 7 then begin
	prinfo, 'Block_name. must be of type string.'
	return
endif

_block_name = strupcase(block_name)

; try to include common block
; if it doesn't exist, this produces an error
dd = execute('common '+_block_name, 1, 1)
if dd ne 1 then begin
    prinfo, 'Common block '+_block_name+' does not exist'
    return
endif

print, '+---+'
print, 'Common block '+_block_name+' contains:'
print, '+---+'

; the "easy" solution
if ~keyword_set(full) then begin
    vars = scope_varname(common=_block_name)
    vars = vars[sort(vars)]
    for i=0, n_elements(vars)-1 do $
    	print, vars[i], format='(A20)'
    return
endif

; the "hard" way
; parsing through output using regular expressions
chars = '[a-zA-Z_0-9]'
ext_chars = '[][ a-zA-Z_0-9<>'+"'"+'-,]'
help, names='*', output=out
nn = n_elements(out)

varname_regex   = '('+chars+'+) +'
varcommon_regex = '\('+block_name+'\)'
vardef_regex    = '('+chars+'+) += +(-> +)?('+ext_chars+'+)'

global_regex = '^'+varname_regex+varcommon_regex+' +'+vardef_regex
varnc_regex = '^'+varname_regex+varcommon_regex

got_all = 0
varname_found = 0
for i=0L, nn-1L do begin
	pos = stregex(out[i], global_regex, length=length, /subexpr)
	if pos[0] eq -1 then begin
		pos = stregex(out[i], varnc_regex, length=length, /subexpr)
		if pos[0] eq -1 then begin
			pos = stregex(out[i], '^ +'+vardef_regex, length=length, /subexpr)
			if pos[0] eq -1 then begin
			endif else begin
				vartype = strmid(out[i], pos[1], length[1])
				varvalu = strmid(out[i], pos[3], length[3])
				if varname_found eq 1 then got_all = 1
			endelse
		endif else begin
			varname = strmid(out[i], pos[1], length[1])
			varname_found = 1
		endelse
	endif else begin
		varname = strmid(out[i], pos[1], length[1])
		vartype = strmid(out[i], pos[2], length[2])
		varvalu = strmid(out[i], pos[4], length[4])
		got_all = 1
	endelse
	if got_all eq 1 then begin
		print, varname, vartype, varvalu, format='(A20,3X,A-10,3X,A-30)'
		varname_found = 0
	endif
	got_all = 0
endfor

end
