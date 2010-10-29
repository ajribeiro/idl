;+ 
; NAME: 
; PS_SET_ISOPEN
; 
; PURPOSE: 
; This procedure sets PS_ISOPEN to true if a PostScript file is open, false otherwise.
; 
; CATEGORY: 
; PostScript
; 
; CALLING SEQUENCE: 
; PS_SET_ISOPEN, Isopen
;
; INPUTS:
; Isopen: A numeric variable containing true (1) or false (0).
;
; COMMON BLOCKS:
; POSTSCRIPT: A common block holding information about the currently active
; PostScript file.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro ps_set_isopen, isopen

common postscript

if n_params() ne 1 then begin
	prinfo, 'Must give Isopen'
	return
endif

if size(isopen, /type) eq 7 then begin
	prinfo, 'Isopen must be numeric.'
	return
endif

ps_isopen = isopen

end
