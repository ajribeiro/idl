;+ 
; NAME: 
; RAD_GRD_CHECK_LOADED
;
; PURPOSE: 
; This function checks whether data for the chosen hemisphere and time interval is
; already loaded.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; ; Result = RAD_GRD_CHECK_LOADED(Date, Hemisphere)
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; Hemisphere: 
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
function rad_grd_check_loaded, date, hemisphere, time=time, long=long, $
	silent=silent

common rad_data_blk

; check if parameters are given
if n_params() lt 2 then begin
	prinfo, 'Must give date and hemisphere.'
	return, !false
endif

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

; convert input date and time to julian day numbers
sfjul, date, time, sjul, fjul, long=long

; check if any records are in the common block
if rad_grd_info[int_hemi].nrecs eq 0L then $
	return, !false

;- give 15 minutes lee way
if rad_grd_info[int_hemi].sjul gt sjul+15.d/1440.d then $
	return, !false

if rad_grd_info[int_hemi].fjul lt fjul-15.d/1440.d then $
	return, !false

if ~keyword_set(silent) then $
	prinfo, 'Data already loaded, skipping.'

return, !true

end
