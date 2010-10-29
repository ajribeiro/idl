;+ 
; NAME: 
; RAD_GRD_READ
;
; PURPOSE: 
; This procedure reads gridded radar data into the variables of the structure RAD_GRD_DATA in
; the common block RAD_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RAD_GRD_READ, Date
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
; NORTH: Set this keyword to read grid data for the northern hemisphere only.
; This is the default.
;
; SOUTH: Set this keyword to read grid data for the southern hemisphere only.
;
; HEMISPHERE: Set this keyword to 0 to read grid data for the northern hemisphere only,
; set it to 1 to read grid data for the southern hemisphere only.
;
; BOTH: Set this keyword to read grid data for the northern and southern hemisphere.
;
; FORCE: Set this keyword to read the data, even if it is already present in the
; RAD_DATA_BLK, i.e. even if RAD_GRD_CHECK_LOADED returns true.
;
; FILENAME: Set this to a string containing the name of the grd file to read.
;
; FILEGRDEX: Set this keyword to indicate that the file in FILENAME is in the grdEX
; file format.
;
; FILEAPLGRD: Set this keyword to indicate that the file in FILENAME is in the APLGRD
; file format.
;
; FILERADAR: Set this to a string containing the radar from which the fit file to read.
;
; FILEDATE: Set this to a string containing the date from which the grd file to read.
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
; RADARINFO: The common block holding data about all radar sites (from RST).
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Adrian Grocott's ARCHIVE_MP.
; Written by Lasse Clausen, Dec, 10 2009
;-
pro rad_grd_read, date, time=time, north=north, south=south, hemisphere=hemisphere, both=both, $
	long=long, silent=silent, filename=filename, filedate=filedate, force=force, $
	filegrdex=filegrdex, fileaplgrd=fileaplgrd, filevtgrd=filevtgrd

; if the user wants to load both hemispheres
; just call RAD_MAP_READ with /NORTH, then /SOUTH and return
if keyword_set(both) then begin
	rad_grd_read, date, time=time,/north, $
		long=long, silent=silent, filename=filename, filedate=filedate, $
		filegrdex=filegrdex, fileaplgrd=fileaplgrd, filevtgrd=filevtgrd, force=force
	rad_grd_read, date, time=time,/south, $
		long=long, silent=silent, filename=filename, filedate=filedate, $
		filegrdex=filegrdex, fileaplgrd=fileaplgrd, filevtgrd=filevtgrd, force=force
	return
endif

common rad_data_blk
common radarinfo

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
rad_grd_info[int_hemi].nrecs = 0L

; check if parameters are given
if n_params() lt 1 then begin
	if ~keyword_set(filename) then begin
		prinfo, 'Must give date.'
		return
	endif
endif

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

; calculate the maximum records the data array will hold
MAX_RECS = GETENV('RAD_MAX_HOURS')*125L

; wether the file is in the old ascii format
oldgrd = !false

if ~keyword_set(filename) then begin
	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = rad_grd_check_loaded(date, hemisphere, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = rad_grd_find_files(date, hemisphere=hemisphere, time=time, $
		long=long, file_count=fc, aplgrd=aplgrd, vtgrd=vtgrd, grdex=grdex)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+format_date(date)+$
				', '+format_time(time)
		return
	endif
	no_delete = !false
endif else begin
	fc = n_elements(filename)
	for i=0, fc-1 do begin
		if ~file_test(filename[i]) then begin
			prinfo, 'Cannot find file: '+filename[i]
			return
		endif
		if keyword_set(filedate) then $
			date = filedate $
		else begin
			bfile = file_basename(filename[i])
			date = long(strmid(bfile, 0, 8))
		endelse
	endfor
	if keyword_set(filegrdex) then begin
		grdex = !true
		aplgrd = !false
		vtgrd = !false
	endif else if keyword_set(fileaplgrd) then begin
		grdex = !false
		aplgrd = !true
		vtgrd = !false
	endif else if keyword_set(filevtgrd) then begin
		grdex = !false
		aplgrd = !false
		vtgrd = !true
	endif else begin
		prinfo, 'I have no idea in which format the file is, grdEX or APLgrd. Guessing grdEX.', /force
		grdex = !true
		aplgrd = !false
		vtgrd = !false
	endelse
	files = filename
	no_delete = !false
endelse

; make arrays holding data
sjuls = make_array(MAX_RECS, /double)
mjuls = make_array(MAX_RECS, /double)
fjuls = make_array(MAX_RECS, /double)
sysec = make_array(MAX_RECS, /long)
mysec = make_array(MAX_RECS, /long)
fysec = make_array(MAX_RECS, /long)
stnum = make_array(MAX_RECS, /int)
vcnum = make_array(MAX_RECS, /int)
gvecs = make_array(MAX_RECS, /ptr)
nrecs = 0L

; set up variables needed for reading grid
GridMakePrm, prm

oldgrd = vtgrd

lib=getenv('LIB_GRDIDL')
if strcmp(lib, '') then begin
		prinfo, 'Cannot find LIB_GRDIDL'
	return
endif

for i=0, fc-1 do begin
	file_base = file_basename(files[i])
	if ~keyword_set(silent) then $
		prinfo, 'Reading '+file_base
	; unzip file to user's home directory
	; if file is zipped
	o_file = rad_unzip_file(files[i])
	if strcmp(o_file, '') then $
		continue
	; open grid file
	if oldgrd then $
		ilun = OldGridOpen(o_file, /read) $
	else $
		ilun = GridOpen(o_file, /read)
	if ilun eq 0 then begin
		prinfo, 'Could not open file: ' + files[i] + $
			'->('+o_file+')', /force
		if files[i] ne o_file then $
			file_delete, o_file
		continue
	endif
	; read all data entries
	while !true do begin

		; read data record
		if oldgrd then begin
			ret = oldgridread(ilun, prm, stvec, gvec)
		endif else begin
			ret = rad_grd_read_record(ilun, lib, prm, stvec, gvec)
		endelse

		; exit if all read
		if ret eq -1 then $
			break

		sjuls[nrecs] = julday(prm.stme.mo,prm.stme.dy,prm.stme.yr,prm.stme.hr,prm.stme.mt,prm.stme.sc)
		fjuls[nrecs] = julday(prm.etme.mo,prm.etme.dy,prm.etme.yr,prm.etme.hr,prm.etme.mt,prm.etme.sc)
		mjuls[nrecs] = (sjuls[nrecs] + fjuls[nrecs])/2.d
		stnum[nrecs] = prm.stnum
		vcnum[nrecs] = prm.vcnum
		gvecs[nrecs] = ptr_new(gvec)
		nrecs += 1L
		if nrecs ge MAX_RECS then begin
			prinfo, 'Too many maps in file: '+string(nrecs)
			break
		endif
	endwhile
  free_lun, ilun
	if files[i] ne o_file then $
		file_delete, o_file
endfor

if nrecs lt 1 then begin
	prinfo, 'No real data read.'
	if aplgrd then begin
		prinfo, 'GRD file is in ASCII format. Cannot read. Must convert to binary grdmap file using the RST command gridtogrdmap.', /force
	endif
	return
endif

; set up temporary structure
rad_grd_data_hemi = { $
	sjuls: dblarr(nrecs), $
	mjuls: dblarr(nrecs), $
	fjuls: dblarr(nrecs), $
	stnum: intarr(nrecs), $
	vcnum: intarr(nrecs), $
	gvecs: ptrarr(nrecs) $
}

; populate structure
rad_grd_data_hemi.sjuls = sjuls[0:nrecs-1L]
rad_grd_data_hemi.mjuls = mjuls[0:nrecs-1L]
rad_grd_data_hemi.fjuls = fjuls[0:nrecs-1L]
rad_grd_data_hemi.stnum = stnum[0:nrecs-1L]
rad_grd_data_hemi.vcnum = vcnum[0:nrecs-1L]
rad_grd_data_hemi.gvecs = gvecs[0:nrecs-1L]

; replace pointer to old data structure
; and first all the pointers inside that pointer
if ptr_valid(rad_grd_data[int_hemi]) then begin
	for i=0L, rad_grd_info[int_hemi].nrecs-1L do begin
		if ptr_valid((*rad_grd_data[int_hemi]).gvecs[i]) then $
			ptr_free, (*rad_grd_data[int_hemi]).gvecs[i]
	endfor
	ptr_free, rad_grd_data[int_hemi]
endif
rad_grd_data[int_hemi] = ptr_new(rad_grd_data_hemi)

rad_grd_info[int_hemi].sjul = (*rad_grd_data[int_hemi]).mjuls[0L]
rad_grd_info[int_hemi].fjul = (*rad_grd_data[int_hemi]).mjuls[nrecs-1L]
rad_grd_info[int_hemi].grd = (aplgrd or vtgrd)
rad_grd_info[int_hemi].grdex = grdex
rad_grd_info[int_hemi].nrecs = nrecs

END
