;+ 
; NAME: 
; THE_FGM_READ
;
; PURPOSE: 
; This procedure reads Themis FGM data into the variables of the structure THE_FGM_DATA in
; the common block THE_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; THE_FGM_READ, Date
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
; The routine calls THM_LOAD_FGM to do all the reading and converting of coordinate
; systems. The read data is then place in the THE_DATA_BLK common block.
;
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; THE_FGM_BLK: The common block holding the currently loaded Themis data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
pro the_fgm_read, date, time=time, long=long, $
	force=force, silent=silent, datatype=datatype

common the_data_blk

for i=0, 4 do $
	the_fgm_info[i].nrecs = 0L

if ~keyword_set(date) then begin
	prinfo, 'Must give date.'
	return
endif

if ~keyword_set(datatype) then $
	datatype = 'fgs'

if n_elements(time) eq 0 then $
	time = [0,2400]
sfjul, date, time, sjul, fjul, long=long
zero_epoch = julday(1,1,1970,0)
trange = ([sjul,fjul]-zero_epoch)*86400.d
timespan, trange

probes = ['a','b','c','d','e']

for i=0, 4 do begin
	probe = probes[i]
	if ~keyword_set(force) then begin
		if the_fgm_check_loaded(date, probe, time=time, long=long) then $
			continue
	endif
	if ptr_valid(the_fgm_data[i]) then $
		ptr_free, the_fgm_data[i]
	thm_load_fgm, datatype=datatype, coord='gse', probe=probe, trange=trange
	get_data, 'th'+probe+'_'+datatype+'_gse', fgm_time, fgm_gse
	thm_load_fgm, datatype=datatype, coord='gsm', probe=probe, trange=trange
	get_data, 'th'+probe+'_'+datatype+'_gsm', fgm_time, fgm_gsm
	fgm_juls = fgm_time/86400.d + zero_epoch
	if n_elements(fgm_gse) eq 1L then begin
		tmp_struc = { $
			juls: -1.d, $
			bx_gse: -1.d, $
			by_gse: -1.d, $
			bz_gse: -1.d, $
			by_gsm: -1.d, $
			bz_gsm: -1.d, $
			bt: -1.d $
		}
		nrecs = 0L
	endif else begin
		tmp_struc = { $
			juls: fgm_juls, $
			bx_gse: reform(fgm_gse[*,0]), $
			by_gse: reform(fgm_gse[*,1]), $
			bz_gse: reform(fgm_gse[*,2]), $
			by_gsm: reform(fgm_gsm[*,1]), $
			bz_gsm: reform(fgm_gsm[*,2]), $
			bt: sqrt(total(fgm_gse^2, 2)) $
		}
		nrecs = n_elements(fgm_juls)
		tpnames = tnames('th'+probe+'_'+datatype+'_*')
		store_data, tpnames, /delete
	endelse
	the_fgm_data[i] = ptr_new(tmp_struc)
	the_fgm_info[i].sjul = fgm_juls[0]
	the_fgm_info[i].fjul = fgm_juls[(nrecs-1L) > 0L]
	the_fgm_info[i].nrecs = nrecs
;1	stop
endfor

end