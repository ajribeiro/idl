;+ 
; NAME: 
; SET_WINDOWSIZE
; 
; PURPOSE: 
; This function sets the currently active window size. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_WINDOWSIZE, windowsize
;
; INPUTS:
; Windowsize: A value to use as the currently active window size.
;
; COMMON BLOCKS:
; USER_PREFS: The common block holding user preferences.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro set_windowsize, windowsize

common user_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Windowsize.'
	return
endif

if size(windowsize, /type) eq 7 then begin
	prinfo, 'Windowsize must numeric.'
	return
endif

up_windowsize = windowsize

end
