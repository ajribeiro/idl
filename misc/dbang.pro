;+
; NAME: 
; DBANG
;
; PURPOSE: 
; This function calculates some obscure number for Associated Legendre Polynomials.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE:
; Result = DBANG(Mmax)
;
; INPUTS:
; Mmax: This variable gives the maximum azimuthal order of the Legendre
; polynomials.
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Dec, 11 2009
;-
function dbang, Mmax

result = replicate(1.0d0, Mmax+1)

for i=1, MMax do $
  for j=i, Mmax do result[j] = result[j]*(2*i - 1.0)

return, result

end