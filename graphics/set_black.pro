;+ 
; NAME: 
; SET_BLACK
; 
; PURPOSE: 
; This function sets the color index of the color black.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_BLACK, Black
;
; INPUTS:
; Black: A value to use as the color index of the color black.
;
; COMMON BLOCKS:
; COLOR_PREFS: The common block holding user preferences.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro set_black, black

common color_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Black.'
	return
endif

if size(black, /type) eq 7 then begin
	prinfo, 'Black must numeric.'
	return
endif

cp_black = black

end
