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
; FILEDATE: Set this to a date in YYYMMDD format to indicate that the file in FILENAME
; contains data from that date.
;
; FORCE: Set this keyword to read the data, even if it is already present in the
; RAD_DATA_BLK, i.e. even if RAD_FIT_CHECK_LOADED returns true.
;
; AJGROUND: Set this keyword to run AJ Ribero's ground scatter search.  This only works on FITACF/FITEX data.  Also, must load in a minimum of 9 hours of data for this to work, because events shorter than 9 hours are not considered ground scatter.  This routine takes some time and memory, so be patient.
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
pro rad_fit_read, date, radar, time=time, $
	long=long, silent=silent, filter=filter, $
	filename=filename, fileoldfit=fileoldfit, fileradar=fileradar, $
	filedate=filedate, filefitex=filefitex, filefitacf=filefitacf, $
	force=force, oldfit=oldfit, fitacf=fitacf, fitex=fitex, $
	nocomb=nocomb, threshold=threshold, $
	stop_after_read=stop_after_read, AJGROUND=ajGround

common rad_data_blk
common radarinfo

; check whether we have slots in rad_fit_data
; available
data_index = rad_fit_get_data_index(/next)
if data_index eq -1 then $
	return

; set current counter to 0
(*rad_fit_info[data_index]).nrecs = 0L

; and delete all data - if any
if ptr_valid(rad_fit_data[data_index]) then $
	ptr_free, rad_fit_data[data_index]

; calculate the maximum records the data array will hold
MAX_RECS = GETENV('RAD_MAX_HOURS')*3600L

; set deault time if neccessary
; if AJ's ground scatter algorithm is called, also set
; full length days
;if ~keyword_set(time)||KEYWORD_SET(ajGround) then $
;	time = [0000,2400]

if keyword_set(nocomb) then $
	nocomb_str = ' -nocomb' $
else $
	nocomb_str = ''

if keyword_set(threshold) then begin
	if threshold lt 0. or threshold gt 1. then begin
		prinfo, 'THRESHOLD must be gt 0 and lt 1.'
		threshold = .4
	endif
	threshold_str = ' -thresh '+string(threshold,format='(F4.2)')
endif else $
	threshold_str = ''

if ~keyword_set(filename) then begin

	; check if parameters are given
	if n_params() lt 2 then begin
		prinfo, 'Must give date and radar code.'
		rad_fit_set_data_index, data_index-1
		return
	endif

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = rad_fit_check_loaded(date, radar, time=time, long=long, filter=filter, silent=silent)
		if dloaded then begin
			;rad_fit_set_data_index, data_index-1
			return
		endif
	endif
	
	; find files to load
	;help, oldfit, fitacf, fitex
	files = rad_fit_find_files(date, radar, time=time, long=long, file_count=fc, $
		oldfit=oldfit, fitacf=fitacf, fitex=fitex)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+radar+', '+format_date(date)+$
				', '+format_time(time)
		rad_fit_set_data_index, data_index-1
		return
	endif
	no_delete = !false
endif else begin
	fc = n_elements(filename)
	for i=0, fc-1 do begin
		if ~file_test(filename[i]) then begin
			prinfo, 'Cannot find file: '+filename[i]
			rad_fit_set_data_index, data_index-1
			return
		endif
		if ~keyword_set(fileradar) then begin
			bfile = file_basename(filename[i])
			if strlen(bfile) lt 20 then begin
				prinfo, 'Cannot parse radar name from filename, set FILERADAR keyword.'
				rad_fit_set_data_index, data_index-1
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
				rad_fit_set_data_index, data_index-1
				return
			endif
			date = long(strmid(bfile, 0, 8))
			if date eq 0 then  begin
				prinfo, 'Cannot parse date from filename, set FILEDATE keyword.'
				rad_fit_set_data_index, data_index-1
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
	rad_fit_set_data_index, data_index-1
	return
endif
; extract components from given date and time
sfjul, date, time, sjul, fjul, long=long,NO_DAYS=no_days
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
; 0 for no interferometer data
; 1 for interferometer data
tmp_xcf       = make_array(MAX_RECS, /byte)
; wait until we know the actual number of gates from the first 
; fit record.
;tmp_power     = make_array(MAX_RECS, maxgates, /float)
;tmp_velocity  = make_array(MAX_RECS, maxgates, /float)
;tmp_width     = make_array(MAX_RECS, maxgates, /float)
;tmp_gscatter  = make_array(MAX_RECS, maxgates, /byte)
tmp_lagfr     = make_array(MAX_RECS, /int)
tmp_smsep     = make_array(MAX_RECS, /int)
tmp_tfreq     = make_array(MAX_RECS, /float)
tmp_noise     = {search: make_array(MAX_RECS, /float), sky: make_array(MAX_RECS, /float)}
tmp_atten     = make_array(MAX_RECS, /int)
tmp_nave      = make_array(MAX_RECS, /byte)
; 0 for HF mode
; 1 for IF mode
; 255 for not set
tmp_ifmode    = make_array(MAX_RECS, /byte)
nrecs = 0L

prinfo, 'Reading into index '+string(data_index,format='(I2)')

; concatenate all files into one
o_file = rad_fit_concat_files(files, oldfit=oldfit, fitacf=fitacf, fitex=fitex, silent=silent)

if strcmp(o_file, '') then $
	return

; call AJs  executable to perform boxcar filtering
if keyword_set(filter) then begin
	if ~keyword_set(silent) then $
		prinfo, 'Filtering '+o_file, /force
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
					print, 'fitexfilter'+nocomb_str+threshold_str+' '+o_file+' > '+o_file+'.filtered'
					spawn, 'fitexfilter'+nocomb_str+threshold_str+' '+o_file+' > '+o_file+'.filtered', filterreso, filterrese
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

;Call AJ's executable for determining ground scatter.
IF KEYWORD_SET(ajGround) AND ~KEYWORD_SET(oldFit) THEN BEGIN
	if ~keyword_set(silent) then $
		prinfo, "Using AJ's algorithm to determine ground scatter: "+o_file, /force
	; check whether dopsearch is available
	spawn, 'which dopsearch', sresult
	if strlen(sresult) lt 1 then begin
		prinfo, 'Cannot find dopsearch.'
		;filter = !false
	endif else begin
            cmd$ = 'dopsearch -new ' + o_file + ' > ' +  o_file + '.gscat'
            IF ~KEYWORD_SET(silent) THEN PRINT,cmd$
            SPAWN,cmd$,gndResult,gndErr
            file_delete, o_file
            o_file = o_file+'.gscat'
	endelse
END

; read file
if ~keyword_set(silent) then $
	prinfo, 'Reading '+o_file, /force

; open fit file
if oldfit then $
	ilun = oldfitopen(o_file) $
else $
	ilun = fitopen(o_file, /read)
if size(ilun, /type) eq 2 then begin
	if ilun eq 0 then begin
		prinfo, 'Could not open file: ' + o_file
		file_delete, o_file
		rad_fit_set_data_index, data_index-1
		return
	endif
endif

startsec = systime(1)

; read all data entries
while !true do begin

	; read data record
	if oldfit then begin
		ret = oldfitread(ilun, prm, fit)
	endif else begin
		ret = fitread(ilun, prm, fit)
	endelse

	; exit if all read
	if ret eq -1 then $
		break

	if keyword_set(stop_after_read) then $
		stop

	; wait until we know the actual number of gates from the first 
	; fit record.
	if nrecs eq 0L then begin
		maxgates = prm.nrang
		tmp_pwr0            = make_array(MAX_RECS, maxgates, /float)
		tmp_power           = make_array(MAX_RECS, maxgates, /float)
		tmp_velocity_error  = make_array(MAX_RECS, maxgates, /float)
		tmp_velocity        = make_array(MAX_RECS, maxgates, /float)
		tmp_width           = make_array(MAX_RECS, maxgates, /float)
		tmp_gscatter        = make_array(MAX_RECS, maxgates, /byte)
		tmp_phi0            = make_array(MAX_RECS, maxgates, /float)
		tmp_elevation       = make_array(MAX_RECS, maxgates, /float)
	endif

	; adjust arrays if number of range gates changes
	if prm.nrang gt maxgates then begin
		prinfo, '  Adjusting new ranges gates...'
		ttmp_pwr0 = make_array(MAX_RECS, prm.nrang, /float)
		ttmp_pwr0[0:nrecs-1L,0:maxgates-1] = tmp_pwr0[0:nrecs-1L,*]
		ttmp_pwr0[0:nrecs-1L,maxgates:prm.nrang-1] = 10000.
		tmp_pwr0 = ttmp_pwr0
		ttmp_pwr0 = 0b
		ttmp_power = make_array(MAX_RECS, prm.nrang, /float)
		ttmp_power[0:nrecs-1L,0:maxgates-1] = tmp_power[0:nrecs-1L,*]
		ttmp_power[0:nrecs-1L,maxgates:prm.nrang-1] = 10000.
		tmp_power = ttmp_power
		ttmp_power = 0b
		ttmp_velocity  = make_array(MAX_RECS, prm.nrang, /float)
		ttmp_velocity[0:nrecs-1L,0:maxgates-1] = tmp_velocity[0:nrecs-1L,*]
		ttmp_velocity[0:nrecs-1L,maxgates:prm.nrang-1] = 10000.
		tmp_velocity = ttmp_velocity
		ttmp_velocity = 0b
		ttmp_velocity_error  = make_array(MAX_RECS, prm.nrang, /float)
		ttmp_velocity_error[0:nrecs-1L,0:maxgates-1] = tmp_velocity_error[0:nrecs-1L,*]
		ttmp_velocity_error[0:nrecs-1L,maxgates:prm.nrang-1] = 10000.
		tmp_velocity_error = ttmp_velocity_error
		ttmp_velocity_error = 0b
		ttmp_width     = make_array(MAX_RECS, prm.nrang, /float)
		ttmp_width[0:nrecs-1L,0:maxgates-1] = tmp_width[0:nrecs-1L,*]
		ttmp_width[0:nrecs-1L,maxgates:prm.nrang-1] = 10000.
		tmp_width = ttmp_width
		ttmp_width = 0b
		ttmp_gscatter  = make_array(MAX_RECS, prm.nrang, /byte)
		ttmp_gscatter[0:nrecs-1L,0:maxgates-1] = tmp_gscatter[0:nrecs-1L,*]
		ttmp_gscatter[0:nrecs-1L,maxgates:prm.nrang-1] = 0
		tmp_gscatter = ttmp_gscatter
		ttmp_gscatter = 0b
		ttmp_phi0  = make_array(MAX_RECS, prm.nrang, /float)
		ttmp_phi0[0:nrecs-1L,0:maxgates-1] = tmp_phi0[0:nrecs-1L,*]
		ttmp_phi0[0:nrecs-1L,maxgates:prm.nrang-1] = 10000.
		tmp_phi0 = ttmp_phi0
		ttmp_phi0 = 0b
		ttmp_elevation  = make_array(MAX_RECS, prm.nrang, /float)
		ttmp_elevation[0:nrecs-1L,0:maxgates-1] = tmp_elevation[0:nrecs-1L,*]
		ttmp_elevation[0:nrecs-1L,maxgates:prm.nrang-1] = 10000.
		tmp_elevation = ttmp_elevation
		ttmp_elevation = 0b
		maxgates = prm.nrang
	endif

	; fill ends with nodata if gate number decreased
	if prm.nrang lt maxgates then begin
		tmp_pwr0[nrecs,prm.nrang:maxgates-1] = 10000.
		tmp_power[nrecs,prm.nrang:maxgates-1] = 10000.
		tmp_velocity[nrecs,prm.nrang:maxgates-1] = 10000.
		tmp_velocity_error[nrecs,prm.nrang:maxgates-1] = 10000.
		tmp_width[nrecs,prm.nrang:maxgates-1] = 10000.
		tmp_gscatter[nrecs,prm.nrang:maxgates-1] = 10000.
		tmp_phi0[nrecs,prm.nrang:maxgates-1] = 10000.
		tmp_elevation[nrecs,prm.nrang:maxgates-1] = 10000.
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
	tmp_xcf[nrecs] = byte(prm.xcf)
	tmp_pwr0[nrecs, 0:prm.nrang-1] = fit.pwr0[0:prm.nrang-1]
	tmp_power[nrecs, 0:prm.nrang-1] = fit.p_l[0:prm.nrang-1]*fit.qflg[0:prm.nrang-1]+$
			10000.*(1.-fit.qflg[0:prm.nrang-1])
	tmp_velocity[nrecs,  0:prm.nrang-1] = fit.v[0:prm.nrang-1]*fit.qflg[0:prm.nrang-1]+$
			10000.*(1.-fit.qflg[0:prm.nrang-1])
	tmp_velocity_error[nrecs,  0:prm.nrang-1] = fit.v_e[0:prm.nrang-1]*fit.qflg[0:prm.nrang-1]+$
			10000.*(1.-fit.qflg[0:prm.nrang-1])
	tmp_width[nrecs,  0:prm.nrang-1] = fit.w_l[0:prm.nrang-1]*fit.qflg[0:prm.nrang-1]+$
			10000.*(1.-fit.qflg[0:prm.nrang-1])
	tmp_gscatter[nrecs,  0:prm.nrang-1] = fit.gflg[0:prm.nrang-1]
	tmp_phi0[nrecs,  0:prm.nrang-1] = fit.phi0[0:prm.nrang-1];*fit.x_qflg[0:prm.nrang-1]+$
			;10000.*(1.-fit.x_qflg[0:prm.nrang-1])
	tmp_elevation[nrecs,  0:prm.nrang-1] = fit.elv[0:prm.nrang-1];*fit.x_qflg[0:prm.nrang-1]+$
			;10000.*(1.-fit.x_qflg[0:prm.nrang-1])
	bad = where(fit.phi0[0:prm.nrang-1] eq 0., nb)
	if prm.xcf eq 0 then begin
		bad = lindgen(prm.nrang)
		nb = prm.nrang
	endif
	if nb gt 0 then begin
		tmp_phi0[nrecs,  [bad]] = 10000.
		tmp_elevation[nrecs, [bad]] = 10000.
	endif
	tmp_lagfr[nrecs] = prm.lagfr
	tmp_smsep[nrecs] = prm.smsep
	tmp_tfreq[nrecs] = prm.tfreq
	tmp_noise.search[nrecs] = prm.noise.search
	tmp_noise.sky[nrecs] = fit.noise.sky
	tmp_atten[nrecs] = prm.atten
	tmp_nave[nrecs]  = prm.nave
	tmp_ifmode[nrecs] = ( prm.ifmode eq -1 ? 255b : byte(prm.ifmode) )
	nrecs += 1L

	; if temporary arrays are too small, warn and break
	if nrecs ge MAX_RECS then begin
		prinfo, 'To many data records in file for initialized array. Truncating.'
		break
	endif
endwhile

;prinfo, 'Reading took: '+string(systime(1)-startsec)
if oldfit then $
	free_lun, ilun.fitunit $
else $
	free_lun, ilun

; delete concat file
file_delete, o_file

if nrecs lt 1 then begin
	prinfo, 'No real data read.'
	rad_fit_set_data_index, data_index-1
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
	channel: bytarr(nrecs), $
	xcf: bytarr(nrecs), $
	lag0power: fltarr(nrecs, maxgates), $
	power: fltarr(nrecs, maxgates), $
	velocity: fltarr(nrecs, maxgates), $
	velocity_error: fltarr(nrecs, maxgates), $
	width: fltarr(nrecs, maxgates), $
	gscatter: bytarr(nrecs, maxgates), $
	phi0: fltarr(nrecs, maxgates), $
	elevation: fltarr(nrecs, maxgates), $
	lagfr: intarr(nrecs), $
	smsep: intarr(nrecs), $
	tfreq: fltarr(nrecs), $
	noise: {search: fltarr(nrecs), sky: fltarr(nrecs)}, $
	atten: intarr(nrecs), $
	nave: bytarr(nrecs), $
	ifmode: bytarr(nrecs) $
}
; distribute data in structure
trad_fit_data.juls = tmp_juls[0:nrecs-1L]
trad_fit_data.ysec = tmp_ysec[0:nrecs-1L]
trad_fit_data.beam = tmp_beam[0:nrecs-1L]
trad_fit_data.scan_id = tmp_scan_id[0:nrecs-1L]
trad_fit_data.scan_mark = tmp_scan_mark[0:nrecs-1L]
trad_fit_data.channel = tmp_channel[0:nrecs-1L]
trad_fit_data.xcf = tmp_xcf[0:nrecs-1L]
trad_fit_data.lag0power = tmp_pwr0[0:nrecs-1L,*]
trad_fit_data.power = tmp_power[0:nrecs-1L,*]
trad_fit_data.velocity = tmp_velocity[0:nrecs-1L,*]
trad_fit_data.velocity_error = tmp_velocity_error[0:nrecs-1L,*]
trad_fit_data.width = tmp_width[0:nrecs-1L,*]
trad_fit_data.gscatter = tmp_gscatter[0:nrecs-1L,*]
trad_fit_data.phi0 = tmp_phi0[0:nrecs-1L,*]
trad_fit_data.elevation = tmp_elevation[0:nrecs-1L,*]
trad_fit_data.lagfr = tmp_lagfr[0:nrecs-1L]
trad_fit_data.smsep = tmp_smsep[0:nrecs-1L]
trad_fit_data.tfreq = tmp_tfreq[0:nrecs-1L]
trad_fit_data.noise.search = tmp_noise.search[0:nrecs-1L]
trad_fit_data.noise.sky = tmp_noise.sky[0:nrecs-1L]
trad_fit_data.atten = tmp_atten[0:nrecs-1L]
trad_fit_data.nave = tmp_nave[0:nrecs-1L]
trad_fit_data.ifmode = tmp_ifmode[0:nrecs-1L]

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
rad_fit_data[data_index] = ptr_new(trad_fit_data)

; get coordinates
coords = get_coordinates()

; determine whether inteferometer data is present
; 0: no interferometer data
; 1: inteferometer data for the ENTIRE time that is loaded
; 2: interferometer data for SOME time
info_xcf = 0b
dummy = where( trad_fit_data.xcf, xcc )
if xcc eq nrecs then $
	info_xcf = 1b $
else if xcc gt 0L then $
	info_xcf = 2b

; set up new info structure
trad_fit_info = { $
	sjul: trad_fit_data.juls[0], $
	fjul: trad_fit_data.juls[nrecs-1L], $
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
;	fov_coords: coords, $
	parameters: ['juls','ysec','beam','scan_id','scan_mark','beam_scan',$
		'channel','xcf','lag0power','power','velocity','velocity_error','width','phi0','elevation',$
		'gscatter','lagfr','smsep','tfreq','noise','atten','nave','ifmode'], $
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
