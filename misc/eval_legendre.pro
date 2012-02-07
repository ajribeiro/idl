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
; PM:
;
; PP:
; 
; EXAMPLE:
;
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Dec, 11 2009
; Based on Kile Baker's IDL code.
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
