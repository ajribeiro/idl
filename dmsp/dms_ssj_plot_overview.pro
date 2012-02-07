;+
; NAME: 
; DMS_SSJ_PLOT_OVERVIEW
; 
; PURPOSE:
; This procedure plots the ion and electron spectra
; for the currently loaded DMSP SSJ/4 data and a map panel
; showing the footprint of the satellite on a page.
; 
; CATEGORY:
; DMSP
; 
; CALLING SEQUENCE: 
; DMS_SSJ_PLOT_OVERVIEW
;
; KEYWORD PARAMETERS:
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; TIME: A 2-element vector giving the time range to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; COORDS: The coodirnates of the map panel. Can be 'geog', 'magn' or 'mlt'.
;
; XRANGE: The xrange of the map panel.
;
; YRANGE: The yrange of the map panel.
;
; MARK_INTERVAL: The time step between time markers on the DMSP footprint, 
; in (decimal) hours. To set it to 2 minutes, set MARK_INTERVAL to 2./60.
;
; NORTH: Set this keyword to plot an overview for the northern hemisphere. This is the default.
;
; SOUTH: Set this keyword to plot an overview for the southern hemisphere.
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
pro dms_ssj_plot_overview, date=date, time=time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, mark_interval=mark_interval, $
	north=north, south=south

common dms_data_blk

if ~keyword_set(yrange) then $
	yrange = [-31,31]

if ~keyword_set(xrange) then $
	xrange = [-46,46]

if ~keyword_set(north) and ~keyword_set(south) then $
	north = 1

aspect = float(xrange[1]-xrange[0])/float(yrange[1]-yrange[0])

if ~keyword_set(coords) then $
	coords = 'mlt'

if ~keyword_set(mark_interval) then $
	mark_interval = 4./60.

clear_page
set_format, /sard

pos = define_panel(2, 3, 1, 0, aspect=aspect, /no_title, /bar) - [0.05, 0, 0.05, 0]
dms_track_plot_panel, position=pos, coords=coords, xrange=xrange, yrange=yrange, $
	date=date, time=time, long=long, mark_interval=mark_interval, $
	mark_charsize=get_charsize(2,3), north=north, south=south, charsize=get_charsize(2,3)
	
plot_colorbar, 1, 3, 0, 1, /no_title, scale=escale, param='power', legend='Log Energy Flux (electrons)'
plot_colorbar, 1, 3, 0, 2, /no_title, scale=iscale, param='power', legend='Log Energy Flux (ions)'

dms_ssj_plot_spectrum_panel, 1, 3, 0, 1, /bar, /no_title, /electrons, $
	date=date, time=time, long=long, scale=escale, mark_interval=mark_interval

dms_ssj_plot_spectrum_panel, 1, 3, 0, 2, /bar, /no_title, /ions, $
	date=date, time=time, long=long, scale=iscale, mark_interval=mark_interval, /last

xyouts, .25, .85, 'F'+string(dms_ssj_info.sat,format='(I02)'), charthick=3, charsize=3, /norm, align=.5
xyouts, .25, .75, format_date(date, /hum)+'!C'+format_time(time), charthick=2, charsize=2, /norm, align=.5

end
