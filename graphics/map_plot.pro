;+ 
; NAME: 
; MAP_PLOT
; 
; PURPOSE: 
; This procedure plots a stereographic map grid and overlays coast
; lines on a new page. It is essentially MPA_PLOT_PANEL with a CLEAR_PAGE before.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; MAP_PLOT
;
; KEYWORD PARAMETERS:
; DATE: A scalar giving the date to plot, in YYYYMMDD format.
;
; TIME: A scalar giving the time to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; COORDS: Set this keyword to a string naming the coordinate system.
; Allowable inputs are 'mlt', 'magn' and 'geog'.
; Default is 'magn'.
;
; XRANGE: Set this keyword to change the range of the x axis.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; POSITION: Set this keyword to a 4-element vector holding the normalized
; coordinates of the ouput panel. Use this to override internal positioning.
;
; BAR: Set this keyword to indicate that you want some space for a colorbar on the right
; of the plot.
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; SOUTH: Set this keyword to plot a map of the southern hemisphere.
;
; NORTH: Set this keyword to plot a map of the norther hemisphere (default).
;
; ROTATE: Set this keyword to a number of degrees by which to rotate the map clockwise.
;
; NO_AXIS: Set this keyword to surpress y and x axes.
;
; NO_COAST: Set this keyword to surpress overlaying coast lines.
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
; Written by Lasse Clausen, Dec, 1 2009
;-
pro map_plot, $
	date=date, time=time, long=long, jul=jul, $
	coords=coords, xrange=xrange, yrange=yrange, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $
	position=position, bar=bar, $
	hemisphere=hemisphere, north=north, south=south, rotate=rotate, $
	no_coast=no_coast, no_axis=no_axis, no_grid=no_grid, no_label=no_label, $
	title=title, isotropic=isotropic

clear_page

map_plot_panel, 1, 1, 0, 0, $
	date=date, time=time, long=long, jul=jul, $
	coords=coords, xrange=xrange, yrange=yrange, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $
	position=position, bar=bar, $
	hemisphere=hemisphere, north=north, south=south, rotate=rotate, $
	no_coast=no_coast, /no_fill, no_axis=no_axis, no_grid=no_grid, no_label=no_label, $
	title=title, isotropic=isotropic

end
