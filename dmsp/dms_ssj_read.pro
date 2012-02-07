;+
; NAME: 
; DMS_SSJ_READ
; 
; PURPOSE:
; This procedure reads ion or electron spectrum data
; in the DMS_DATA_BLK common block.
; 
; CATEGORY:
; DMSP
; 
; CALLING SEQUENCE: 
; DMS_SSJ_READ, Date, Sat
;
; INPUTS:
; Date: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; Sat: The DMSP satellite number, currently active are 12-18.
;
; KEYWORD PARAMETERS:
; TIME: A 2-element vector giving the time range to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; SILENT: Set this keyword to surpress messages.
;
; FORCE: Read data even if DSMP_CHECK_DATA_LOADED returns true.
;
; FILENAME: A scalar or array of strings containing the filenames
; of the data files to read.
;
; FILEDATE: When FILENAME is set, set this keyword to the 
; date for which the data is read. If FILEDATE is not provided
; DSM_SSJ_READ will attempt to extract the date from teh filename.
;
; FILESAT: When FILENAME is set, set this keyword to the 
; satellite for which the data is read. If FILESAT is not provided
; DSM_SSJ_READ will attempt to extract the date from teh filename.
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
; Written by Lasse Clausen, Apr, 4 2010
;-
pro dms_ssj_read, date, sat, time=time, long=long, $
	silent=silent, force=force, $
	filename=filename, filedate=filedate, filesat=filesat

common dms_data_blk

dms_ssj_info.nrecs = 0L

; resolution is 1 seconds, hence one day
; has about 86400 data records (and a bit of lee way)
NFILERECS = 86420L

if ~keyword_set(filename) then begin
	; check if parameters are given
	if n_params() lt 2 then begin
		prinfo, 'Must give date and satellite number.'
		return
	endif

	if sat lt 6 or sat gt 18 or date lt 19830101 then begin
		prinfo, '19830101 <= date and 6<= sat <= 18'
		return
	endif

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = dms_ssj_check_loaded(date, sat, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = dms_ssj_find_files(date, sat, time=time, long=long, file_count=fc)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+format_date(date)+$
				', '+format_time(time)
		return
	endif
endif else begin
	fc = n_elements(filename)
	; j4f1308090
	for i=0, fc-1 do begin
		if ~file_test(filename[i]) then begin
			prinfo, 'Cannot find file: '+filename[i]
			return
		endif
		if keyword_set(filedate) then $
			date = filedate $
		else begin
			bfile = file_basename(filename[i])
			yr = strmid(bfile, 5, 2)+2000
			caldat, julday(1, fix(strmid(bfile, 7, 3)), yr), mm, dd, yy
			date = yy*10000L + mm*100L + dd
		endelse
		if keyword_set(filesat) then $
			sat = filesat $
		else begin
			bfile = file_basename(filename[i])
			sat = strmid(bfile, 3, 2)
		endelse
	endfor
	files = filename
endelse

sfjul, date, time, sjul, fjul, no_d=nd, long=long
MAX_RECS = NFILERECS*nd

; init temporary arrays
juls = dblarr(MAX_RECS)
glat = fltarr(MAX_RECS)
glon = fltarr(MAX_RECS)
mlat = fltarr(MAX_RECS)
mlon = fltarr(MAX_RECS)
amlt = fltarr(MAX_RECS)
jne = fltarr(MAX_RECS)
jee = fltarr(MAX_RECS)
deflux = fltarr(MAX_RECS, 19)
jni = fltarr(MAX_RECS)
jei = fltarr(MAX_RECS)
diflux = fltarr(MAX_RECS, 19)
hemi = fltarr(MAX_RECS)
nrecs = 0L

;***************************************************************************************************
; Reads the new APL SSJ/4/5 format
; Tom Sotirelis     8/2004
; returns 1 on success and 0 on ioerror failure
;***************************************************************************************************
;     BYTE     DESCRIPTION
;       1       satellite number (BYTE)
;       2       Year: last two digits of year (BYTE)
;     3-4       Day number of year (INTEGER)
;     5-6       Latitude Position in tenths of Degree (INTEGER) 
;                  (original or replaced by NORAD)
;     7-8       Longitude Position in tenths of Degree (INTEGER) 
;                  (original or replaced by NORAD)
;    9-48       EFULX in counts (20 INTEGERS)
;   49-88       IFLUX in counts (20 INTEGERS)
;   89-92       SECONDS into the day (LONG INTEGER)
;   93-94       Version Number of data file (multiplied by 1000) (INTEGER)
;      95       Original Position Source flag 
;                  (0-original data file, 1-replaced with NORAD position)(see note)
;      96       filler byte (zero)
;      97       NORAD error flag (0- good, 1- error) (BYTE)
;      98       Geomagnetic error flag (0- good, 1- error) (BYTE)
;   99-102      NORAD Latitude in ten-thousandths of degree (LONG INTEGER)
;  103-106      NORAD Longitude in ten-thousandths of degree (LONG INTEGER)
;  107-110      NORAD Altitude in decimeters (LONG INTEGER)
;  111-114      Magnetic Latitude in ten-thousandths of degree (LONG INTEGER)
;  115-118      Magnetic Longitude in ten-thousandths of degree (LONG INTEGER)
;  119-122      MLT in hundred-thousands of an hour (LONG INTEGER)
;  123-124      PACE Model Year used
;  125-128      Filler (all zeros)
;***************************************************************************************************
d0  =  {apl_ssj_ty, sat:0B, yr:0B, doy:0, ilat:0, ilon:0, eflux:intarr(20), iflux:intarr(20), sod:0L, $
	ver:0, orig_pos_f:0B, f1:0B, norad_err_f:0B, geomag_err_f:0B, $
	nlat:0L, nlon:0L, nalt:0L, mlat:0L, mlon:0L, mlt:0L, aacgm_year:0, f2:0L}

last_year = 0
; read files
for i=0, fc-1 do begin

	; unzip file to user's home directory
	; if file is zipped
	o_file = rad_unzip_file(files[i])
	if strcmp(o_file, '') then $
		continue
	if ~keyword_set(silent) then $
		prinfo, 'Reading '+o_file +' ('+files[i]+')', /force

	tnrecs = (file_info(o_file)).size/128L
	if tnrecs lt 1L then begin
		file_delete, o_file
		continue
	endif

	; if temporary arrays are too small, warn and break
	if nrecs gt MAX_RECS then begin
		prinfo, 'To many data records in file for initialized array. Truncating.'
		file_delete, o_file
		break
	endif

	data  =  replicate(d0, tnrecs)
	openr, ilun, o_file, /get_lun, /swap_if_big_endian
	readu, ilun, data
	free_lun, ilun
	file_delete, o_file

	if max(data[*].geomag_err_f) gt 0 then begin
		w = where(data[*].geomag_err_f gt 0, nw)
		prinfo, 'geomag_err_f', data[0].yr, data[0].doy, nw
		continue
	endif

	if max(data[*].sat) ne min(data[*].sat) then begin
		prinfo, 'max(in.sat) ne min(in.sat)', data[0].yr, data[0].doy, max(data[0].sat), min(data[0].sat)
		continue
	endif

	w = where(data[*].norad_err_f, nw)
	if nw gt 0 then begin
		data[w].nlat  =  data[w].ilat*1e3
		data[w].nlon  =  data[w].ilon*1e3
	endif

	juls[nrecs:nrecs+tnrecs-1L] = julday(1, data[*].doy, 2000+data[*].yr, 0, 0, data[*].sod)
	glat[nrecs:nrecs+tnrecs-1L] = data[*].nlat/1e4
	glon[nrecs:nrecs+tnrecs-1L] = data[*].nlon/1e4
	tmp = cnvcoord(data[*].nlat/1e4, data[*].nlon/1e4, replicate(600., tnrecs))
	mlat[nrecs:nrecs+tnrecs-1L] = tmp[0,*] ; data[*].mlat/1e4
	mlon[nrecs:nrecs+tnrecs-1L] = tmp[1,*] ; data[*].mlon/1e4
	amlt[nrecs:nrecs+tnrecs-1L] = mlt(  2000+data[*].yr, (juls[nrecs:nrecs+tnrecs-1L] - julday(1,1,2000+data[*].yr,0) )*86400.d, mlon[nrecs:nrecs+tnrecs-1L] ) ; data[*].mlt/1e5
	hemi[nrecs:nrecs+tnrecs-1L] = sign(mlat[nrecs:nrecs+tnrecs-1L])
	;************************************************************************************
	; rescale
	;************************************************************************************
	eflux    =  float(data[*].eflux > 0)
	w         =  where(eflux gt 32000.0, nw)
	if nw gt 0 then $
		eflux[w] = 32000.0 + (eflux[w] - 32000.0) * 100.0
	iflux   =  float(data[*].iflux > 0)
	w        =  where(iflux gt 32000.0, nw)
	if nw gt 0 then $
		iflux[w] = 32000.0 + (iflux[w] - 32000.0) * 100.0

	;***************************************************************************************
	; eliminate non-channel in J5 data
	;***************************************************************************************
	if sat ge 16 then begin
		eflux = [eflux[0:8, *], eflux[10:19, *]]
		iflux = [iflux[0:8, *], iflux[10:19, *]]
	endif

	;******************************************************************************************
	; Make J4 data into 19 channels by discarding redundant channel
	;******************************************************************************************
	if sat le 15 then begin
		eflux = [ eflux[0:8, *], eflux[10:19, *]]
    iflux = [ iflux[0:9, *], iflux[11:19, *]]
	endif

	; read calibration if need be
	if last_year ne data[0].yr then begin
		dms_ssj_read_cal, 2000+data[0].yr, sat
		last_year = data[0].yr
		if ~ptr_valid( dms_ssj_info.calibration ) then $
			return
	endif

	;******************************************************************************************
	; Number and energy fluxes
	; jn in #/cm^2/s/sr
	; je in ev/cm^2/s/sr
	;******************************************************************************************
	jne[nrecs:nrecs+tnrecs-1L] = reform( (*dms_ssj_info.calibration).jne#eflux )
	jee[nrecs:nrecs+tnrecs-1L] = reform( (*dms_ssj_info.calibration).jee#eflux )
	jni[nrecs:nrecs+tnrecs-1L] = reform( (*dms_ssj_info.calibration).jni#iflux )
	jei[nrecs:nrecs+tnrecs-1L] = reform( (*dms_ssj_info.calibration).jei#iflux )

	;*************************************************
	; differential energy fluxes in 1/cm^2/s/sr
	;*************************************************
	;*************************************************
	; energy flux vector
	; jXv in ev/cm^2/s/sr per channel
	;*************************************************
	for j=0l, tnrecs-1L do begin
		deflux[nrecs+j,*] = eflux[*,j]*(*dms_ssj_info.calibration).edef
		diflux[nrecs+j,*] = iflux[*,j]*(*dms_ssj_info.calibration).idef
	endfor
	nrecs += tnrecs

endfor

if nrecs lt 1L then begin
	prinfo, 'No real data read.'
	return
endif

jinds = where(juls ge sjul and juls le fjul, ccc)
if ccc lt 1L then begin
	prinfo, 'No data found between '+format_date(date) +' and '+format_time(time)
	return
endif

; set up temporary structure
tdms_ssj_data = { $
	juls: dblarr(ccc), $
	glat: fltarr(ccc), $
	glon: fltarr(ccc), $
	mlat: fltarr(ccc), $
	mlon: fltarr(ccc), $
	mlt:  fltarr(ccc), $
	jne:  fltarr(ccc), $
	jee:  fltarr(ccc), $
	deflux: fltarr(ccc, 19), $
	jni:  fltarr(ccc), $
	jei:  fltarr(ccc), $
	diflux: fltarr(ccc, 19), $
	hemi: fltarr(ccc) $
}

; populate structure
tdms_ssj_data.juls = (juls[0:nrecs-1L])[jinds]
tdms_ssj_data.glat = (glat[0:nrecs-1L])[jinds]
tdms_ssj_data.glon = (glon[0:nrecs-1L])[jinds]
tdms_ssj_data.mlat = (mlat[0:nrecs-1L])[jinds]
tdms_ssj_data.mlon = (mlon[0:nrecs-1L])[jinds]
tdms_ssj_data.mlt = (amlt[0:nrecs-1L])[jinds]
tdms_ssj_data.jne = (jne[0:nrecs-1L])[jinds]
tdms_ssj_data.jee = (jee[0:nrecs-1L])[jinds]
tdms_ssj_data.deflux = (deflux[0:nrecs-1L,*])[jinds,*]
tdms_ssj_data.jni = (jni[0:nrecs-1L])[jinds]
tdms_ssj_data.jei = (jei[0:nrecs-1L])[jinds]
tdms_ssj_data.diflux = (diflux[0:nrecs-1L,*])[jinds,*]
tdms_ssj_data.hemi = (hemi[0:nrecs-1L])[jinds]

;inds = where(twnd_mag_data.bx_gse lt -1e30, cc)
;if cc gt 0L then $
;	twnd_mag_data.bx_gse[inds] = !values.f_nan

; replace old data structure with new one
dms_ssj_data = tdms_ssj_data

dms_ssj_info.sjul = dms_ssj_data.juls[0L]
dms_ssj_info.fjul = dms_ssj_data.juls[ccc-1L]
dms_ssj_info.sat = sat
dms_ssj_info.nrecs = ccc

end
