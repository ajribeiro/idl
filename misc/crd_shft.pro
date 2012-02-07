;+
; NAME: 
; CRD_SHFT
;
; PURPOSE: 
; This function shifts all input points by a certain amount in latitude and longitude.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE:
; Result = CRD_SHFT(Grid, Lon_shft, Lat_shft, Kaz)
;
; INPUTS:
; Grid: A (2,N) element vector containing the latitude and logitude coordinates
; of N point in the grid to shift.
;
; Lon_shft: The shift in longitude in degree.
;
; Lat_shft: The shift in latitude in degree.
;
; Kaz: Something...
;
; KEYWORD PARAMETERS:
; NKAZ: Set this to a named variable that will contain the new values from kaz.
;
; OUTPUTS:
; Returns the shifted grid positions.
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
function crd_shft, grid, lon_shft, lat_shft, kaz, nkaz=nkaz

ss = size(grid, /dim)
npnts = ss[1]

lat   =  fltarr(npnts)
lon   =  fltarr(npnts)
vazm  =  fltarr(npnts)
lat   =  grid[0,0:npnts-1]
lon   =  grid[1,0:npnts-1]
vazm  =  kaz[0:npnts-1]
ngrid = grid

lon_min  =    0.
lon_max  =  360.

lon      =  lon + lon_shft
lon = check_lon(lon, lon_min, lon_max)

if (lat_shft eq 0.) then begin
	print,' lat_shift is set to zero!'
	print,' this call to crd_shft is unneccesary..but continuing..'
endif else begin 
	a_side = (90.-lat) * !pi/180.				;colat
	B_angl = (180.-lon) * !pi/180.				;lon
	d_side =  lat_shft * !pi/180.				;shift

	arg    =  cos(a_side)*cos(d_side) + sin(a_side)*sin(d_side)*cos(B_angl)
	q = where (abs(arg) gt 1., qcnt)
	if (qcnt ne 0) then arg[q] = arg[q]/abs(arg[q]) 

	b_side =  acos(arg)
	q = where(b_side eq 0., qc)			;adjust for point on pole
	if (qc ne 0) then b_side[q] = 0.1

	arg    = (cos(a_side)-cos(b_side)*cos(d_side))/(sin(b_side)*sin(d_side))
	q      =  where (abs(arg) gt 1., qcnt)
	if (qcnt ne 0) then arg[q] = arg[q]/abs(arg[q]) 

	A_angl =   acos(arg)

	q      =  where (lon gt 180., qcnt)			;acos ambiguity
	if (qcnt ne 0) then A_angl[q] = 2*!pi - A_angl[q]

	lon    =  A_angl * 180/!pi
	lat    =  (!pi/2.-b_side) * 180./!pi

	arg    = (cos(d_side)-cos(a_side)*cos(b_side))/(sin(a_side)*sin(b_side))
	q      =  where (abs(arg) gt 1., qcnt)
	if (qcnt ne 0) then arg[q] = arg[q]/abs(arg[q]) 

	C_angl =  acos(arg)
	sign_d =  d_side/abs(d_side)

	q      =  where (lon le 180., qcnt)			
	if (qcnt ne 0) then vazm[q] = vazm[q] - sign_d*C_angl[q]*180./!pi

	q      =  where (lon gt 180., qcnt)			
	if (qcnt ne 0) then vazm[q] = vazm[q] + sign_d*C_angl[q]*180./!pi

endelse

lon    =  lon - lon_shft
lon = check_lon(lon, lon_min, lon_max)

ngrid[0,0:npnts-1] = lat
ngrid[1,0:npnts-1] = lon
nkaz               = vazm

END
