;+ 
; NAME: 
; SET_BACKGROUND
; 
; PURPOSE: 
; This function sets color index of the background color. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_BACKGROUND, Background
;
; INPUTS:
; Background: A value to use as the color index of the background color. 
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
pro set_background, background

common color_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Background.'
	return
endif

if size(bottom, /type) eq 7 then begin
	prinfo, 'Background must numeric.'
	return
endif

cp_background = background

end
