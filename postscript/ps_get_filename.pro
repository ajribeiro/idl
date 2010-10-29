;+ 
; NAME: 
; PS_GET_FILENAME
; 
; PURPOSE: 
; This function returns the filename of the currently active PostScript file. 
; 
; CATEGORY: 
; PostScript
; 
; CALLING SEQUENCE: 
; Result = PS_GET_FILENAME()
;
; OUTPUT:
; This function returns the filename of the currently active PostScript file.
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
function ps_get_filename

common postscript

return, ps_filename

end
