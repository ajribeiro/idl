;+ 
; NAME: 
; SFJUL 
; 
; PURPOSE: 
; This function converts numeric date and time in YYYYMMDD and HHII or HHIISS
; format into Julian day numbers and vice versa.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; SFJUL, Date, Time, Sjul, Fjul
; 
; INPUTS: 
; Date: If the DATE_TO_JUL keyword is set (default) this variable contains
; the numeric date which will be converted to a Julian day number. In
; YYYYMMDD ot MMMYYYY format. Can be
; a scalar or a 2-element vector.
;
; Time: If the DATE_TO_JUL keyword is set (default) this variable contains
; the numeric time which will be converted to a Julian day number. In
; HHII or HHIISS (with LONG keyword set) format. Can be
; a scalar or a 2-element vector.
; If time is 2-element vector and time[0] is less than time[1], the two times are 
; assumed to be on the same day. If time[1] is less then time[0], it is assumed 
; that time[1] gives the time on the day after.
;
; Sjul: If the JUL_TO_DATE keyword is set, this variable contains the 
; Julian day number which will be converted to a numeric date and time.
;
; Fjul: If the JUL_TO_DATE keyword is set, this variable contains the 
; Julian day number which will be converted to a numeric date and time.
; Date and Time will then contain ranges, i.e. be 2-element vectors.
; 
; OUTPUTS: 
; Date: If the JUL_TO_DATE keyword is set this variable contains
; the numeric date of the input Julian day number. If both Sjul
; and Fjul were given, this will be a 2-element vector.
;
; Time: If the JUL_TO_DATE keyword is set this variable contains
; the numeric time of the input Julian day number. If both Sjul
; and Fjul were given, this will be a 2-element vector.
;
; Sjul: If the DATE_TO_JUL keyword is set (default), this variable contains the 
; Julian day number associated with the first element in Date and Time.
;
; Fjul: If the DATE_TO_JUL keyword is set (default), this variable contains the 
; Julian day number associated with the first element in Date and Time. Hence
; this variable will only be set if Date and Time are 2-element vectors.
; 
; KEYWORD PARAMETERS:
; LONG: Set this keyword to indicate that the input is in HHIISS format. Default is
; HHII format.
; 
; NO_HOURS: Set this keyword to a named variable that will contain the number of 
; hours that the given time range covers. This will only be calculated when converting
; from numeric Date/Time to Julian day number.
;
; NO_DAYS: Set this keyword to a named variable that will contain the number of 
; days that the given time range covers. This will only be calculated when converting
; from numeric Date/Time to Julian day number.
;
; NO_MONTHS: Set this keyword to a named variable that will contain the number of 
; months that the given time range covers. This will only be calculated when converting
; from numeric Date/Time to Julian day number.
;
; NO_YEARS: Set this keyword to a named variable that will contain the number of 
; years that the given time range covers. This will only be calculated when converting
; from numeric Date/Time to Julian day number.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro sfjul, date, time, sjul, fjul, $
	jul_to_date=jul_to_date, $
	date_to_jul=date_to_jul, $
	no_days=no_days, no_months=no_months, no_years=no_years, $
	no_hours=no_hours, $
	long=long

;- default is date, time to julian day number
if ~keyword_set(jul_to_date) and ~keyword_set(date_to_jul) then $
	date_to_jul=1
; check input

if keyword_set(date_to_jul) then begin
	if n_params() lt 3 then begin
		prinfo, 'Must give Date, Time, Sjul.'
		return
	endif
endif else begin
	if n_params() lt 3 then begin
		prinfo, 'Must give Date, Time, Sjul.'
		return
	endif
endelse

if keyword_set(date_to_jul) then begin
	if size(date, /type) eq 7 then $
		parse_str_date, date, ndate $
	else $
		ndate = date
	if n_elements(ndate) eq 2 then begin
		parse_date, ndate[0], syear, smonth, sday
		parse_date, ndate[1], fyear, fmonth, fday
		if n_elements(time) eq 1 then $
			time = replicate(time, 2)
		parse_time, time, shour, sminute, fhour, fminute, ssecond, fsecond, $
			long=long
		sjul = julday(smonth, sday, syear, shour, sminute, ssecond)
		fjul = julday(fmonth, fday, fyear, fhour, fminute, fsecond)
		no_days = long(fjul-sjul-(time[1] eq 2400 ? 1.d/86400.d : 0.d))+1L+$
			(time[1] lt time[0] ? 1L : 0L)
		if arg_present(no_months) or arg_present(no_years) then begin
			caldat, sjul, sm, sd, sy
			caldat, fjul-(time[1] eq 2400 ? 1.d/86400.d : 0.d), fm, fd, fy
			no_months = (fy*12+fm - (sy*12+sm)) + 1L
			no_years = fy-sy
		endif
	endif else if n_elements(ndate) eq 1 then begin
		no_days = 1L
		no_years = 1L
		parse_date, ndate, year, month, day
		if n_elements(time) eq 1 then $
			_time = replicate(time, 2) $
		else $
			_time = time
		parse_time, _time, shour, sminute, fhour, fminute, ssecond, fsecond, $
			long=long
		sjul = julday(month, day, year, shour, sminute, ssecond)
		fjul = julday(month, day, year, fhour, fminute, fsecond)
		;- take care of day boundary.
		if n_elements(time) eq 2 then begin
			if time[1] le time[0] then begin
				fjul += 1.d
				no_days = 2l
			endif
		endif
		no_days = long(fjul-sjul-(_time[1] eq 2400 ? 1.d/86400.d : 0.d))+1L+$
			(_time[1] lt _time[0] ? 1L : 0L)
		if arg_present(no_months) then begin
			caldat, sjul, sm
			caldat, fjul-(time[1] eq 2400 ? 1.d/86400.d : 0.d), fm
			if sm ne fm then $
				no_months = 2 $
			else $
				no_months = 1
		endif
	endif else begin
		message, /info, 'DATE must be 1 or 2 elements vector.'
		return
	endelse
	no_hours = (fjul-sjul)*24.d
endif
if keyword_set(jul_to_date) then begin
	caldat, sjul, smonth, sday, syear, shour, sminute, ssecond
	date = syear*10000L + smonth*100L + sday
	if keyword_set(long) then $
		time = shour*10000L+sminute*100L+round(ssecond) $
	else $
		time = shour*100+sminute
	
	if n_params() eq 4 then begin
		caldat, fjul, fmonth, fday, fyear, fhour, fminute, fsecond
		if fhour eq 0 and fminute eq 0 and fsecond lt 1. then begin
			caldat, fjul-1.d/86400.d, fmonth, fday, fyear
			fhour = 24
		endif
		if fday ne sday or fmonth ne smonth or fyear ne syear then $
			date = [date, fyear*10000L + fmonth*100L + fday]
		if keyword_set(long) then $
			time = [time, $
				fhour*10000L+fminute*100L+round(fsecond)] $
		else $
			time = [time, fhour*100+fminute]
	endif
endif
end
