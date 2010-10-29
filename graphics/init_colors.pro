;+ 
; NAME: 
; INIT_COLORS
; 
; PURPOSE: 
; This procedure initializes variables in the COLOR_PREFS common block and 
; loads the Cutlass/SuperDARN Color Table by calling RAD_LOAD_COLORTABLE.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; INIT_COLORS
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's UPDATE_COLOURS.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro init_colors, invert_bw=invert_bw

set_ncolors, 253
set_bottom, 1
set_colorsteps, 10

set_black, 0
set_gray, 254
set_white, 255

;rad_load_colortable

if !d.name eq 'X' then begin
	if keyword_set(invert_bw) then begin
		set_foreground, get_white()
		set_background, get_black()
	endif else begin
		set_foreground, get_black()
		set_background, get_white()
	endelse
endif

if !d.name eq 'PS' then begin
	set_foreground, get_black()
	set_background, get_white()
endif

!p.color = get_foreground()
!p.background = get_background()

end
