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
