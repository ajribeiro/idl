;+ 
; NAME: 
; RAD_GET_BEAM
; 
; PURPOSE: 
; This function returns the currently active beam.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; Result = RAD_GET_BEAM()
;
; OUTPUTS:
; This function returns the currently active beam.
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
function rad_get_beam

common user_prefs

return, up_beam

end
