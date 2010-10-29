;+ 
; NAME: 
; PARSE_DATE 
; 
; PURPOSE: 
; This procedure extracts day, month and year from a numeric date in YYYYMMDD
; format.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; PARSE_DATE, Date
; 
; INPUTS: 
; Date: The date in YYYYMMDD format from which the day, month and year are
; extracted. Can be a 2-element vector for a date range.
; 
; KEYWORD PARAMETERS: 
; SILENT: Set this keyword to surpress warning messages.
;
; FIRST: Set this keyword to indicate that the day, month, year of the first
; element of the 2-element input vector is returned.
;
; MIDDLE: Set this keyword to indicate that the day, month, year of the average
; date of the 2-element input vector is returned.
;
; LAST: Set this keyword to indicate that the day, month, year of the last (second)
; element of the 2-element input vector is returned.
; 
; OPTIONAL OUTPUTS: 
; Year: A named variable that will contain the year of the input date.
;
; Month: A named variable that will contain the month of the input date.
;
; Day: A named variable that will contain the day of the input date.
;
; Doy: A named variable that will contain the day of year of the input date.
; 
; EXAMPLE: 
; date = 20060212
; parse_date, date, year, month, day
; print, year, month, day
;         2006           2          12
; date = [20040101,20050101]
; parse_date,date,year
; % PARSE_DATE:             DATE is 2-element vector. Taking first.
; print, year
;         2004
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro parse_date, date, year, month, day, doy, silent=silent, $
	first=first, middle=middle, last=last

if n_params() lt 1 then begin
	prinfo, 'Must give Date.'
	year = 0
	month = 0
	day = 0
	doy = 0
	return
endif

if ~keyword_set(first) and ~keyword_set(middle) and ~keyword_set(last) then $
	first = 1

if n_elements(date) eq 2 then begin

	if keyword_set(first) then begin
		if ~keyword_set(silent) then $
			prinfo, 'DATE is 2-element vector. Taking first.'
		year  = date[0]/10000L
		month = (date[0] mod 10000L)/100L
		day   = (date[0] mod 100L)
		doy   = day_no(year, month, day)
	endif else if keyword_set(middle) then begin
		if ~keyword_set(silent) then $
			prinfo, 'DATE is 2-element vector. Taking average.'
		syear  = date[0]/10000L
		smonth = (date[0] mod 10000L)/100L
		sday   = (date[0] mod 100L)
		fyear  = date[1]/10000L
		fmonth = (date[1] mod 10000L)/100L
		fday   = (date[1] mod 100L)
		caldat, (julday(smonth, sday, syear)+julday(fmonth, fday, fyear))/2.d, $
			month, day, year
		doy   = day_no(year, month, day)
	endif else begin
		if ~keyword_set(silent) then $
			prinfo, 'DATE is 2-element vector. Taking last.'
		year  = date[1]/10000L
		month = (date[1] mod 10000L)/100L
		day   = (date[1] mod 100L)
		doy   = day_no(year, month, day)
	endelse
endif else begin
	year  = date/10000L
	month = (date mod 10000L)/100L
	day   = (date mod 100L)
	doy   = day_no(year, month, day)
endelse

end
