;+ 
; NAME: 
; RAD_GRD_FIND_FILES
;
; PURPOSE: 
; This function returns grd files that fall in the given time interval.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = RAD_GRD_FIND_FILES(Date)
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; KEYWORD PARAMETERS:
; HEMISPHERE: Set this keyword to 1 to look for map potentail files for the norther hemisphere
; set it to -1 to look for files of the southern hemisphere.
;
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
; The default is to use the output from RAD_MAP_GET_PATH().
;
; FILE_COUNT: Set this to a named variable that will contain the number
; of files found for the given time interval.
;
; APLGRD: Set this keyword to a named variable that will contain TRUE if
; the found files are APL grid files.
;
; GRDEX: Set this keyword to a named variable that will contain TRUE if
; the found files are grdEX files.
;
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Adrian Grocott's OPEN_MAP_FILE and ARCHIVE_MP.
; Written by Lasse Clausen, Dec, 10 2009
;-
function rad_grd_find_files, date, hemisphere=hemisphere, time=time, long=long, $
	file_count=file_count, silent=silent, $
	path=path, aplgrd=aplgrd, grdex=grdex, vtgrd=vtgrd

file_count = 0
files = ''

aplgrd = !false
vtgrd = !false
grdex = !true

; check if parameters are given
if n_params() lt 1 then begin
	prinfo, 'Must give date.'
	return, files
endif

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

; set default hemisphere
if ~keyword_set(hemisphere) then $
	hemisphere = 1.

if hemisphere ge 0 then $
	str_hemi = 'north' $
else $
	str_hemi = 'south'

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
		_path = rad_grd_get_path(yy, hemisphere)

	; check if directory exists
;	if ~file_test(_path, /dir) then begin
;		if ~keyword_set(silent) then $
;			prinfo, 'Path to map data does not exist: '+_path, /force
;		continue
;	endif
	
	; find all zipped files on the current day
	tfiles = file_search(_path+'/'+astrdate+'.'+str_hemi+'.'+$
		'grdex.{gz,bz2}', count=fc)
;	print, _path+'/'+astrdate+'.*.'+strlowcase(radar)+'*.'+file_ending

	; only of no zipped files were found, look for unzipped files
	if fc eq 0 then begin
		tfiles = file_search(_path+'/'+astrdate+'.'+str_hemi+'.'+$
			'grdex', count=fc)
	endif

	; only of no files were found, look for apl map files
	if fc eq 0 then begin
		grdex = !false
		vtgrd = !true
		_path = rad_grd_get_path(yy, hemisphere, /vtgrd)
		tfiles = file_search(_path+'/'+astrdate+'.'+str_hemi+'.'+$
			'vtgrd.{gz,bz2}', count=fc)
	endif

	; only of no zipped files were found, look for unzipped files
	if fc eq 0 then begin
		tfiles = file_search(_path+'/'+astrdate+'.'+str_hemi+'.'+$
			'vtgrd', count=fc)
	endif

	; only of no files were found, look for apl map files
	if fc eq 0 then begin
		vtgrd = !false
		aplgrd = !true
		_path = rad_grd_get_path(yy, hemisphere, /aplgrd)
		tfiles = file_search(_path+'/'+astrdate+'.'+str_hemi+'.'+$
			'grd.{gz,bz2}', count=fc)
	endif

	; only of no zipped files were found, look for unzipped files
	if fc eq 0 then begin
		tfiles = file_search(_path+'/'+astrdate+'.'+str_hemi+'.'+$
			'grd', count=fc)
	endif
	
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

if file_count eq 0L then begin
	grdex = !false
	aplgrd = !false
endif

;print, files

return, files

end
