;+ 
; NAME: 
; SET_COLORSTEPS
; 
; PURPOSE: 
; This function sets the number of steps of colors to use for plotting.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_COLORSTEPS, Colorsteps
;
; INPUTS:
; Colorsteps: A value to use as the number of steps of colors to use for plotting.
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
pro set_colorsteps, colorsteps

common color_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Colorsteps.'
	return
endif

if size(colorsteps, /type) eq 7 then begin
	prinfo, 'Colorsteps must numeric.'
	return
endif

cp_colorsteps = colorsteps

end
