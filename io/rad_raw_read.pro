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
; FILEDAT: Set this keyword to indicate that the file in FILENAME is in the old
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
; MODIFICATION HISTORY:
; Based on Steve Milan's READ_FILES.
; Written by Lasse Clausen, Nov, 24 2009
; Modified, Dec 6 2009, LBNC: Added functionality to account for fact that fitacf file might not be zipped.
;-
pro rad_raw_read, date, radar, time=time, $
	long=long, silent=silent, $
	filename=filename, fileolddat=fileolddat, fileradar=fileradar, $
	filedate=filedate, filerawacf=filerawacf, $
	force=force

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
tmp_lagfr     = make_array(MAX_RECS, /int)
tmp_smsep     = make_array(MAX_RECS, /float)
tmp_tfreq     = make_array(MAX_RECS, /float)
tmp_noise     = make_array(MAX_RECS, /float)
tmp_atten     = make_array(MAX_RECS, /float)
tmp_mplgs     = make_array(MAX_RECS, /byte)
tmp_acf_r     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
tmp_acf_i     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
tmp_xcf_r     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
tmp_xcf_i     = make_array(MAX_RECS, maxgates, MAX_LAGS, /float)
nrecs = 0L

; make structures for reading fit files
; this is done in order to speed things up a little
RadarMakeRadarPrm, prm
RawMakeRawData, raw
lib = getenv('LIB_RAWIDL')
if strcmp(lib, '') then begin
	prinfo, 'Cannot find LIB_RAWIDL'
	return
endif

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
			ret = rad_raw_read_record(ilun, lib, prm, raw)
		endelse

		; exit if all read
		if ret eq -1 then $
			break

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
		tmp_acf_r[nrecs,0:maxgates-1,0:prm.mplgs-1] = raw.acfd[0:maxgates-1,0:prm.mplgs-1,0]
		tmp_acf_i[nrecs,0:maxgates-1,0:prm.mplgs-1] = raw.acfd[0:maxgates-1,0:prm.mplgs-1,1]
		tmp_xcf_r[nrecs,0:maxgates-1,0:prm.mplgs-1] = raw.xcfd[0:maxgates-1,0:prm.mplgs-1,0]
		tmp_xcf_i[nrecs,0:maxgates-1,0:prm.mplgs-1] = raw.xcfd[0:maxgates-1,0:prm.mplgs-1,1]
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
	if ~file_test(getenv('RAD_WWW_DATA_DIR'), /dir) and ~no_delete then $
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
	scan_mark: fltarr(nrecs), $
	beam_scan: lonarr(nrecs), $
	channel: fltarr(nrecs), $
	lagfr: intarr(nrecs), $
	smsep: fltarr(nrecs), $
	tfreq: fltarr(nrecs), $
	noise: fltarr(nrecs), $
	atten: fltarr(nrecs), $
	mplgs: bytarr(nrecs), $
	acf_r: fltarr(nrecs, maxgates, MAX_LAGS), $
	acf_i: fltarr(nrecs, maxgates, MAX_LAGS), $
	xcf_r: fltarr(nrecs, maxgates, MAX_LAGS), $
	xcf_i: fltarr(nrecs, maxgates, MAX_LAGS) $
}
; distribute data in structure
trad_raw_data.juls = tmp_juls[0:nrecs-1L]
trad_raw_data.ysec = tmp_ysec[0:nrecs-1L]
trad_raw_data.beam = tmp_beam[0:nrecs-1L]
trad_raw_data.scan_id = tmp_scan_id[0:nrecs-1L]
trad_raw_data.scan_mark = tmp_scan_mark[0:nrecs-1L]
trad_raw_data.channel = tmp_channel[0:nrecs-1L]
trad_raw_data.lagfr = tmp_lagfr[0:nrecs-1L]
trad_raw_data.smsep = tmp_smsep[0:nrecs-1L]
trad_raw_data.tfreq = tmp_tfreq[0:nrecs-1L]
trad_raw_data.noise = tmp_noise[0:nrecs-1L]
trad_raw_data.atten = tmp_atten[0:nrecs-1L]
trad_raw_data.mplgs = tmp_mplgs[0:nrecs-1L]
trad_raw_data.acf_r = tmp_acf_r[0:nrecs-1L,*,*]
trad_raw_data.acf_i = tmp_acf_i[0:nrecs-1L,*,*]
trad_raw_data.xcf_r = tmp_xcf_r[0:nrecs-1L,*,*]
trad_raw_data.xcf_i = tmp_xcf_i[0:nrecs-1L,*,*]

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
for s=0, nids-1 do begin
	nscans = 0L
	sinds = where(trad_raw_data.scan_id eq scan_ids[s], cc)
	for i=0L, cc-1L do begin
		if abs(trad_raw_data.scan_mark[sinds[i]]) eq 1 then begin
			if i ne 0L then $
				nscans += 1L
			trad_raw_data.beam_scan[sinds[i]] = nscans
		endif else if trad_raw_data.scan_mark[sinds[i]] eq 0 then $
			trad_raw_data.beam_scan[sinds[i]] = nscans $
		else if trad_raw_data.scan_mark[sinds[i]] eq -32768 THEN $
			trad_raw_data.beam_scan[sinds[i]] = -1L
	endfor
endfor

; find all channels
channels = trad_raw_data.channel[uniq(trad_raw_data.channel, $
	sort(trad_raw_data.channel))]

; put new structure in common block
rad_raw_data = trad_raw_data

; set up new info structure
trad_raw_info = { $
	sjul: rad_raw_data.juls[0], $
	fjul: rad_raw_data.juls[nrecs-1L], $
	name: network[ind].name, $
	code: network[ind].code[0], $
	id: network[ind].id, $
	scan_ids: scan_ids, $
	channels: channels, $
	glat: network[ind].site[_snum].geolat, $
	glon: network[ind].site[_snum].geolon, $
	mlat: 0.0, $
	mlon: 0.0, $
	nbeams: network[ind].site[_snum].maxbeam, $
	ngates: maxgates, $
	bmsep: network[ind].site[_snum].bmsep, $
	fov_loc_full: ptr_new(), $
	fov_loc_center: ptr_new(), $
	parameters: ['juls','ysec','beam','scan_id','scan_mark',$
		'channel','acf_i','acf_r','mplgs',$
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
if ptr_valid(rad_raw_info.fov_loc_full) then $
	ptr_free, rad_raw_info.fov_loc_full
if ptr_valid(rad_raw_info.fov_loc_center) then $
	ptr_free, rad_raw_info.fov_loc_center
; write to common block
rad_raw_info = trad_raw_info

; define beam and gate positions for radar
rad_raw_define_beams, id=rad_raw_info.id

;help, rad_fit_info
;help, rad_fit_info, /str


end
