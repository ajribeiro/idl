;+ 
; NAME: 
; GBM_READ
;
; PURPOSE: 
; This procedure reads THEMIS ground-based magnetometer data into the structure
; GBM_DATA.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; GBM_READ, Date, Station
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; Station: Set this to a 4-letter radar code to indicate the GBM for which to read
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
; FORCE: Set this keyword to read the data, even if it is already present in the
; GBM_DATA_BLK, i.e. even if GBM_CHECK_LOADED returns true.
;
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; GBM_DATA_BLK: The common block holding the currently loaded radar data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Jan, 22 2010
;-
pro gbm_read, date, station, time=time, $
	long=long, silent=silent, $
	filename=filename, filestation=filestation, filedate=filedate, $
	force=force

common gbm_data_blk

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
gbm_info.nrecs = 0L

; calculate the maximum records the data array will hold
; take 1/2 second sampling time for one day
MAX_RECS = 2L*86400L

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

if ~keyword_set(filename) then begin
	; check if parameters are given
	if n_params() lt 2 then begin
		prinfo, 'Must give date and GBM code.'
		return
	endif

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = gbm_check_loaded(date, station, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = gbm_find_files(date, station, time=time, long=long, file_count=fc)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+station+', '+format_date(date)+$
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
		if ~keyword_set(filestation) then begin
			bfile = file_basename(filename[i])
			station = strmid(bfile, 11, 4)
		endif else $
			station = filestation
		if keyword_set(filedate) then $
			date = filedate $
		else begin
			bfile = file_basename(filename[i])
			date = long(strmid(bfile, 16, 8))
		endelse
	endfor
	files = filename
	no_delete = !true
endelse

; init temporary arrays
tmp_juls = make_array(MAX_RECS, /double)
tmp_bx   = make_array(MAX_RECS, /double)
tmp_by   = make_array(MAX_RECS, /double)
tmp_bz   = make_array(MAX_RECS, /double)
nrecs = 0L

; read files
for i=0, fc-1 do begin

	data = cdf_read(files[i], ['thg_mag_'+station+'_time','thg_mag_'+station+''], $
		tagnames=['time','mag'], /silent)

	; exit if all read
	if size(data, /type) ne 8 then $
		continue

	; how much data was read
	anrecs = n_elements(data.time)
	if anrecs lt 1L then $
		continue

	tmp_juls[nrecs:nrecs+anrecs-1L] = julday(1,1,1970,0,0,data.time)
	tmp_bx[nrecs:nrecs+anrecs-1L]   = reform(data.mag[0,*])
	tmp_by[nrecs:nrecs+anrecs-1L]   = reform(data.mag[1,*])
	tmp_bz[nrecs:nrecs+anrecs-1L]   = reform(data.mag[2,*])
	nrecs += anrecs
	
	; if temporary arrays are too small, warn and break
	if nrecs gt MAX_RECS then begin
		prinfo, 'To many data records in file for initialized array. Truncating.'
		break
	endif
endfor

if nrecs lt 1 then begin
	prinfo, 'No real data read.'
	return
endif

; make new structure for data
tgbm_data = { $
	juls: dblarr(nrecs), $
	bx_mag: dblarr(nrecs), $
	by_mag: dblarr(nrecs), $
	bz_mag: dblarr(nrecs), $
	bt_mag: dblarr(nrecs) $
}
; distribute data in structure
tgbm_data.juls   = tmp_juls[0:nrecs-1L]
tgbm_data.bx_mag = tmp_bx[0:nrecs-1L]
tgbm_data.by_mag = tmp_by[0:nrecs-1L]
tgbm_data.bz_mag = tmp_bz[0:nrecs-1L]
tgbm_data.bt_mag = sqrt( tgbm_data.bx_mag^2 + tgbm_data.by_mag^2 + tgbm_data.bz_mag^2 )

; put new structure in common block
gbm_data = tgbm_data

; populate with data
gbm_info.nrecs = nrecs
gbm_info.sjul = gbm_data.juls[0]
gbm_info.fjul = gbm_data.juls[nrecs-1L]
gbm_info.station = station
gbm_info.chain = !GBM_THEMIS
geolat = gbm_get_pos(station, longitude=geolon, coords='geog')
if geolat eq -1. then begin
	cid = cdf_open(files[0])
	cdfstr = cdf_inquire(cid)
	if cdfstr.natts ge 1 then begin
		for i=0, cdfstr.natts-1 do begin
			cdf_attinq, cid, i, Name, Scope, MaxEntry
			if strcmp(name, 'station_latitude', /fold) then $
				break
		endfor
		if i ne cdfstr.natts then begin
			cdf_control, cid, attribute=name, get_attr_info=gg
			zvar = -1
			if gg.numzentries gt 0 then $
				zvar = 1 $
			else if gg.numrentries gt 0 then $
				zvar = 0
			if zvar gt -1 then $
				cdf_attget, cid, name, 0, geolat, zvar=zvar
		endif
		for i=0, cdfstr.natts-1 do begin
			cdf_attinq, cid, i, Name, Scope, MaxEntry
			if strcmp(name, 'station_longitude', /fold) then $
				break
		endfor
		if i ne cdfstr.natts then begin
			cdf_control, cid, attribute=name, get_attr_info=gg
			zvar = -1
			if gg.numzentries gt 0 then $
				zvar = 1 $
			else if gg.numrentries gt 0 then $
				zvar = 0
			if zvar gt -1 then $
				cdf_attget, cid, name, 0, geolon, zvar=zvar
		endif
	endif
	cdf_close, cid
endif
gbm_info.glat = geolat
gbm_info.glon = geolon
if geolat eq -1. or geolon eq -1. then begin
	gbm_info.mlat = -1.
	gbm_info.mlon = -1.
	gbm_info.l_value = -1.
endif else begin
	tpos = cnvcoord(gbm_info.glat,gbm_info.glon,1.)
	gbm_info.mlat = tpos[0]
	gbm_info.mlon = tpos[1]+( tpos[1] lt 0. ? 360. : 0. )
	gbm_info.l_value = get_l_value([gbm_info.mlat,gbm_info.mlon,1.],coords='magn')
endelse

end
