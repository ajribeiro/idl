;+ 
; NAME: 
; RAD_SET_SCATTERFLAG
; 
; PURPOSE: 
; This function sets the currently active scatter flag. 
; 0: plot all backscatter data
; 1: plot ground backscatter only
; 2: plot ionospheric backscatter only
; 3: plot all backscatter data with a ground backscatter flag. 
; Scatter flags 0 and 3 produce identical output unless the 
; parameter plotted is velocity, in which case all ground 
; backscatter data is identified by a grey colour. Ground 
; backscatter is identified by a low velocity (|v| < 50 m/s) 
; and a low spectral width. 
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; RAD_SET_SCATTERFLAG, Scatterflag
;
; INPUTS:
; Scatterflag: A value to use as the currently active scatter flag.
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
pro rad_set_scatterflag, scatterflag

common user_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Scatterflag.'
	return
endif

if size(scatterflag, /type) eq 7 then begin
	prinfo, 'Scatterflag must numeric.'
	return
endif

up_scatterflag = scatterflag

end
