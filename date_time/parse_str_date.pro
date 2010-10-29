;+ 
; NAME: 
; PARSE_STR_DATE 
; 
; PURPOSE: 
; This procedure converts a string date in MMMYYYY or YYYYMMDD format into the 
; numeric YYYYMMDD format.
; 
; CATEGORY: 
; Date/Time
; 
; CALLING SEQUENCE: 
; PARSE_STR_DATE, Strdate
; 
; INPUTS: 
; Strdate: The date in MMMYYYY or YYYYMMDD format of data type string - where 
; MMM are the first three letters of the name of a month. This can be a scalar
; or a 2-element vector.
; 
; OPTIONAL OUTPUTS: 
; Date: The date in numeric YYYYMMDD format.
; 
; EXAMPLE: 
; strdate = ['jan2004','jun2005']
; parse_str_date,strdate,date
; print, date
;         20040101        20050601
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro parse_str_date, strdate, date

if n_params() lt 1 then begin
	prinfo, 'Must give Strdate.'
	date = 0
	return
endif

months = ['jan','feb','mar','apr','may','jun',$
	'jul','aug','sep','oct','nov','dec']

if n_elements(strdate) eq 2 then begin
	parse_str_date, strdate[0], sdate
	parse_str_date, strdate[1], fdate
	if n_elements(sdate) eq 2 and n_elements(fdate) eq 2 then $
		date = [sdate[0], fdate[1]] $
	else $
		date = [sdate, fdate]
	return
endif

if strlen(strdate) eq 7 then begin
	month = strlowcase(strmid(strdate, 0, 3))
	year = fix(strmid(strdate, 3, 4))
endif else if strlen(strdate) eq 6 then begin
	month = months[fix(strmid(strdate, 0, 2))-1]
	year = fix(strmid(strdate, 2, 4))
endif else if strlen(strdate) eq 9 then begin
	day = fix(strmid(strdate, 0, 2))
	month = strlowcase(strmid(strdate, 2, 3))
	year = fix(strmid(strdate, 5, 4))
	dd = where(months eq month, mm)
	if mm eq 0 then begin
		prinfo, 'Invalid STRDATE format (month): '+strdate, /force
		return
	endif
	date = year*10000L + (dd+1)*100L + day
	return
endif else if strlen(strdate) eq 11 then begin
	day = fix(strmid(strdate, 0, 2))
	month = strlowcase(strmid(strdate, 3, 3))
	year = fix(strmid(strdate, 7, 4))
	dd = where(months eq month, mm)
	if mm eq 0 then begin
		prinfo, 'Invalid STRDATE format (month): '+strdate, /force
		return
	endif
	date = year*10000L + (dd+1)*100L + day
	return
endif else if strlen(strdate) eq 8 then begin
	date = long(strdate)
	return
endif else begin
	prinfo, 'Invalid STRDATE format (length): '+strdate, /force
	return
endelse

if year lt 1900 or year gt 2020 then begin
	prinfo, 'Invalid STRDATE format (year): '+strdate, /force
	return
endif

dd = where(months eq month, mm)
if mm eq 0 then begin
	prinfo, 'Invalid STRDATE format (month): '+strdate, /force
	return
endif
days = days_in_month(dd+1, year=year)

date = [year*10000L+(dd+1)*100L+1, year*10000L+(dd+1)*100L+days]

end
