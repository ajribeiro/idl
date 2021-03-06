;+
; NAME: 
; DMS_SSJ_DOWNLOAD_FILES
; 
; PURPOSE:
; This procedure downloads DMSP SSJ/4 data files
; from the archive at http://sd-www.jhuapl.edu/Aurora/data/ssj/
; and puts the downloaded files on sd-data. It uses wget and scp.
; 
; CATEGORY:
; DMSP
; 
; CALLING SEQUENCE: 
; DMS_SSJ_DOWNLOAD_FILES, Date
; 
; INPUTS:
; Date: A scalar giving the date to convert, 
; in YYYYMMDD format.
;
; KEYWORD PARAMETERS:
; SILENT: If this keyword is set, no outp[ut from wget or scp is 
; out on the command line.
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
pro dms_ssj_download_files, date, silent=silent

;http://sd-www.jhuapl.edu/Aurora/data/ssj/2008/mar/2008mar29.f13.gz

if n_params() ne 1 then begin
	prinfo, 'Must give Date.'
	return
endif

if n_elements(date) ne 1 then begin
	prinfo, 'Date must be scalar.'
	return
endif

base_url = 'http://sd-www.jhuapl.edu/Aurora/data/ssj'

sfjul, date, [0,2400], sjul, fjul, no_days=nd

prinfo, 'Downloading DMSP data.'
for d=0, nd-1 do begin

	ajul = sjul + double(d)
	sfjul, adate, atime, ajul, /jul
	
	str_date = format_date(adate, /dmsp)
	str_year = strmid(str_date, 0, 4)
	str_mon  = strmid(str_date, 4, 3)

	; looping over satellites
	for i=10, 18 do begin
		str_sat = 'f'+string(i,format='(I02)')
		outdi = '/tmp'
		if ~file_test(outdi, /dir) then begin
			prinfo, '/tmp/ directory does not exist.'
			return
		endif
		fname = str_date+'.'+str_sat+'.gz'
		cmd = 'wget -P '+outdi+' '+base_url+'/'+str_year+'/'+str_mon+'/'+fname
		if keyword_set(silent) then $
			spawn, cmd, outps, outpe $
		else $
			spawn, cmd
		if ~file_test(outdi+'/'+fname) then $
			continue
		if (file_info(outdi+'/'+fname)).size lt 1000 then $
			file_delete, outdi+'/'+fname $
		else begin
			cmd = 'scp '+outdi+'/'+fname+' sd-data@sd-data:/sd-data/dmsp/ssj/'+str_year+'/'
			if keyword_set(silent) then $
				spawn, cmd, outps, outpe $
			else $
				spawn, cmd
		endelse
	endfor

	wait, 5

endfor

end
