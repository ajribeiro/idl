;+
; NAME: 
; NORM_THETA
;
; PURPOSE: 
; This function returns the adjusted values of the 
; angle theta, such that the full range of theta values run
; from 0 to Theta_Limit, where Theta_Limit is either pi or pi/2
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE:
; Result = NORM_THETA(Theta, Thetamax)
;
; INPUTS:
; Theta: The azimuthal andgle theta, in radians
;
; Thetamax: The maximum theta value.
;
; KEYWORD PARAMETERS:
; THETA_LIMIT: The upper limit to which theta  is scaled, defualt is pi.
;
; ALPHA: The ratio of THETA_LIMIT to Thetamax.
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Dec, 11 2009
;-
function norm_theta, theta, thetamax, $
	theta_limit=theta_limit, alpha=alpha
;----------------------------------------------------------------------
; FUNCTION  NORM_THETA
;
; PURPOSE:
;   This function returns the adjusted values of the 
;   angle theta, such that the full range of theta values run
;   from 0 to Theta_Limit, where Theta_Limit is either pi or pi/2
;
; $Log: norm_theta.pro,v $
; Revision 1.1  1997/08/05 14:50:53  baker
; Initial revision
;
;
if ~keyword_set(theta_limit) then $
	theta_limit = !pi

theta_limit = (~keyword_set(theta_limit) ? !PI : theta_limit)

alpha = theta_limit/thetamax
theta_prime = alpha * theta

return,theta_prime

end