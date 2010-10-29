;+ 
; NAME: 
; GET_FORMAT
; 
; PURPOSE: 
; This function returns the currently active format. 
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_FORMAT()
;
; OUTPUTS:
; This function returns the currently active format.
;
; KEYWORD PARAMETERS:
; FREE: Set this keyword to a named variable that will contain true if FREE is set, false otherwise.
;
; SQUARE: Set this keyword to a named variable that will contain true if SQUARE is set, false otherwise.
;
; LANDSCAPE: Set this keyword to a named variable that will contain true if LANDSCAPE is set, false otherwise.
;
; PORTRAIT: Set this keyword to a named variable that will contain true if PORTRAIT is set, false otherwise.
;
; COLORSCALE: Set this keyword to a named variable that will contain true if COLORSCALE is set, false otherwise.
;
; GRAYSCALE: Set this keyword to a named variable that will contain true if GRAYSCALE is set, false otherwise.
;
; GUPPIES: Set this keyword to a named variable that will contain true if GUPPIES is set, false otherwise.
;
; SARDINES: Set this keyword to a named variable that will contain true if SARDINES is set, false otherwise.
;
; SCALE: Set this keyword to a named variable that will contain true if SCALE is set, false otherwise.
;
; ELACS: Set this keyword to a named variable that will contain true if ELACS is set, false otherwise.
;
; TOKYO: Set this keyword  to a named variable that will contain true if TOKYO is set, false otherwise.
;
; KANSAS: Set this keyword  to a named variable that will contain true if KANSAS is set, false otherwise.
;
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
function get_format, square=square, free=free, $
	landscape=landscape, portrait=portrait, $
	colorscale=colorscale, grayscale=grayscale, $
	guppies=guppies, sardines=sardines, $
	scale=scale, elacs=elacs, $
	tokyo=tokyo, kansas=kansas

common user_prefs

square     = (up_format and 2^0) eq 2^0
free       = (up_format and 2^0) eq 0
portrait   = (up_format and 2^1) eq 2^1
landscape  = (up_format and 2^1) eq 0
grayscale  = (up_format and 2^2) eq 2^2
colorscale = (up_format and 2^2) eq 0
sardines   = (up_format and 2^3) eq 2^3
guppies    = (up_format and 2^3) eq 0
elacs      = (up_format and 2^4) eq 2^4
scale      = (up_format and 2^4) eq 0
tokyo      = (up_format and 2^5) eq 2^5
kansas     = (up_format and 2^5) eq 0

return, up_format

end
