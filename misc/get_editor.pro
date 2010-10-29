;+ 
; NAME: 
; GET_EDITOR
; 
; PURPOSE: 
; This function returns the currently active command for the editor. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_EDITOR()
;
; OUTPUTS:
; This function returns the currently active command for the editor.
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
function get_editor

common user_prefs

return, up_editor

end
