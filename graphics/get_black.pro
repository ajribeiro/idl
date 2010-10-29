;+ 
; NAME: 
; GET_BLACK
; 
; PURPOSE: 
; This function returns the color index of the color black. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_BLACK()
;
; OUTPUTS:
; This function returns the color index of the color black. 
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
function get_black

common color_prefs

return, cp_black

end
