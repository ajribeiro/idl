function rad_map_eval_grad_vecs, pos, coeffs, latmin, order, e_field=e_field

e_field = rad_map_eval_efield(pos, coeffs, latmin, order)

theta = (90.0 - pos[0,*])*!dtor
Re = !re*1000.
Altitude = 300.0*1000.0
bpolar = -.62e-4

bmag = bpolar*(1.0-3.0*Altitude/Re)*sqrt(3.0*cos(theta)^2+1.0)/2.0
vel = e_field
vel[0,*] =  e_field[1,*]/bmag
vel[1,*] = -e_field[0,*]/bmag

return, vel
;-----------------------------------------------------
; this code now lives in RAD_MAP_EVAL_EFIELD

lmax = order
theta = (90.0 - pos[0,*])*!dtor
thetamax = (90.0-latmin)*!dtor
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

bmag = bpolar*(1.0-3.0*Altitude/Re)*sqrt(3.0*cos(theta)^2+1.0)/2.0
vel = e_field
vel[0,*] =  e_field[1,*]/bmag
vel[1,*] = -e_field[0,*]/bmag

return, vel

end
