;+ 
; NAME: 
; CDF_I
; 
; PURPOSE: 
; This function reads some of the data attributes of a CDF (Common Data Format)
; file. It is by no means complete and should only be used to get the 
; variable names which are needed for using CDF_READ.
; 
; CATEGORY: 
; Input/Output 
; 
; CALLING SEQUENCE: 
; Result = CDF_I(Filename)
; 
; INPUTS: 
; Filename: The full filename (including path) of the CDF file to be inspected.
; 
; KEYWORD PARAMETERS: 
; SILENT: Set this keyword to surpress output of error messages.

; VARIABLES: Set this keyword to a named variable which will contain the names
; of all variables present in the CDF file.
;
; ZVARIABLES: Set this keyword to a named variable which will contain the names
; of all z-variables present in the CDF file.
; 
; OUTPUTS: 
; The function returns 1 if the information was read successfully, -1 if an 
; error occurred.
; 
; EXAMPLE: 
; Display the variables and z-variables of a CDF file.
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
; dir  = '/home/lbnc/data/doublestar/2006/'
; file = 'T1_PP_FGM_20060925_V01.cdf'
; ret = CDF_INFO(dir+file, variables=vars, zvariables=zvars)
; print, vars
; 
; print, zvars
;   Epoch__T1_PP_FGM L_Status L_gse_xyz Half_interval__T1_PP_FGM 
;   Status__T1_PP_FGM B_xyz_gse__T1_PP_FGM L_B_xyz_gseT1_PP_FGM 
;   B_nsigma_t__T1_PP_FGM B_nsigma_b__T1_PP_FGM
;
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2007
;-
function cdf_i, filename, variables=variables, zvariables=zvariables, $
	silent=silent

on_ioerror, error

if not(keyword_set(silent)) then silent=0

if n_params() eq 0 then begin
	filename = dialog_pickfile(path='/home/lbnc/data/')
	if strcmp(filename, '') then begin
		prinfo, 'No file selected. Exit.'
		return, -1
	endif
endif

if file_test(filename, /directory) then begin
	filename = dialog_pickfile(path=filename)
	if strcmp(filename, '') then begin
		prinfo, 'No file selected. Exit.'
		return, -1
	endif
endif

if ~file_test(filename) then begin
	prinfo, 'File not found: '+filename
	return, -1
endif

if ~file_test(filename, /read) then begin
	prinfo, ''+filename+' not readable. Exit.'
	return, -1
endif
print, filename
cid = cdf_open(filename)

cdf_inq_res = cdf_inquire(cid)

if arg_present(variables) then begin
	if cdf_inq_res.nvars gt 0L then begin
		variables  = make_array(cdf_inq_res.nvars, /string)
		for i=0, cdf_inq_res.nvars-1 do begin
			var_inq = cdf_varinq(cid, i)
			variables[i] = var_inq.name
		endfor
	endif else $
		variables = ''
endif

if arg_present(zvariables) then begin
	if cdf_inq_res.nzvars gt 0L then begin
		zvariables = make_array(cdf_inq_res.nzvars, /string)
		for i=0, cdf_inq_res.nzvars-1 do begin
			var_inq = cdf_varinq(cid, i, /zvariable)
			zvariables[i] = var_inq.name
		endfor
	endif else $
		zvariables = ''
endif
goto, good

error:
if ~keyword_set(silent) then begin
	prinfo, 'An error occured. Exit.'
	print, !err_string
	cdf_close, cid
endif
return, -1


good:
cdf_close, cid
return, 1
end
