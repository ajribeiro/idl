;+ 
; NAME: 
; SET_BOTTOM
; 
; PURPOSE: 
; This function sets the the first index in the system color table to use 
; for plotting. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_BOTTOM, Bottom
;
; INPUTS:
; Bottom: A value to use the first index in the system color table to use 
; for plotting. 
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
pro set_bottom, bottom

common color_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Bottom.'
	return
endif

if size(bottom, /type) eq 7 then begin
	prinfo, 'Bottom must numeric.'
	return
endif

cp_bottom = bottom

end
