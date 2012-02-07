;+ 
; NAME: 
; PRI 
; 
; PURPOSE: 
; This procedure prints information about the procedure/function
; Routine_name, if such a procedure/function exists. The procedure/function
; must be written in IDL, it will not work on built-in IDL functions not written
; in IDL. If no procedure/function
; if found that matches Routine_name exactly, all procedures/functions which
; have Routine_name as a part of their name are printed.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; PRI, Routine_name
; 
; INPUTS: 
; Routine_name: A string containing the name of the procedure/function
; to query.
; 
; KEYWORD PARAMETERS:
; USAGE: Set this keyword to a named variable that will contain information
; about the usage of the procedure/function. If this keyword is set
; PRI will not print any information on the sreen.
;
; SOURCE_FILE: Set this keyword to a named variable that will contain
; the full path top the source file of the procedure/function. If this keyword is set
; PRI will not print any information on the sreen.
;
; NO_COMPILE: Set this keyword to prevent PRI from trying to resolving/compiling
; the procedure/function. Bear in mind that PRI only finds compiled 
; procedures/functions.
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
pro pri, routine_name, usage=usage, source_file=source_file, $
	no_compile=no_compile

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Routine_name.'
	return
endif
if size(routine_name, /type) ne 7 then begin
	prinfo, 'Routine_name must be of type string.'
	return
endif

; set this up such that no message is printed if any
; of the following keywords are set.
if arg_present(usage) or arg_present(source_file) then $
	donotdisplay = 1b $
else $
	donotdisplay = 0b

; we'll try and resolve the routine is it is not
; compiled yet
try_compile = 1b
if keyword_set(no_compile) then $
	try_compile = 0b

; what happens is this:
;
; IDL distinguishes between routines and functions.
; Function return something, routines don't.
; When using the IDL routine RESOLVE_ROUTINE, we'll 
; need to know whether the routine to resolve
; is a function or a procedure.
; We don't know that, hence be establish an error handler
; and try first for a routine and then for a function
; If both fails, we know that the routines doesn't exist.
; But we don't go home just yet, instead we'll try the
; IDL function ROUTINE_INFO (again with procedure and function)
; and if that fails, we'll just look through all compile
; routines to see if we find routines which name contains
; Routine_name.
; 
; If the resolving phase is skipped, because NO_COMPILE is 
; set, we need to find whether it is a function or procedure
; when trying to get the inputs, keywords, etc.

; start off by assuming it is not a function
func = 0b
error_count = 0

; try to resolve/compile the routine
; Establish error handler. When an errors occurs,
; program control resumes after this command
catch, error_status

;This statement begins the error handler:
if error_status ne 0 then begin
;	print, !ERROR_STATE.MSG
	error_count = error_count + 1
	; both routine and function have not worked
	; hence we know no such routine exists.
	; But we'll continue anyway
	if error_count gt 1 then begin
		print, 'Routine "'+routine_name+'" cannot be compiled.'
		catch, /cancel
		try_compile = 0b
	endif
	func = 1b
endif
if try_compile then $
	; can't handle self-compiling stuff
	if ~strcmp(routine_name, 'pri', /fold_case) then $
		resolve_routine, routine_name, is_function=func, /no_recompile
; earse error handler
catch, /cancel

; if routine was compiled, we know
; whether is is function or procedure
; no nedd to go through that again
if ~try_compile then $
	func = 0b
error_count = 0

; Establish error handler. When errors occurs, 
; program control resumes after this command
catch, Error_status

;This statement begins the error handler:  
IF Error_status NE 0 THEN BEGIN
;	print, !ERROR_STATE.MSG
	error_count = error_count + 1
	; ROUTINE_INFO failed twice, hence
	; we definitively know it doesn't exist.
	; so we loop through all compiled routines and try and find
	; routines with similar names.
	if error_count gt 1 then begin
		help, /routines, /procedures, output=routs
		help, /routines, /functions, output=funcs
		comp_found = 0b
		for i=2, n_elements(routs)-1L do begin
			arout = strmid(routs[i], 0, (strpos(routs[i], ' '))[0])
			if strpos(arout, strupcase(routine_name)) ne -1 then begin
				comp_found = 1b
				print, 'Similar routine found: ', $
					strmid(routs[i], 0, strpos(routs[i],' '))
			endif
		endfor
		for i=2, n_elements(funcs)-1L do begin
			afunc = strmid(funcs[i], 0, (strpos(funcs[i], ' '))[0])
			if strpos(afunc, strupcase(routine_name)) ne -1 then begin
				comp_found = 1b
				print, 'Similar function found: ', $
					strmid(funcs[i], 0, strpos(funcs[i],' '))
			endif
		endfor
		if ~comp_found then begin
			print, 'Cannot find procedure/function: '+routine_name
		endif
		catch, /cancel
		return
	endif
	func = 1b
ENDIF
; get info on procedure/function
aa = routine_info(routine_name, /parameter, func=func)

; earse error handler
catch, /cancel
; get source file of procedure/function
bb = routine_info(routine_name, /source, func=func)

; assemble output string
if func then begin
	str_func = 'Result = '
endif else begin
	str_func = ''
endelse
str_op_brack = ''
str_args = ''
str_jner = ''
str_keyw = ''
str_cl_brack = ''

; assemble arguments
if aa.num_args ne 0 then begin
	if func then begin
		str_op_brack = '('
		str_cl_brack = ')'
	endif else begin
		str_op_brack = ', '
		str_cl_brack = ''
	endelse
	str_args = strjoin(aa.args, ', ')
endif

; and keywords
if aa.num_kw_args ne 0 then begin
	tmp = transpose([[aa.kw_args], [aa.kw_args]])
	str_keyw = strjoin(strjoin(tmp, '='), ', ')
	str_jner = ', '
endif

; put together usage string
usage = str_func + strupcase(routine_name) + $
	str_op_brack + str_args + str_jner + str_keyw + str_cl_brack
source_file = bb.path

; return if no output is wanted
if donotdisplay then $
	return

; print some information
print, '+---+'
print, (func ? 'Function ' : 'Procedure '), strupcase(routine_name)
print, 'Usage: '
print, '  '+usage
print, 'Source: '
print, '  '+source_file
print, '+---+'

end
