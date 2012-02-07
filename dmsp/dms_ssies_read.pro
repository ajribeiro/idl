;+
; NAME: 
; DMS_SSIES_READ
; 
; PURPOSE:
; This procedure reads cross-track drift velocities
; in the DMS_DATA_BLK common block.
; 
; CATEGORY:
; DMSP
; 
; CALLING SEQUENCE: 
; DMS_SSIES_READ, Date, Sat
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
; FORCE: Read data even if DSM_SSIES_CHECK_LOADED returns true.
;
; FILENAME: A scalar or array of strings containing the filenames
; of the data files to read.
;
; FILEDATE: When FILENAME is set, set this keyword to the 
; date for which the data is read. If FILEDATE is not provided
; DSM_SSIES_READ will attempt to extract the date from teh filename.
;
; FILESAT: When FILENAME is set, set this keyword to the 
; satellite for which the data is read. If FILESAT is not provided
; DSM_SSIES_READ will attempt to extract the date from teh filename.
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
pro dms_ssies_read, date, sat, time=time, long=long, $
	silent=silent, force=force, $
	filename=filename, filedate=filedate, filesat=filesat

common dms_data_blk

dms_ssies_info.nrecs = 0L

; resolution is 1 seconds, hence one day
; has about 86400 data records (and a bit of lee way)
NFILERECS = 86420L

if ~keyword_set(filename) then begin
	; check if parameters are given
	if n_params() lt 2 then begin
		prinfo, 'Must give date and satellite number.'
		return
	endif

	if sat lt 6 or sat gt 18 or date gt 20101231 or date lt 19830101 then begin
		prinfo, '19830101 <= date <= 20101231 and 6<= sat <= 18'
		return
	endif

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = dms_ssies_check_loaded(date, sat, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = dms_ssies_find_files(date, sat, time=time, long=long, file_count=fc)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+format_date(date)+$
				', '+format_time(time)
		return
	endif
endif else begin
	fc = n_elements(filename)
	; PS.CKGWC_SC.U_DI.A_GP.SIES3-F16-R99990-B9999090-APGA_AR.GLOBAL_DD.20090101_TP.000002-235959_DF.EDR.gz
	for i=0, fc-1 do begin
		if ~file_test(filename[i]) then begin
			prinfo, 'Cannot find file: '+filename[i]
			return
		endif
		if keyword_set(filedate) then $
			date = filedate $
		else begin
			bfile = file_basename(filename[i])
			date = long(strmid(bfile, 66, 8))
		endelse
		if keyword_set(filesat) then $
			sat = filesat $
		else begin
			bfile = file_basename(filename[i])
			sat = strmid(bfile, 29, 2)
		endelse
	endfor
	files = filename
endelse

sfjul, date, time, sjul, fjul, no_d=nd, long=long
MAX_RECS = NFILERECS*nd
parse_date, date[0], year, month, day
zeroep = julday(month, day, year, 0)

; init temporary arrays
juls = dblarr(MAX_RECS)
glat = fltarr(MAX_RECS)
glon = fltarr(MAX_RECS)
gazm = fltarr(MAX_RECS)
mlat = fltarr(MAX_RECS)
mlon = fltarr(MAX_RECS)
mazm = fltarr(MAX_RECS)
mlts = fltarr(MAX_RECS)
lazm = fltarr(MAX_RECS)
vh = fltarr(MAX_RECS)
hemi = fltarr(MAX_RECS)
nrecs = 0L

; temp arrays for reading
tcoords  = dblarr(6,3)
headings = dblarr(3)
tvels    = dblarr(60)
dummy    = ''
d16      = 35l + 104l + 94l + 36l + 780l + 3l + 28l
d81      = 26l + 780l + 26l + 6*52l + 6*104l + 6*94l + 3l + 23l + 15*63l + 19l + 3l + 37l + 15*81l + 3l + 15l + 780l + 17l + 71l + 7l + 91l
sp       = 0L
norec    = 0
edr      = 0
satno    = 0
drdate   = 0L
drtime   = 0
oldjul   = 0

sctime = systime(1)

; read files
for i=0, fc-1 do begin

	; unzip file to user's home directory
	; if file is zipped
	o_file = rad_unzip_file(files[i])
	if strcmp(o_file, '') then $
		continue
	if ~keyword_set(silent) then $
		prinfo, 'Reading '+o_file +' ('+files[i]+')', /force

	; if temporary arrays are too small, warn and break
	if nrecs gt MAX_RECS then begin
		prinfo, 'To many data records in file for initialized array. Truncating.'
		file_delete, o_file
		break
	endif

	openr, ilun, o_file, /get_lun

	; read the stupid format
	; the data is grouped in 60 second blocks
	while ~eof(ilun) do begin

		point_lun, -ilun, sp
		point_lun, ilun, sp + ( nrecs gt 0L ? 43l : 111l )
		readf, ilun, norec, edr, satno, drdate, drtime
		point_lun, -ilun, sp
		point_lun, ilun, sp+10l
		readf, ilun, tcoords
		point_lun, -ilun, sp
		point_lun, ilun, sp+d16
		readf, ilun, tvels
		point_lun, -ilun, sp
		point_lun, ilun, sp+d81

		sfjul, drdate, drtime, drsjul
		if nrecs gt 0L and (drsjul - oldjul)*1440.d gt 1.1 then begin
			nomissing = long( round( (drsjul - oldjul)*1440.d - 1. ) * 60. )
			juls[nrecs:nrecs+nomissing-1L] = oldjul + 60.d / 86400.d + dindgen(nomissing)/86400.d
			glat[nrecs:nrecs+nomissing-1L] = replicate(!values.f_nan, nomissing)
			glon[nrecs:nrecs+nomissing-1L] = replicate(!values.f_nan, nomissing)
			gazm[nrecs:nrecs+nomissing-1L] = replicate(!values.f_nan, nomissing)
			mlat[nrecs:nrecs+nomissing-1L] = replicate(!values.f_nan, nomissing)
			mlon[nrecs:nrecs+nomissing-1L] = replicate(!values.f_nan, nomissing)
			mazm[nrecs:nrecs+nomissing-1L] = replicate(!values.f_nan, nomissing)
			mlts[nrecs:nrecs+nomissing-1L] = replicate(!values.f_nan, nomissing)
			lazm[nrecs:nrecs+nomissing-1L] = replicate(!values.f_nan, nomissing)
			vh[nrecs:nrecs+nomissing-1L] = replicate(!values.f_nan, nomissing)
			hemi[nrecs:nrecs+nomissing-1L] = replicate(!values.f_nan, nomissing)
			nrecs += nomissing
		endif

		years = replicate((drdate/10000L), 60)
		yrsec = ( drsjul - julday(1, 1, years[0], 0) )*86400.d + dindgen(60)
		juls[nrecs:nrecs+59L] = drsjul + dindgen(60)/86400.d
		; as I understand it, the current is measure left to right, 
		; i.e. positive current and flow means left to right
		vh[nrecs:nrecs+59L] = tvels
		gvinds = where(tvels gt -1e30 and tvels ne 0., gvcc, complement=bvinds, ncomplement=bvcc)

		xs = (!re + reform(tcoords[5,*]))*cos(reform(tcoords[1,*])*!dtor)*sin(!pi/2. - reform(tcoords[0,*])*!dtor)
		ys = (!re + reform(tcoords[5,*]))*sin(reform(tcoords[1,*])*!dtor)*sin(!pi/2. - reform(tcoords[0,*])*!dtor)
		zs = (!re + reform(tcoords[5,*]))*cos(!pi/2. - reform(tcoords[0,*])*!dtor)

		ixs = interpol(xs, [9.,29.,49.], findgen(60))
		iys = interpol(ys, [9.,29.,49.], findgen(60))
		izs = interpol(zs, [9.,29.,49.], findgen(60))
		alts = sqrt(ixs^2+iys^2+izs^2) - !re

		glon[nrecs:nrecs+59L] = (atan(iys, ixs)*!radeg + 360.) mod 360.
		glat[nrecs:nrecs+59L] = 90. - acos(izs/sqrt(ixs^2+iys^2+izs^2))*!radeg
		tazm = calc_vector_bearing(glat[nrecs:nrecs+59L], glon[nrecs:nrecs+59L])
		tazm = interpol(tazm, findgen(59)+.5, findgen(60))
		if gvcc gt 0L then $
			tazm[gvinds] += 90.*tvels[gvinds]/abs(tvels[gvinds])
		if bvcc gt 0L then $
			tazm[bvinds] = replicate(!values.f_nan, bvcc)
		gazm[nrecs:nrecs+59L] = tazm

		tmp = cnvcoord(glat[nrecs:nrecs+59L], glon[nrecs:nrecs+59L], alts)
		mlat[nrecs:nrecs+59L] = tmp[0,*]
		mlon[nrecs:nrecs+59L] = tmp[1,*]
		tazm = calc_vector_bearing(mlat[nrecs:nrecs+59L], mlon[nrecs:nrecs+59L])
		tazm = interpol(tazm, findgen(59)+.5, findgen(60))
		if gvcc gt 0L then $
			tazm[gvinds] += 90.*tvels[gvinds]/abs(tvels[gvinds])
		if bvcc gt 0L then $
			tazm[bvinds] = replicate(!values.f_nan, bvcc)
		mazm[nrecs:nrecs+59L] = tazm

		mlts[nrecs:nrecs+59L] = mlt( years, yrsec, mlon[nrecs:nrecs+59L] )
		tazm = calc_vector_bearing(mlat[nrecs:nrecs+59L], mlts[nrecs:nrecs+59L]*15.)
		tazm = interpol(tazm, findgen(59)+.5, findgen(60))
		if gvcc gt 0L then $
			tazm[gvinds] += 90.*tvels[gvinds]/abs(tvels[gvinds])
		if bvcc gt 0L then $
			tazm[bvinds] = replicate(!values.f_nan, bvcc)
		lazm[nrecs:nrecs+59L] = tazm

		hemi[nrecs:nrecs+59L] = sign(mlat[nrecs:nrecs+59L])

		oldjul = drsjul

		nrecs += 60L

	endwhile

	free_lun, ilun
	file_delete, o_file

endfor

print, systime(1)-sctime

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
tdms_ssies_data = { $
	juls: dblarr(ccc), $
	glat: fltarr(ccc), $
	glon: fltarr(ccc), $
	gazm: fltarr(ccc), $
	mlat: fltarr(ccc), $
	mlon: fltarr(ccc), $
	mazm: fltarr(ccc), $
	mlts:  fltarr(ccc), $
	lazm:  fltarr(ccc), $
	vh:  fltarr(ccc), $
	hemi: fltarr(ccc) $
}

; populate structure
tdms_ssies_data.juls = (juls[0:nrecs-1L])[jinds]
tdms_ssies_data.glat = (glat[0:nrecs-1L])[jinds]
tdms_ssies_data.glon = (glon[0:nrecs-1L])[jinds]
tdms_ssies_data.gazm = (gazm[0:nrecs-1L])[jinds]
tdms_ssies_data.mlat = (mlat[0:nrecs-1L])[jinds]
tdms_ssies_data.mlon = (mlon[0:nrecs-1L])[jinds]
tdms_ssies_data.mazm = (mazm[0:nrecs-1L])[jinds]
tdms_ssies_data.mlts = (mlts[0:nrecs-1L])[jinds]
tdms_ssies_data.lazm = (lazm[0:nrecs-1L])[jinds]
tdms_ssies_data.vh = (vh[0:nrecs-1L])[jinds]
tdms_ssies_data.hemi = (hemi[0:nrecs-1L])[jinds]

inds = where(tdms_ssies_data.vh lt -1e30, cc)
if cc gt 0L then begin
	tdms_ssies_data.vh[inds]   = !values.f_nan
;	tdms_ssies_data.gazm[inds] = !values.f_nan
;	tdms_ssies_data.mazm[inds] = !values.f_nan
;	tdms_ssies_data.lazm[inds] = !values.f_nan
endif

; replace old data structure with new one
dms_ssies_data = tdms_ssies_data

dms_ssies_info.sjul = dms_ssies_data.juls[0L]
dms_ssies_info.fjul = dms_ssies_data.juls[ccc-1L]
dms_ssies_info.sat = sat
dms_ssies_info.nrecs = ccc

end
