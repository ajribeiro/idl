;+ 
; NAME: 
; DST_READ
;
; PURPOSE: 
; This procedure reads DST index data into the variables of the structure DST_DATA in
; the common block DST_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; DST_READ, Date
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
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; DST_DATA_BLK: The common block holding the currently loaded radar data and 
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
; Based on Steve Milan's READ_FILES.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro dst_read, date, time=time, long=long, $
	silent=silent, force=force

common dst_data_blk

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
dst_info.nrecs = 0L

; check if parameters are given
if n_params() lt 1 then begin
	prinfo, 'Must give date.'
	return
endif

if ~keyword_set(force) && dst_check_loaded(date, time=time, long=long) then $
	return

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

if size(date, /type) eq 7 then begin
	parse_str_date, date, ndate
	if n_elements(ndate) eq 0 then $
		return
	date = ndate
endif

sfjul, date, time, sjul, fjul, no_months=nm
caldat, sjul, mm, dd, yy, hh, ii, ss

tmp_dst  = make_array(24L*31L*nm, /int, value=-9999)
tmp_juls = make_array(24L*31L*nm, /double, value=-9999.d)
tt_dst = make_array(24*31, /int)

for i=0L, nm-1L do begin

	caldat, julday(mm+i, 01, yy), nmm, dd, nyy

	ad = nyy*100L + nmm
	str_date = string(ad,format='(I6)')
	
	if ~keyword_set(datdi) then $
		adatdi = dst_get_path(nyy) $
	else $
		adatdi = datdi

	if ~file_test(adatdi, /dir) then begin
		prinfo, 'Data directory does not exist: ', adatdi, /force
		continue
	endif

	filename = file_select(adatdi+'/'+str_date+'_dst.dat', $
		success=success)
	if ~success then begin
		prinfo, 'Data file not found.'
		continue
	endif
	
	if ~keyword_set(silent) then $
		prinfo, 'Reading ', filename
	
	openr, il, filename, /get_lun
	readu, il, tt_dst
	free_lun, il
	
	tmp_dst[i*24L*31L:(i+1L)*24L*31L-1L] = tt_dst
	tt = timegen(start=julday(nmm, 1, nyy, 0, 0, 0), final=julday(nmm+1, 0, nyy, 23, 0, 0), $
		unit='H', step=1)
	;tt = timegen(start=julday(nmm, 1, nyy, 1), final=julday(nmm+1, 1, nyy, 0, 1), $
	;	unit='H', step=1)
	ntt = n_elements(tt)
	tmp_juls[i*24L*31L:i*24L*31L+ntt-1L] = tt

endfor

good = where(tmp_juls gt -9999.d, ng)
if ng eq 0 then $
	return
tjuls = tmp_juls[good]
tdst  = tmp_dst [good]

; dst is given every hour
; so if the time span is less than 1 hour
; we need to adjust
dur = ( fjul - sjul ) * 24.d
adfac = ( (1. - dur)/24. ) > 0.
jinds = where(tjuls ge sjul-adfac and tjuls le fjul+adfac, cc)
if cc eq 0 then begin
	prinfo, 'No data found.'
	return
endif

juls = tjuls[jinds]
dst  = tdst [jinds]

tdst_data = { $
	juls: dblarr(cc), $
	dst_index: fltarr(cc) $
}

tdst_data.juls = juls
tdst_data.dst_index = dst
dst_data = tdst_data

dst_info.sjul = juls[0L]
dst_info.fjul = juls[cc-1L]
dst_info.nrecs = cc

end
