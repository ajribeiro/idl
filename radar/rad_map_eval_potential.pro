;+
; NAME: 
; RAD_MAP_EVAL_POTENTIAL
;
; PURPOSE: 
; This function does the actual calculation of the electric potential from the harmonic expansion coefficients
; on a latitude-longitude grid used for overlaying the potential contours.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; Result = RAD_MAP_EVAL_POTENTIAL(Coeffs, Plm, Phi)
;
; INPUTS:
; Coeffs: An array holding the coefficients of the harmonic expansion.
;
; Plm: This is an array (N,Lmax,Lmax) where N = number of points
; where the potential is to be evaluated, and the
; other two indices give the associated Legendre polynomial
; to be evaluated at each position.
;
; Phi: The azimuthal coordinate at each evaluation point.
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Dec, 11 2009
;-
function rad_map_eval_potential, coeffs, plm, phi
;+
; FUNCTION EVAL_POTENTIAL
;
; PURPOSE:  evaluate the electric potential on a set of
;           points, given the coefficients of the spherical
;           harmonic expansion.
;
; Calling Sequence:
;
;   pot = eval_potential,a,plm,phi
;
;     where 'a' is the set of coefficients given as a vector
;               indexed by k = index_legendre(l,m,/dbl)
;
;     plm is an array (N,Lmax,Lmax) where N = number of points
;         where the potential is to be evaluated, and the
;         other two indices give the associated Legendre polynomial
;         to be evaluated at each position.
;
;     phi is the azimuthal coordinate at each evaluation point.
;
;-
ss = size(plm)
lmax = ss[2] - 1L
v = replicate(0.,n_elements(phi))

for m=0L, lmax do begin
	for L=m, Lmax do begin
		k = index_legendre(L, m, /dbl)
		v = (m eq 0) ? v + coeffs[k]*plm[*,L,0] : $
			v + coeffs[k]*cos(m*phi)*plm[*,l,m] + coeffs[k+1]*sin(m*phi)*plm[*,l,m]
	endfor
endfor

return, v

end