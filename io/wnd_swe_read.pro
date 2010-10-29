;+ 
; NAME: 
; WND_SWE_READ
;
; PURPOSE: 
; This procedure reads Wind SWE data into the variables of the structure WND_SWE_DATA in
; the common block WND_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; WND_SWE_READ, Date
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
; MODIFICATION HISTORY:
; Based on Steve Milan's READ_FILES.
; Written by Lasse Clausen, Nov, 24 2009
; Changed to 1 minute format, 13 Jan, 2010
;-
pro wnd_swe_read, date, time=time, long=long, $
	silent=silent, force=force, $
	filename=filename, filedate=filedate

common wnd_data_blk

wnd_swe_info.nrecs = 0L

; resolution is up to 6 seconds, hence one day
; has about 14400 data records
NFILERECS = 14400L

if ~keyword_set(filename) then begin
	; check if parameters are given
	if n_params() lt 1 then begin
		prinfo, 'Must give date.'
		return
	endif

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = wnd_swe_check_loaded(date, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = wnd_swe_find_files(date, time=time, long=long, file_count=fc)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+format_date(date)+$
				', '+format_time(time)
		return
	endif
	no_delete = !false
endif else begin
	fc = n_elements(filename)
	; wi_h?_swe_20090303_v10.cdf
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
vx_gse = fltarr(MAX_RECS)
vy_gse = fltarr(MAX_RECS)
vz_gse = fltarr(MAX_RECS)
vt = fltarr(MAX_RECS)
np = fltarr(MAX_RECS)
pd = fltarr(MAX_RECS)
nrecs = 0L

; read files
for i=0, fc-1 do begin

	if ~keyword_set(silent) then $
		prinfo, 'Reading '+files[i]

	data = cdf_read(files[i], ['Epoch','N_elec','U_eGSE'], /silent)

	; exit if all read
	if size(data, /type) ne 8 then $
		continue

	; how much data was read
	tnrecs = n_elements(data.epoch[0,*])
	if tnrecs lt 1L then $
		continue

;	help, nrecs, tnrecs, MAX_RECS

	juls[nrecs:nrecs+tnrecs-1L] = cdf_epoch2jul(reform(data.epoch[0,*]))
	vx_gse[nrecs:nrecs+tnrecs-1L] = data.U_eGSE[0,*]
	vy_gse[nrecs:nrecs+tnrecs-1L] = data.U_eGSE[1,*]
	vz_gse[nrecs:nrecs+tnrecs-1L] = data.U_eGSE[2,*]
	vt[nrecs:nrecs+tnrecs-1L] = sqrt(total(data.U_eGSE^2, 1))
	np[nrecs:nrecs+tnrecs-1L] = data.N_elec[0,*]
	pd[nrecs:nrecs+tnrecs-1L] = ((data.N_elec[0,*]*1E6)*(1.92E-27)*(vt[nrecs:nrecs+tnrecs-1L]*1000.0)^2)/1E-9
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
twnd_swe_data = { $
	juls: dblarr(ccc), $
	vx_gse: fltarr(ccc), $
	vy_gse: fltarr(ccc), $
	vz_gse: fltarr(ccc), $
	vy_gsm: fltarr(ccc), $
	vz_gsm: fltarr(ccc), $
	vt: fltarr(ccc), $
	np: fltarr(ccc), $
	pd: fltarr(ccc) $
}

; populate structure
twnd_swe_data.juls = (juls[0:nrecs-1L])[jinds]
twnd_swe_data.vx_gse = (vx_gse[0:nrecs-1L])[jinds]
twnd_swe_data.vy_gse = (vy_gse[0:nrecs-1L])[jinds]
twnd_swe_data.vz_gse = (vz_gse[0:nrecs-1L])[jinds]
; calculate time structure for CXFORM conversion routines
caldat, twnd_swe_data.juls, imn, idy, iyear, ih, im, is
time = date2es(imn,idy,iyear,ih,im,is)
; call CXFORM routine
; for the magnetic field
ib = transpose([[twnd_swe_data.vx_gse],[twnd_swe_data.vy_gse],[twnd_swe_data.vz_gse]])
ob = cxform(ib, 'GSE', 'GSM', time)
twnd_swe_data.vy_gsm = ob[1,*]
twnd_swe_data.vz_gsm = ob[2,*]
twnd_swe_data.vt = (vt[0:nrecs-1L])[jinds]
twnd_swe_data.np = (np[0:nrecs-1L])[jinds]
twnd_swe_data.pd = (pd[0:nrecs-1L])[jinds]

; replace old data structure with new one
wnd_swe_data = twnd_swe_data

wnd_swe_info.sjul = wnd_swe_data.juls[0L]
wnd_swe_info.fjul = wnd_swe_data.juls[ccc-1L]
wnd_swe_info.nrecs = ccc

end
