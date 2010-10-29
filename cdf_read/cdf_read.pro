;+ 
; NAME: 
; CDF_READ 
; 
; PURPOSE: 
; This function reads data from a CDF (Common Data Format) file. It is 
; a convenience wrapper for the CDF routines IDL provides.
;
; In CDF files the data is arrange in blocks that have names. In order to
; read the data you want, you have to provide the name of the block, i.e. 
; the variable name.
; 
; CATEGORY: 
; Input/Output 
; 
; CALLING SEQUENCE: 
; Result = CDF_READ(Filename, Variable_Names)
; 
; INPUTS: 
; Filename: The full filename (including the path) of the CDF file from which 
; the data 
; will be read
; 
; Variable_Names: An scalar string or array of strings that holds the names
; of the variables which will be read from the CDF file. THESE ARE CASE SENSITIVE!
; 
; KEYWORD PARAMETERS: 
; TAGNAMES: Set the keyword to an array of strings that will be the names of
; the tags in the returned data structure.
; 
; FILLVAL: Set this keyword to a value used as the fill value for undefined
; values in the CDF file.
;
; READ_VARIABLES: Set this to an variable name that will upon completion 
; contain the names of the variables that were actually read.
;
; SILENT: Set this keyword to surpress any warning messages.
; 
; OUTPUTS:
; The function returns a structure which holds the data. The data is arranged
; in tags named after the variable names that were read, 
; or, if the TAGNAMES keyword is set, named after the TAGNAMES.
; 
; EXAMPLE: 
; Use CDF_READ to read magnetic field data and epoch times measured by the 
; DoubleStar satellites from a CDF file downloaded from the Cluster Active Archive
; 
; dir  = '/home/lbnc/data/doublestar/2006/'
; file = 'T1_PP_FGM_20060925_V01.cdf'
; vars = ['Epoch__T1_PP_FGM','L_gse_xyz','B_xyz_gse__T1_PP_FGM']
; data = CDF_READ(dir+file, vars)
; help, data, /structure
;   ** Structure <a0e6b8>, 3 tags, length=441048, data length=441041, refs=1:
;   EPOCH__T1_PP_FGM
;                   DOUBLE    Array[1, 22051]
;   L_GSE_XYZ       BYTE      Array[7, 3]
;   B_XYZ_GSE__T1_PP_FGM
;                   FLOAT     Array[3, 22051]
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2007
;-
function cdf_read, filename, variable_names, $
	tagnames=tagnames, $
	read_variables=read_variables, $
	fillval=fillval, silent=silent

oquiet = !quiet
if keyword_set(silent) then $
	!quiet = 1

catch, error_status

;This statement begins the error handler:  
if error_status ne 0 then begin
	prinfo, !ERROR_STATE.MSG+' - '+!err_string
	if n_elements(cid) gt 0 then begin
		if cid gt 0L then $
			cdf_close, cid
	endif
	catch, /cancel
	return, -1
endif  

varget_count = n_elements(variable_names)
if varget_count lt 1 then begin
		prinfo, 'Give variable names.'
	return, -1
endif

varnames = replicate('-1', varget_count)
iszvars = replicate(-1, varget_count)
fillval = replicate(0.0, varget_count)
rec_counts = replicate(-1L, varget_count)

if file_test(filename, /dir) then begin
	filename = dialog_pickfile(path=filename)
	if strcmp(filename, '') then begin
		prinfo, 'No file selected. Exit.'
		return, -1
	endif
endif

f = file_test(filename, /regular)
if f eq 0 then begin
	prinfo, 'File not found: '+filename
	return, -1
endif

cid = cdf_open(filename)

cdf_inq_res = cdf_inquire(cid)

for j=0, varget_count-1 do begin
	for i=0, cdf_inq_res.nvars-1 do begin
		var_inq = cdf_varinq(cid, i)
		if strcmp(var_inq.name, variable_names[j]) eq 1 then begin
			;cdf_attget, cid, 'FILLVAL', i, value
			;fillval[j] = value
			cdf_control, cid, variable=i, get_var_info=var_info;, set_padvalue=-1e30
			iszvars[j] = 0
			varnames[j] = variable_names[j]
			rec_counts[j] = var_info.maxrec+1L
		endif
	endfor

	for i=0, cdf_inq_res.nzvars-1 do begin
		var_inq = cdf_varinq(cid, i, /zvariable)
		if strcmp(var_inq.name, variable_names[j]) eq 1 then begin
			;cdf_attget, cid, 'FILLVAL', i, value, /zvariable
			;fillval[j] = value
			cdf_control, cid, variable=i, get_var_info=var_info, /zvariable;, set_padvalue=-1e30
			iszvars[j] = 1
			varnames[j] = variable_names[j]
			rec_counts[j] = var_info.maxrec+1L
		endif
	endfor
endfor

ninds = where(strcmp(varnames,'-1'), ncount, complement=inds, ncomplement=count)
if ncount ne 0 then begin
	if ~keyword_set(silent) then begin
		prinfo, 'The following variable names were not found in '+filename
		for i=0, ncount-1 do $
			prinfo, '   '+variable_names[ninds[i]]
	endif
	if ncount eq varget_count then begin
		prinfo, 'No variable can be read. Exit.'
		cdf_close, cid
		return, -1
	endif
endif
varget_count = count
varnames   = varnames[inds]
iszvars    = iszvars[inds]
fillval    = fillval[inds]
rec_counts = rec_counts[inds]
read_variables = variable_names[inds]

if ~keyword_set(tagnames) then $
	tagnames = varnames $
else begin
	if n_elements(tagnames) ne varget_count then begin
		if ~keyword_set(silent) then begin
			prinfo, 'Number of tagnames not equal to variable count.'
			prinfo, 'Cannot use tagnames.'
		endif
		tagnames = varnames
	endif
endelse

for j=0, varget_count-1 do begin
	cdf_control, cid, variable=varnames[j];, set_padvalue=-1e30
;	print, varnames[j], iszvars[j],rec_counts[j]
	if rec_counts[j] lt 1L then begin
		if ~keyword_set(silent) then $
			prinfo, 'REC_COUNT of '+varnames[j]+' is zero. Skipping '+varnames[j]
		s=execute('data_'+string(j,format='(I02)')+'=-1.')
		continue
	endif
	cdf_varget, cid, varnames[j], data, zvariable=iszvars[j], rec_count=rec_counts[j]
	s=execute('data_'+string(j,format='(I02)')+'=data')
endfor

cdf_close, cid

if varget_count eq 1 then begin
	str = 'ret_struc = {'+idl_validname(tagnames[0], /convert_all)+': data_00}'
endif else begin
	for j=0, varget_count-1 do begin
		if j eq 0 then $
			str = 'ret_struc = {' + idl_validname(tagnames[j], /convert_all)+': data_'+$
				string(j,format='(I02)')+', ' $
		else if j eq varget_count-1 then $
			str = str + idl_validname(tagnames[j], /convert_all)+': data_'+$
				string(j,format='(I02)')+'}' $
		else $
			str = str + idl_validname(tagnames[j], /convert_all)+': data_'+$
				string(j,format='(I02)')+', '
	endfor
endelse
s=execute(str)

!quiet = oquiet

return, ret_struc

end
