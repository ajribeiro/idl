;+ 
; NAME: 
; SET_FOREGROUND
; 
; PURPOSE: 
; This function sets color index of the foreground color. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_FOREGROUND, Foreground
;
; INPUTS:
; Foreground: A value to use as the color index of the foreground color. 
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
pro set_foreground, foreground

common color_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Foreground.'
	return
endif

if size(foreground, /type) eq 7 then begin
	prinfo, 'Foreground must numeric.'
	return
endif

cp_foreground = foreground

end
