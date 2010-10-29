;+ 
; NAME: 
; SET_EDITOR
; 
; PURPOSE: 
; This function sets the currently active command for the editor. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_EDITOR, Editor_command
;
; INPUTS:
; Editor_command: The  command for the currently active editor.
;
; COMMON BLOCKS:
; USER_PREFS: The common block holding user preferences.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro set_editor, editor_command

common user_prefs

; check if command can is there
spawn, 'which '+editor_command, e1, e2, exit_status=es
if es eq 1 then begin
	prinfo, 'Cannot set editor. Command not found: '+editor_command
	up_editor = ''
endif else $
	up_editor = strtrim(editor_command, 2)

end
