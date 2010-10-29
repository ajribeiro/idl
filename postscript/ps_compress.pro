;+ 
; NAME: 
; PS_COMPRESS
; 
; PURPOSE: 
; This procedure calles GZip to compress a PostScript file. This procedure was written
; because PostScript files - being ASCII files - tend to get very large. In principle,
; however, you can compress any file type with this procedure.
; 
; CATEGORY: 
; PostScript
; 
; CALLING SEQUENCE: 
; PS_COMPRESS, Filename
;
; INPUTS:
; Filename: The full filename (including path) of the file to compress. If no filename
; is supplied, The file given in the Ps_info common block is compressed - if it exists.
;
; KEYWORD PARAMETERS:
; SILENT: Set this keyword to surpress messages about the closed file.
;
; OVERWRITE: Set this keyword to force overwriting of the .gz file. If this keyword is
; not set and a file called Filename.gz already exists, it will not be overwritten.
;
; SILENT: Set this keyword to surpress messages.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2007.
;-
pro ps_compress, filename, overwrite=overwrite, silent=silent

if n_params() eq 0 then $
	filename = ps_get_filename()

if ~file_test(filename) then begin
	prinfo, 'Cannot find file: ', filename
	return
endif

if ~keyword_set(overwrite) and file_test(filename+'.gz') then begin
	prinfo, 'File exists, will not overwrite.'
	return
endif

spawn, 'gzip --force -9 '+filename, exit_status=es
if es ne 0 then begin
	prinfo, 'Cannot compress file: ', filename
	return
endif

if ~keyword_set(silent) then $
	prinfo, 'Compressed ', filename

end
