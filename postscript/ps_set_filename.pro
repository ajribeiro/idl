;+ 
; NAME: 
; PS_SET_FILENAME
; 
; PURPOSE: 
; This procedure sets the name of the currently active PostScript file. 
; 
; CATEGORY: 
; PostScript
; 
; CALLING SEQUENCE: 
; PS_SET_FILENAME, Filename
;
; INPUTS:
; Filename: A string variable containing the filename.
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
pro ps_set_filename, filename

common postscript

if n_params() ne 1 then begin
	prinfo, 'Must give Filename'
	return
endif

if size(filename, /type) ne 7 then begin
	prinfo, 'Filename must be of type string.'
	return
endif

ps_filename = filename

end
