;+ 
; NAME: 
; WND_MAG_READ
;
; PURPOSE: 
; This procedure reads Wind MAG data into the variables of the structure WND_MAG_DATA in
; the common block WND_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; WND_MAG_READ, Date
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
; WND_DATA_BLK: The common block holding the currently loaded OMNI data and 
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
; Changed to 1 minute format, 13 Jan, 2010
;-
pro wnd_mag_read, date, time=time, long=long, $
	silent=silent, force=force, $
	filename=filename, filedate=filedate

common wnd_data_blk

wnd_mag_info.nrecs = 0L

; resolution is 3 seconds, hence one day
; has about 28800 data records
NFILERECS = 28800L

if ~keyword_set(filename) then begin
	; check if parameters are given
	if n_params() lt 1 then begin
		prinfo, 'Must give date.'
		return
	endif

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = wnd_mag_check_loaded(date, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = wnd_mag_find_files(date, time=time, long=long, file_count=fc)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+format_date(date)+$
				', '+format_time(time)
		return
	endif
	no_delete = !false
endif else begin
	fc = n_elements(filename)
	; wi_h0_mfi_20090303_v10.cdf
	for i=0, fc-1 do begin
		if ~file_test(filename[i]) then begin
			prinfo, 'Cannot find file: '+filename[i]
			return
		endif
		if keyword_set(filedate) then $
			date = filedate $
		else begin
			bfile = file_basename(filename[i])
			date = long(strmid(bfile, 10, 8))
		endelse
	endfor
	files = filename
endelse

sfjul, date, time, sjul, fjul, no_d=nd, long=long
MAX_RECS = NFILERECS*nd

; init temporary arrays
juls = dblarr(MAX_RECS)
bx_gse = fltarr(MAX_RECS)
by_gse = fltarr(MAX_RECS)
bz_gse = fltarr(MAX_RECS)
by_gsm = fltarr(MAX_RECS)
bz_gsm = fltarr(MAX_RECS)
bt = fltarr(MAX_RECS)
rx_gse = fltarr(MAX_RECS)
ry_gse = fltarr(MAX_RECS)
rz_gse = fltarr(MAX_RECS)
ry_gsm = fltarr(MAX_RECS)
rz_gsm = fltarr(MAX_RECS)
rt = fltarr(MAX_RECS)
nrecs = 0L

; read files
for i=0, fc-1 do begin

	if ~keyword_set(silent) then $
		prinfo, 'Reading '+files[i]

	data = cdf_read(files[i], ['Epoch3','B3GSM','B3GSE','Epoch','PGSM','PGSE'], /silent)

	; exit if all read
	if size(data, /type) ne 8 then $
		continue

	; how much data was read
	tnrecs = n_elements(data.epoch3[0,*])
	if tnrecs lt 1L then $
		continue

;	help, nrecs, tnrecs, MAX_RECS

	juls[nrecs:nrecs+tnrecs-1L] = cdf_epoch2jul(reform(data.epoch3[0,*]))
	bx_gse[nrecs:nrecs+tnrecs-1L] = data.b3gse[0,*]
	by_gse[nrecs:nrecs+tnrecs-1L] = data.b3gse[1,*]
	bz_gse[nrecs:nrecs+tnrecs-1L] = data.b3gse[2,*]
	by_gsm[nrecs:nrecs+tnrecs-1L] = data.b3gsm[1,*]
	bz_gsm[nrecs:nrecs+tnrecs-1L] = data.b3gsm[2,*]
	bt[nrecs:nrecs+tnrecs-1L] = sqrt(total(data.b3gse^2, 1))
	ttjuls = cdf_epoch2jul(reform(data.epoch[0,*]))
	rx_gse[nrecs:nrecs+tnrecs-1L] = interpol(data.pgse[0,*], ttjuls, juls[nrecs:nrecs+tnrecs-1L])
	ry_gse[nrecs:nrecs+tnrecs-1L] = interpol(data.pgse[1,*], ttjuls, juls[nrecs:nrecs+tnrecs-1L])
	rz_gse[nrecs:nrecs+tnrecs-1L] = interpol(data.pgse[2,*], ttjuls, juls[nrecs:nrecs+tnrecs-1L])
	ry_gsm[nrecs:nrecs+tnrecs-1L] = interpol(data.pgsm[1,*], ttjuls, juls[nrecs:nrecs+tnrecs-1L])
	rz_gsm[nrecs:nrecs+tnrecs-1L] = interpol(data.pgsm[2,*], ttjuls, juls[nrecs:nrecs+tnrecs-1L])
	rt[nrecs:nrecs+tnrecs-1L] = sqrt( (rx_gse[nrecs:nrecs+tnrecs-1L])^2 + (ry_gse[nrecs:nrecs+tnrecs-1L])^2 + (rz_gse[nrecs:nrecs+tnrecs-1L])^2 )
	nrecs += tnrecs
	
	; if temporary arrays are too small, warn and break
	if nrecs gt MAX_RECS then begin
		prinfo, 'To many data records in file for initialized array. Truncating.'
		break
	endif

endfor

if nrecs lt 1L then begin
	prinfo, 'No real data read.'
	return
endif

jinds = where(juls ge sjul and juls le fjul, ccc)
if ccc lt 1L then begin
	prinfo, 'No data found between '+format_date(date) +' and '+format_time(time)
	return
endif

; set up temporary structure
twnd_mag_data = { $
	juls: dblarr(ccc), $
	bx_gse: fltarr(ccc), $
	by_gse: fltarr(ccc), $
	bz_gse: fltarr(ccc), $
	by_gsm: fltarr(ccc), $
	bz_gsm: fltarr(ccc), $
	bt: fltarr(ccc), $
	rx_gse: fltarr(ccc), $
	ry_gse: fltarr(ccc), $
	rz_gse: fltarr(ccc), $
	ry_gsm: fltarr(ccc), $
	rz_gsm: fltarr(ccc), $
	rt: fltarr(ccc) $
}

; populate structure
twnd_mag_data.juls = (juls[0:nrecs-1L])[jinds]
twnd_mag_data.bx_gse = (bx_gse[0:nrecs-1L])[jinds]
twnd_mag_data.by_gse = (by_gse[0:nrecs-1L])[jinds]
twnd_mag_data.bz_gse = (bz_gse[0:nrecs-1L])[jinds]
twnd_mag_data.by_gsm = (by_gsm[0:nrecs-1L])[jinds]
twnd_mag_data.bz_gsm = (bz_gsm[0:nrecs-1L])[jinds]
twnd_mag_data.bt = (bt[0:nrecs-1L])[jinds]
twnd_mag_data.rx_gse = (rx_gse[0:nrecs-1L])[jinds]
twnd_mag_data.ry_gse = (ry_gse[0:nrecs-1L])[jinds]
twnd_mag_data.rz_gse = (rz_gse[0:nrecs-1L])[jinds]
twnd_mag_data.ry_gsm = (ry_gsm[0:nrecs-1L])[jinds]
twnd_mag_data.rz_gsm = (rz_gsm[0:nrecs-1L])[jinds]
twnd_mag_data.rt = (rt[0:nrecs-1L])[jinds]

inds = where(twnd_mag_data.bx_gse lt -1e30, cc)
if cc gt 0L then $
	twnd_mag_data.bx_gse[inds] = !values.f_nan
inds = where(twnd_mag_data.by_gse lt -1e30, cc)
if cc gt 0L then $
	twnd_mag_data.by_gse[inds] = !values.f_nan
inds = where(twnd_mag_data.bz_gse lt -1e30, cc)
if cc gt 0L then $
	twnd_mag_data.bz_gse[inds] = !values.f_nan
inds = where(twnd_mag_data.by_gsm lt -1e30, cc)
if cc gt 0L then $
	twnd_mag_data.by_gsm[inds] = !values.f_nan
inds = where(twnd_mag_data.bz_gsm lt -1e30, cc)
if cc gt 0L then $
	twnd_mag_data.bz_gsm[inds] = !values.f_nan
inds = where(twnd_mag_data.bt lt -1e30, cc)
if cc gt 0L then $
	twnd_mag_data.bt[inds] = !values.f_nan

; replace old data structure with new one
wnd_mag_data = twnd_mag_data

wnd_mag_info.sjul = wnd_mag_data.juls[0L]
wnd_mag_info.fjul = wnd_mag_data.juls[ccc-1L]
wnd_mag_info.nrecs = ccc

end
