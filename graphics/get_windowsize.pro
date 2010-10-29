;+ 
; NAME: 
; GET_WINDOWSIZE
; 
; PURPOSE: 
; This function returns the currently active window size. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_WINDOWSIZE()
;
; OUTPUTS:
; This function returns the currently window size.
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
function get_windowsize

common user_prefs

return, up_windowsize

end
