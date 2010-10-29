;+ 
; NAME: 
; SET_NCOLORS
; 
; PURPOSE: 
; This function sets the number of colors used for plotting. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_NCOLORS, Ncolors
;
; INPUTS:
; Ncolors: A value to use as the number of colors used for plotting.
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
pro set_ncolors, ncolors

common color_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Ncolors.'
	return
endif

if size(ncolors, /type) eq 7 then begin
	prinfo, 'Ncolors must numeric.'
	return
endif

cp_ncolors = ncolors

end
