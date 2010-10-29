;+ 
; NAME: 
; GET_SCALE
; 
; PURPOSE: 
; This function returns the currently scale. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_SCALE()
;
; OUTPUTS:
; This function returns the currently scale.
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
function get_scale

common user_prefs

return, up_scale

end
