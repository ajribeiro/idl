;+ 
; NAME: 
; PS_GET_ISOPEN
; 
; PURPOSE: 
; This function returns true if a PostScript file is open, false otherwise. 
; 
; CATEGORY: 
; PostScript
; 
; CALLING SEQUENCE: 
; Result = PS_GET_ISOPEN()
;
; OUTPUT:
; This function returns true if a PostScript file is open, false otherwise.
;
; COMMON BLOCKS:
; POSTSCRIPT: A common block holding information about the currently active
; PostScript file.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
function ps_get_isopen

common postscript

return, ps_isopen

end
