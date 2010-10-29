;+ 
; NAME: 
; GET_BACKGROUND
; 
; PURPOSE: 
; This function returns the color index of the background color. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_BACKGROUND()
;
; OUTPUTS:
; This function returns the color index of the background color.
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
function get_background

common color_prefs

return, cp_background

end
