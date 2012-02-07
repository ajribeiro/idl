;+ 
; NAME: 
; RAD_FIT_PLOT_FAN
; 
; PURPOSE: 
; This procedure plots a stereographic map grid and overlays coast
; lines and the currently loaded radar data. This routine will call
; RAD_FIT_PLOT_FAN_PANEL multiple times if need be.
;
; The scan that will be plot is either chosen by its number (set keyword
; SCAN_NUMBER), the date and time closest to an available scan 
; (set DATE and TIME keywords) or the Juliand Day in SCAN_STARTJUL.
;
; NSCANS then determines how many sequential fan plots are put on one page.
; 
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_FAN
;
; KEYWORD PARAMETERS:
; DATE: A scalar giving the date to plot, in YYYYMMDD format.
;
; TIME: A scalar giving the time to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn' and 'geog'.
;
; XRANGE: Set this keyword to change the range of the x axis.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; SCAN_STARTJUL: Set this to a Julian Day determining the scan to plot.
;
; SCAN_NUMBER: Set this to a numer specifying the scan to plot.
;
; NSCANS: Set this to the number of sequential scans to plot. Default is 1.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; NO_FILL: Set this keyword to surpress filling of land masses and lakes with colors.
;
; NO_TITLE: Set this keyword to omit individual titles for the plots.
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
; Based on Steve Milan's PLOT_POLAR.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_fit_plot_fan, date=date, time=time, long=long, $
	param=param, scale=scale, channel=channel, scan_id=scan_id, $
	scan_startjul=scan_startjul, nscans=nscans, $
	coords=coords, xrange=xrange, yrange=yrange, $
	charthick=charthick, charsize=charsize, $
	scan_number=scan_number, $
	freq_band=freq_band, silent=silent, no_fill=no_fill, no_title=no_title

prinfo, 'DEPRECATED. Use RAD_FIT_PLOT_SCAN.'

rad_fit_plot_scan, date=date, time=time, long=long, $
	param=param, scale=scale, channel=channel, scan_id=scan_id, $
	scan_startjul=scan_startjul, nscans=nscans, $
	coords=coords, xrange=xrange, yrange=yrange, $
	charthick=charthick, charsize=charsize, $
	scan_number=scan_number, $
	freq_band=freq_band, silent=silent, no_fill=no_fill, no_title=no_title

prinfo, 'DEPRECATED. Use RAD_FIT_PLOT_SCAN.'

end
