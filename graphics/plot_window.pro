;+ 
; NAME: 
; PLOT_WINDOW 
; 
; PURPOSE: 
; This procedure opens a new window for plotting.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; PLOT_WINDOW
;
; KEYWORD PARAMETERS: 
; SIZE: The size of the shorter dimension of the window in pixel. If no value 
; is given, the value from the USER_PREFS common block is used.
;
; INDEX: Set this to a number to use as the window number. If none is set
; either !D.WINDOW is taken (if not -1) or 0.
;
; LANDSCAPE: Open the window in landscape format.
;
; PORTRAIT: Open the window in portrait format.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_WINDOW.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro plot_window, index=index, size=size, landscape=landscape, portrait=portrait

if n_elements(index) eq 0 then $
	index = ( !d.window eq -1 ? 0 : !d.window )

IF ~keyword_set(size) THEN $
	size = get_windowsize()

xsize = size
ysize = size

if ~keyword_set(landscape) and ~keyword_set(portrait) then begin
	fmt = get_format(portrait=pt)
	if pt eq 1 then $
		portrait = 1 $
	else $
		landscape = 1
endif

IF keyword_set(landscape) THEN xsize=xsize*SQRT(2)
IF keyword_set(portrait) THEN ysize=ysize*SQRT(2)

WINDOW, index, XSIZE=xsize, YSIZE=ysize,$
	TITLE=getenv('MYNAME')+' Output '+string(index,format='(I1)'), RETAIN=2

END
