;+ 
; NAME: 
; CLEAR_PAGE
; 
; PURPOSE: 
; This procedure clears the current graphics output. If the current output is directed
; to PostScript, a new page is started. If the current output is to the Window system
; a new window is opened if none is open yet. If a window is open, the contents are erased.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; CLEAR_PAGE
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's CLEAR_PAGE
; Written by Lasse Clausen, Nov, 24 2009
;-
PRO clear_page, index=index, next=next

if keyword_set(next) then $
	index = !d.window + 1


if n_elements(index) eq 0 then $
	index = ( !d.window eq -1 ? 0 : !d.window )

IF !D.NAME EQ 'PS' THEN $
	erase

IF !D.NAME EQ 'X' THEN begin
	if !d.window eq -1 or !d.window ne index then $
		plot_window, index=index
	erase
endif

END
