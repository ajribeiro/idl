;+
; NAME: 
; RAD_WRITE_ALL_HARDWARE_INFOS
;
; PURPOSE: 
; This function loops over all hdw.dat files
; beautifies the contents and writes general and hdw.dat specific
; information. The outputs of this command are used for the tiki.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; RAD_WRITE_ALL_HARDWARE_INFOS
;
; KEYWORD PARAMETERS:
; INDIR: Set this keyword to a directory from which to read the input (hdw.dat) files.
; 
; OUTDIR: Set this keyword to a directory into which to write the output files.
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
; Written by Lasse Clausen, Dec, 11 2009
;-
pro rad_write_all_hardware_infos, indir=indir, outdir=outdir

if ~keyword_set(indir) then $
	indir = '/davit/lib/rst/tables/superdarn/hdw'

if ~file_test(indir, /dir) then begin
	prinfo, 'Input directory does not exist: '+indir
	return
endif

if ~keyword_set(outdir) then $
	outdir = '/var/www/hdw'

if ~file_test(outdir, /dir) then begin
	prinfo, 'Output directory does not exist: '+outdir
	return
endif

files = file_search(indir+'/hdw.dat.???', count=fc)
if fc lt 1 then begin
	prinfo, 'No hardware files found: '+indir+'/hdw.dat.???'
	return
endif

rad_write_general_hardware_info, outdir=outdir
for i=0, fc-1 do begin
	;prinfo, 'Doing '+files[i]
	rad_prettyprint_hardware_info, files[i]
	rad_write_hardware_info, files[i], outdir=outdir
	sid = strmid(file_basename(files[i]), 8, 3)
	ihtmlfilename = outdir+'/'+file_basename(files[i])+'.html'
	ohtmlfilename = ihtmlfilename+'.tmp'
	line = ''
	in_table = !false
	openw, olun, ohtmlfilename, /get_lun
	printf, olun, '<html><body><link rel="stylesheet" href="http://vt.superdarn.org/styles/vtsuperdarn.css" type="text/css" media="screen" />'
	openr, ilun, ihtmlfilename, /get_lun
	while ~eof(ilun) do begin
		readf, ilun, line
		if (pos = strpos(line, '<table')) ne -1 then begin
			line = strmid(line, pos)
			in_table = !true
		endif
		if in_table then begin
			if strpos(line, 'PDF') ne -1 then $
				continue
			if (pos = strpos(line, '</table>')) ne -1 then begin
				line = strmid(line, 0, pos+8)
				printf, olun, line
				break
			endif
			printf, olun, line
		endif
	endwhile
	free_lun, ilun
	printf, olun, '<p />'
	filename = 'hdw.general.html'
	ihtmlfilename = outdir+'/'+file_basename(filename)
	openr, ilun, ihtmlfilename, /get_lun
	while ~eof(ilun) do begin
		readf, ilun, line
		if (pos = strpos(line, '<table')) ne -1 then begin
			line = strmid(line, pos)
			in_table = !true
		endif
		if in_table then begin
			if strpos(line, 'PDF') ne -1 then $
				continue
			if (pos = strpos(line, '</table>')) ne -1 then begin
				line = strmid(line, 0, pos+8)
				printf, olun, line
				break
			endif
			printf, olun, line
		endif
	endwhile
	free_lun, ilun
	printf, olun, '</body></html>'
	free_lun, olun
	html2ps = '/usr/bin/html2ps'
	if ~file_test(html2ps) then begin
		prinfo, 'Cannot find html2ps.'
		return
	endif
	opsfilename = outdir+'/'+file_basename(ohtmlfilename, '.html.tmp')+'.ps'
	print, ohtmlfilename+' -> '+opsfilename
	spawn, html2ps+' '+ohtmlfilename+' > '+opsfilename
	file_delete, ohtmlfilename
	ps2pdf = '/usr/bin/ps2pdf'
	if ~file_test(ps2pdf) then begin
		prinfo, 'Cannot find ps2pdf.'
		file_delete, opsfilename
		return
	endif
	opdffilename = outdir+'/'+file_basename(ohtmlfilename, '.html.tmp')+'.pdf'
	print, opsfilename+' -> '+opdffilename
	spawn, ps2pdf+' '+opsfilename+' > '+opdffilename
	file_delete, opsfilename
endfor

end
