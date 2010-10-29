;+ 
; NAME: 
; THE_POS_READ
;
; PURPOSE: 
; This procedure reads Themis position data into the variables of the structure THE_POS_DATA in
; the common block THE_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; THE_POS_READ, Date
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
; COORDS: A string sontaining the coordinate system abbreviation in which to load the data.
; Can be 'gsm', 'gse', 'gei', 'geo'. Default is 'gsm'.
;
; PROCEDURE:
; The routine calls THM_LOAD_STATE to do all the reading and converting of coordinate
; systems. The read data is then place in the THE_DATA_BLK common block.
;
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; THE_POS_BLK: The common block holding the currently loaded Themis data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
pro the_pos_read, date, time=time, long=long, $
	coords=coords, silent=silent

common the_data_blk

for i=0, 4 do $
	the_pos_info[i].nrecs = 0L

if ~keyword_set(date) then begin
	prinfo, 'Must give date.'
	return
endif

if n_elements(time) eq 0 then $
	time = [0,2400]
sfjul, date, time, sjul, fjul, long=long
zero_epoch = julday(1,1,1970,0)
trange = ([sjul,fjul]-zero_epoch)*86400.d
timespan, trange

if ~keyword_set(coords) then $
	coords = 'gse'

probes = ['a','b','c','d','e']

for i=0, 4 do begin
	probe = probes[i]
	if the_pos_check_loaded(date, probe, coords, time=time, long=long) then $
		continue
	if ptr_valid(the_pos_data[i]) then $
		ptr_free, the_pos_data[i]
	thm_load_state, datatype='pos', coord=coords, probe=probe, trange=trange
	get_data, 'th'+probe+'_state_pos', pos_time, pos
	pos_time = pos_time/86400.d + zero_epoch
	tmp_struc = { $
		juls: pos_time, $
		rx: reform(pos[*,0])/!re, $
		ry: reform(pos[*,1])/!re, $
		rz: reform(pos[*,2])/!re, $
		rt: sqrt(total(pos^2, 2)) $
	}
	nrecs = n_elements(pos_time)
	the_pos_data[i] = ptr_new(tmp_struc)
	the_pos_info[i].sjul = pos_time[0]
	the_pos_info[i].fjul = pos_time[nrecs-1L]
	the_pos_info[i].coords = coords
	the_pos_info[i].nrecs = nrecs
	tpnames = tnames('th'+probe+'_state*')
	store_data, tpnames, /delete
endfor

end