;+ 
; NAME: 
; GET_PARAMETER
; 
; PURPOSE: 
; This function returns the currently active radar parameter. 
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; Result = GET_PARAMETER()
;
; OUTPUTS:
; This function returns the currently active radar parameter.
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
function get_parameter

common user_prefs

return, up_parameter

end
