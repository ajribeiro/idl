;+
; NAME: 
; INDEX_LEGENDRE
;
; PURPOSE: 
; This function converts a Legendre polynoiomial index pair (l,m)
; into a single index (k).
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE:
; Result = INDEX_LEGENDRE(L, M)
;
; INPUTS:
; L: The first Legendre index.
;
; M: The second Legendre index.
;
; KEYWORD PARAMETERS:
; SH: We are doing Spherical harmonics where m runs from -l to + l
;
; SNGL: We are doing Associated Legendre Polynomials with m=0,l
;
; DBL: We are doing Associated Legendre Polynomials
; but for each polynomial we have two coefficients 
; one for cos(phi) and one for sin(phi), as before, m
; runs from 0 to l.  Basically, /DOUBLE means we
; are doing spherical harmonics for a real valued 
; function using sin(phi) and cos(phi) rather than
; exp(i*phi).
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Dec, 11 2009
;-
function index_legendre, l, m, $
	sh=sh, sngl=sngl, dbl=dbl

;+
; PURPOSE
;  This routine converts a Legendre polynoiomial index pair (l,m)
;  into a single index (k).
;
; FUNCTION:  INDEX_LEGENDRE
;
; Calling Sequence:
;   k = index_legendre(l,m,[/SH],[/SNGL],[/DBL])
;
; The keywords SH, SNGL, and DBL have the following
; meanings:
;   /SH:  We are doing Spherical harmonics where m runs from -l to + l
;
;   /SINGLE:  We are doing Associated Legendre Polynomials with m=0,l
;
;   /DOUBLE:  We are doing Associated Legendre Polynomials
;             but for each polynomial we have two coefficients 
;             one for cos(phi) and one for sin(phi), as before, m
;             runs from 0 to l.  Basically, /DOUBLE means we
;             are doing spherical harmonics for a real valued 
;             function using sin(phi) and cos(phi) rather than
;             exp(i*phi).
;-
; $Log: index_legendre.pro,v $
; Revision 1.1  1997/08/05 14:47:30  baker
; Initial revision
;
;

if (m GT l) then return,-1
;
if (keyword_set(SH)) then begin
  return, fix(m+l*(l+1))
endif $
else if(keyword_set(SNGL)) then begin
  return, fix(m + l*(l+1)/2)
endif $
else if(keyword_set(DBL)) then begin
  if (l eq 0) then return,0 $
  else if (m eq 0) then return, L*L $
  else return, L*L + 2*m - 1
endif $
else begin
  print,'INDEX_LEGENDRE:  you must specify one and only one of'
  print,'the keywords /SH (spherical harmonics),'
  print,'/SNGL (single Legendre polynomial),'
  print,'/DBL (cos(phi),sin(phi) pairs with Legendre Polynomials'
endelse
end