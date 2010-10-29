;+ 
; NAME: 
; SWAP 
; 
; PURPOSE: 
; This procedure rotates the contents of the variables A and B 90 degree
; (anti-)clockwise. The rotation is done in place, i.e. A and B will have
; different values after you called this function.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; SWAP, A, B
; 
; INPUTS: 
; A: Any numeric array.
;
; B: Any numeric array.
; 
; KEYWORD PARAMETERS: 
; LEFT: Set this keyword to perfom a anti-clockwise rotation.
;
; RIGHT: Set this keyword to perform a clockwise rotation.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro swap, a, b, left=left, right=right

if n_elements(a) ne n_elements(b) then begin
    print, 'SWAP: A and B not the same size.'
    return
endif

if ~keyword_set(left) and ~keyword_set(right) then $
    left=1

if keyword_set(left) then $
    fac = 1.

if keyword_set(right) then $
    fac = -1.

tmp = fac*a
a = -fac*b
b = tmp

end
