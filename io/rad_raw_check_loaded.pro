;+ 
; NAME: 
; RAD_RAW_CHECK_LOADED
;
; PURPOSE: 
; This function checks whether dat/rawacf data for the chosen radar and time interval is
; already loaded.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = RAD_RAW_CHECK_LOADED(Date, Radar)
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
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Dec, 11 2009
;-
function rad_raw_check_loaded, date, radar, time=time, long=long, $
	silent=silent

common rad_data_blk

; check if parameters are given
if n_params() lt 2 then begin
	prinfo, 'Must give date and radar code.'
	return, !false
endif

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

; convert input date and time to julian day numbers
sfjul, date, time, sjul, fjul, long=long

; check if any records are in the common block
if rad_raw_info.nrecs eq 0L then $
	return, !false

;- give 2 minutes lee way
if rad_raw_info.sjul gt sjul+2.d/1440.d then $
	return, !false

if rad_raw_info.fjul lt fjul-2.d/1440.d then $
	return, !false

if ~strcmp(rad_raw_info.code,strlowcase(radar)) then $
	return, !false

if ~keyword_set(silent) then $
	prinfo, 'Data already loaded, skipping.'

return, !true

end
