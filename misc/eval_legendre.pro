;+
; NAME: 
; EVAL_LEGENDRE
;
; PURPOSE: 
; This function evalautes all the Associated Legendre Polynomials
; from L=0 to L=Lmax, at a set of points.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE:
; Result = EVAL_LEGENDRE(Lmax, Pos)
;
; INPUTS:
; Lmax: Lmax give the maximum order of the Legendre
; polynomials.
;
; Pos: This variable gives the positions where the
; the polynomials are to be evaluated. It is pos(2,N) 
; where the first index indicates
; the theta,phi position and the second index
; lists the points where we have data.
;
; KEYWORD PARAMETERS:
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Dec, 11 2009
;-
function eval_legendre, Lmax, pos, $
	pm=pm, pp=pp
;+
;  FUNCTION EVAL_LEGENDRE
;
;  Purpose:  evalaute all the Associated Legendre Polynomials
;            from L=0 to L=Lmax, at a set of points
;
;  Calling Sequence:
;    PLM = eval_legendre(Lmax, pos)
;
;          where Lmax give the maximum order of the Legendre
;          polynomials, and pos gives the positions where the
;          the polynomials are to be evaluated.
; 
;          pos = pos(2,N) where the first index indicates
;                the theta,phi position and the second index
;                lists the points where we have data.
;
;
;-
; $Log: eval_legendre.pro,v $
; Revision 1.1  1997/08/05 14:42:55  baker
; Initial revision
;
;
x = double(reform(pos,n_elements(pos)))
N = n_elements(x)
xx = (1-x^2)
xx_L = xx # replicate(1.0d0, Lmax+1)
; this is the old way of calculating this:
;
; mover2 = dindgen(Lmax+1)/2.0
; mover2 = replicate(1.0d0, N) # mover2
; xx_Mover2 = xx_L^mover2
;
; however, mover2 is not of type integer, so IDL 
; evaluates the above as
; A^B = e^( B ln(A) )
; which takes about a second for typical input values
; we can speed this up be a factor of 1000 (!!!!)
; by making the exponent an integer value
; note that mover2 is initially 0, 1/2, 2/2, 3/2, 4/2 ...
; so a^mover2 is the same as sqrt( a^( 2*mover2 ) ) only that
; now the exponent is an integer and IDL simply multiplies
; a couple of times.
; again, this little fix speeds things up by a factor of 1000.
mover2 = indgen(Lmax+1)
mover2 = replicate(1, N) # mover2
xx_Mover2 = sqrt(xx_L^mover2)

; xx_Mover2 is the matrix of all the (1-x^2) values raised to
; all the powers of m/2 with m running from 0 to Lmax.
;
two_m_dbang = dbang(Lmax)
two_m_dbang = replicate(1.0d0, N) # two_m_dbang
pwrm = replicate(1.0d0, N) # ((-1)^indgen(Lmax+1))
pmm = xx_Mover2*pwrm*two_m_dbang
; 
;  we have now computed the value of Pmm at each point for
;  each value of m from 0 to Lmax
;
;
; We have now compute P(m+1,m) at each point and for each
; value of m from 0 to Lmax.
;
;
;  p(m+1,m) = x(2m+1)P(m,m)
;

pmmp1 = (x # replicate(1.0d0, Lmax+1))*(replicate(1.0d0, N) # $
                                     (dindgen(Lmax+1)*2.0+1.0)) * pmm
;
; OK, now we have pmm and pmmp1 at every point.
; Next we have to compute the rest of the plm values from
; the recursion relation:
; (l-m)P(l,m) = x(2l-1)p(l-1,m) - (l+m-1)P(l-2,m)
;
plm = replicate(0.0d0, N, lmax+1, lmax+1)
for l = 0,lmax do plm[*,l,l] = pmm[*,l]
for l = 0,lmax-1 do plm[*,l+1,l] = pmmp1[*,l]
for l = 0, lmax -2 do $
   for k=l+2,Lmax do plm[*,k,l] = $
               (1.0d0/(k-l))*((x*plm[*,k-1,l]*(2*k -1))-(k+l-1)*plm[*,k-2,l])

if (keyword_set(pm)) then pm = pmm
if (keyword_set(pp)) then pp = pmmp1

return, plm

end