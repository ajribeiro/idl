;+ 
; NAME: 
; RAD_FIT_CALCULATE_ELEVATION
; 
; PURPOSE: 
; This procedure calculates the elevation angle (angle of arrival) from the
; phase difference. It mimicks the C function elevation which is used
; by make_fit and make_fitex2. However, here you can specify (fiddle with)
; a couple of parameters in order to see how the elevation angle changes.
; If you don't set any keywords, the parameters are pulled from the hardware file
; and the results from this function will be
; exactly the same as those in the fit file.
; Note: If you set the OVERWRITE keyword, the elevation angles in 
; RAD_FIT_DATA are overwritten!
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE: 
; RAD_FIT_CALCULATE_ELEVATION
;
; KEYWORD PARAMETERS:
; TDIFF: The propagation time from interferometer array antenna to
; phasing matrix input minus propagation time from main array antenna
; through transmitter to phasing matrix input. Units are decimal
; microseconds.
;
; PHIDIFF: Phase sign. Cabling errors can lead to a 180 degree shift of the
; interferometry phase measurement. +1 indicates that the sign is
; correct, -1 indicates that it must be flipped.
;
; INTERFER_POS: Set this keyword to the interferometer offset. 
; It is the displacement of the midpoint of the interferometer array 
; from the midpoint of the main array. This is given in
; meters in Cartesian coordinates. X is along the line of antennas with
; +X toward higher antenna numbers, Y is along the array normal
; direction with +Y in the direction of the array normal. Z is the
; altitude difference, +Z up.)
;
; SCAN_BORESITE_OFFSET: Set this keyword to the offset in degree between
; the physical boresite and the scanning boresite.
; The physical boresite is the antenna array normal direction.
; The scanning boresite is the direction of the center beam.
; As far as I know, these values differ only at Blackstone.
;
; DATE: Set this to a date in YYYYMMDD format to use the hardware 
; configuration at that date in the calculations.
;
; TIME: Set this to a time in HHMM format to use the hardware 
; configuration at that date in the calculations.
;
; LONG: Set this keyword to indicate that the TIME keyword is in 
; HHMMSS format and not in HHMM format.
;
; JUL: Set this to a Julian date to use the hardware 
; configuration at that date in the calculations.
;
; OVERWRITE: Set this keyword to overwrite the angle of arrival values in 
; the RAD_FIT_DATA structure.
;
; THETA: Set this keyword to a named variable that will contain the
; calculated elevation angles.
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
; Written by Lasse Clausen, Nov, 17 2010
;-
pro rad_fit_calculate_elevation, $
	date=date, time=time, long=long, jul=jul, $
	overwrite=overwrite, $
	tdiff=tdiff, phidiff=phidiff, $
	interfer_pos=interfer_pos, scan_boresite_offset=scan_boresite_offset, $
	theta=theta, chi_max=chi_max, phi_temp=phi_temp, psi=psi

common rad_data_blk
common radarinfo

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data in index '+string(data_index)
	return
endif

; check if any data is loaded
if (*rad_fit_info[data_index]).nrecs eq 0L then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data in index '+string(data_index)
		rad_fit_info
	endif
	return
endif

; get date from first datum
if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, (*rad_fit_data[data_index]).juls[0], month, day, year, hh, ii
	date = year*10000L + month*100L + day
	_time = hh*100 + ii
endif

; get time
if n_elements(time) ne 0 then $
	_time = time[0]

; calculate julian day if not given
if ~keyword_set(jul) then $
	sfjul, date, _time, jul, long=long

; get time
caldat, jul, month, day, year, hour, minute, second

; get hardware configuration at the time
radar = radargetradar(network, (*rad_fit_info[data_index]).id)
site = radarymdhmsgetsite(radar, year, month, day, hour, minute, second)

; get default tdiff from hardware file
if ~keyword_set(tdiff) then $
	tdiff = site.tdiff

; get default phidiff from hardware file
if ~keyword_set(phidiff) then $
	phidiff = site.phidiff

; get default interferometer position
; or the one that's in the hdw file, anyway
if n_elements(interfer_pos) ne 3 then $
	interfer_pos = site.interfer

; get default interferometer position
; or the one that's in the hdw file, anyway
if total(interfer_pos^2) le 0. then $
	interfer_pos = site.interfer

; this is the offset in degree between
; the physical boresite and the scanning boresite
; the physical boresite is the antenna array normal direction
; the scanning boresite is the direction of the center beam
; as far as I know, these values differ only at Blackstone.
if n_elements(scan_boresite_offset) eq 0 then $
	scan_boresite_offset = 0.

; get dimensions of data array
sz = size((*rad_fit_data[data_index]).phi0, /dim)

; antenna separation in meters
if total(interfer_pos^2) le 0. then begin
	prinfo, 'Antenna separation cannot <= 0.'
	if keyword_set(overwrite) then $
		(*rad_fit_data[data_index]).elevation[*] = 10000.
	return
endif
antenna_separation = sqrt(total(interfer_pos^2))

;print, tdiff, phidiff, interfer_pos, scan_boresite_offset

; elevation angle correction, if antennas are at different heights; rad
elev_corr = phidiff * asin( interfer_pos[2] / antenna_separation)

; +1 if interferometer antenna is in front of main antenna, -1 otherwise
; interferometer in front of main antenna
if interfer_pos[1] gt 0.0 then $
	phi_sign = 1.0 $
; interferometer behind main antenna
else $
	phi_sign = -1.0
elev_corr *= -phi_sign

; offset in beam widths to the edge of the array
offset = site.maxbeam/2.0 - 0.5


; beam direction off boresight; rad
phi = ( site.bmsep*( (*rad_fit_data[data_index]).beam - offset ) + scan_boresite_offset ) * !dtor

; cosine of phi
c_phi = cos( phi )
; replicate c_phi to match dimensions of phi0
c_phi = rebin(c_phi, sz[0], sz[1])

; wave number; 1/m
k = 2. * !PI * (*rad_fit_data[data_index]).tfreq * 1000.0 / 2.99792458e8
; replicate k to match dimensions of phi0
k = rebin(k, sz[0], sz[1])

; the phase difference phi0 is between -pi and +pi and gets positive,
; if the signal from the interferometer antenna arrives earlier at the
; receiver than the signal from the main antenna.
; If the cable to the interferometer is shorter than the one to
; the main antenna, than the signal from the interferometer
; antenna arrives earlier. tdiff < 0  --> dchi_cable > 0

; phase shift caused by cables; rad
dchi_cable = -2. * !PI * (*rad_fit_data[data_index]).tfreq * 1000.0 * tdiff * 1.0e-6
; replicate dchi_cable to match dimensions of phi0
dchi_cable = rebin(dchi_cable, sz[0], sz[1])

; If the interferometer antenna is in front of the main antenna
; then lower elevation angles correspond to earlier arrival
; and greater phase difference.
; If the interferometer antenna is behind of the main antenna 
; then lower elevation angles correspond to later arrival
; and smaller phase difference

; maximum phase shift possible; rad
chi_max = phi_sign * k * antenna_separation * c_phi + dchi_cable
; replicate chi_max to match dimensions of phi0
chi_max = rebin(chi_max, sz[0], sz[1])

; change phi0 by multiples of twopi, until it is in the range
; (chi_max - twopi) to chi_max (interferometer in front)
; or chi_max to (chi_max + twopi) (interferometer in the back)

; actual phase angle + cable; rad
phi_temp = (*rad_fit_data[data_index]).phi0 + 2.*!PI*floor( (chi_max - (*rad_fit_data[data_index]).phi0)/ (2.*!PI) )
if phi_sign lt 0.0 then $
	phi_temp = phi_temp + (2.*!PI)

; subtract the cable effect
; actual phase angle - cable;   rad
psi = phi_temp - dchi_cable

; angle of arrival for horizontal antennas
; not quite yet
theta = psi / (k * antenna_separation)
theta = (c_phi * c_phi - theta * theta)

; set elevation angle to 10000. for out of range values
; vectorize
;  if ( (theta < 0.0) || (fabs( theta) > 1.0) ) theta= - elev_corr;
;  else theta= asin( sqrt( theta));
inds = where(theta lt 0. or abs(theta) gt 1. or (*rad_fit_data[data_index]).phi0 eq 10000., ni, complement=ninds, ncomplement=nn)
if ni gt 0L then begin
	theta[inds] = 10000.
	phi_temp[inds] = 10000.
	psi[inds] = 10000.
endif
if nn gt 0L then $
	theta[ninds] = !radeg * ( asin( sqrt( theta[ninds] ) ) + elev_corr )

if keyword_set(overwrite) then $
	(*rad_fit_data[data_index]).elevation = theta ; in degree

;----
;; ORIGINAL C FUNCTION
;----
;double elevation_ex(struct FitPrm *prm,double phi0) {
;  
;   double k;          /* wave number; 1/m */
;   double phi;        /* beam direction off boresight; rad */
;   double c_phi;      /* cosine of phi                     */
;   double dchi_cable; /* phase shift caused by cables; rad */
;   double chi_max;    /* maximum phase shift possible; rad */
;   double phi_temp;   /* actual phase angle + cable;   rad */
;   double psi;        /* actual phase angle - cable;   rad */
;   double theta;      /* angle of arrival for horizontal antennas; rad */
;   double offset=7.5; /* offset in beam widths to the edge of the array */
;   static double antenna_separation= 0.0; /* m */
;   static double elev_corr= 0.0;
;   /* elevation angle correction, if antennas are at different heights; rad */
;   static double phi_sign= 0;
;   /* +1 if interferometer antenna is in front of main antenna, -1 otherwise*/
; 
;   /* calculate the values that don't change if this hasn't already been done. */
; 
;   if (antenna_separation == 0.0) {
;     antenna_separation= sqrt(prm->interfer[1]*prm->interfer[1] + 
; 			                 prm->interfer[0]*prm->interfer[0] +
; 	                         prm->interfer[2]*prm->interfer[2]);
;     elev_corr= prm->phidiff* asin( prm->interfer[2]/ antenna_separation);
;     if (prm->interfer[1] > 0.0) /* interferometer in front of main antenna */
;       phi_sign= 1.0;
;     else {                           /* interferometer behind main antenna */
;       phi_sign= -1.0;
;       elev_corr= -elev_corr;
;     }
;   }
;   offset=prm->maxbeam/2.0-0.5;
;   phi= prm->bmsep*(prm->bmnum - offset)* PI/ 180.0;
;   c_phi= cos( phi); 
;   k= 2 * PI * prm->tfreq * 1000.0/C;
; 
;   /* the phase difference phi0 is between -pi and +pi and gets positive,  */
;   /* if the signal from the interferometer antenna arrives earlier at the */
;   /* receiver than the signal from the main antenna. */
;   /* If the cable to the interferometer is shorter than the one to */
;   /* the main antenna, than the signal from the interferometer     */
;   /* antenna arrives earlier. tdiff < 0  --> dchi_cable > 0        */
; 
;   dchi_cable= - 2* PI * prm->tfreq * 1000.0 * prm->tdiff * 1.0e-6;
; 
;   /* If the interferometer antenna is in front of the main antenna */
;   /* then lower elevation angles correspond to earlier arrival     */
;   /* and greater phase difference. */    
;   /* If the interferometer antenna is behind of the main antenna   */
;   /* then lower elevation angles correspond to later arrival       */
;   /* and smaller phase difference */    
; 
;   chi_max= phi_sign* k* antenna_separation* c_phi + dchi_cable;
; 
;   /* change phi0 by multiples of twopi, until it is in the range   */
;   /* (chi_max - twopi) to chi_max (interferometer in front)        */
;   /* or chi_max to (chi_max + twopi) (interferometer in the back)  */
; 
;   phi_temp= phi0 + 2*PI* floor( (chi_max - phi0)/ (2*PI));
;   if (phi_sign < 0.0) phi_temp= phi_temp + (2*PI);
; 
;   /* subtract the cable effect */
;   psi= phi_temp - dchi_cable;
;   theta= psi/ (k* antenna_separation);
;   theta= (c_phi* c_phi - theta* theta);
;   /* set elevation angle to 0 for out of range values */
; 
;   if ( (theta < 0.0) || (fabs( theta) > 1.0) ) theta= - elev_corr;
;   else theta= asin( sqrt( theta));
; 
; 
;   return 180.0* (theta + elev_corr)/ PI; /* in degree */
; }
end