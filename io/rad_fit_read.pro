;+ 
; NAME: 
; RAD_FIT_READ
;
; PURPOSE: 
; This procedure reads radar fitacf data into the variables of the structure RAD_FIT_DATA in
; the common block RAD_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RAD_FIT_READ, Date, Radar
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
; FILENAME: Set this to a string containing the name of the fit file to read.
;
; FILEOLDFIT: Set this keyword to indicate that the file in FILENAME is in the old
; fit file format.
;
; FILEFITEX: Set this keyword to indicate that the file in FILENAME is in the fitEX
; fit file format.
;
; FILEFITACF: Set this keyword to indicate that the file in FILENAME is in the fitACF
; fit file format.
;
; FILERADAR: Set this to a string containing the radar from which the fit file to read.
;
; FILEDATE: Set this to a string containing the date from which the fit file to read.
;
; FORCE: Set this keyword to read the data, even if it is already present in the
; RAD_DATA_BLK, i.e. even if RAD_FIT_CHECK_LOADED returns true.
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
pro rad_fit_read, date, radar, time=time, $
	long=long, silent=silent, filter=filter, $
	filename=filename, fileoldfit=fileoldfit, fileradar=fileradar, $
	filedate=filedate, filefitex=filefitex, filefitacf=filefitacf, $
	force=force, oldfit=oldfit, fitacf=fitacf, fitex=fitex, $
	nocomb=nocomb, native=native

common rad_data_blk
common radarinfo

; check whether we have slots in rad_fit_data
; available
data_index = rad_fit_get_data_index(/next)
if data_index eq -1 then $
	return

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
(*rad_fit_info[data_index]).nrecs = 0L

; calculate the maximum records the data array will hold
MAX_RECS = GETENV('RAD_MAX_HOURS')*3600L

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

if keyword_set(nocomb) then $
	nocomb_str = ' -nocomb' $
else $
	nocomb_str = ''

if ~keyword_set(filename) then begin
	; check if parameters are given
	if n_params() lt 2 then begin
		prinfo, 'Must give date and radar code.'
		return
	endif

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = rad_fit_check_loaded(date, radar, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	;help, oldfit, fitacf, fitex
	files = rad_fit_find_files(date, radar, time=time, long=long, file_count=fc, $
		oldfit=oldfit, fitacf=fitacf, fitex=fitex)
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
		if n_elements(fileoldfit) gt 0 then $
			oldfit = fileoldfit $
		else $
			oldfit = !false
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
		if keyword_set(filefitacf) then $
			fitacf = !true $
		else begin
			if strpos(filename[i], 'fitacf') ne -1 then $
				fitacf = !true $
			else $
				fitacf = !false
		endelse
		if keyword_set(filefitex) then $
			fitex = !true $
		else begin
			if strpos(filename[i], 'fitex') ne -1 then $
				fitex = !true $
			else $
				fitex = !false
		endelse
	endfor
	files = filename
	no_delete = !true
endelse

; check file dates.
; a bug in make_fitex2 was fixed on 
; May 18 after which all fitex files
; were reprocessed. So if we intend to
; read fitex files that date from 
; ealier, give a warning message
fix_fitex_jul = julday(5,18,2010,14,30)
nwarn = 0
if fitex then begin
	for i=0, fc-1 do begin
		ii = file_info(files[i])
		if julday(1,1,1970,0,0,ii.ctime) lt fix_fitex_jul then begin
			if nwarn eq 0 then $
				wfiles = files[i] $
			else $
				wfiles = [wfiles, files[i]]
			nwarn += 1
		endif
	endfor
	if nwarn gt 0 then begin
		prinfo, '-- -- --'
		prinfo, '-- WARNING --'
		prinfo, '-- -- --'
		prinfo, 'The following files were generated '
		prinfo, ' before a major bug was fixed in the make_fitex2 code: '
		for i=0, nwarn-1 do $
			prinfo, '  '+wfiles[i]
	endif
endif

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
;maxgates = network[ind].site[_snum].maxrange

; init temporary arrays
tmp_juls      = make_array(MAX_RECS, /double)
tmp_ysec      = make_array(MAX_RECS, /long)
tmp_beam      = make_array(MAX_RECS, /int)
tmp_scan_id   = make_array(MAX_RECS, /int)
tmp_scan_mark = make_array(MAX_RECS, /int)
tmp_channel   = make_array(MAX_RECS, /byte)
; wait until we know the actual number of gates from the first 
; fit record.
;tmp_power     = make_array(MAX_RECS, maxgates, /float)
;tmp_velocity  = make_array(MAX_RECS, maxgates, /float)
;tmp_width     = make_array(MAX_RECS, maxgates, /float)
;tmp_gscatter  = make_array(MAX_RECS, maxgates, /byte)
tmp_lagfr     = make_array(MAX_RECS, /int)
tmp_smsep     = make_array(MAX_RECS, /float)
tmp_tfreq     = make_array(MAX_RECS, /float)
tmp_noise     = make_array(MAX_RECS, /float)
tmp_atten     = make_array(MAX_RECS, /float)
nrecs = 0L

; make structures for reading fit files
; this is done in order to speed things up a little
RadarMakeRadarPrm, prm
FitMakeFitData, fit
lib = getenv('LIB_FITIDL')
if strcmp(lib, '') then begin
	prinfo, 'Cannot find LIB_FITIDL'
	return
endif

prinfo, 'Reading into index '+string(data_index,format='(I1)')

; read files
for i=0, fc-1 do begin
	; unzip file to user's home directory
	; if file is zipped
	o_file = rad_unzip_file(files[i])
	if strcmp(o_file, '') then $
		continue
	; call AJs  executable to perform boxcar filtering
	if keyword_set(filter) then begin
		; check whether fitexfilter is available
		spawn, 'which fitexfilter', sresult
		if strlen(sresult) lt 1 then begin
			prinfo, 'Cannot find fitexfilter.'
			filter = !false
		endif else begin
			spawn, 'fitexfilter', filterreso, filterrese
			if n_elements(filterrese) eq 2 then begin
				if strpos(filterrese[0], '(null)') ne -1 then begin
					if oldfit then begin
						prinfo, 'Old fit file format not supported for filtering.'
						filter = !false
					endif else begin
						spawn, 'fitexfilter'+nocomb_str+' '+o_file+' > '+o_file+'.filtered', filterreso, filterrese
						file_delete, o_file
						o_file = o_file+'.filtered'
						filter = !true
					endelse
				endif else begin
					prinfo, 'fitexfilter returned with the following error: '+strjoin(filterrese, '-')
					filter = !false
				endelse
			endif else begin
				prinfo, 'fitexfilter returned with the following error: '+strjoin(filterrese, '-')
				filter = !false
			endelse
		endelse
	endif else $
		filter = !false
	if ~keyword_set(silent) then $
		prinfo, 'Reading '+o_file +' ('+files[i]+')', /force
	; open fit file
	if oldfit then $
		ilun = oldfitopen(o_file) $
	else $
		ilun = fitopen(o_file, /read)
	if size(ilun, /type) eq 2 then begin
		if ilun eq 0 then begin
			prinfo, 'Could not open file: ' + o_file + $
				'->('+files[i]+')', /force
			if files[i] ne o_file then $
				file_delete, o_file
			continue
		endif
	endif

	startsec = systime(1)
	; read all data entries
	while !true do begin

		; read data record
		if oldfit then begin
			ret = oldfitread(ilun, prm, fit)
		endif else begin
			ret = rad_fit_read_record(ilun, lib, prm, fit, native=native)
		endelse

		; exit if all read
		if ret eq -1 then $
			break
		
		; wait until we know the actual number of gates from the first 
		; fit record.
		if nrecs eq 0L then begin
			maxgates = prm.nrang
			tmp_power     = make_array(MAX_RECS, maxgates, /float)
			tmp_velocity  = make_array(MAX_RECS, maxgates, /float)
			tmp_width     = make_array(MAX_RECS, maxgates, /float)
			tmp_gscatter  = make_array(MAX_RECS, maxgates, /byte)
		endif
		if prm.nrang ne maxgates then begin
			prinfo, 'Number of range gates changed.'
			if prm.nrang gt maxgates then begin
				prinfo, '  Adjusting new ranges gates...'
				ttmp_power = make_array(MAX_RECS, prm.nrang, /float)
				ttmp_power[0:nrecs-1L,0:maxgates-1] = tmp_power[0:nrecs-1L,*]
				tmp_power = ttmp_power
				ttmp_velocity  = make_array(MAX_RECS, prm.nrang, /float)
				ttmp_velocity[0:nrecs-1L,0:maxgates-1] = tmp_velocity[0:nrecs-1L,*]
				tmp_velocity = ttmp_velocity
				ttmp_width     = make_array(MAX_RECS, prm.nrang, /float)
				ttmp_width[0:nrecs-1L,0:maxgates-1] = tmp_width[0:nrecs-1L,*]
				tmp_width = ttmp_width
				ttmp_gscatter  = make_array(MAX_RECS, prm.nrang, /byte)
				ttmp_gscatter[0:nrecs-1L,0:maxgates-1] = tmp_gscatter[0:nrecs-1L,*]
				tmp_gscatter = ttmp_gscatter
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
		;print, nrecs, prm.scan
		tmp_channel[nrecs] = prm.channel - ( prm.channel gt 0 ? 1 : 0 )
		tmp_power[nrecs, 0:prm.nrang-1] = fit.p_l[0:prm.nrang-1]*fit.qflg[0:prm.nrang-1]+$
				10000.*(1.-fit.qflg[0:prm.nrang-1])
		tmp_velocity[nrecs,  0:prm.nrang-1] = fit.v[0:prm.nrang-1]*fit.qflg[0:prm.nrang-1]+$
				10000.*(1.-fit.qflg[0:prm.nrang-1])
		tmp_width[nrecs,  0:prm.nrang-1] = fit.w_l[0:prm.nrang-1]*fit.qflg[0:prm.nrang-1]+$
				10000.*(1.-fit.qflg[0:prm.nrang-1])
		tmp_gscatter[nrecs,  0:prm.nrang-1] = fit.gflg[0:prm.nrang-1]
		tmp_lagfr[nrecs] = prm.lagfr
		tmp_smsep[nrecs] = prm.smsep
		tmp_tfreq[nrecs] = prm.tfreq
		tmp_noise[nrecs] = prm.noise.search
		tmp_atten[nrecs] = prm.atten

		nrecs += 1L

		; if temporary arrays are too small, warn and break
		if nrecs ge MAX_RECS then begin
			prinfo, 'To many data records in file for initialized array. Truncating.'
			break
		endif
	endwhile
	prinfo, 'Reading took: '+string(systime(1)-startsec)
	if oldfit then $
		free_lun, ilun.fitunit $
	else $
		free_lun, ilun
	if files[i] ne o_file then $
		file_delete, o_file
	if nrecs ge MAX_RECS then $
		break
endfor

if nrecs lt 1 then begin
	prinfo, 'No real data read.'
	return
endif

; make new structure for data
trad_fit_data = { $
	juls: dblarr(nrecs), $
	ysec: lonarr(nrecs), $
	beam: intarr(nrecs), $
	scan_id: intarr(nrecs), $
	scan_mark: intarr(nrecs), $
	beam_scan: lonarr(nrecs), $
	channel: fltarr(nrecs), $
	power: fltarr(nrecs, maxgates), $
	velocity: fltarr(nrecs, maxgates), $
	width: fltarr(nrecs, maxgates), $
	gscatter: bytarr(nrecs, maxgates), $
	lagfr: intarr(nrecs), $
	smsep: fltarr(nrecs), $
	tfreq: fltarr(nrecs), $
	noise: fltarr(nrecs), $
	atten: fltarr(nrecs) $
}
; distribute data in structure
trad_fit_data.juls = tmp_juls[0:nrecs-1L]
trad_fit_data.ysec = tmp_ysec[0:nrecs-1L]
trad_fit_data.beam = tmp_beam[0:nrecs-1L]
trad_fit_data.scan_id = tmp_scan_id[0:nrecs-1L]
trad_fit_data.scan_mark = tmp_scan_mark[0:nrecs-1L]
trad_fit_data.channel = tmp_channel[0:nrecs-1L]
trad_fit_data.power = tmp_power[0:nrecs-1L,*]
trad_fit_data.velocity = tmp_velocity[0:nrecs-1L,*]
trad_fit_data.width = tmp_width[0:nrecs-1L,*]
trad_fit_data.gscatter = tmp_gscatter[0:nrecs-1L,*]
trad_fit_data.lagfr = tmp_lagfr[0:nrecs-1L]
trad_fit_data.smsep = tmp_smsep[0:nrecs-1L]
trad_fit_data.tfreq = tmp_tfreq[0:nrecs-1L]
trad_fit_data.noise = tmp_noise[0:nrecs-1L]
trad_fit_data.atten = tmp_atten[0:nrecs-1L]

; find all programs that were running in the interval
scan_ids = trad_fit_data.scan_id[uniq(trad_fit_data.scan_id, $
	sort(trad_fit_data.scan_id))]
nids = n_elements(scan_ids)

; find all channels
channels = trad_fit_data.channel[uniq(trad_fit_data.channel, $
	sort(trad_fit_data.channel))]

; Use fit file scan marks to create scans:
; scan_mark() = +/- 1  - start of a new scan
;             = 0      - include in current scan
;             = -32768 - camp beam - don't include in scan
; but we need to take care if data from multiple channels
; is available
nscans = 0L
for c=0, n_elements(channels)-1 do begin
	cinds = where(trad_fit_data.channel eq channels[c], ncc)
	a_scan_mark = trad_fit_data.scan_mark[cinds]
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
			;((trad_fit_data.beam_scan[cinds])[scm[s]:scm[s+1L]-1L])[ginds] = replicate(nscan, sc)
			trad_fit_data.beam_scan[cinds[ttmp[ginds]]] = replicate(nscans, sc)
			nscans += 1L
		endif
		if nc gt 0 then $
			;((trad_fit_data.beam_scan[cinds])[scm[s]:scm[s+1L]-1L])[ninds] = -1L
			trad_fit_data.beam_scan[cinds[ttmp[ninds]]] = -1L
	endfor
endfor
;for s=0, nids-1 do begin
;	nscans = 0L
;	sinds = where(trad_fit_data.scan_id eq scan_ids[s], cc)
;	for i=0L, cc-1L do begin
;		if abs(trad_fit_data.scan_mark[sinds[i]]) eq 1 then begin
;			if i ne 0L then $
;				nscans += 1L
;			trad_fit_data.beam_scan[sinds[i]] = nscans
;		endif else if trad_fit_data.scan_mark[sinds[i]] eq 0 then $
;			trad_fit_data.beam_scan[sinds[i]] = nscans $
;		else if trad_fit_data.scan_mark[sinds[i]] eq -32768 THEN $
;			trad_fit_data.beam_scan[sinds[i]] = -1L
;	endfor
;endfor

; put new structure in common block
if ptr_valid(rad_fit_data[data_index]) then $
	ptr_free, rad_fit_data[data_index]
rad_fit_data[data_index] = ptr_new(trad_fit_data)

; get coordinates
coords = get_coordinates()

; set up new info structure
trad_fit_info = { $
	sjul: trad_fit_data.juls[0], $
	fjul: trad_fit_data.juls[nrecs-1L], $
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
;	fov_loc_full: ptr_new(), $
;	fov_loc_center: ptr_new(), $
;	fov_coords: coords, $
	parameters: ['juls','ysec','beam','scan_id','scan_mark','beam_scan',$
		'channel','power','velocity','width',$
		'gscatter','lagfr','smsep','tfreq','noise','atten'], $
	nscans: nscans+1L, $
	fitex: fitex, $
	fitacf: fitacf, $
	fit: oldfit, $
	filtered: filter, $
	nrecs: nrecs $
}
; populate with data
tpos = cnvcoord(trad_fit_info.glat,trad_fit_info.glon,1.)
trad_fit_info.mlat = tpos[0]
trad_fit_info.mlon = tpos[1]

; check time
;sjul = trad_fit_info.sjul
;caldat, sjul, mm, dd, year
;yrsec = trad_fit_data.ysec[0]

; define beam and gate positions for radar
;if (*rad_fit_info[data_index]).fov_coords ne coords or $
;	~ptr_valid((*rad_fit_info[data_index]).fov_loc_full) or $
;	~ptr_valid((*rad_fit_info[data_index]).fov_loc_center) then begin
;	rad_define_beams, trad_fit_info.id, trad_fit_info.nbeams, trad_fit_info.ngates, trad_fit_info.bmsep, year, yrsec, coords=coords, $
;		lagfr0=trad_fit_data.lagfr[0], smsep0=trad_fit_data.smsep[0], fov_loc_full=fov_loc_full, fov_loc_center=fov_loc_center
;endif else begin
;	fov_loc_full = (*rad_fit_info[data_index]).fov_loc_full
;	fov_loc_center = (*rad_fit_info[data_index]).fov_loc_center
;endelse

; delete old pointers otherwise they stay in memory
;if ptr_valid((*rad_fit_info[data_index]).fov_loc_full) then $
;	ptr_free, (*rad_fit_info[data_index]).fov_loc_full
;if ptr_valid((*rad_fit_info[data_index]).fov_loc_center) then $
;	ptr_free, (*rad_fit_info[data_index]).fov_loc_center

; put new ones in
;trad_fit_info.fov_loc_full = ptr_new(fov_loc_full)
;trad_fit_info.fov_loc_center =  ptr_new(fov_loc_center)

; write to common block
if ptr_valid(rad_fit_info[data_index]) then $
	ptr_free, rad_fit_info[data_index]
rad_fit_info[data_index] = ptr_new(trad_fit_info)

end
