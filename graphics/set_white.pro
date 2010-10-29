;+ 
; NAME: 
; SET_WHITE
; 
; PURPOSE: 
; This function sets the color index of the color white.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_WHITE, White
;
; INPUTS:
; White: A value to use as the color index of the color white.
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
pro set_white, white

common color_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give White.'
	return
endif

if size(white, /type) eq 7 then begin
	prinfo, 'White must numeric.'
	return
endif

cp_white = white

end
