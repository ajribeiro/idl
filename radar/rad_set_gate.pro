;+ 
; NAME: 
; RAD_SET_GATE
; 
; PURPOSE: 
; This function sets the currently active gate.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; RAD_SET_GATE, Gate
;
; INPUTS:
; Gate: A value to use as the currently active gate.
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
pro rad_set_gate, gate

common user_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Gate'
	return
endif

if size(gate, /type) eq 7 then begin
	prinfo, 'Gate must numeric.'
	return
endif

up_gate = gate

end
