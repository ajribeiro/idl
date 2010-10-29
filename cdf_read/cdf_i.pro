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
