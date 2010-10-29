;+ 
; NAME: 
; GET_GRAY
; 
; PURPOSE: 
; This function returns the color index of the color gray. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_GRAY()
;
; OUTPUTS:
; This function returns the color index of the color gray. 
;
; COMMON BLOCKS:
; COLOR_PREFS: The common block holding color preferences.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
function get_gray

common color_prefs

return, cp_gray

end
