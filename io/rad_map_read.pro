;+ 
; NAME: 
; RAD_MAP_READ
;
; PURPOSE: 
; This procedure reads radar map potential data into the variables of the structure RAD_MAP_DATA in
; the common block RAD_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RAD_MAP_READ, Date
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
; FILEMAPEX: Set this keyword to indicate that the file in FILENAME is in the mapEX
; file format.
;
; FILEAPLMAP: Set this keyword to indicate that the file in FILENAME is in the APLMAP
; file format.
;
; FILEDATE: Set this to a date in YYYMMDD format to indicate that the file in FILENAME
; contains data from that date.
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
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY:
; Based on Adrian Grocott's ARCHIVE_MP.
; Written by Lasse Clausen, Dec, 10 2009
;-
pro rad_map_read, date, time=time, north=north, south=south, hemisphere=hemisphere, both=both, $
	long=long, silent=silent, filename=filename, filedate=filedate, $
	filemapex=filemapex, fileaplmap=fileaplmap, force=force

; if the user wants to load both hemispheres
; just call RAD_MAP_READ with /NORTH, then /SOUTH and return
if keyword_set(both) then begin
	rad_map_read, date, time=time,/north, $
		long=long, silent=silent, filename=filename, filedate=filedate, $
		filemapex=filemapex, fileaplmap=fileaplmap, force=force
	rad_map_read, date, time=time,/south, $
		long=long, silent=silent, filename=filename, filedate=filedate, $
		filemapex=filemapex, fileaplmap=fileaplmap, force=force
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
rad_map_info[int_hemi].nrecs = 0L

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

if ~keyword_set(filename) then begin
	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = rad_map_check_loaded(date, hemisphere, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = rad_map_find_files(date, hemisphere=hemisphere, time=time, $
		long=long, file_count=fc, aplmap=aplmap, mapex=mapex)
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
	if keyword_set(filemapex) then $
		mapex = !true $
	else begin
		prinfo, 'I have no idea in which format the file is, mapEX or APLmap. Guessing mapEX.', /force
		mapex = !true
	endelse
	if keyword_set(fileaplmap) then begin
		aplmap = !true
		mapex = !false
	endif else $
		aplmap = !false
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
modnum = make_array(MAX_RECS, /int)
bndnum = make_array(MAX_RECS, /int)
imf_delay = make_array(MAX_RECS, /int)
b_imf = make_array(MAX_RECS, 3, /float)
imf_model = make_array(MAX_RECS, /string)
lat_shft = make_array(MAX_RECS, /float)
lon_shft = make_array(MAX_RECS, /float)
latmin = make_array(MAX_RECS, /float)
fit_order = make_array(MAX_RECS, /byte)
pot_drop = make_array(MAX_RECS, /double)
pot_drop_err = make_array(MAX_RECS, /double)
pot_min = make_array(MAX_RECS, /double)
pot_min_err = make_array(MAX_RECS, /double)
pot_max = make_array(MAX_RECS, /double)
pot_max_err = make_array(MAX_RECS, /double)
gvecs = make_array(MAX_RECS, /ptr)
bvecs = make_array(MAX_RECS, /ptr)
mvecs = make_array(MAX_RECS, /ptr)
coeffs = make_array(MAX_RECS, /ptr)
nrecs = 0L

; set up variables needed for reading maps
CnvMapMakePrm, prm 

;lib=getenv('LIB_CNVMAPIDL')
;if strcmp(lib, '') then begin
;	prinfo, 'Cannot find LIB_CNVMAPIDL'
;	return
;endif

for i=0, fc-1 do begin
	file_base = file_basename(files[i])
	if ~keyword_set(silent) then $
		prinfo, 'Reading '+file_base +' ('+files[i]+')', /force
	; unzip file to user's home directory
	; if file is zipped
	o_file = rad_unzip_file(files[i])
	if strcmp(o_file, '') then $
		continue
	; open map file
	ilun = CnvMapOpen(o_file, /read)
	if ilun eq 0 then begin
		prinfo, 'Could not open file: ' + files[i] + $
			'->('+o_file+')', /force
		if files[i] ne o_file then $
			file_delete, o_file
		continue
	endif
	; read all data entries
	; stvec is information about the radars that contributed velocity vectors
	; gvec are actual velocity measurements that went into the fitting
	; mvec are model velocity vectors that went into the fit to constrain it
	; coef are the coefficients of the spherical expansion
	; bvec contains the boundary of the zero-padding on the dayside
;	while rad_map_read_record(ilun, lib, prm, stvec, gvec, mvec, coef, bvec) ne -1 do begin
	while cnvmapread(ilun, prm, stvec, gvec, mvec, coef, bvec) ne -1L do begin
		sjuls[nrecs] = julday(prm.stme.mo,prm.stme.dy,prm.stme.yr,prm.stme.hr,prm.stme.mt,prm.stme.sc)
		fjuls[nrecs] = julday(prm.etme.mo,prm.etme.dy,prm.etme.yr,prm.etme.hr,prm.etme.mt,prm.etme.sc)
		mjuls[nrecs] = (sjuls[nrecs] + fjuls[nrecs])/2.d
		stnum[nrecs] = prm.stnum
		vcnum[nrecs] = prm.vcnum
		modnum[nrecs] = prm.modnum
		bndnum[nrecs] = prm.bndnum
		imf_delay[nrecs] =  prm.imf_delay
		b_imf[nrecs,*] = [prm.bx, prm.by, prm.bz]
		imf_model[nrecs] = strjoin(prm.imf_model, ', ')
		lat_shft[nrecs] = prm.lat_shft
		lon_shft[nrecs] = prm.lon_shft
		latmin[nrecs] = prm.latmin
		fit_order[nrecs] = prm.fit_order
		pot_drop[nrecs] = prm.pot_drop
		pot_drop_err[nrecs] = prm.pot_drop_err
		pot_min[nrecs] = prm.pot_min
		pot_min_err[nrecs] = prm.pot_min_err
		pot_max[nrecs] = prm.pot_max
		pot_max_err[nrecs] = prm.pot_max_err
		gvecs[nrecs] = ptr_new(gvec)
		mvecs[nrecs] = ptr_new(mvec)
		bvecs[nrecs] = ptr_new(bvec)
		coeffs[nrecs] = ptr_new(coef)
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
	return
endif

; set up temporary structure
rad_map_data_hemi = { $
	sjuls: dblarr(nrecs), $
	mjuls: dblarr(nrecs), $
	fjuls: dblarr(nrecs), $
	stnum: intarr(nrecs), $
	vcnum: intarr(nrecs), $
	modnum: intarr(nrecs), $
	bndnum: intarr(nrecs), $
	imf_delay: intarr(nrecs), $
	b_imf: fltarr(nrecs, 3), $
	imf_model: strarr(nrecs), $
	lat_shft: fltarr(nrecs), $
	lon_shft: fltarr(nrecs), $
	latmin: fltarr(nrecs), $
	fit_order: bytarr(nrecs), $
	pot_drop: fltarr(nrecs), $
	pot_drop_err: fltarr(nrecs), $
	pot_min: fltarr(nrecs), $
	pot_min_err: fltarr(nrecs), $
	pot_max: fltarr(nrecs), $
	pot_max_err: fltarr(nrecs), $
	gvecs: ptrarr(nrecs), $
	mvecs: ptrarr(nrecs), $
	bvecs: ptrarr(nrecs), $
	coeffs: ptrarr(nrecs) $
}

; populate structure
rad_map_data_hemi.sjuls = sjuls[0:nrecs-1L]
rad_map_data_hemi.mjuls = mjuls[0:nrecs-1L]
rad_map_data_hemi.fjuls = fjuls[0:nrecs-1L]
rad_map_data_hemi.stnum = stnum[0:nrecs-1L]
rad_map_data_hemi.vcnum = vcnum[0:nrecs-1L]
rad_map_data_hemi.modnum = modnum[0:nrecs-1L]
rad_map_data_hemi.bndnum = bndnum[0:nrecs-1L]
rad_map_data_hemi.imf_delay = imf_delay[0:nrecs-1L]
rad_map_data_hemi.b_imf = b_imf[0:nrecs-1L,*]
rad_map_data_hemi.imf_model = imf_model[0:nrecs-1L]
rad_map_data_hemi.lat_shft = lat_shft[0:nrecs-1L]
rad_map_data_hemi.lon_shft = lon_shft[0:nrecs-1L]
rad_map_data_hemi.fit_order = fit_order[0:nrecs-1L]
rad_map_data_hemi.latmin = latmin[0:nrecs-1L]
rad_map_data_hemi.pot_drop = pot_drop[0:nrecs-1L]
rad_map_data_hemi.pot_drop_err = pot_drop_err[0:nrecs-1L]
rad_map_data_hemi.pot_min = pot_min[0:nrecs-1L]
rad_map_data_hemi.pot_min_err = pot_min_err[0:nrecs-1L]
rad_map_data_hemi.pot_max = pot_max[0:nrecs-1L]
rad_map_data_hemi.pot_max_err = pot_max_err[0:nrecs-1L]
rad_map_data_hemi.gvecs = gvecs[0:nrecs-1L]
rad_map_data_hemi.mvecs = mvecs[0:nrecs-1L]
rad_map_data_hemi.bvecs = bvecs[0:nrecs-1L]
rad_map_data_hemi.coeffs = coeffs[0:nrecs-1L]

; replace pointer to old data structure
; and first all the pointers inside that pointer
if ptr_valid(rad_map_data[int_hemi]) then begin
	for i=0L, n_elements( (*rad_map_data[int_hemi]).gvecs )-1L do begin
		if ptr_valid((*rad_map_data[int_hemi]).gvecs[i]) then $
			ptr_free, (*rad_map_data[int_hemi]).gvecs[i]
		if ptr_valid((*rad_map_data[int_hemi]).mvecs[i]) then $
			ptr_free, (*rad_map_data[int_hemi]).mvecs[i]
		if ptr_valid((*rad_map_data[int_hemi]).bvecs[i]) then $
			ptr_free, (*rad_map_data[int_hemi]).bvecs[i]
		if ptr_valid((*rad_map_data[int_hemi]).coeffs[i]) then $
			ptr_free, (*rad_map_data[int_hemi]).coeffs[i]
	endfor
	ptr_free, rad_map_data[int_hemi]
endif
rad_map_data[int_hemi] = ptr_new(rad_map_data_hemi)

rad_map_info[int_hemi].sjul = (*rad_map_data[int_hemi]).mjuls[0L]
rad_map_info[int_hemi].fjul = (*rad_map_data[int_hemi]).mjuls[nrecs-1L]
rad_map_info[int_hemi].map = aplmap
rad_map_info[int_hemi].mapex = mapex
rad_map_info[int_hemi].nrecs = nrecs

END
