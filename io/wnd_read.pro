;+ 
; NAME: 
; WND_READ
;
; PURPOSE: 
; This procedure reads Wind MAG and SWEPAM data into the variables of the structure WND_MAG_DATA and WND_SWE_DATA in
; the common block WND_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; WND_READ, Date
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
; WND_DATA_BLK: The common block holding the currently loaded Wind data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Steve Milan's READ_FILES.
; Written by Lasse Clausen, Nov, 24 2009
; Changed to 1 minute format, 13 Jan, 2010
;-
pro wnd_read, date, time=time, long=long, $
	silent=silent, force=force

if n_params() ne 1 then begin
	if ~keyword_set(silent) then $
		prinfo, 'Must give DATE.'
	return
endif

wnd_mag_read, date, time=time, long=long, $
	silent=silent, force=force

wnd_swe_read, date, time=time, long=long, $
	silent=silent, force=force

end
