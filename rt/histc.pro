;+ 
; NAME: 
; HISTC
;
; PURPOSE: 
; This function generates an histogram count
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; HISTC, y, x
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORDS:
;
; COMMON BLOCKS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Sebastien de Larquier, Sept. 2010
;-
function	histc, y, x

max_val = MAX(y)
min_val = MIN(y)

tmp = SORT(x)
x = x(tmp)

n = n_elements(x)-1
freq = fltarr(n)
FOR i=0, n-1 DO BEGIN
	freq(i) = TOTAL(y LT x(i+1) AND y GE x(i))
ENDFOR
freq(n-1) += TOTAL(y EQ x(n))

RETURN, freq

END
