;+ 
; NAME: 
; RAD_FIT_OVERLAY_FAN
; 
; PURPOSE: 
; This procedure overlays a certain radar scan on a stereographic polar map.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_OVERLAY_FAN
;
; OPTIONAL INPUTS:
; Scan_number: The number of the scan to overlay. Set to -1 if you want to
; choose the scan number by providing a date/time via the JUL keyword.
;
; KEYWORD PARAMETERS:
; JUL: Set this to a julian day number to select the scan to plot as that
; nearest to this date/time.
;
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn', 'geog', 'range' and 'gate'.
; Default is 'gate'.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; SCAN_STARTJUL: Set this to a named variable that will contain the
; julian day number of the plotted scan.
;
; ROTATE: Set this keyword to rotate the scan plot by 90 degree clockwise.
;
; FORCE_DATA: Set this keyword to a [nb, ng] array holding the scan data to plot.
; this overrides the internal scan finding procedures. nb is the number of beams,
; ng is the number of gates.
;
; VECTOR: Set this keyword to plot colored vectors 
; (like in the map potential plots)
; instead of colored polygons.
;
; FACTOR: Set this keyword to alter the length of vectors - only valid
; when plotting vectors.
;
; SIZE: Set this keyword to adjust thickness of vector and size of dot - only valid
; when plotting vectors.
;
; EXCLUDE: Set to a 2-element array giving the lower and upper velocity limit 
; to plot.
;
; FIXED_LENGTH: Set this keyword to a velocity value such that all vectors will be drawn
; with a lentgh correponding to that value, however they will still be color-coded
; according to their actual velocity value.
;
; SYMSIZE: Size of the symbols used to mark the radar position.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
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
; Based on Steve Milan's .
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_fit_overlay_fan, scan_number, coords=coords, time=time, date=date, jul=jul, $
	param=param, scale=scale, channel=channel, scan_id=scan_id, $
	freq_band=freq_band, rotate=rotate, force_data=force_data, $
	scan_startjul=scan_startjul, no_redefine=no_redefine, $
	vector=vector, factor=factor, size=size, exclude=exclude, $
	fixed_length=fixed_length, symsize=symsize

prinfo, 'DEPRECATED. Use RAD_FIT_OVERLAY_SCAN.'

rad_fit_overlay_scan, scan_number, coords=coords, time=time, date=date, jul=jul, $
	param=param, scale=scale, channel=channel, scan_id=scan_id, $
	freq_band=freq_band, rotate=rotate, force_data=force_data, $
	scan_startjul=scan_startjul, no_redefine=no_redefine, $
	vector=vector, factor=factor, size=size, exclude=exclude, $
	fixed_length=fixed_length, symsize=symsize

prinfo, 'DEPRECATED. Use RAD_FIT_OVERLAY_SCAN.'

end
