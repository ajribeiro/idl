;+ 
; NAME: 
; SET_FORMAT
; 
; PURPOSE: 
; This function returns the currently active format. 
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; SET_FORMAT
;
; KEYWORD PARAMETERS:
; FREE: Set this keyword to set a free aspect ratio. This is the default.
;
; SQUARE: Set this keyword to format the panel as a square, i.e. xsize=ysize.
;
; LANDSCAPE: Set this keyword to format the output device in landscape mode.
;
; PORTRAIT: Set this keyword to format the output device in portrait mode.
;
; COLORSCALE: Set this keyword to use colored output.
;
; GRAYSCALE: Set this keyword to use monochrome output.
;
; GUPPIES: Set this keyword to allow for top and bottom margins around panels.
;
; SARDINES: Set this keyword to loose top and bottom margins around panels.
;
; SCALE: Set this keyword to use the normal color scale.
;
; ELACS: Set this keyword to use the reversed color scale.
;
; TOKYO: Set this keyword to loose left and right margins.
;
; KANSAS: Set this keyword to allow for left and right margins around the panel.
;
; COMMON BLOCKS:
; USER_PREFS: The common block holding user preferences.
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro set_format, square=square, free=free, $
	landscape=landscape, portrait=portrait, $
	colorscale=colorscale, grayscale=grayscale, $
	guppies=guppies, sardines=sardines, $
	scale=scale, elacs=elacs, $
	tokyo=tokyo, kansas=kansas

COMMON user_prefs

no_bits = 6
mask = 2^no_bits-1

if n_elements(up_format) eq 0 then $
	up_format = 0

IF KEYWORD_SET(square)     THEN up_format=(up_format OR 2^0)
IF KEYWORD_SET(free)       THEN up_format=(up_format AND mask-2^0)
IF KEYWORD_SET(portrait)   THEN begin
	up_format=(up_format OR 2^1)
	if strcmp(!d.name, 'PS') then begin
		DEVICE,/PORTRAIT, /inches, $
			XOFFSET=0.25,YOFFSET=0.25,XSIZE=8.0,YSIZE=10.5,$
			FONT_SIZE=18,SCALE_FACTOR=1
	endif
endif
IF KEYWORD_SET(landscape)  THEN begin
	up_format=(up_format AND mask-2^1)
	if strcmp(!d.name, 'PS') then begin
		DEVICE, /LANDSCAPE, /inches, $
			XOFFSET=0.25,YOFFSET=10.75,XSIZE=10.5,YSIZE=8.0,$
			FONT_SIZE=18,SCALE_FACTOR=1
	endif
endif
IF KEYWORD_SET(grayscale)  THEN up_format=(up_format OR 2^2)
IF KEYWORD_SET(colorscale) THEN up_format=(up_format AND mask-2^2)
IF KEYWORD_SET(sardines)   THEN up_format=(up_format OR 2^3)
IF KEYWORD_SET(guppies)    THEN up_format=(up_format AND mask-2^3)
IF KEYWORD_SET(elacs)      THEN up_format=(up_format OR 2^4)
IF KEYWORD_SET(scale)      THEN up_format=(up_format AND mask-2^4)
IF KEYWORD_SET(tokyo)      THEN up_format=(up_format OR 2^5)
IF KEYWORD_SET(kansas)     THEN up_format=(up_format AND mask-2^5)

END

