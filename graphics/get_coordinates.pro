;+ 
; NAME: 
; GET_COORDINATES
; 
; PURPOSE: 
; This function returns the currently active coordinate system. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_COORDINATES()
;
; OUTPUTS:
; This function returns the currently coordinate system.
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
function get_coordinates

common user_prefs

return, up_coordinates

end
