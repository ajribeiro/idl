;+ 
; NAME: 
; RAD_UNZIP_FILE
;
; PURPOSE: 
; This procedure copies Filename to the home directory of the current
; user and - if the file is zipped - unzips it there. 
; This is done to files because in the 
; files need to be unzipped before they can be read and the user
; has write permission in his home directory.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RAD_UNZIP_FILE, Filename
;
; INPUTS:
; Filename: The name of the zipped file.
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
; Based on Steve Milan's READ_FILES.
; Written by Lasse Clausen, Nov, 24 2009
;-
function rad_unzip_file, filename

; Copy the file to be read into the current directory (where hopefully
; the user has write permission) and unzip it if it is zipped

on_ioerror, error_bad

;outdir = getenv('RAD_WWW_DATA_DIR')
;if strlen(outdir) eq 0 then $

outdir = getenv('RAD_TMP_PATH')
if strlen(outdir) eq 0 then $
	outdir = getenv('HOME')
outdir += '/'

if ~file_test(outdir, /dir) then begin
	prinfo,'Cannot find directory to put zipped files.'
	return, ''
endif

; check whether file is zipped
zipped = 0b
file_ending = strmid(filename, strlen(filename)-3)
if strcmp(file_ending, '.gz') then $
	zipped = 1b $
else begin
	file_ending = strmid(filename, strlen(filename)-4)
	if strcmp(file_ending, '.bz2') then $
		zipped = 2b $
	else $
;		return, filename
		file_ending = ''
endelse
unzipped_file = outdir+file_basename(filename, file_ending)
zipped_file = outdir+file_basename(filename)

; Else copy over from /sd-data and unzip
; check if output file exists
; if yes, add five random characters to the file name
; until the new filename is not found in the
; output directory
if zipped eq 0b then begin
	while file_test(unzipped_file) do begin
		random_char = string(byte(randomu(systime(/sec)+13L, 5)*25.)+97b)
		unzipped_file = outdir+random_char+'.'+file_basename(filename, file_ending)
	endwhile
	file_copy, filename, unzipped_file
endif else if zipped eq 1b then begin
	while file_test(zipped_file) do begin
		random_char = string(byte(randomu(systime(/sec), 5)*25.)+97b)
		zipped_file = outdir+random_char+'.'+file_basename(filename)
	endwhile
	file_copy, filename, zipped_file
	while file_test(unzipped_file) do begin
		random_char = string(byte(randomu(systime(/sec)+13L, 5)*25.)+97b)
		unzipped_file = outdir+random_char+'.'+file_basename(filename, file_ending)
	endwhile
	SPAWN,'gzip -dc '+zipped_file+' > '+unzipped_file
	file_delete, zipped_file
endif else if zipped eq 2b then begin
	while file_test(zipped_file) do begin
		random_char = string(byte(randomu(systime(/sec), 5)*25.)+97b)
		zipped_file = outdir+random_char+'.'+file_basename(filename)
	endwhile
	file_copy, filename, zipped_file
	while file_test(unzipped_file) do begin
		random_char = string(byte(randomu(systime(/sec)+13L, 5)*25.)+97b)
		unzipped_file = outdir+random_char+'.'+file_basename(filename, file_ending)
	endwhile
	SPAWN,'bzip2 -dc '+zipped_file+' > '+unzipped_file
	file_delete, zipped_file
endif

return, unzipped_file

error_bad:
return, ''

end
