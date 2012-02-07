;+ 
; NAME: 
; CLU_FGM_FIND_FILES
;
; PURPOSE: 
; This function returns names of Cluster FGM data files that fall in the given time interval.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = CLU_FGM_FIND_FILES(Date, Sc)
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; Sc: Set this to the number of the spacecraft to find the files for.
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
; Written by Lasse Clausen, Jan, 24 2010
;-
function clu_fgm_find_files, date, sc, time=time, long=long, $
	file_count=file_count, silent=silent, $
	path=path

file_count = 0
files = ''

; check if parameters are given
if n_params() lt 2 then begin
	prinfo, 'Must give date and sc.'
	return, files
endif

if sc lt 1 or sc gt 4 then  begin
	prinfo, 'Sc must be 1 <= sc <= 4.'
	return, !false
endif

str_sc = string(sc, format='(I1)')

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
		_path = clu_fgm_get_path(yy)

	; check if directory exists
	if ~file_test(_path, /dir) then $
		err = 'Path to cluster fgm data does not exist: '+_path
	
	; find all zipped fitex files on the current day
	; C2_CP_FGM_SPIN__20050417_000000_20050418_000000_V070905.cdf
	;print, _path+'/C'+str_sc+'_CP_FGM_SPIN__'+astrdate+'*.cdf'
	tfiles = file_search(_path+'/C'+str_sc+'_CP_FGM_SPIN__'+astrdate+'*.cdf', count=fc)
	
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
