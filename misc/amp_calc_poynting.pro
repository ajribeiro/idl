;+ 
; NAME: 
; AMP_CALC_POYNTING
;
; PURPOSE:
; This procedure computes the Poynting flux by combining magnetic perturbation vectors
; measured by AMPERE with the electric field measured by SuperDARN. It requires
; that a SuperDARN convection map file and an AMPERE data file from the same day be
; loaded. It extracts the coefficients from the spherical harmonic expansion of the convection
; map, expands the harmonics at the positions where we have AMPERE data and computes
; E x dB. The result is saved in the AMP_DATA data structure and can be plotted on
; maps using AMP_OVERLAY_POYNTING.
;
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE:
; AMP_CALC_POYNTING
;
; INPUTS:
;
; KEYWORD PARAMETERS:
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; NORTH: Set this keyword to calculate the Poynting flux for the northern hemisphere only.
; This is the default.
;
; SOUTH: Set this keyword to calculate the Poynting flux for the southern hemisphere only.
;
; HEMISPHERE: Set this keyword to 0 to calculate the Poynting flux for the northern hemisphere only,
; set it to 1 to calculate the Poynting flux for the southern hemisphere only.
;
; BOTH: Set this keyword to calculate the Poynting flux for the northern and southern hemisphere.
;
; COMMON BLOCKS:
; AMP_DATA_BLK: The common block holding the currently loaded AMPERE data and 
; information about that data.
;
; RAD_DATA_BLK: The common block holding the currently loaded SuperDARN map potential data and 
; information about that data.
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
; Written by Lasse Clausen, Feb, 12, 2011
;-
pro amp_calc_poynting, both=both, north=north, south=south, hemisphere=hemisphere, raw=raw, silent=silent

if keyword_set(both) then begin
	amp_calc_poynting, /north
	amp_calc_poynting, /south
	return
endif

mu0 = 4e-7*!pi

common amp_data_blk
common rad_data_blk

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

if rad_map_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No SuperDARN data loaded.'
	return
endif

if amp_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No AMPERE data loaded.'
	return
endif

for ap_index=0, amp_info[int_hemi].nrecs-1 do begin

	jul = (*amp_data[int_hemi]).mjuls[ap_index]
	caldat, jul, month, day, year
	utsec = (jul - julday(1, 1, year, 0, 0))*86400.d

	; calculate index from date and time for SuperDARN
	dd = min( abs( (*rad_map_data[int_hemi]).mjuls-jul ), sd_index)
	; check if time distance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

	; get minimum latitude
	latmin = (*rad_map_data[int_hemi]).latmin[sd_index]
	; get the order of the fit
	order = (*rad_map_data[int_hemi]).fit_order[sd_index]
	; get coefficients of the expansion
	coeffs = (*(*rad_map_data[int_hemi]).coeffs[sd_index])

	; get ampere grid and rotate that into magnetic coordinates
	ap_lats = 90.-reform((*amp_data[int_hemi]).colat[ap_index, *])
	ap_lons = ( ( reform((*amp_data[int_hemi]).mlt[ap_index, *]) - mlt(year, utsec, 0.) )*15. + 360. ) mod 360.

	pos = transpose([[ap_lats],[ap_lons]])
	; evaluate the sd coefficients, efield is NS, EW, on the Ampere grid
	e_field = rad_map_eval_efield( pos, coeffs[*,2], latmin, order )

	; get ampere data
	if keyword_set(raw) then begin
		dbn = reform((*amp_data[int_hemi]).dbnorth1[ap_index, *])
		dbe = reform((*amp_data[int_hemi]).dbeast1[ap_index, *])
	endif else begin
		dbn = reform((*amp_data[int_hemi]).dbnorth2[ap_index, *])
		dbe = reform((*amp_data[int_hemi]).dbeast2[ap_index, *])
	endelse

	; negative Poynting flux is down in the northern hemisphere
	; multiplier is to get mW/m^2 as unit, dB is in nT, e_field is in V/m
	(*amp_data[int_hemi]).p1[ap_index,*] = e_field[0,*]*dbe*1e-9/mu0*1e3
	(*amp_data[int_hemi]).p2[ap_index,*] = e_field[1,*]*dbn*1e-9/mu0*1e3
	(*amp_data[int_hemi]).poynting[ap_index,*] = -(-e_field[0,*]*dbe - $
		e_field[1,*]*dbn)*1e-9/mu0*1e3

	binds = where(ap_lats lt latmin, bc)
	if bc gt 0 then begin
		(*amp_data[int_hemi]).p1[ap_index,binds] = 0.
		(*amp_data[int_hemi]).p2[ap_index,binds] = 0.
		(*amp_data[int_hemi]).poynting[ap_index,binds] = 0.
	endif

endfor

amp_info[int_hemi].poynting = !true

end