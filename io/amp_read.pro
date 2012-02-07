;+ 
; NAME: 
; AMP_READ
;
; PURPOSE:
; This procedure reads AMPERE data into the variables of the structure AMP_DATA in
; the common block AMP_DATA_BLK. The time range for which data is read is controlled by
; the DATE and TIME keywords.
;
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; AMP_READ, Date
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
; NORTH: Set this keyword to read AMPERE data for the northern hemisphere only.
; This is the default.
;
; SOUTH: Set this keyword to read AMPERE data for the southern hemisphere only.
;
; HEMISPHERE: Set this keyword to 0 to read AMPERE data for the northern hemisphere only,
; set it to 1 to read grid data for the southern hemisphere only.
;
; BOTH: Set this keyword to read AMPERE data for the northern and southern hemisphere.
;
; FORCE: Set this keyword to read the data, even if it is already present in the
; AMP_DATA_BLK, i.e. even if AMP_CHECK_LOADED returns true.
;
; FILENAME: Set this to a string containing the name of the AMPERE file to read.
;
; FILEDATE: Set this to a date in YYYMMDD format to indicate that the file in FILENAME
; contains data from that date.
;
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; AMP_DATA_BLK: The common block holding the currently loaded AMPERE data and 
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
; Written by Lasse Clausen, Jan, 5, 2011
;-
pro amp_read, date, time=time, north=north, south=south, hemisphere=hemisphere, both=both, $
	long=long, silent=silent, filename=filename, filedate=filedate, force=force

; if the user wants to load both hemispheres
; just call AMP_READ with /NORTH, then /SOUTH and return
if keyword_set(both) then begin
	amp_read, date, time=time,/north, $
		long=long, silent=silent, filename=filename, filedate=filedate, force=force
	amp_read, date, time=time,/south, $
		long=long, silent=silent, filename=filename, filedate=filedate, force=force
	return
endif

common amp_data_blk

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

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
amp_info[int_hemi].nrecs = 0L

; check if parameters are given
if n_params() lt 1 then begin
	if ~keyword_set(filename) then begin
		prinfo, 'Must give date.'
		return
	endif
endif

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

if ~keyword_set(filename) then begin

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = amp_check_loaded(date, hemisphere, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = amp_find_files(date, hemisphere=hemisphere, time=time, $
		long=long, file_count=fc)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+format_date(date)+$
				', '+format_time(time)
		return
	endif

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
			date = long(strmid(bfile, 0, 8))
		endelse
	endfor
	files = filename

endelse

; maximum number of measurements per map
MAX_PTS = 1440L

sfjul, date, time, ds, df, no_days=nd
; calculate the maximum records the data array will hold
MAX_RECS = MAX_PTS*long(nd)

; make arrays holding data
sjuls    = make_array(MAX_RECS, /double)
mjuls    = make_array(MAX_RECS, /double)
fjuls    = make_array(MAX_RECS, /double)
nlon     = make_array(MAX_RECS, /int)
nlat     = make_array(MAX_RECS, /int)
colat    = make_array(MAX_RECS, MAX_PTS, /float)
mlt      = make_array(MAX_RECS, MAX_PTS, /float)
dbnorth1 = make_array(MAX_RECS, MAX_PTS, /float)
dbeast1  = make_array(MAX_RECS, MAX_PTS, /float)
dbnorth2 = make_array(MAX_RECS, MAX_PTS, /float)
dbeast2  = make_array(MAX_RECS, MAX_PTS, /float)
jr       = make_array(MAX_RECS, MAX_PTS, /float)
nrecs = 0L

for i=0, fc-1 do begin
	file_base = file_basename(files[i])
	if ~keyword_set(silent) then $
		prinfo, 'Reading '+file_base
	o_file = files[i]
	if strcmp(o_file, '') then $
		continue
	ilun = ncdf_open(o_file, /nowrite)
	if ilun eq 0 then begin
		prinfo, 'Could not open file: ' + files[i] + $
			'->('+o_file+')', /force
		continue
	endif
	; get info on the file
	file_inq = ncdf_inquire(ilun)
	; loop through the variables in the fiel in order to find the right ones
	for v=0, file_inq.nvars-1 do begin
		tmpstr = ncdf_varinq(ilun, v)
		if strcmp(tmpstr.name, 'nlat', /fold) then begin
			ncdf_varget, ilun, v, tnlat, count=mlat_count
			continue
		endif
		if strcmp(tmpstr.name, 'nlon', /fold) then begin
			ncdf_varget, ilun, v, tnlon, count=nlon_count
			continue
		endif
		if strcmp(tmpstr.name, 'end_yr', /fold) then begin
			ncdf_varget, ilun, v, tend_yr, count=end_yr_count
			continue
		endif
		if strcmp(tmpstr.name, 'end_mo', /fold) then begin
			ncdf_varget, ilun, v, tend_mo, count=end_mo_count
			continue
		endif
		if strcmp(tmpstr.name, 'end_dy', /fold) then begin
			ncdf_varget, ilun, v, tend_dy, count=end_dy_count
			continue
		endif
		if strcmp(tmpstr.name, 'end_hr', /fold) then begin
			ncdf_varget, ilun, v, tend_hr, count=end_hr_count
			continue
		endif
		if strcmp(tmpstr.name, 'end_mt', /fold) then begin
			ncdf_varget, ilun, v, tend_mt, count=end_mt_count
			continue
		endif
		if strcmp(tmpstr.name, 'end_sc', /fold) then begin
			ncdf_varget, ilun, v, tend_sc, count=end_sc_count
			continue
		endif
		if strcmp(tmpstr.name, 'start_yr', /fold) then begin
			ncdf_varget, ilun, v, tstart_yr, count=start_yr_count
			continue
		endif
		if strcmp(tmpstr.name, 'start_mo', /fold) then begin
			ncdf_varget, ilun, v, tstart_mo, count=start_mo_count
			continue
		endif
		if strcmp(tmpstr.name, 'start_dy', /fold) then begin
			ncdf_varget, ilun, v, tstart_dy, count=start_dy_count
			continue
		endif
		if strcmp(tmpstr.name, 'start_hr', /fold) then begin
			ncdf_varget, ilun, v, tstart_hr, count=start_hr_count
			continue
		endif
		if strcmp(tmpstr.name, 'start_mt', /fold) then begin
			ncdf_varget, ilun, v, tstart_mt, count=start_mt_count
			continue
		endif
		if strcmp(tmpstr.name, 'start_sc', /fold) then begin
			ncdf_varget, ilun, v, tstart_sc, count=start_sc_count
			continue
		endif
		if strcmp(tmpstr.name, 'colat', /fold) then begin
			ncdf_varget, ilun, v, tcolat, count=colat_count
			continue
		endif
		if strcmp(tmpstr.name, 'mlt', /fold) then begin
			ncdf_varget, ilun, v, tmlt, count=mlt_count
			continue
		endif
		if strcmp(tmpstr.name, 'dbnorth1', /fold) then begin
			ncdf_varget, ilun, v, tdbnorth1, count=dbnorth1_count
			continue
		endif
		if strcmp(tmpstr.name, 'dbeast1', /fold) then begin
			ncdf_varget, ilun, v, tdbeast1, count=dbeast1_count
			continue
		endif
		if strcmp(tmpstr.name, 'dbnorth2', /fold) then begin
			ncdf_varget, ilun, v, tdbnorth2, count=dbnorth2_count
			continue
		endif
		if strcmp(tmpstr.name, 'dbeast2', /fold) then begin
			ncdf_varget, ilun, v, tdbeast2, count=dbeast2_count
			continue
		endif
		if strcmp(tmpstr.name, 'jr', /fold) then begin
			ncdf_varget, ilun, v, tjr, count=jr_count
			continue
		endif
	endfor
  ncdf_close, ilun
	; stick the read data into the temporary arrays
	ndx = n_elements(tstart_yr)
	if nrecs + ndx gt MAX_RECS then begin
		prinfo, 'Array too small for all the data (MAX_RECS).'
		return
	endif
	ndy = n_elements(tmlt[*,0])
	if ndy gt MAX_PTS then begin
		MAX_PTS = ndy
		ncolat    = make_array(MAX_RECS, ndy, /float)
		ncolat[0:nrecs-1] = colat[0:nrecs-1, 0:MAX_PTS-1]
		colat = ncolat
		nmlt      = make_array(MAX_RECS, ndy, /float)
		nmlt[0:nrecs-1] = mlt[0:nrecs-1, 0:MAX_PTS-1]
		mlt = nmlt
		ndbnorth1 = make_array(MAX_RECS, ndy, /float)
		ndbnorth1[0:nrecs-1] = dbnorth1[0:nrecs-1, 0:MAX_PTS-1]
		dbnorth1 = ndbnorth1
		ndbeast1  = make_array(MAX_RECS, ndy, /float)
		ndbeast1[0:nrecs-1] = dbeast1[0:nrecs-1, 0:MAX_PTS-1]
		dbeast1 = ndbeast1
		ndbnorth2 = make_array(MAX_RECS, ndy, /float)
		ndbnorth2[0:nrecs-1] = dbnorth2[0:nrecs-1, 0:MAX_PTS-1]
		dbnorth2 = ndbnorth2
		ndbeast2  = make_array(MAX_RECS, ndy, /float)
		ndbeast2[0:nrecs-1] = dbeast2[0:nrecs-1, 0:MAX_PTS-1]
		dbeast2 = ndbeast2
		njr       = make_array(MAX_RECS, ndy, /float)
		njr[0:nrecs-1] = jr[0:nrecs-1, 0:MAX_PTS-1]
		jr = njr
	endif
	sjuls[nrecs:nrecs+ndx-1] = julday(tstart_mo, tstart_dy, tstart_yr, tstart_hr, tstart_mt, tstart_sc)
	fjuls[nrecs:nrecs+ndx-1] = julday(tend_mo, tend_dy, tend_yr, tend_hr, tend_mt, tend_sc)
	mjuls[nrecs:nrecs+ndx-1] = ( sjuls[nrecs:nrecs+ndx-1] + fjuls[nrecs:nrecs+ndx-1] )/2.d
	nlon[nrecs:nrecs+ndx-1]  = tnlon
	nlat[nrecs:nrecs+ndx-1]  = tnlat
	colat[nrecs:nrecs+ndx-1,0:ndy-1] = (transpose(tcolat))
	mlt[nrecs:nrecs+ndx-1,0:ndy-1] = (transpose(tmlt))
	dbnorth1[nrecs:nrecs+ndx-1,0:ndy-1] = (transpose(tdbnorth1))
	dbeast1[nrecs:nrecs+ndx-1,0:ndy-1] = (transpose(tdbeast1))
	dbnorth2[nrecs:nrecs+ndx-1,0:ndy-1] = (transpose(tdbnorth2))
	dbeast2[nrecs:nrecs+ndx-1,0:ndy-1] = (transpose(tdbeast2))
	jr[nrecs:nrecs+ndx-1,0:ndy-1] = (transpose(tjr))
	nrecs += ndx
endfor

if nrecs lt 1 then begin
	prinfo, 'No real data read.'
	return
endif

; set up temporary structure
amp_data_hemi = { $
	sjuls: dblarr(nrecs), $
	mjuls: dblarr(nrecs), $
	fjuls: dblarr(nrecs), $
	nlat: fltarr(nrecs), $
	nlon: fltarr(nrecs), $
	colat: fltarr(nrecs, MAX_PTS), $
	mlt: fltarr(nrecs, MAX_PTS), $
	dbnorth1: fltarr(nrecs, MAX_PTS), $
	dbeast1: fltarr(nrecs, MAX_PTS), $
	dbnorth2: fltarr(nrecs, MAX_PTS), $
	dbeast2: fltarr(nrecs, MAX_PTS), $
	jr: fltarr(nrecs, MAX_PTS), $
	p1: fltarr(nrecs, MAX_PTS), $
	p2: fltarr(nrecs, MAX_PTS), $
	poynting: fltarr(nrecs, MAX_PTS), $
	jr_fit_order: intarr(nrecs), $
	jr_fit_pos_r1: fltarr(nrecs, 24, 3), $
	jr_fit_pos_r2: fltarr(nrecs, 24, 3), $
	jr_fit_coeffs_r1: fltarr(nrecs, 9, 2), $
	jr_fit_coeffs_r2: fltarr(nrecs, 9, 2), $
	area_r1: fltarr(nrecs, 3), $
	area_r2: fltarr(nrecs, 3), $
	flux_r1: fltarr(nrecs, 3), $
	flux_r2: fltarr(nrecs, 3) $
}

; populate structure
amp_data_hemi.sjuls = sjuls[0:nrecs-1L]
amp_data_hemi.mjuls = mjuls[0:nrecs-1L]
amp_data_hemi.fjuls = fjuls[0:nrecs-1L]
amp_data_hemi.nlat = nlat[0:nrecs-1L]
amp_data_hemi.nlon = nlon[0:nrecs-1L]
amp_data_hemi.colat = colat[0:nrecs-1L,*]
amp_data_hemi.mlt = mlt[0:nrecs-1L,*]
amp_data_hemi.dbnorth1 = dbnorth1[0:nrecs-1L,*]
amp_data_hemi.dbeast1 = dbeast1[0:nrecs-1L,*]
amp_data_hemi.dbnorth2 = dbnorth2[0:nrecs-1L,*]
amp_data_hemi.dbeast2 = dbeast2[0:nrecs-1L,*]
amp_data_hemi.jr = jr[0:nrecs-1L,*]

; replace pointer to old data structure
; and first all the pointers inside that pointer
if ptr_valid(amp_data[int_hemi]) then begin
	ptr_free, amp_data[int_hemi]
endif
amp_data[int_hemi] = ptr_new(amp_data_hemi)

amp_info[int_hemi].sjul = (*amp_data[int_hemi]).mjuls[0L]
amp_info[int_hemi].fjul = (*amp_data[int_hemi]).mjuls[nrecs-1L]
amp_info[int_hemi].nrecs = nrecs
amp_info[int_hemi].poynting = !false

END
