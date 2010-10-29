;+ 
; NAME: 
; GET_BOTTOM
; 
; PURPOSE: 
; This function returns the first index in the system color table to use 
; for plotting. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_BOTTOM()
;
; OUTPUTS:
; This function returns the irst index in the system color table to use 
; for plotting. 
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
function get_bottom

common color_prefs

return, cp_bottom

end
