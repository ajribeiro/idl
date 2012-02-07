;+ 
; NAME: 
; RAD_RAW_READ
;
; PURPOSE: 
; This procedure reads radar rawacf/dat data into the variables of the structure RAD_RAW_DATA in
; the common block RAD_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RAD_RAW_READ, Date, Radar
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; Radar: Set this to a 3-letter radar code to indicate the radar for which to read
; data.
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
; FILENAME: Set this to a string containing the name of the rawacf/dat file to read.
;
; FILEOLDDAT: Set this keyword to indicate that the file in FILENAME is in the old
; dat file format.
;
; FILERAWACF: Set this keyword to indicate that the file in FILENAME is in rawacf
; file format
;
; FILERADAR: Set this to a string containing the radar from which the rawacf/dat file to read.
;
; FILEDATE: Set this to a string containing the date from which the rawacf/dat file to read.
;
; FORCE: Set this keyword to read the data, even if it is already present in the
; RAD_DATA_BLK, i.e. even if RAD_RAW_CHECK_LOADED returns true.
;
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding the currently loaded radar data and 
; information about that data.
;
; RADARINFO: The common block holding data about all radar sites (from RST).
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
; Modified, Dec 6 2009, LBNC: Added functionality to account for fact that fitacf file might not be zipped.
;-
pro rad_raw_read, date, radar, time=time, $
	long=long, silent=silent, $
	filename=filename, fileolddat=fileolddat, fileradar=fileradar, $
	filedate=filedate, filerawacf=filerawacf, $
	force=force, stop_after_read=stop_after_read

common rad_data_blk
common radarinfo

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
rad_raw_info.nrecs = 0L

; calculate the maximum records the data array will hold
MAX_RECS = GETENV('RAD_MAX_HOURS')/2L*1800L
MAX_LAGS = GETENV('RAD_MAX_LAGS')

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

if ~keyword_set(filename) then begin
	; check if parameters are given
	if n_params() lt 2 then begin
		prinfo, 'Must give date and radar code.'
		return
	endif

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = rad_raw_check_loaded(date, radar, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = rad_raw_find_files(date, radar, time=time, long=long, file_count=fc, $
		olddat=olddat, rawacf=rawacf)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+radar+', '+format_date(date)+$
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
		if ~keyword_set(fileradar) then begin
			bfile = file_basename(filename[i])
			if strlen(bfile) lt 20 then begin
				prinfo, 'Cannot parse radar name from filename, set FILERADAR keyword.'
				return
			endif
			radar = strmid(bfile, 17, 3)
		endif else $
			radar = fileradar
		if n_elements(fileolddat) gt 0 then $
			olddat = fileolddat $
		else $
			olddat = !false
		if keyword_set(filedate) then $
			date = filedate $
		else begin
			bfile = file_basename(filename[i])
			if strlen(bfile) lt 8 then begin
				prinfo, 'Cannot parse date from filename, set FILEDATE keyword.'
				return
			endif
			date = long(strmid(bfile, 0, 8))
			if date eq 0 then  begin
				prinfo, 'Cannot parse date from filename, set FILEDATE keyword.'
				return
			endif
		endelse
		if keyword_set(filerawacf) then $
			rawacf = !true $
		else begin
			if strpos(filename[i], 'rawacf') ne -1 then $
				rawacf = !true $
			else $
				rawacf = !false
		endelse
	endfor
	files = filename
	no_delete = !true
endelse

; network in radarinfo contains information about the 
; radar sites of the superdarn network. sometimes, radars
; move about (i.e. change geographic location) or the hard/software
; is upgraded, adding new capabilities. the current and the old
; configs are in the network variable. we now find the config
; appropriate for the time from which to read data.
;
; find radar in variable
ind = where(network[*].code[0] eq radar, cc)
if cc lt 1 then begin
	prinfo, 'Uh-oh! Radar not in SuperDARN list: '+radar
	return
endif
; extract components from given date and time
sfjul, date, time, sjul, fjul, long=long
; loop through all radar sites find the one appropriate for
; the chosen time
; if the config changed during the interval, tough!
; we will then choose the older one
; but we'll be nice and print a warning
for i=0, network[ind].snum-1 do begin
	if network[ind].site[i].tval eq -1 then $
		break
	ret = TimeEpochToYMDHMS(yy, mm, dd, hh, ii, ss, network[ind].site[i].tval)
	sitechange = julday(mm, dd, yy, hh, ii, ss)
	if sjul lt sitechange and fjul gt sitechange then begin
		prinfo, 'Radar site configuration changed during interval.', /force
		prinfo, 'Radar site configuration changed: ' + $
			format_juldate(sitechange), /force
		prinfo, 'To avoid confusion you might want to split the plotting in two parts.', /force
		prinfo, 'Choosing the latter one.', /force
	endif
	if fjul le sitechange then $
		break
endfor
_snum = i
; find maxbeams and maxrange
maxgates = network[ind].site[_snum].maxrange

; init temporary arrays
tmp_juls      = make_array(MAX_RECS, /double)
tmp_ysec      = make_array(MAX_RECS, /long)
tmp_beam      = make_array(MAX_RECS, /int)
tmp_scan_id   = make_array(MAX_RECS, /int)
tmp_scan_mark = make_array(MAX_RECS, /int)
tmp_channel   = make_array(MAX_RECS, /byte)
; 0 for no interferometer data
; 1 for interferometer data
tmp_xcf       = make_array(MAX_RECS, /byte)
tmp_lagfr     = make_array(MAX_RECS, /int)
tmp_smsep     = make_array(MAX_RECS, /int)
tmp_tfreq     = make_array(MAX_RECS, /float)
tmp_noise     = make_array(MAX_RECS, /float)
tmp_atten     = make_array(MAX_RECS, /int)
tmp_mplgs     = make_array(MAX_RECS, /byte)
; 0 for HF mode
; 1 for IF mode
; 255 for not set
tmp_ifmode     = make_array(MAX_RECS, /byte)
; wait until we know the actual number of gates from the first 
; fit record.
;tmp_acf_r     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
;tmp_acf_i     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
;tmp_xcf_r     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
;tmp_xcf_i     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
nrecs = 0L

; make structures for reading fit files
; this is done in order to speed things up a little
;RadarMakeRadarPrm, prm
;RawMakeRawData, raw
;lib = getenv('LIB_RAWIDL')
;if strcmp(lib, '') then begin
;	prinfo, 'Cannot find LIB_RAWIDL'
;	return
;endif

; read files
for i=0, fc-1 do begin
	file_base = file_basename(files[i])
	if ~keyword_set(silent) then $
		prinfo, 'Reading '+file_base +' ('+files[i]+')', /force
	; unzip file to user's home directory
	; if file is zipped
	o_file = rad_unzip_file(files[i])
	if strcmp(o_file, '') then $
		continue
	; open fit file
	if olddat then $
		ilun = oldrawopen(o_file) $
	else $
		ilun = rawopen(o_file, /read)
	if size(ilun, /type) eq 2 then begin
		if ilun eq 0 then begin
			prinfo, 'Could not open file: ' + files[i] + $
				'->('+o_file+')', /force
			file_delete, o_file
			continue
		endif
	endif
	; read all data entries
	while !true do begin

		; read data record
		if olddat then begin
			ret = oldrawread(ilun, prm, raw)
		endif else begin
;			ret = rad_raw_read_record(ilun, lib, prm, raw)
			ret = rawread(ilun, prm, raw)
		endelse

		; exit if all read
		if ret eq -1 then $
			break

		if keyword_set(stop_after_read) then $
			stop

		if nrecs eq 0 then begin
			maxgates = prm.nrang
			tmp_pwr0      = make_array(MAX_RECS, maxgates, /float)
			tmp_lagtime   = make_array(MAX_RECS, MAX_LAGS, /float)
			tmp_acf_r     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
			tmp_acf_i     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
			tmp_xcf_r     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
			tmp_xcf_i     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
		endif
		if prm.nrang ne maxgates then begin
			prinfo, 'Number of range gates changed.'
			if prm.nrang gt maxgates then begin
				prinfo, '  Adjusting new ranges gates...'
				ttmp_pwr0 = make_array(MAX_RECS, prm.nrang, /float)
				ttmp_pwr0[0:nrecs-1L,0:maxgates-1] = tmp_pwr0[0:nrecs-1L,*]
				tmp_pwr0 = ttmp_pwr0
				ttmp_acf_r = make_array(MAX_RECS, prm.nrang, MAX_LAGS, /float)
				ttmp_acf_r[0:nrecs-1L,0:maxgates-1,*] = tmp_acf_r[0:nrecs-1L,*,*]
				tmp_acf_r = ttmp_acf_r
				ttmp_acf_i = make_array(MAX_RECS, prm.nrang, MAX_LAGS, /float)
				ttmp_acf_i[0:nrecs-1L,0:maxgates-1,*] = tmp_acf_i[0:nrecs-1L,*,*]
				tmp_acf_i = ttmp_acf_i
				ttmp_xcf_r = make_array(MAX_RECS, prm.nrang, MAX_LAGS, /float)
				ttmp_xcf_r[0:nrecs-1L,0:maxgates-1,*] = tmp_xcf_r[0:nrecs-1L,*,*]
				tmp_xcf_r = ttmp_xcf_r
				ttmp_xcf_i = make_array(MAX_RECS, prm.nrang, MAX_LAGS, /float)
				ttmp_xcf_i[0:nrecs-1L,0:maxgates-1,*] = tmp_xcf_i[0:nrecs-1L,*,*]
				tmp_xcf_i = ttmp_xcf_i
				maxgates = prm.nrang
			endif
		endif

		; This logic sets the parameters to the values as read in 
		; from the file or 10000 if the qflg=0 (or x_qflg=0
		; in the case of phi0]
		tmp_juls[nrecs] = julday(prm.time.mo, prm.time.dy, prm.time.yr, $
			prm.time.hr,prm.time.mt, prm.time.sc)
		tmp_ysec[nrecs] = (day_no(prm.time.yr,prm.time.mo,prm.time.dy)-1)*86400L+$
			prm.time.hr*3600L+prm.time.mt*60+prm.time.sc
		tmp_beam[nrecs] = prm.bmnum
		tmp_scan_id[nrecs] = prm.cp
		tmp_scan_mark[nrecs] = prm.scan
		tmp_channel[nrecs] = prm.channel
		tmp_xcf[nrecs] = prm.xcf
		tmp_lagfr[nrecs] = prm.lagfr
		tmp_smsep[nrecs] = prm.smsep
		tmp_tfreq[nrecs] = prm.tfreq
		tmp_noise[nrecs] = prm.noise.search
		tmp_atten[nrecs] = prm.atten
		tmp_mplgs[nrecs] = prm.mplgs
		if prm.mplgs gt MAX_LAGS then begin
			prinfo, 'To many lags in file, set MAX_LAGS.'
			nrecs = 0
			MAX_RECS = -1
			break
		endif
		tmp_pwr0[nrecs,0:maxgates-1] = raw.pwr0[0:maxgates-1]
		tmp_lagtime[nrecs,0:prm.mplgs-1] = (prm.lag[0:prm.mplgs-1,1]-prm.lag[0:prm.mplgs-1,0])*prm.smsep
		tmp_acf_r[nrecs,0:maxgates-1,0:prm.mplgs-1] = raw.acfd[0:maxgates-1,0:prm.mplgs-1,0]
		tmp_acf_i[nrecs,0:maxgates-1,0:prm.mplgs-1] = raw.acfd[0:maxgates-1,0:prm.mplgs-1,1]
		tmp_xcf_r[nrecs,0:maxgates-1,0:prm.mplgs-1] = raw.xcfd[0:maxgates-1,0:prm.mplgs-1,0]
		tmp_xcf_i[nrecs,0:maxgates-1,0:prm.mplgs-1] = raw.xcfd[0:maxgates-1,0:prm.mplgs-1,1]

		tmp_ifmode[nrecs] = ( prm.ifmode eq -1 ? 255b : byte(prm.ifmode) )

		nrecs += 1L
		; if temporary arrays are too small, warn and break
		if nrecs ge MAX_RECS then begin
			prinfo, 'To many data records in file for initialized array. Truncating.'
			break
		endif
	endwhile
	if olddat then $
		s = oldrawclose(ilun) $
	else $
		free_lun, ilun
	file_delete, o_file
	if nrecs ge MAX_RECS then $
		break
endfor

if nrecs lt 1 then begin
	prinfo, 'No real data read.'
	return
endif

; make new structure for data
trad_raw_data = { $
	juls: dblarr(nrecs), $
	ysec: lonarr(nrecs), $
	beam: intarr(nrecs), $
	scan_id: intarr(nrecs), $
	scan_mark: intarr(nrecs), $
	beam_scan: lonarr(nrecs), $
	channel: bytarr(nrecs), $
	xcf: bytarr(nrecs), $
	lagfr: intarr(nrecs), $
	smsep: intarr(nrecs), $
	tfreq: fltarr(nrecs), $
	noise: fltarr(nrecs), $
	atten: intarr(nrecs), $
	mplgs: bytarr(nrecs), $
	pwr0:  fltarr(nrecs, maxgates), $
	lagtime: fltarr(nrecs, MAX_LAGS), $
	acf_r: fltarr(nrecs, maxgates, MAX_LAGS), $
	acf_i: fltarr(nrecs, maxgates, MAX_LAGS), $
	xcf_r: fltarr(nrecs, maxgates, MAX_LAGS), $
	xcf_i: fltarr(nrecs, maxgates, MAX_LAGS), $
	ifmode: bytarr(nrecs) $
}
; distribute data in structure
trad_raw_data.juls = tmp_juls[0:nrecs-1L]
trad_raw_data.ysec = tmp_ysec[0:nrecs-1L]
trad_raw_data.beam = tmp_beam[0:nrecs-1L]
trad_raw_data.scan_id = tmp_scan_id[0:nrecs-1L]
trad_raw_data.scan_mark = tmp_scan_mark[0:nrecs-1L]
trad_raw_data.channel = tmp_channel[0:nrecs-1L]
trad_raw_data.xcf = tmp_xcf[0:nrecs-1L]
trad_raw_data.lagfr = tmp_lagfr[0:nrecs-1L]
trad_raw_data.smsep = tmp_smsep[0:nrecs-1L]
trad_raw_data.tfreq = tmp_tfreq[0:nrecs-1L]
trad_raw_data.noise = tmp_noise[0:nrecs-1L]
trad_raw_data.atten = tmp_atten[0:nrecs-1L]
trad_raw_data.mplgs = tmp_mplgs[0:nrecs-1L]
trad_raw_data.pwr0  = tmp_pwr0[0:nrecs-1L,*]
trad_raw_data.lagtime = tmp_lagtime[0:nrecs-1L,*]
trad_raw_data.acf_r = tmp_acf_r[0:nrecs-1L,*,*]
trad_raw_data.acf_i = tmp_acf_i[0:nrecs-1L,*,*]
trad_raw_data.xcf_r = tmp_xcf_r[0:nrecs-1L,*,*]
trad_raw_data.xcf_i = tmp_xcf_i[0:nrecs-1L,*,*]
trad_raw_data.ifmode = tmp_ifmode[0:nrecs-1L]

; release some memory
tmp_acf_r = 0b
tmp_acf_i = 0b
tmp_xcf_r = 0b
tmp_xcf_i = 0b

; find all programs that were running in the interval
scan_ids = trad_raw_data.scan_id[uniq(trad_raw_data.scan_id, $
	sort(trad_raw_data.scan_id))]
nids = n_elements(scan_ids)

; Use fit file scan marks to create scans:
; scan_mark() = +/- 1  - start of a new scan
;             = 0      - include in current scan
;             = -32768 - camp beam - don't include in scan
; but we need to take care if data from multiple channels
; is available
nscans = 0L
for c=0, n_elements(channels)-1 do begin
	cinds = where(trad_raw_data.channel eq channels[c], ncc)
	a_scan_mark = trad_raw_data.scan_mark[cinds]
	scm = where(abs(a_scan_mark) eq 1, cc)
	if cc eq 0L then begin
		prinfo, 'No scan flag set, for some reason.'
		continue
	endif
	if scm[0] ne 0L then $
		scm = [0L, scm]
	if scm[cc-1] ne nrecs-1 then $
		scm = [scm, ncc]
	for s=0L, n_elements(scm)-2L do begin
		ginds = where(abs(a_scan_mark[scm[s]:scm[s+1L]-1L]) le 1, complement=ninds, sc, ncomplement=nc)
		ttmp = lindgen(scm[s+1L]-scm[s]) + scm[s]
		if sc gt 0 then begin
			;((trad_raw_data.beam_scan[cinds])[scm[s]:scm[s+1L]-1L])[ginds] = replicate(nscan, sc)
			trad_raw_data.beam_scan[cinds[ttmp[ginds]]] = replicate(nscans, sc)
			nscans += 1L
		endif
		if nc gt 0 then $
			;((trad_raw_data.beam_scan[cinds])[scm[s]:scm[s+1L]-1L])[ninds] = -1L
			trad_raw_data.beam_scan[cinds[ttmp[ninds]]] = -1L
	endfor
endfor
;for s=0, nids-1 do begin
;	nscans = 0L
;	sinds = where(trad_raw_data.scan_id eq scan_ids[s], cc)
;	for i=0L, cc-1L do begin
;		if abs(trad_raw_data.scan_mark[sinds[i]]) eq 1 then begin
;			if i ne 0L then $
;				nscans += 1L
;			trad_raw_data.beam_scan[sinds[i]] = nscans
;		endif else if trad_raw_data.scan_mark[sinds[i]] eq 0 then $
;			trad_raw_data.beam_scan[sinds[i]] = nscans $
;		else if trad_raw_data.scan_mark[sinds[i]] eq -32768 THEN $
;			trad_raw_data.beam_scan[sinds[i]] = -1L
;	endfor
;endfor

; find all channels
channels = trad_raw_data.channel[uniq(trad_raw_data.channel, $
	sort(trad_raw_data.channel))]

; put new structure in common block
rad_raw_data = trad_raw_data

; determine whether inteferometer data is present
; 0: no interferometer data
; 1: inteferometer data for the ENTIRE time that is loaded
; 2: interferometer data for SOME time
info_xcf = 0b
dummy = where( trad_raw_data.xcf, xcc )
if xcc eq nrecs then $
	info_xcf = 1b $
else if xcc gt 0L then $
	info_xcf = 2b

; set up new info structure
trad_raw_info = { $
	sjul: rad_raw_data.juls[0], $
	fjul: rad_raw_data.juls[nrecs-1L], $
	name: network[ind].name, $
	code: network[ind].code[0], $
	id: network[ind].id, $
	scan_ids: scan_ids, $
	channels: channels, $
	xcf: info_xcf, $
	glat: network[ind].site[_snum].geolat, $
	glon: network[ind].site[_snum].geolon, $
	mlat: 0.0, $
	mlon: 0.0, $
	nbeams: network[ind].site[_snum].maxbeam, $
	ngates: maxgates, $
	bmsep: network[ind].site[_snum].bmsep, $
;	fov_loc_full: ptr_new(), $
;	fov_loc_center: ptr_new(), $
	parameters: ['juls','ysec','beam','scan_id','scan_mark',$
		'channel','xcf','acf_i','acf_r','mplgs',$
		'lagfr','smsep','tfreq','noise','atten'], $
	nscans: nscans+1L, $
	dat: olddat, $
	rawacf: rawacf, $
	nrecs: nrecs $
}
; populate with data
tpos = cnvcoord(trad_raw_info.glat,trad_raw_info.glon,1.)
trad_raw_info.mlat = tpos[0]
trad_raw_info.mlon = tpos[1]

; delete old pointers otherwise they stay in memory
;if ptr_valid(rad_raw_info.fov_loc_full) then $
;	ptr_free, rad_raw_info.fov_loc_full
;if ptr_valid(rad_raw_info.fov_loc_center) then $
;	ptr_free, rad_raw_info.fov_loc_center
; write to common block
rad_raw_info = trad_raw_info

; define beam and gate positions for radar
;rad_raw_define_beams, id=rad_raw_info.id

;help, rad_fit_info
;help, rad_fit_info, /str


end
