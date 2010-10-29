;+ 
; NAME: 
; CLU_FGM_READ
;
; PURPOSE: 
; This procedure reads data from the FGM experiment onboard the Cluster 
; satellites into the variables in CLU_DATA_BLK.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; CLU_FGM_READ, Date
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; KEYWORD PARAMETERS:
; SC: Set this to specify the spacecraft of which to read data. Can be an array.
;
; ALL: Set this keyword to read the data for all spacecraft. Equivalent to 
; SC=[1,2,3,4];
;
; TIME: The time range for which to read data. Must be a 2-element vector in 
; HHII format, or HHIISS format if the LONG keyword is set. If TIME is not set
; the default value [0000,2400] is assumed.
;
; LONG: Set this keyword to indicate that the Time value is in HHIISS
; format rather than HHII format.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; FILENAME: Set this to a string containing the name of the file to read.
;
; FILESC: Set this to the spacecraft number of the file to read.
;
; FILEDATE: Set this to a string containing the date from which the file to read.
;
; FORCE: Set this keyword to read the data, even if it is already present in the
; CLU_DATA_BLK, i.e. even if CLU_CHECK_LOADED returns true.
;
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; CLU_DATA_BLK: The common block holding the currently loaded radar data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Jan, 22 2010
;-
pro clu_fgm_read, date, time=time, $
	long=long, silent=silent, $
	sc=sc, all=all, $
	filename=filename, filesc=filesc, filedate=filedate, $
	force=force

common clu_data_blk

; calculate the maximum records the data array will hold
; take 4 second sampling time for four days
MAX_RECS = 86400L/4L*10L

if ~keyword_set(sc) and ~keyword_set(all) then $
	all=1

if keyword_set(all) then begin
	; check if parameters are given
	if n_params() lt 1 then begin
		prinfo, 'Must give date.'
		return
	endif
	clu_fgm_read, date, time=time, long=long, silent=silent, $
		force=force, sc=1
	clu_fgm_read, date, time=time, long=long, silent=silent, $
		force=force, sc=2
	clu_fgm_read, date, time=time, long=long, silent=silent, $
		force=force, sc=3
	clu_fgm_read, date, time=time, long=long, silent=silent, $
		force=force, sc=4
	return
endif

if n_elements(sc) gt 1 then begin
	; check if parameters are given
	if n_params() lt 1 then begin
		prinfo, 'Must give date.'
		return
	endif
	for i=0, n_elements(sc)-1 do $
		clu_fgm_read, date, time=time, long=long, silent=silent, $
			force=force, sc=sc[i]
	return
endif

if sc lt 1 or sc gt 4 then  begin
	prinfo, 'Sc must be 1 <= sc <= 4.'
	return
endif
str_sc = string(sc, format='(I1)')

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
clu_fgm_info[sc-1].nrecs = 0L

; set default time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

if ~keyword_set(filename) then begin
	; check if parameters are given
	if n_params() lt 1 then begin
		prinfo, 'Must give date.'
		return
	endif

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = clu_fgm_check_loaded(date, sc, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = clu_fgm_find_files(date, sc, time=time, long=long, file_count=fc)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: sc '+str_sc+', '+format_date(date)+$
				', '+format_time(time)
		return
	endif
	no_delete = !false
endif else begin
	fc = n_elements(filename)
	; C2_CP_FGM_SPIN__20050417_000000_20050418_000000_V070905.cdf
	for i=0, fc-1 do begin
		if ~file_test(filename[i]) then begin
			prinfo, 'Cannot find file: '+filename[i]
			return
		endif
		if ~keyword_set(filesc) then begin
			bfile = file_basename(filename[i])
			sc = fix(strmid(bfile, 1, 1))
		endif else $
			sc = filesc
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
tmp_bx   = make_array(MAX_RECS, /float)
tmp_by   = make_array(MAX_RECS, /float)
tmp_bz   = make_array(MAX_RECS, /float)
tmp_bt   = make_array(MAX_RECS, /float)
tmp_rx   = make_array(MAX_RECS, /float)
tmp_ry   = make_array(MAX_RECS, /float)
tmp_rz   = make_array(MAX_RECS, /float)
nrecs = 0L

; read files
for i=0, fc-1 do begin

	if ~keyword_set(silent) then $
		prinfo, 'Reading '+files[i]

	; time_tags__C1_CP_FGM_SPIN
	; B_vec_xyz_gse__C1_CP_FGM_SPIN
	; B_mag__C1_CP_FGM_SPIN
	; sc_pos_xyz_gse__C1_CP_FGM_SPIN
	data = cdf_read(files[i], ['time_tags__C'+str_sc+'_CP_FGM_SPIN', $
		'B_vec_xyz_gse__C'+str_sc+'_CP_FGM_SPIN', 'B_mag__C'+str_sc+'_CP_FGM_SPIN', $
		'sc_pos_xyz_gse__C'+str_sc+'_CP_FGM_SPIN'], $
		tagnames=['time','bvec','bmag','pos'], /silent)

	; exit if all read
	if size(data, /type) ne 8 then $
		continue

	; how much data was read
	anrecs = n_elements(data.time)
	if anrecs lt 1L then $
		continue

;	print, files[i]
;4	help, data, /str

	tmp_juls[nrecs:nrecs+anrecs-1L] = cdf_epoch2jul(data.time)
	tmp_bx[nrecs:nrecs+anrecs-1L]   = reform(data.bvec[0,*])
	tmp_by[nrecs:nrecs+anrecs-1L]   = reform(data.bvec[1,*])
	tmp_bz[nrecs:nrecs+anrecs-1L]   = reform(data.bvec[2,*])
	tmp_bt[nrecs:nrecs+anrecs-1L]   = reform(data.bmag)
	tmp_rx[nrecs:nrecs+anrecs-1L]   = reform(data.pos[0,*])
	tmp_ry[nrecs:nrecs+anrecs-1L]   = reform(data.pos[1,*])
	tmp_rz[nrecs:nrecs+anrecs-1L]   = reform(data.pos[2,*])
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

; set up temporary structure
clu_fgm_data_sc = { $
	juls: dblarr(nrecs), $
	bx_gse: fltarr(nrecs), $
	by_gse: fltarr(nrecs), $
	bz_gse: fltarr(nrecs), $
	by_gsm: fltarr(nrecs), $
	bz_gsm: fltarr(nrecs), $
	bt: fltarr(nrecs), $
	rx_gse: fltarr(nrecs), $
	ry_gse: fltarr(nrecs), $
	rz_gse: fltarr(nrecs), $
	ry_gsm: fltarr(nrecs), $
	rz_gsm: fltarr(nrecs), $
	rt: fltarr(nrecs) $
}

; populate structure
clu_fgm_data_sc.juls = tmp_juls[0:nrecs-1L]
clu_fgm_data_sc.bx_gse = tmp_bx[0:nrecs-1L]
clu_fgm_data_sc.by_gse = tmp_by[0:nrecs-1L]
clu_fgm_data_sc.bz_gse = tmp_bz[0:nrecs-1L]
clu_fgm_data_sc.bt = tmp_bt[0:nrecs-1L]
clu_fgm_data_sc.rx_gse = tmp_rx[0:nrecs-1L]/!re
clu_fgm_data_sc.ry_gse = tmp_ry[0:nrecs-1L]/!re
clu_fgm_data_sc.rz_gse = tmp_rz[0:nrecs-1L]/!re

; calculate time structure for CXFORM conversion routines
caldat, clu_fgm_data_sc.juls, imn, idy, iyear, ih, im, is
estime = date2es(imn,idy,iyear,ih,im,is)
; call CXFORM routine
; for the magnetic field
ib = transpose([[clu_fgm_data_sc.bx_gse],[clu_fgm_data_sc.by_gse],[clu_fgm_data_sc.bz_gse]])
ob = cxform(ib, 'GSE', 'GSM', estime)
clu_fgm_data_sc.by_gsm = ob[1,*]
clu_fgm_data_sc.bz_gsm = ob[2,*]
; and position
ip = transpose([[clu_fgm_data_sc.rx_gse],[clu_fgm_data_sc.ry_gse],[clu_fgm_data_sc.rz_gse]])
op = cxform(ip, 'GSE', 'GSM', estime)
clu_fgm_data_sc.ry_gsm = op[1,*]
clu_fgm_data_sc.rz_gsm = op[2,*]
clu_fgm_data_sc.rt = sqrt(clu_fgm_data_sc.rx_gse^2 + clu_fgm_data_sc.ry_gse^2 + clu_fgm_data_sc.rz_gse^2)

; replace pointer to old data structure
; and first all the pointers inside that pointer
if ptr_valid(clu_fgm_data[sc-1]) then $
	ptr_free, clu_fgm_data[sc-1]
clu_fgm_data[sc-1] = ptr_new(clu_fgm_data_sc)

clu_fgm_info[sc-1].sjul = (*clu_fgm_data[sc-1]).juls[0L]
clu_fgm_info[sc-1].fjul = (*clu_fgm_data[sc-1]).juls[nrecs-1L]
clu_fgm_info[sc-1].nrecs = nrecs

end
