;+ 
; NAME: 
; RAD_SET_CHANNEL
; 
; PURPOSE: 
; This function sets the currently active channel
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; RAD_SET_CHANNEL, Channel
;
; INPUTS:
; Channel: A value to use as the currently active channel.
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
pro rad_set_channel, channel

common user_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Channel.'
	return
endif

if size(channel, /type) eq 7 then begin
	prinfo, 'Channel must numeric.'
	return
endif

up_channel = channel

end
