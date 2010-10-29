;+ 
; NAME: 
; SET_MINCHARSIZE
; 
; PURPOSE: 
; This function sets the currently active minimum charsize. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_MINCHARSIZE, Mincharsize
;
; INPUTS:
; Mincharsize: A value to use as the currently active minimum charsize.
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
pro set_mincharsize, mincharsize

common user_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Mincharsize.'
	return
endif

if size(mincharsize, /type) eq 7 then begin
	prinfo, 'Mincharsize must numeric.'
	return
endif

up_mincharsize = mincharsize

end
