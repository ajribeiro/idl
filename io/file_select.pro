;+ 
; NAME: 
; FILE_SELECT
; 
; PURPOSE: 
; This function searches for files mathing a user-defined pattern. If more
; than one file is found matching the pattern, the user is prompted with a menu
; from which to choose a file.
; 
; CATEGORY:
; Input/Output
; 
; CALLING SEQUENCE:
;	Result = FILE_SELECT(Pattern)
;
; INPUTS:
; Pattern: The pattern of the files to search, can include directories and wild cards, see
; IDL documentation of FILE_SEARCH.
;
; KEYWORD PARAMETERS:
; SUCCESS: Set this to a named variable that will contain
; true (1) if a file is found, false (0) if none was 
; found matching pattern
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
function file_select, pattern, success=success, silent=silent, _extra=_extra

f1 = file_search(pattern, count=count, _extra=_extra)

success = !false

if count eq 0 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No file found matching '+pattern
	return, ''
endif

input = ''
select = 0
if count gt 1 then begin
	while !true do begin
		for i=0, count-1 do $
			print, '('+string(i+1,format='(I2)')+') '+f1[i]
		read, input, prompt='Choose file: '
		catch, error_status
		if error_status ne 0 then begin
			print, !ERROR_STATE.MSG
			catch, /cancel
			continue
		endif 
		select = fix(input)
		select -= 1
		if select ge 0 and select lt count then $
			break
	endwhile
endif

success = !true
return, f1[select]

end
