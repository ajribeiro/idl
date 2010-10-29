;+ 
; NAME: 
; THE_POS_CHECK_LOADED
;
; PURPOSE: 
; This function checks whether Themis position data for the chosen time interval is
; already loaded.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = THE_POS_CHECK_LOADED(Date, Probe, Coords)
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; Probe: A string containing the probe to check.
;
; Coords: A string containing the coordinate system in which teh position data is saved.
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
; KPI_DATA_BLK: The common block holding the currently loaded radar data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Nov, 30 2009
;-
function the_pos_check_loaded, date, probe, coords, time=time, long=long, $
	silent=silent

common the_data_blk

; check if parameters are given
if n_params() lt 3 then begin
	prinfo, 'Must give date, probe and coordinate system.'
	return, !false
endif

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

; convert input date and time to julian day numbers
sfjul, date, time, sjul, fjul, long=long

ind = byte(probe) - (byte('a'))[0]

; check if any records are in the common block
if the_pos_info[ind].nrecs eq 0L then $
	return, !false

; check if data is in correct coordinate system
if the_pos_info[ind].coords ne coords then $
	return, !false

;- give 3 minutes lee way
if the_pos_info[ind].sjul gt sjul+3.d/1440.d then $
	return, !false

if the_pos_info[ind].fjul lt fjul-3.d/1440.d then $
	return, !false

if ~keyword_set(silent) then $
	prinfo, 'Data already loaded, skipping.'

return, !true

end
