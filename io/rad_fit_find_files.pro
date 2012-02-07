;+ 
; NAME: 
; RAD_FIT_FIND_FILES
;
; PURPOSE: 
; This function returns names of fit/fitacf/fitex files that fall in the given time interval.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = RAD_FIT_FIND_FILES(Date, Radar)
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; Radar: Set this to a 3-letter radar code to indicate the radar for which to read
; data.
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
; PATH: Set this to a directory name in which to look for the fit/fitacf/fitex files.
; The default is to use the output from RAD_FIT_GET_PATH().
;
; FILE_COUNT: Set this to a named variable that will contain the number
; of files found for the given time interval.
;
; OLDFIT: Set this keyword to a named variable that will contain TRUE if
; the found files are fit files.
;
; FITACF: Set this keyword to a named variable that will contain TRUE if
; the found files are fitACF files.
;
; FITEX: Set this keyword to a named variable that will contain TRUE if
; the found files are fitEX files.
;
; PROCEDURE:
; This routines looks for the follwoign things in the following order:
; 1) bzipped fitEX files
; 2) fitEX files
; 3) bzipped fitACF
; 4) fitACF files
; 5) old-style fit files (derived from dat files)
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
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
; Based on Steve Milan's FIND_FILES and ARCHIVE and AUTO_CONCAT.
; Written by Lasse Clausen, Nov, 24 2009
; Modified, Dec 6 2009, LBNC: Added functionality to account for fact that fitacf file might not be zipped.
;-
function rad_fit_find_files, date, radar, time=time, long=long, $
	file_count=file_count, silent=silent, $
	path=path, oldfit=oldfit, fitacf=fitacf, fitex=fitex

file_count = 0
files = ''

; check if parameters are given
if n_params() lt 2 then begin
	prinfo, 'Must give date and radar code.'
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

if ~keyword_set(oldfit) and ~keyword_set(fitacf) and ~keyword_set(fitex) then begin
	fitex = !true
	files = rad_fit_find_files(date, radar, time=time, long=long, $
		file_count=file_count, silent=silent, $
		path=path, oldfit=oldfit, fitacf=fitacf, fitex=fitex)
	if file_count gt 0 then $
		return, files
	fitex = !false
	fitacf = !true
	files = rad_fit_find_files(date, radar, time=time, long=long, $
		file_count=file_count, silent=silent, $
		path=path, oldfit=oldfit, fitacf=fitacf, fitex=fitex)
	if file_count gt 0 then $
		return, files
	fitacf = !false
	oldfit = !true
	files = rad_fit_find_files(date, radar, time=time, long=long, $
		file_count=file_count, silent=silent, $
		path=path, oldfit=oldfit, fitacf=fitacf, fitex=fitex)
	if file_count gt 0 then $
		return, files
	oldfit = !false
	return, ''
endif

if keyword_set(fitex) then begin
	fitacf = !false
	oldfit = !false
endif

if keyword_set(fitacf) then begin
	fitex = !false
	oldfit = !false
endif

if keyword_set(oldfit) then begin
	fitex = !false
	fitacf = !false
endif

; loop over number of days, finding the files
for i=0, no_d-1 do begin

	; make current date as string
	caldat, sjul+double(i), mm, dd, yy
	astrdate = format_date(yy*10000L + mm*100L + dd)

	; need to do this in the loop as the interval could
	; span over a year boundary
	if ~keyword_set(path) then $
		_path = rad_fit_get_path(yy, radar, fitex=fitex, fitacf=fitacf, oldfit=oldfit)

	; check if directory exists
	if ~file_test(_path, /dir) then $
		err = 'Path to fit/fitACF/fitEX data does not exist: '+_path
	
	; find all zipped fitex files on the current day
	;print, _path+'/'+astrdate+'.[0-9][0-9][0-9][0-9].[0-9][0-9].'+$
	;	strlowcase(radar)+'.fitex.{bz2,gz}'
	if fitex then begin
		; find all bzipped fitEX files on the current day
		tfiles = file_search(_path+'/'+astrdate+'.[0-9][0-9][0-9][0-9].[0-9][0-9].'+$
			strlowcase(radar)+'.fitex.bz2', count=fc)
		; only if no bz2 fitex files were found, look for gz fitex files
		if fc eq 0 then begin
			;prinfo, 'No bz2 fitEX files found.'
			tfiles = file_search(_path+'/'+astrdate+'.[0-9][0-9][0-9][0-9].[0-9][0-9].'+$
			strlowcase(radar)+'.fitex.gz', count=fc)
		endif
		; only if no zipped fitex files were found, look for unzipped fitex files
		if fc eq 0 then begin
			;prinfo, 'No zipped fitEX files found.'
			tfiles = file_search(_path+'/'+astrdate+'.[0-9][0-9][0-9][0-9].[0-9][0-9].'+$
				strlowcase(radar)+'.fitex', count=fc)
		endif
	endif else if fitacf then begin
		; find all bzipped fitACF files on the current day
		tfiles = file_search(_path+'/'+astrdate+'.[0-9][0-9][0-9][0-9].[0-9][0-9].'+$
			strlowcase(radar)+'.fitacf.bz2', count=fc)
		; only if no bz2 fitacf files were found, look for gz fitacf files
		if fc eq 0 then begin
			;prinfo, 'No bz2 fitACF files found.'
			tfiles = file_search(_path+'/'+astrdate+'.[0-9][0-9][0-9][0-9].[0-9][0-9].'+$
				strlowcase(radar)+'.fitacf.gz', count=fc)
		endif
		; only if no zipped fitacf files were found, look for unzipped fitacf files
		if fc eq 0 then begin
			;prinfo, 'No zipped fitACF files found.'
			tfiles = file_search(_path+'/'+astrdate+'.[0-9][0-9][0-9][0-9].[0-9][0-9].'+$
				strlowcase(radar)+'.fitacf', count=fc)
		endif
	endif else if oldfit then begin
		; find all bzipped fit files on the current day
		tfiles = file_search(_path+'/'+astrdate+'[0-9][0-9][a-z].'+$
			'fit.bz2', count=fc)
		; only if no bz2 fit files were found, look for gz fit files
		if fc eq 0 then begin
			;prinfo, 'No bzipped fit files found.'
			tfiles = file_search(_path+'/'+astrdate+'[0-9][0-9][a-z].'+$
				'fit.gz', count=fc)
		endif
		; only if no zipped fit files were found, look for unzipped fit files
		if fc eq 0 then begin
			;prinfo, 'No zipped fit files found.'
			tfiles = file_search(_path+'/'+astrdate+'[0-9][0-9][a-z].'+$
				'fit', count=fc)
		endif
	endif
	
	; if any files were found, make sure only those between
	; the right start and end times are selected
	; and added to the total array
	if fc gt 0L then begin
		stime = string( $
			(i eq 0 ? (time[0]/100 - ((time[0]/100) mod 2)) : 0), $
			format='(I02)' $
		)
		etime = string( $
			(i eq no_d-1 ? time[1]/100 + ((time[1] mod 100) gt 0) : 24), $
			format='(I02)' $
		)		
;		print, stime, ' ', etime		
		if oldfit then begin
			part_tfiles = strmid(tfiles, strlen(_path)+1, 10)
;			print, part_tfiles, astrdate+stime
			finds = where( $
				part_tfiles ge astrdate+stime and $
				part_tfiles lt astrdate+etime, fic $
			)
		endif else begin
			part_tfiles = strmid(tfiles, strlen(_path)+1, 11)
			finds = where( $
				part_tfiles ge astrdate+'.'+stime and $
				part_tfiles lt astrdate+'.'+etime, fic $
			)
		endelse
		if fic gt 0L then begin
			if file_count eq 0 then $
				files = tfiles[finds] $
			else $
				files = [files, tfiles[finds]]
			file_count += fic
		endif
	endif
endfor

if file_count eq 0 then begin
	fitex  = !false
	fitacf = !false
	oldfit = !false
endif

;print, files

return, files

end
