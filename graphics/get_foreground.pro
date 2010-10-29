;+ 
; NAME: 
; GET_FOREGROUND
; 
; PURPOSE: 
; This function returns the color index of the foreground color. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_FOREGROUND()
;
; OUTPUTS:
; This function returns the color index of the foreground color.
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
function get_foreground

common color_prefs

return, cp_foreground

end
