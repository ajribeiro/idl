;+ 
; NAME: 
; RAD_GET_SCATTERFLAG
; 
; PURPOSE: 
; This function returns the currently active scatter flag. 
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
; Result = RAD_GET_SCATTERFLAG()
;
; OUTPUTS:
; This function returns the currently scatter flag.
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
function rad_get_scatterflag

common user_prefs

return, up_scatterflag

end
