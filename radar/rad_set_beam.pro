;+ 
; NAME: 
; RAD_SET_BEAM
; 
; PURPOSE: 
; This function sets the currently active beam.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; RAD_SET_BEAM, Beam
;
; INPUTS:
; Beam: A value to use as the currently active beam.
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
pro rad_set_beam, beam

common user_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Beam.'
	return
endif

if size(beam, /type) eq 7 then begin
	prinfo, 'Beam must numeric.'
	return
endif

up_beam = beam

end
