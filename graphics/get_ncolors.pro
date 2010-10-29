;+ 
; NAME: 
; GET_NCOLORS
; 
; PURPOSE: 
; This function returns the number of colors used in the radar colorbar. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_NCOLORS()
;
; OUTPUTS:
; This function returns the number of colors used in the radar colorbar.
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
function get_ncolors

common color_prefs

return, cp_ncolors

end
