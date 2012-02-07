;+
; NAME: 
; GET_DEFAULT_RANGE
; 
; PURPOSE: 
; This function returns the default range for some parameters, like the variables
; in RAD_FIT_DATA, OMN_DATA and DST_DATA. 
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; Result = GET_DEFAULT_RANGE(Parameter)
;
; INPUTS:
; Parameter: A parameter.
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
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
function get_default_range, parameter

common rad_data_blk

latrange = [55,75]
gatrange = [00,75]

data_index = rad_fit_get_data_index()
if data_index ge 0 then begin
	gatrange = [0,(*rad_fit_info[data_index]).ngates]
	rlat = ( strcmp(parameter, 'geog', /fold) ? (*rad_fit_info[data_index]).glat : (*rad_fit_info[data_index]).mlat )
	latrange = rlat + (rlat lt 0. ? -1. : 1.)*[2.,22.]
endif

; check input
if n_params() ne 1 then begin
	prinfo, 'Must give Parameter.'
	return, ''
endif

if strcmp(strlowcase(parameter), 'power') then $
	return, [0,30] $
else if strcmp(strlowcase(parameter), 'lag0power') then $
	return, [0,30] $
else if strcmp(strlowcase(parameter), 'velocity') then $
	return, [-500,500] $
else if strcmp(strlowcase(parameter), 'velocity_error') then $
	return, [0,100] $
else if strcmp(strlowcase(parameter), 'width') then $
	return, [0,100] $
else if strcmp(strlowcase(parameter), 'phi0') then $
	return, [-!pi,!pi] $
else if strcmp(strlowcase(parameter), 'elevation') then $
	return, [10,30] $
else if strcmp(strlowcase(parameter), 'tfreq') then $
	return, [6,16] $
else if strcmp(strlowcase(parameter), 'noise') then $
	return, [1,1e5] $
else if strcmp(strlowcase(parameter), 'nave') then $
	return, [0,60] $
else if strcmp(strlowcase(parameter), 'npoints') then $
	return, [1e1,1e3] $
else if strcmp(strlowcase(parameter), 'potential') then $
	return, [0,1e2] $
else if strcmp(strlowcase(parameter), 'gate') then $
	return, gatrange $
else if strcmp(strlowcase(parameter), 'rang') then $
	return, [0,3000] $
else if strcmp(strlowcase(parameter), 'geog') then $
	return, latrange $
else if strcmp(strlowcase(parameter), 'magn') then $
	return, latrange $
else if strcmp(strlowcase(parameter), 'dst_index') then $
	return, [-100,20] $
else if strcmp(strlowcase(parameter), 'kp_index') then $
	return, [0,9] $
else if strcmp(strlowcase(parameter), 'aur_index') then $
	return, [-500,500] $
else if strcmp(strlowcase(parameter), 'bx_gse') then $
	return, [-10,10] $
else if strcmp(strlowcase(parameter), 'by_gse') then $
	return, [-10,10] $
else if strcmp(strlowcase(parameter), 'bz_gse') then $
	return, [-10,10] $
else if strcmp(strlowcase(parameter), 'by_gsm') then $
	return, [-10,10] $
else if strcmp(strlowcase(parameter), 'bz_gsm') then $
	return, [-10,10] $
else if strcmp(strlowcase(parameter), 'bt') then $
	return, [0,10] $
else if strcmp(strlowcase(parameter), 'ex_gse') then $
	return, [-5,5] $
else if strcmp(strlowcase(parameter), 'ey_gse') then $
	return, [-5,5] $
else if strcmp(strlowcase(parameter), 'ez_gse') then $
	return, [-5,5] $
else if strcmp(strlowcase(parameter), 'ey_gsm') then $
	return, [-5,5] $
else if strcmp(strlowcase(parameter), 'ez_gsm') then $
	return, [-5,5] $
else if strcmp(strlowcase(parameter), 'et') then $
	return, [0,10] $
else if strcmp(strlowcase(parameter), 'brad') then $
	return, [-60,60] $
else if strcmp(strlowcase(parameter), 'bazm') then $
	return, [-40,40] $
else if strcmp(strlowcase(parameter), 'bfie') then $
	return, [0,200] $
else if strcmp(strlowcase(parameter), 'vx_gse') then $
	return, [-800,300] $
else if strcmp(strlowcase(parameter), 'vy_gse') then $
	return, [-100,100] $
else if strcmp(strlowcase(parameter), 'vz_gse') then $
	return, [-100,100] $
else if strcmp(strlowcase(parameter), 'vy_gsm') then $
	return, [-100,100] $
else if strcmp(strlowcase(parameter), 'vz_gsm') then $
	return, [-100,100] $
else if strcmp(strlowcase(parameter), 'vt') then $
	return, [300,800] $
else if strcmp(strlowcase(parameter), 'np') then $
	return, [0,20] $
else if strcmp(strlowcase(parameter), 'pd') then $
	return, [0,20] $
else if strcmp(strlowcase(parameter), 'beta') then $
	return, [0,40] $
else if strcmp(strlowcase(parameter), 'tpr') then $
	return, [0,1e6] $
else if strcmp(strlowcase(parameter), 'ma') then $
	return, [0,50] $
else if strcmp(strlowcase(parameter), 'asi') then $
	return, [2e3,3e4] $
else if strcmp(strlowcase(parameter), 'cone_angle') then $
	return, [0,90] $
else if strcmp(strlowcase(parameter), 'clock_angle') then $
	return, [-180,180] $
else $
	prinfo, 'Unknown parameter: '+parameter, /force

return, [0,0]

end
