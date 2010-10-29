;+ 
; NAME: 
; DMS_SSJ_FIND_FILES
;
; PURPOSE: 
; This function returns names of DMSP SSJ/4 data files that fall in the given time interval.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = DMS_SSJ_FIND_FILES(Date, Sat)
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; Sat: Set this to the number of the spacecraft to find the files for.
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
; The default is to use the output from CLU_FGM_GET_PATH().
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
function dms_ssj_find_files, date, sat, time=time, long=long, $
	file_count=file_count, silent=silent, $
	path=path

file_count = 0
files = ''

; check if parameters are given
if n_params() lt 2 then begin
	prinfo, 'Must give date and sat.'
	return, files
endif

if sat lt 6 or sat gt 18 then  begin
	prinfo, 'Sat must be 6 <= sat <= 18.'
	return, files
endif

str_sat = 'f'+string(sat, format='(I02)')

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
	astrdate = format_date(yy*10000L + mm*100L + dd, /dmsp)

	; need to do this in the loop as the interval could
	; span over a year boundary
	if ~keyword_set(path) then $
		_path = dms_ssj_get_path(yy)

	; check if directory exists
	if ~file_test(_path, /dir) then $
		err = 'Path to DMSP SSJ/4 data does not exist: '+_path
	
	; find all zipped fitex files on the current day
	; 2008mar29.f13.gz
	;print, _path+'/'+astrdate+'.'+str_sat+'.gz'
	tfiles = file_search(_path+'/'+astrdate+'.'+str_sat+'.gz', count=fc)
	;help, fc
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

if file_count eq 0 then $
	prinfo, 'No files found, try dms_ssj_download_files'

return, files

end
