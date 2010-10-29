;+ 
; NAME: 
; RAD_GET_CHANNEL
; 
; PURPOSE: 
; This function returns the currently active data channel.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; Result = RAD_GET_CHANNEL()
;
; OUTPUTS:
; This function returns the currently active data channel.
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
function rad_get_channel

common user_prefs

return, up_channel

end
