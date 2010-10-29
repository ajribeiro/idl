;+
; NAME: 
; LOAD_USERSYM
;
; PURPOSE: 
; This procedure loads a user defines shape as plotting symbol. The symbol can be used by setting
; PSYM=8.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; LOAD_USERSYM 
;
; KEYWORD PARAMETERS:
; CIRCLE: Set this keyword to load a circle.
;
; TRIANGLE: Set this keyword to load a triangle.
;
; SQUARE: Set this keyword to load a square.
;
; NO_FILL: Set this keyword to surpress filling of the symbol.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Dec, 4 2009
;-
pro load_usersym, circle=circle, square=square, triangle=triangle, no_fill=no_fill, thick=thick

if keyword_set(circle) then begin
	if !d.name eq 'X' then $
		radius = 1.5
	if !d.name eq 'PS' then $
		radius = 0.75
	tt = findgen(33)/32.*2.*!pi
	xx = radius*cos(tt)
	yy = radius*sin(tt)
endif

if keyword_set(square) then begin
	xx = [ 1., -1., -1., 1.,  1.]
	yy = [-1., -1.,  1., 1., -1.]
endif

if keyword_set(triangle) then begin
	xx = [ 1., -1.,  0.,  1.]
	yy = [-1., -1.,  1., -1.]
endif

usersym, xx, yy, fill=(keyword_set(no_fill) eq !false), thick=thick

end
