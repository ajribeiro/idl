;+ 
; NAME: 
; PS_READ_CREATOR
; 
; PURPOSE: 
; This procedure reads a small comment in the header of a PostScript file
; which was put there by PS_WRITE_CREATOR.
; This enables the user to identify the program name that created that
; particular PostScript.
; 
; CATEGORY: 
; PostScript
; 
; CALLING SEQUENCE: 
; PS_READ_CREATOR, Filename
;
; INPUTS:
; Filename: The full filename (including path) of the PostScript file in which
; to look for the header.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2007.
;-
pro ps_read_creator, filename, dialog=dialog

if keyword_set(dialog) then begin
    if size(dialog, /type) eq 7 then $
    	if file_test(dialog, /dir) then $
    	    start_path = dialog $
    else $
    	start_path = ''
    filename = dialog_pickfile(/read, filter='*.ps', path=start_path)
endif

if n_elements(filename) ne 1 then $
	filename = ps_get_filename()

openr, fin, filename, /get_lun, error=ioerr
if ioerr ne 0 then begin
    prinfo, 'Could not open file: '+filename
    return
end

found = !false
line = ''
; looking for the following line in the PostScript header
; %%Creator: IDL Version ...
while ~eof(fin) do begin
    readf, fin, line
    if strmatch(line, '%%CreatorScript:*') then begin
    	found = !true
    	tmp = strsplit(line, ':', /extract)
		if n_elements(tmp) lt 2 then begin
			print, 'Something is wrong:'
			print, line
			break
		endif
		tmp2 = strsplit(tmp[1], ' ', /extract)
		if n_elements(tmp2) lt 3 then begin
			print, 'Something is wrong:'
			print, line
			break
		endif
		prinfo, 'Created by: '+tmp2[0]
		print, 'Line: '+tmp2[1]
		print, 'File: '+tmp2[2]
    endif
endwhile
free_lun, fin

if ~found then $
    prinfo, 'CreatorScript comment could not be found.'

end
