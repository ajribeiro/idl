;+ 
; NAME: 
; THE_MFP_CALC
;
; PURPOSE: 
; This procedure calculates the magnetic footprint of the Themis probes based on the 
; position data and puts the magnetic footprint (MFP) into the variables of the structure THE_MFP_DATA in
; the common block THE_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; THE_MFP_CALC, Date
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; KEYWORD PARAMETERS:
; TIME: The time range for which to read data. Must be a 2-element vector in 
; HHII format, or HHIISS format if the LONG keyword is set. If TIME is not set
; the default value [0000,2400] is assumed.
;
; LONG: Set this keyword to indicate that the Time value is in HHIISS
; format rather than HHII format.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; PARAM: A 10-element numeric array hloding the input parameters for the
; chosen Tsyganenko model. See the documentation for trace2iono for further details.
;
; MODEL: A string specifying the Tsyganenko model to use. Default is 't96'. 
; See the documentation for trace2iono for further details.
;
; PROCEDURE:
; The routine calls TRACE2IONO to do the tracing depending on the model and param
; input. The MFG in the southern and northern hemisphere
; is then stored in the THE_MFP_DATA structure in geographic and magnetic
; coordinates.
;
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; THE_MFG_BLK: The common block holding the currently loaded Themis data and 
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
;-
pro the_mfp_calc, date, time=time, long=long, $
	param=param, model=model, silent=silent

common the_data_blk

if ~keyword_set(date) then begin
	prinfo, 'Must give date.'
	return
endif

if n_elements(time) eq 0 then $
	time = [0,2400]
sfjul, date, time, sjul, fjul, long=long
zero_epoch = julday(1,1,1970,0)
trange = ([sjul,fjul]-zero_epoch)*86400.d
timespan, trange

if ~keyword_set(model) then $
	model = 't96'

if ~keyword_set(param) then begin
	par = fltarr(10)
	if model eq 't89' then $
		par[0] = 2.
	if model eq 't96' then begin
		par[0] = 2.
		par[1] = -10.
		par[2] = 0.001
		par[3] = 0.001
	endif
endif else $
	par = param

probes = ['a','b','c','d','e']

for i=0, 4 do begin
	probe = probes[i]
	if the_mfp_check_loaded(date, probe, model, time=time, long=long) then $
		continue
	if the_pos_info[i].nrecs lt 1L then begin
		prinfo, 'No position data loaded for probe '+probe
		continue
	endif
	adstruc = (*the_pos_data[i])
	inds = where(adstruc.juls ge sjul and adstruc.juls le fjul, cc)
	if cc lt 1L then begin
		prinfo, 'No position data found in time range for probe '+probe
		continue
	endif
	tjuls = adstruc.juls[inds]
	if ptr_valid(the_mfp_data[i]) then $
		ptr_free, the_mfp_data[i]
	tarr = (adstruc.juls[inds]-zero_epoch)*86400.d
	parr = [ $
		[adstruc.rx[inds]], $
		[adstruc.ry[inds]], $
		[adstruc.rz[inds]] $
	]
	if ~keyword_set(silent) then $
		prinfo, 'Tracing probe '+probe+' North.'
	trace2iono, tarr, parr, n_oarr, external_model=model, internal_model='igrf', $
		in_coord=the_pos_info[i].coords, out_coord='geo', par=par
	xyz_to_polar, n_oarr, mag=tn_alt, theta=tn_glat, phi=tn_glon
	;tmp = cnvcoord(transpose([[tn_glat], [tn_glon], [tn_alt]]))
	tmp = cnvcoord(tn_glat,tn_glon,tn_alt)
	tn_mlat = reform(tmp[0,*])
	tn_mlon = reform(tmp[1,*])
	if ~keyword_set(silent) then $
		prinfo, 'Tracing probe '+probe+' South.'
	trace2iono, tarr, parr, s_oarr, external_model=model, internal_model='igrf', $
		in_coord=the_pos_info[i].coords, out_coord='geo', par=par, /south
	xyz_to_polar, s_oarr, mag=ts_alt, theta=ts_glat, phi=ts_glon
	;tmp = cnvcoord(transpose([[ts_glat], [ts_glon], [ts_alt]]))
	tmp = cnvcoord(ts_glat,ts_glon,ts_alt)
	ts_mlat = reform(tmp[0,*])
	ts_mlon = reform(tmp[1,*])
	tstruc = { $
		juls: tjuls, $
		n_glat: tn_glat, $
		n_glon: tn_glon, $
		n_mlat: tn_mlat, $
		n_mlon: tn_mlon, $
		n_alt: tn_alt, $
		s_glat: ts_glat, $
		s_glon: ts_glon, $
		s_mlat: ts_mlat, $
		s_mlon: ts_mlon, $
		s_alt: ts_alt $
	}
	the_mfp_data[i] = ptr_new(tstruc)
	the_mfp_info[i].sjul = tjuls[0]
	the_mfp_info[i].fjul = tjuls[cc-1L]
	the_mfp_info[i].model = model
	the_mfp_info[i].nrecs = cc
endfor

end
