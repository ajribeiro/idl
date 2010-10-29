;+ 
; NAME: 
; RAD_UNZIP_FILE
;
; PURPOSE: 
; This procedure copies Filename to the home directory of the current
; user and - if the file is zipped - unzips it there. 
; This is done to files because in the 
; files need to be unzipped before they can be read and the user
; has write permission in his home directory.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RAD_UNZIP_FILE, Filename
;
; INPUTS:
; Filename: The name of the zipped file.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Steve Milan's READ_FILES.
; Written by Lasse Clausen, Nov, 24 2009
;-
function rad_unzip_file, filename

; Copy the file to be read into the current directory (where hopefully
; the user has write permission) and unzip it if it is zipped

on_ioerror, error_bad

;outdir = getenv('RAD_WWW_DATA_DIR')
;if strlen(outdir) eq 0 then $

outdir = getenv('RAD_TMP_PATH')
if strlen(outdir) eq 0 then $
	outdir = getenv('HOME')
outdir += '/'

if ~file_test(outdir, /dir) then begin
	prinfo,'Cannot find directory to put zipped files.'
	return, ''
endif

; check whether file is zipped
zipped = 0b
file_ending = strmid(filename, strlen(filename)-3)
if strcmp(file_ending, '.gz') then $
	zipped = 1b $
else begin
	file_ending = strmid(filename, strlen(filename)-4)
	if strcmp(file_ending, '.bz2') then $
		zipped = 2b $
	else $
;		return, filename
		file_ending = ''
endelse
unzipped_file = outdir+file_basename(filename, file_ending)
zipped_file = outdir+file_basename(filename)

; if unzipped file exists in cache, use that
;if file_test(unzipped_file) then $
;	return, unzipped_file

; Else copy over from /sd-data and unzip
if zipped eq 0b then begin
	file_copy, filename, unzipped_file, /overwrite
endif else if zipped eq 1b then begin
	file_copy, filename, zipped_file, /overwrite
	SPAWN,'gzip -df '+zipped_file
endif else if zipped eq 2b then begin
	file_copy, filename, zipped_file, /overwrite
	SPAWN,'bzip2 -df '+zipped_file
endif

return, unzipped_file

error_bad:
return, ''

end
