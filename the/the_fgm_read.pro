;+ 
; NAME: 
; THE_FGM_READ
;
; PURPOSE: 
; This procedure reads Themis FGM data into the variables of the structure THE_FGM_DATA in
; the common block THE_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; THE_FGM_READ, Date
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
; The routine calls THM_LOAD_FGM to do all the reading and converting of coordinate
; systems. The read data is then place in the THE_DATA_BLK common block.
;
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; THE_FGM_BLK: The common block holding the currently loaded Themis data and 
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
pro the_fgm_read, date, time=time, long=long, $
	force=force, silent=silent, datatype=datatype

common the_data_blk

for i=0, 4 do $
	the_fgm_info[i].nrecs = 0L

if ~keyword_set(date) then begin
	prinfo, 'Must give date.'
	return
endif

if ~keyword_set(datatype) then $
	datatype = 'fgs'

if n_elements(time) eq 0 then $
	time = [0,2400]
sfjul, date, time, sjul, fjul, long=long
zero_epoch = julday(1,1,1970,0)
trange = ([sjul,fjul]-zero_epoch)*86400.d
timespan, trange

probes = ['a','b','c','d','e']

for i=0, 4 do begin
	probe = probes[i]
	if ~keyword_set(force) then begin
		if the_fgm_check_loaded(date, probe, time=time, long=long) then $
			continue
	endif
	if ptr_valid(the_fgm_data[i]) then $
		ptr_free, the_fgm_data[i]
	thm_load_fgm, datatype=datatype, coord='gse', probe=probe, trange=trange
	get_data, 'th'+probe+'_'+datatype+'_gse', fgm_time, fgm_gse
	thm_load_fgm, datatype=datatype, coord='gsm', probe=probe, trange=trange
	get_data, 'th'+probe+'_'+datatype+'_gsm', fgm_time, fgm_gsm
	fgm_juls = fgm_time/86400.d + zero_epoch
	if n_elements(fgm_gse) eq 1L then begin
		tmp_struc = { $
			juls: -1.d, $
			bx_gse: -1.d, $
			by_gse: -1.d, $
			bz_gse: -1.d, $
			by_gsm: -1.d, $
			bz_gsm: -1.d, $
			bt: -1.d $
		}
		nrecs = 0L
	endif else begin
		tmp_struc = { $
			juls: fgm_juls, $
			bx_gse: reform(fgm_gse[*,0]), $
			by_gse: reform(fgm_gse[*,1]), $
			bz_gse: reform(fgm_gse[*,2]), $
			by_gsm: reform(fgm_gsm[*,1]), $
			bz_gsm: reform(fgm_gsm[*,2]), $
			bt: sqrt(total(fgm_gse^2, 2)) $
		}
		nrecs = n_elements(fgm_juls)
		tpnames = tnames('th'+probe+'_'+datatype+'_*')
		store_data, tpnames, /delete
	endelse
	the_fgm_data[i] = ptr_new(tmp_struc)
	the_fgm_info[i].sjul = fgm_juls[0]
	the_fgm_info[i].fjul = fgm_juls[(nrecs-1L) > 0L]
	the_fgm_info[i].nrecs = nrecs
;1	stop
endfor

end
