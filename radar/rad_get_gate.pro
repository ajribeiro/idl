;+ 
; NAME: 
; RAD_GET_GATE
; 
; PURPOSE: 
; This function returns the currently active gate.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; Result = RAD_GET_GATE()
;
; OUTPUTS:
; This function returns the currently active gate.
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
function rad_get_gate

common user_prefs

return, up_gate

end
