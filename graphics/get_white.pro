;+ 
; NAME: 
; GET_WHITE
; 
; PURPOSE: 
; This function returns the color index of the color white. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_WHITE()
;
; OUTPUTS:
; This function returns the color index of the color white. 
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
function get_white

common color_prefs

return, cp_white

end
