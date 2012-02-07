;+
; NAME: 
; RAD_WRITE_HARDWARE_INFO
;
; PURPOSE: 
; This function reads a hdw.dat file and writes the 
; contents of the hdw.dat file in HTML format.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; RAD_WRITE_HARDWARE_INFO, Filename
;
; INPUTS:
; Filename: The name of the output file.
;
; KEYWORD PARAMETERS:
; OUTDIR: Set this keyword to a directory into which to write the output file.
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
pro rad_write_hardware_info, filename, outdir=outdir

common radarinfo

if ~file_test(filename) then begin
	prinfo, 'Cannot find file: '+filename
	return
endif

if ~file_test(filename, /read) then begin
	prinfo, 'Cannot open file: '+filename
	return
endif

if ~keyword_set(outdir) then $
	outdir = '/var/www/hdw'

if ~file_test(outdir, /dir) then begin
	prinfo, 'Output directory does not exist: '+outdir
	return
endif

; open output HTML file
ohtmlfilename = outdir+'/'+file_basename(filename)+'.html'
openw, ohtmllun, ohtmlfilename, /get_lun, error=error
if error ne 0 then begin
	prinfo, 'Cannot open HTML output file: '+!error_state.msg
	return
endif

sid = strmid(file_basename(ohtmlfilename), 8, 3)

sbeghighlight = '<strong><font color="red">'
sendhighlight = '</strong></font>'
fsize = '.78em'

; open output RFT file
; read line
; parse line
; write HTML output
; write RFT output
; close all

line = ''
st_id = 0
year = 0
yrsec = 0L
glat = 0.0
glon = 0.0
alt = 0.0
boresite = 0.
bmsep = 0.
vdir = 0.
atten = 0.
tdiff = 0.
phidiff = 0.
i_xpos = 0.
i_ypos = 0.
i_zpos = 0.
rec_rise = 0.0
maxatten = 0
ngates = 0
nbeams = 0
nlines = 0
; open input file
openr, ilun, filename, /get_lun, error=error
if error ne 0 then begin
	prinfo, 'Cannot open input file: '+!error_state.msg
	free_lun, ohtmllun
	return
endif
;printf, ohtmllun, '<html>'
olddate = ''
oldvals = replicate(' ', 13)
while ~eof(ilun) do begin
	readf, ilun, line
	line = strtrim(line, 2)
	if strmid(line, 0, 1) eq '#' then $
		continue
	if strlen(line) lt 10 then $
		continue
	;# station_id, year, yr_sec, lat, long, altitude, boresite, bm_sep,
	;#   vdir, atten, tdiff, phidiff, interfer_pos[3], rec_rise
	; 204 2010 15346800 +38.859 -99.389 675.534 -25 +3.24 +1.0 10.0 +0.4778 +1.0 +1.5 +100.0 +0.0 0.0 2 75 16
	reads, line, st_id, year, yrsec, glat, glon, alt, boresite, bmsep, vdir, atten, $
		tdiff, phidiff, i_xpos, i_ypos, i_zpos, rec_rise, maxatten, ngates, nbeams
	rad = radarGetRadar(network, st_id)
	if size(rad, /type) ne 8 then begin
		prinfo, 'Station ID not found in network structure: '+string(st_id, format='(I3)')
		continue
	endif
	sradnme = rad.name
	sradid  = string(st_id, format='(I3)')
	syear   = string(year, format='(I4)')
	jul = julday(1, 1, year, 0, 0, yrsec)
	sdate = format_juldate(jul)
	sdate = sbeghighlight+strjoin(strsplit(sdate, ' ', /extr), sendhighlight+' ')
	;ret = timeYrsecToYMDHMS(year, mo, dy, hr, mi, ss, yrsec)
	;sdate   = string([year,mo], format='(I4,"/",I2)')
	sglat   = (glat lt 0. ? '' : '+')+strtrim(string(glat, format='(F8.3)'),2)
	sglon   = (glon lt 0. ? '' : '+')+strtrim(string(glon, format='(F8.3)'),2)
	salt    = strtrim(string(alt, format='(F7.1)'),2)
	sbores  = strtrim(string(boresite, format='(F6.1)'),2)
	sbmsep  = strtrim(string(bmsep, format='(F5.2)'),2)
	svdir   = (vdir lt 0. ? '' : '+')+strtrim(string(vdir, format='(I2)'),2)
	satten  = strtrim(string(atten, format='(I4)'),2)
	stdiff  = (tdiff lt 0. ? '' : '+')+strtrim(string(tdiff, format='(F6.3)'),2)
	spdiff  = (phidiff lt 0. ? '' : '+')+strtrim(string(phidiff, format='(I2)'),2)
	sixpos  = (i_xpos lt 0. ? '' : '+')+strtrim(string(i_xpos, format='(F6.1)'),2)
	siypos  = (i_ypos lt 0. ? '' : '+')+strtrim(string(i_ypos, format='(F6.1)'),2)
	sizpos  = (i_zpos lt 0. ? '' : '+')+strtrim(string(i_zpos, format='(F6.1)'),2)
	srecrs  = strtrim(string(rec_rise, format='(F5.1)'),2)
	smaxa   = strtrim(string(maxatten, format='(I2)'),2)
	sngates = strtrim(string(ngates, format='(I3)'),2)
	snbeams = strtrim(string(nbeams, format='(I2)'),2)
	vals =[sbores,sbmsep,svdir,satten,stdiff,spdiff,sixpos,siypos,sizpos,srecrs,smaxa,sngates,snbeams]
	if nlines eq 0 then begin
;		printf, ohtmllun, '<script type="text/javascript"> '
;		printf, ohtmllun, 'function fold(id)'
;		printf, ohtmllun, '{'
;		printf, ohtmllun, '	dd = document.getElementById(id);'
;		printf, ohtmllun, '	if (dd.style.display == "none")'
;		printf, ohtmllun, '	{'
;		printf, ohtmllun, '		dd.style.display = "block";'
;		printf, ohtmllun, '	}'
;		printf, ohtmllun, '	else'
;		printf, ohtmllun, '	{'
;		printf, ohtmllun, '		dd.style.display = "none";'
;		printf, ohtmllun, '	}'
;		printf, ohtmllun, '}'
;		printf, ohtmllun, '</script>'
;		printf, ohtmllun, '<body>'
;		printf, ohtmllun, '<a href="javascript:fold('+"'"+'hdwtable'+sid+"'"+')">Show '+sradnme+' Hardware Table</a>'+$
;		printf, ohtmllun, '<div id="hdwtable'+sid+'" style="display: none;">
		printf, ohtmllun, '<table width="100%" cellpadding="5px" cellspacing="2px" border="0">'
		printf, ohtmllun, '<tr><th colspan="15"><strong>'+sradnme+' (code: '+strupcase(rad.code[0])+', ID: '+sradid+')</strong></th></tr>'
		printf, ohtmllun, '<tr><th colspan="15"><strong> Geog. Position: ('+sglat+'&deg;, '+sglon+'&deg;, '+salt+'m)</strong></th></tr>'
		printf, ohtmllun, '<tr><th><div style="font-size: '+fsize+';">Configuration valid from</div></th>'+$
			'<th><div style="font-size: '+fsize+';">Configuration valid until</div></th>'+$
			'<th><div style="font-size: '+fsize+';">Scanning Boresite<br>&#91;&deg;&#93;</div></th>'+$
			'<th><div style="font-size: '+fsize+';">Beam Separation<br>&#91;&deg;&#93;</div></th>'+$
			'<th><div style="font-size: '+fsize+';">Velocity Sign</div></th>'+$
			'<th><div style="font-size: '+fsize+';">Attenuation Step&#42;<br>&#91;dB&#93;</div></th>' + $
			'<th><div style="font-size: '+fsize+';">Time Difference<br>&#91;&mu;s&#93;</div></th>'+$
			'<th><div style="font-size: '+fsize+';">Phase Sign</div></th>'+$
			'<th colspan=3 width="200px"><div style="font-size: '+fsize+';">Interferometer<br>Array<br>Position<br>&#91;m&#93;</div></th>'+$
			'<th><div style="font-size: '+fsize+';">Receiver Rise Time&#42;<br>&#91;&mu;s&#93;</div></th>'+$
			'<th><div style="font-size: '+fsize+';">Stages of Attenuation&#42;</div></th>' + $
			'<th><div style="font-size: '+fsize+';">No. of Gates</div></th>'+$
			'<th><div style="font-size: '+fsize+';">No. of Beams</div></th></tr>'
	endif
	if year ge 2900 then $
		continue
	if nlines eq 0 then begin
		printf, ohtmllun, '<tr>'
		printf, ohtmllun, '<td class="'+(nlines mod 2 ? 'even' : 'odd' )+'" align="center" valign="middle"><div style="font-size: '+fsize+';"></div></td>'
		printf, ohtmllun, '<td class="'+(nlines mod 2 ? 'even' : 'odd' )+'" align="center" valign="middle"><div style="font-size: '+fsize+';">'+sdate+'</div></td>'
		for i=0, n_elements(vals)-1 do begin
			printf, ohtmllun, '<td class="'+(nlines mod 2 ? 'even' : 'odd' )+'" align="center" valign="middle"><div style="font-size: '+fsize+';">'+vals[i]+'</div></td>'
		endfor
		printf, ohtmllun, '</tr>'
	endif else begin
		printf, ohtmllun, '<tr>'
		printf, ohtmllun, '<td class="'+(nlines mod 2 ? 'even' : 'odd' )+'" align="center" valign="middle"><div style="font-size: '+fsize+';">'+olddate+'</div></td>'
		printf, ohtmllun, '<td class="'+(nlines mod 2 ? 'even' : 'odd' )+'" align="center" valign="middle"><div style="font-size: '+fsize+';">'+sdate+'</div></td>'
		for i=0, n_elements(vals)-1 do begin
			printf, ohtmllun, '<td class="'+(nlines mod 2 ? 'even' : 'odd' )+'" align="center" valign="middle">'+sbeghighlight+$
				'<div style="font-size: '+fsize+';">'+(vals[i] eq oldvals[i] ? '' : vals[i])+'</div>'+sendhighlight+'</td>'
		endfor
		printf, ohtmllun, '</tr>'
	endelse
	nlines += 1
	oldvals =[sbores,sbmsep,svdir,satten,stdiff,spdiff,sixpos,siypos,sizpos,srecrs,smaxa,sngates,snbeams]
	olddate = sdate
endwhile
free_lun, ilun
printf, ohtmllun, '<tr>'
printf, ohtmllun, '<td class="'+(nlines mod 2 ? 'even' : 'odd' )+'" align="center" valign="middle">'+$
	'<div style="font-size: '+fsize+';">'+olddate+'</div></td>'
printf, ohtmllun, '<td class="'+(nlines mod 2 ? 'even' : 'odd' )+'" align="center" valign="middle">'+sbeghighlight+$
	'<div style="font-size: '+fsize+';">Current</div>'+sendhighlight+'</td>'
for i=0, n_elements(vals)-1 do begin
	printf, ohtmllun, '<td class="'+(nlines mod 2 ? 'even' : 'odd' )+'" align="center">'+$
		(vals[i] eq oldvals[i] ? '' : sbeghighlight)+$
				'<div style="font-size: '+fsize+';">'+vals[i]+'</div>'+(vals[i] eq oldvals[i] ? '' : sendhighlight)+'</td>'
endfor
printf, ohtmllun, '</tr>'
printf, ohtmllun, '<tr>'
printf, ohtmllun, '<td align="left" colspan="8"><div style="font-size: '+fsize+';">&#42; Only valid for analog receivers, 0 for digital receivers</div>'
;printf, ohtmllun, '<a href="http://sd-work5.ece.vt.edu/hdw/hdw.dat.'+sid+'.pdf">Download Hardware Table as PDF</a>'
printf, ohtmllun, '</td>'
printf, ohtmllun, '<td align="right" colspan="7"><div style="font-size: '+fsize+';">Last Updated: '+systime()+'</div></td>'
printf, ohtmllun, '</tr>'
;printf, ohtmllun, '<tr><td align="left" colspan="15">' + $
;	'<a href="http://sd-work5.ece.vt.edu/hdw/hdw.dat.'+sid+'.pdf">Download Hardware Table as PDF</a>' + $
;	'</td></tr>'
printf, ohtmllun, '</table>'
;printf, ohtmllun, '</div>'
;prinft, ohtmllun, '</body></html>'
free_lun, ohtmllun

end
