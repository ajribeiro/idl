;+ 
; NAME: 
; TEC_READ
;
; PURPOSE: 
; This procedure reads TEC data into the variables of the structure TEC_DATA in
; the common block TEC_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; TEC_READ, Date
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
; FORCE: If this keyword is set, the data is even if it was already in
; memory, i.e. the output of TEC_CHECK_LOADED is ignored.
;
; FILENAME: Set this keyword to a valid file name and TEC_READ will attempt
; to read the data from that file. Obviously, for this to work the file
; structure must be the same as the global one.
;
; FILEDATE: If FILENAME is given, TEC_READ will attempt to parse the 
; date of the data from the filename. If that is not possible, give the 
; date via this keyword.
;
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; TEC_DATA_BLK: The common block holding GPS TEC data.
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
; Modified by Evan Thomas, April 6, 2011
;-
pro tec_read, date, time=time, long=long, $
	silent=silent, force=force, $
	filename=filename, filedate=filedate

common tec_data_blk

; Set nrecs to zero such that
; you have a way of checking
; whether data was loaded.
tec_info.nrecs = 0L

if keyword_set(time) then $
	if time[1] gt 2400 then $
		time[1] = time[1]-2400

if ~keyword_set(filename) then begin
	; check if parameters are given
	if n_params() lt 1 then begin
		prinfo, 'Must give date.'
		return
	endif

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = tec_check_loaded(date, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = tec_find_files(date, time=time, long=long, file_count=fc)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+format_date(date)+$
				', '+format_time(time)
		return
	endif
	no_delete = !false
endif else begin
	fc = n_elements(filename)
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

if n_elements(files) eq 1 then begin
	parse_str_date,strmid(files,18,8),_date
endif else $
	_date = date

NFILERECS = 2740925L ;?????
sfjul, date, time, sjul, fjul, no_d=nd
MAX_RECS = NFILERECS*nd

; init temporary arrays
tmp_hr=intarr(MAX_RECS)
tmp_min=intarr(MAX_RECS)
tmp_juls=dblarr(MAX_RECS)
tmp_glat=intarr(MAX_RECS)
tmp_glon=intarr(MAX_RECS)
tmp_tec=fltarr(MAX_RECS)
tmp_dtec=fltarr(MAX_RECS)

nrecs=0L
old_nrecs=0L
parse_date,_date,year,month,day


; read files
for i=0, fc-1 do begin
	if ~keyword_set(silent) then $
		prinfo, 'Reading '+files[i]

	; Read GPS TEC data from tec.dat.zip file
	openr,unit,files[i],/compress,/get_lun

	readu,unit,old_nrecs

	_hr=intarr(old_nrecs)
	_min=intarr(old_nrecs)
	_glat=intarr(old_nrecs)
	_glon=intarr(old_nrecs)
	_tec=fltarr(old_nrecs)
	_dtec=fltarr(old_nrecs)

	readu,unit,_hr,_min,_glat,_glon,_tec,_dtec

	free_lun,unit

	; how much data was read
	tnrecs = n_elements(_hr)
	if tnrecs lt 1L then $
		continue

	; help, nrecs, tnrecs, MAX_RECS
	if tnrecs gt MAX_RECS then $
		tnrecs = MAX_RECS

	tmp_hr[nrecs:nrecs+tnrecs-1L] = _hr[0:tnrecs-1L]
	tmp_min[nrecs:nrecs+tnrecs-1L] = _min[0:tnrecs-1L]
	tmp_juls[nrecs:nrecs+tnrecs-1L] = julday(month[0],day[0]+i,year[0],_hr,_min,30)
	tmp_glat[nrecs:nrecs+tnrecs-1L] = _glat[0:tnrecs-1L]
	tmp_glon[nrecs:nrecs+tnrecs-1L] = _glon[0:tnrecs-1L]
	tmp_tec[nrecs:nrecs+tnrecs-1L] = _tec[0:tnrecs-1L]
	tmp_dtec[nrecs:nrecs+tnrecs-1L] = _dtec[0:tnrecs-1L]
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

jinds = where(tmp_juls ge sjul and tmp_juls le fjul, ccc)
if ccc lt 1L then begin
	prinfo, 'No data found between '+format_date(date) +' and '+format_time(time)
	return
endif


; Make new structure for data
ttec_data = { $
	juls: dblarr(ccc), $
	glat: intarr(ccc), $
	glon: intarr(ccc), $
	tec: fltarr(ccc), $
	dtec: fltarr(ccc), $
	map_no: intarr(ccc) $
}

; Distribute data in structure
ttec_data.juls = (tmp_juls[0:nrecs-1L])[jinds]
ttec_data.glat = (tmp_glat[0:nrecs-1L])[jinds]
ttec_data.glon = (tmp_glon[0:nrecs-1L])[jinds]
ttec_data.tec = (tmp_tec[0:nrecs-1L])[jinds]
ttec_data.dtec = (tmp_dtec[0:nrecs-1L])[jinds]

; Calculate indices for each new map
tmp = uniq(ttec_data.juls)
ttec_data.map_no[0L:tmp[0]] = 0
for i=0, n_elements(tmp)-2 do begin
	ttec_data.map_no[tmp[i]+1L:tmp[i+1]] = i+1
endfor

; put new structure in common block
tec_data = ttec_data

; Populate with data
tec_info.nrecs = nrecs
tec_info.sjul = tec_data.juls[0]
tec_info.fjul = tec_data.juls[ccc-1L]

end


