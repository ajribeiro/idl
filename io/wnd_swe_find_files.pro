;+ 
; NAME: 
; WND_SWE_FIND_FILES
;
; PURPOSE: 
; This function returns names of Wind SWE data files that fall in the given time interval.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = WND_SWE_FIND_FILES(Date)
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
; PATH: Set this to a directory name in which to look for the fitacf files.
; The default is to use the output from ACE_MAG_GET_PATH().
;
; FILE_COUNT: Set this to a named variable that will contain the number
; of files found for the given time interval.
;
; OPTIONAL OUTPUTS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Jan, 24 2010
;-
function wnd_swe_find_files, date, time=time, long=long, $
	file_count=file_count, silent=silent, $
	path=path

file_count = 0
files = ''

; check if parameters are given
if n_params() lt 1 then begin
	prinfo, 'Must give date.'
	return, files
endif

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

if keyword_set(path) then $
	_path = path

; get beginning and end time of interval,
; as well as the number of days involved
sfjul, date, time, sjul, fjul, long=long, no_d=no_d

; loop over number of days, finding the files
for i=0, no_d-1 do begin

	; make current date as string
	caldat, sjul+double(i), mm, dd, yy
	astrdate = format_date(yy*10000L + mm*100L + dd)

	; need to do this in the loop as the interval could
	; span over a year boundary
	if ~keyword_set(path) then $
		_path = wnd_swe_get_path(yy)

	; check if directory exists
	if ~file_test(_path, /dir) then $
		err = 'Path to Wind SWE data does not exist: '+_path
	
	; find all zipped fitex files on the current day
	; wi_h(4|5)_swe_20090315_v10.cdf
	tfiles = file_search(_path+'/wi_h?_swe_'+astrdate+'_v*.cdf', count=fc)
	
	; if any files were found, make sure only those between
	; the right start and end times are selected
	; and added to the total array
	if fc gt 0L then begin
		if file_count eq 0 then $
			files = tfiles $
		else $
			files = [files, tfiles]
		file_count += fc
	endif
endfor

;print, files

return, files

end
