;+
; NAME:
; RAD_MAP_EVAL_EFIELD
;
; PURPOSE:
; This function calculates the two horizontal electric field components
; at a given set of locations using the coefficients of the spherical harmonic fit.
;
; CATEGORY:
; Radar
;
; CALLING SEQUENCE:
; Result = RAD_MAP_EVAL_EFIELD(Pos, Coeffs, Latmin, Order)
;
; INPUTS:
; Pos: A 2 by n array of magnetic latitudes and longitudes of locations at
; which to calculate the horizontal electric field.
;
; Coeffs: An array holding the coefficients of the harmonic expansion.
;
; Latmin: The minimal latitude of the sperical harmonic fit. This number
; is part of the convection map files.
;
; Order: The order of the sperical harmonic fit. This number
; is part of the convection map files.
;
; OUTPUTS:
;	
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
; Edited by Bharat Kunduri, Feb 1, 2012 (lines 110 & 111 - effective colatitude was reaching values beyond 'pi' so using abs values instead)
;-
function rad_map_eval_efield, pos, coeffs, latmin, order

Re = !re*1000.

lmax = fix(order)
theta = (90.0 - abs(pos[0,*]))*!dtor
thetamax = (90.0-abs(latmin))*!dtor
alpha = 1.0d0
theta_prime = norm_theta(theta, thetamax, alpha=alpha)
x = cos(theta_prime)
plm = eval_legendre(order, x)
phi = pos[1,*]*!dtor

n = n_elements(theta)
kmax = index_legendre(Lmax, Lmax, /dbl)

theta_ecoeffs = dblarr(kmax+2,n)
phi_ecoeffs   = dblarr(kmax+2,n)
q_prime = where(theta_prime ne 0.0)
q = where(theta ne 0.0)

; convert coefficients of for the potential
; into coefficients for the electric field
for m=0, Lmax do begin
  for L=m, Lmax do begin
    k3 = index_legendre(L, m, /dbl)
    k4 = index_legendre(L, m, /dbl)
    if (k3 ge 0) then begin
      theta_ecoeffs[k4,q_prime] = theta_ecoeffs[k4,q_prime] - $
        coeffs[k3]*alpha*L*cos(theta_prime[q_prime])/sin(theta_prime[q_prime])/Re
      phi_ecoeffs[k4,q]   = phi_ecoeffs[k4,q] - coeffs[k3+1]*m/sin(theta[q])/Re
      phi_ecoeffs[k4+1,q] = phi_ecoeffs[k4+1,q] + coeffs[k3]*m/sin(theta[q])/Re
    endif
    k1 = (L LT Lmax) ? index_legendre(L+1, m, /dbl) : -1
    k2 = index_legendre(L, m, /dbl)
    if (k1 ge 0) then begin
      theta_ecoeffs[k2,q_prime] = theta_ecoeffs[k2,q_prime] + $
        coeffs[k1]*alpha*(L+1+m)/sin(theta_prime[q_prime])/Re
    endif

    if (m gt 0) then begin
      if (k3 ge 0) then k3 = k3 + 1
      k4 = k4 + 1
      if (k1 ge 0) then k1 = k1 + 1
      k2 = k2 + 1
      if (k3 ge 0) then begin
        theta_ecoeffs[k4,q_prime] = theta_ecoeffs[k4,q_prime] - $
          coeffs[k3]*alpha*L*cos(theta_prime[q_prime])/sin(theta_prime[q_prime])/Re
      endif
      if (k1 ge 0) then begin
        theta_ecoeffs[k2,q_prime] = theta_ecoeffs[k2,q_prime] + $
          coeffs[k1]*alpha*(L+1+m)/sin(theta_prime[q_prime])/Re
      endif
    endif
  endfor
endfor

; now calculate the electric field at the positions
; of the velocity measurements
theta_ecomp = dblarr(n)
phi_ecomp   = dblarr(n)
for m = 0,Lmax do begin
  for L=m,Lmax do begin
    k = index_legendre(L, m, /dbl)
    if (m eq 0) then begin
			theta_ecomp = theta_ecomp + theta_ecoeffs[k,*]*plm[*,l,m]
			phi_ecomp = phi_ecomp + phi_ecoeffs[k,*]*plm[*,l,m]
    endif else begin
			theta_ecomp = theta_ecomp + theta_ecoeffs[k,*]*plm[*,l,m]*cos(m*phi) + $
				theta_ecoeffs[k+1,*]*plm[*,l,m]*sin(m*phi)
			phi_ecomp = phi_ecomp + phi_ecoeffs[k,*]*plm[*,l,m]*cos(m*phi) + $
				phi_ecoeffs[k+1,*]*plm[*,l,m]*sin(m*phi)
		endelse
  endfor
endfor
e_field = fltarr(2,n)
e_field[0,*] = theta_ecomp
e_field[1,*] = phi_ecomp

return, e_field

end
