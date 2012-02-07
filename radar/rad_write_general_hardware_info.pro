;+
; NAME: 
; RAD_WRITE_GENERAL_HARDWARE_INFO
;
; PURPOSE: 
; This function writes general information about the 
; contents of hdw.dat files in HTML format.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; RAD_WRITE_GENERAL_HARDWARE_INFO, Filename
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
pro rad_write_general_hardware_info, filename, outdir=outdir

common radarinfo

if n_params() eq 0 then $
	filename = 'hdw.general.html'

if ~keyword_set(outdir) then $
	outdir = '/var/www/hdw'

if ~file_test(outdir, /dir) then begin
	prinfo, 'Output directory does not exist: '+outdir
	return
endif

; open output HTML file
ohtmlfilename = outdir+'/'+file_basename(filename)
openw, ohtmllun, ohtmlfilename, /get_lun, error=error
print, ohtmlfilename
if error ne 0 then begin
	prinfo, 'Cannot open HTML output file: '+!error_state.msg
	return
endif

sbeghighlight = '<strong><font color="red">'
sendhighlight = '</strong></font>'
fsize = '.78em'

pname = [ $
	'Station ID', $
	'Year', $
	'Seconds in Year', $
	'Geog. Latitude', $
	'Geog. Longitude', $
	'Altitude', $
	'Scanning Boresite', $
	'Beam Separation', $
	'Velocity Sign', $
	'Attenuation Step&#42;', $
	'Time Difference', $
	'Phase Sign', $
	'Interferometer Array Position X', $
	'Interferometer Array Position Y', $
	'Interferometer Array Position Z', $
	'Receiver Rise Time&#42;', $
	'Stages of Attenuation&#42;', $
	'No. of Gates', $
	'No. of Beams' $
]
nparam = n_elements(pname)
descr = [ $
	'The unique numeric ID of the radar. Assigned by Rob Barnes.', $
	'This and the next parameter describe the date up until which the radar configuration described in that line was valid.', $
	'This and the previous parameter describe the date up until which the radar configuration described in that line was valid.', $
	'The geographic latitude of the radar location, given in decimal degrees to 3 decimal places. Southern hemisphere values are negative.', $
	'The geographic longitude of the radar location, in degree given in decimal degrees to 3 decimal places. West longitude values are negative.', $
	'The altitude above sealevel of the radar location, in meter.', $
	'The direction of the center of the field-of-view of the radar, in degree, relative to geographic North, positive clockwise.<br>'+$
		'Traditionally, this direction was the same as the direction of the main antenna array normal.', $
	'The angular separation of two adjacent beams, in degree. Normally 3.24 degrees.', $
	'The sign of the velocity direction, either +1 or -1, usually +1.(At the radar level, backscattered signals with frequencies above the transmitted frequency are assigned positive Doppler velocities while backscattered signals with frequencies below the transmitted frequency are assigned negative Doppler velocity. This convention can be reversed by changes in receiver design or in the data samping rate. This parameter is set to +1 or -1 to maintain the convention.)', $
	'The step size of the receiver attenuation in dB.', $
	'The relative time delay of signal paths from the interferometer array to the receiver and the main array to the receiver, in microseconds.<br>'+$
		'tdiff = signal_travel_time_from_interferometer_to_receiver - signal_travel_time_from_main_to_receiver<br>'+$
		'If tdiff is positive, the signal travel time from the interferometer array to the receiver is longer than the travel time from the main array to the receiver.', $
	'The sign of the phase shift between interferometer and main array, either +1 or -1, usually +1. (Cabling errors can lead to a 180 degree shift of the interferometry phase measurement. +1 indicates that the sign is correct, -1 indicates that it must be flipped.)', $
	'The offset distance between the mid points of the interferometer and main array, in the direction along the main array, positive towards higher antenna numbers, in meter.', $
	'The offset distance between the mid points of the interferometer and main array, in the direction perpendicular to the main array, positive values indicate that the interferometer array is in front of the main array, in meter.', $
	'The offset distance between the mid points of the interferometer and main array, in the vertical direction, positive up, in meter.', $
	'The rise time of the analog receiver, in microseconds. (Time delays of less than ~10 microseconds can be ignored. If narrow-band filters are used in analog receivers or front-ends, the time delays should be specified.)', $
	'The maximum number of steps of analog attenuation in the receiver. (This is used for gain control of an analog receiver or front-end.)', $
	'The maximum number of range gates from which the radar can receive data. Usually 75. (This is used for allocation of array storage.)', $
	'The maximum number of beams the radar can form. Usually 16. Together with the scanning boresite, this parameter defined the direction of each beam relative to geographic North. (It is important to specify the true maximum. This will assure that a given beam number always points in the same direction. A subset of these beams, e.g. 8-23, can be used for standard 16 beam operation.)' $
]

printf, ohtmllun, '<a href="javascript:fold('+"'"+'hdwinfo'+"'"+')">Show a detailed decription of the parameters in the hardware files</a>'+$
	'<div id="hdwinfo" style="display: none;"><table width="100%">'
printf, ohtmllun, '<tr><th width="10%">Position in Line</th><th width="25%">Parameter Name</th><th>Description</th></tr>'
for i=0, nparam-1 do begin
	printf, ohtmllun, '<tr>'
	printf, ohtmllun, '<td class="'+(i mod 2 ? 'even' : 'odd' )+'" align="center">'+strtrim(string(i+1),2)+'</td>'
	printf, ohtmllun, '<td class="'+(i mod 2 ? 'even' : 'odd' )+'" align="center">'+pname[i]+'</td>'
	printf, ohtmllun, '<td class="'+(i mod 2 ? 'even' : 'odd' )+'">'+descr[i]+'</td>'
printf, ohtmllun, '</tr>'
endfor
printf, ohtmllun, '</tr>'
printf, ohtmllun, '<tr>'
printf, ohtmllun, '<td align="left" colspan="2"><div style="font-size: '+fsize+';">&#42; Only valid for analog receivers, 0 for digital receivers</div></td>'
printf, ohtmllun, '<td align="right" colspan="1"><div style="font-size: '+fsize+';">Last Updated: '+systime()+'</div></td>'
printf, ohtmllun, '</tr>'
;printf, ohtmllun, '<tr><td align="left" colspan="3">' + $
;	'<a href="http://sd-work5.ece.vt.edu/hdw/hdw.dat.'+sid+'.pdf">Download Hardware Table as PDF</a>' + $
;	'</td></tr>'
printf, ohtmllun, '</table></div>'
;prinft, ohtmllun, '</body></html>'
free_lun, ohtmllun

end
