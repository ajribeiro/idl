;+ 
; NAME: 
; SET_GRAY
; 
; PURPOSE: 
; This function sets the color index of the color gray.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_GRAY, Gray
;
; INPUTS:
; Gray: A value to use as the color index of the color gray.
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
pro set_gray, gray

common color_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Gray.'
	return
endif

if size(gray, /type) eq 7 then begin
	prinfo, 'Gray must numeric.'
	return
endif

cp_gray = gray

end
