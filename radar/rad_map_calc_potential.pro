;+
; NAME: 
; RAD_MAP_CALC_POTENTIALS
;
; PURPOSE: 
; This function calculates the electric potential from the harmonic expansion coefficients
; on a latitude-longitude grid used for overlaying the potential contours.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; Result = RAD_MAP_CALC_POTENTIALS(Int_hemi, Index)
;
; INPUTS:
; Int_hemi: An integer indicating the hemisphere, 0 for north, 1 for south.
;
; Index: The index number of the coefficients to calculate.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding map data.
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
; Based on get_electric_potentials in the leicester world
; Written by Lasse Clausen, Dec, 11 2009
;-
function rad_map_calc_potential, int_hemi, index

common rad_data_blk

if n_elements(int_hemi) eq 0 then $
	int_hemi = 0

if n_elements(index) eq 0 then $
	index = 0

; get the order of the fit
order = (*rad_map_data[int_hemi]).fit_order[index]

; get latitude shift
lat_shft = (*rad_map_data[int_hemi]).lat_shft[index]

; get latitude shift
lon_shft = (*rad_map_data[int_hemi]).lon_shft[index]

; get minimum latitude
latmin = (*rad_map_data[int_hemi]).latmin[index]
tmax      = (90.0 - abs(latmin))*!dtor

; get coefficients of the expansion
coeffs = (*(*rad_map_data[int_hemi]).coeffs[index])

plot_lat_min = 30.

; initialize the grid on which to 
; evaluated the potential
latstep   =  1.0				;points in plotting coords
longstep  =  2.0
nlats     =  fix((90.-plot_lat_min)/latstep)
nlongs    =  fix(360./longstep)+1
zat_arr   =  (findgen(nlats)*latstep + plot_lat_min);*( int_hemi eq 0 ? 1. : -1. )
zon_arr   =  findgen(nlongs)*longstep
grid      =  transpose([[reform(rebin(zat_arr, nlats, nlongs), nlats*nlongs)], $
	[rebin(zon_arr, nlats*nlongs, /sample)]])
pot_arr   =  fltarr(nlongs,nlats)

; convert to spherical coordinates
; i.e. azimuth and polar angle
theta  = (90.-reform(grid[0,*]))*!dtor
phi    = reform(grid[1,*])*!dtor
tprime =  norm_theta(theta, tmax)
x      =  cos(tprime)
plm    =  eval_legendre(order, x)
v      =  rad_map_eval_potential(coeffs[*,2], plm, phi)
pot_arr = transpose(reform(v, nlats, nlongs))/1000.

if (lat_shft eq 0) then iflg_coord = 1
if (lat_shft ne 0) then iflg_coord = 0

if (iflg_coord eq 1) then begin			;plot in primed coords

  q = where(zat_arr le abs(latmin), qc)		;set to zero below latmin
  if (qc ne 0) then pot_arr[*,q[0]:q[qc-1]] = 0.

endif

if (iflg_coord eq 0) then begin			;plot in unprimed coords

  npnts      =  nlongs * nlats
  kaz        =  fltarr(npnts)
  grid = crd_shft(grid, lon_shft, lat_shft, kaz)
  xon_arr_p  =  fltarr(nlongs,nlats)
  xat_arr_p  =  fltarr(nlongs,nlats)
	xon_arr_p = transpose(reform(reform(grid[1,*], nlats, nlongs)))
	xat_arr_p = transpose(reform(reform(grid[0,*], nlats, nlongs)))

  q = where(xat_arr_p le abs(latmin), qc)		;zero pot below latmin
  if (qc ne 0) then pot_arr[q] = 0.

endif

return, {potarr:pot_arr, zatarr:zat_arr, zonarr:zon_arr}

end
