;+ 
; NAME: 
; GET_MINCHARSIZE
; 
; PURPOSE: 
; This function returns the currently active minimum charsize. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_MINCHARSIZE()
;
; OUTPUTS:
; This function returns the currently minimum charsize.
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
function get_mincharsize

common user_prefs

return, up_mincharsize

end
