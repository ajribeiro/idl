;+ 
; NAME: 
; SET_SCALE
; 
; PURPOSE: 
; This function sets the currently active scale. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; SET_SCALE, Scale
;
; INPUTS:
; Scale: A 2-element vector to use as the currently active scale.
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
pro set_scale, scale

common user_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Scale.'
	return
endif

if size(scale, /type) eq 7 then begin
	prinfo, 'Scale must numeric.'
	return
endif

if n_elements(scale) ne 2 then begin
	prinfo, 'Scale must be 2-element vector.'
	return
endif

up_scale = scale

end
