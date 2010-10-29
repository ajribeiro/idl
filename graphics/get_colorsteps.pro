;+ 
; NAME: 
; GET_COLORSTEPS
; 
; PURPOSE: 
; This function returns the number of steps of colors to use for plotting. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_COLORSTEPS()
;
; OUTPUTS:
; This function returns the number of steps of colors to use for plotting.
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
function get_colorsteps

common color_prefs

return, cp_colorsteps

end
