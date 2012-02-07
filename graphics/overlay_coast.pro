;+ 
; NAME: 
; OVERLAY_COAST
; 
; PURPOSE: 
; This procedure overlays coast lines on a stereographic map grid produced by MAP_PLOT_PANEL.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
;
; KEYWORD PARAMETERS:
; COORDS: Set this keyword to the coordinates in which to overlay the coast lines
;
; JUL: Set this keyword to the Julian Day Number to use for the plotting of the coast lines.
; This keyword only applies when using Magnetic Local Time coordinates.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; COAST_LINESTYLE: Set this keyword to change the style of the coast line.
; Default is 0 (solid).
;
; COAST_LINECOLOR: Set this keyword to a color index to change the color of the coast line.
; Default is black.
;
; COAST_LINETHICK: Set this keyword to change the thickness of the coast line.
; Default is 1.
;
; LAND_FILLCOLOR: Set this keyword to the color index to use for filling land masses.
; Default is green (123).
;
; LAKE_FILLCOLOR: Set this keyword to the color index to use for filling lakes.
; Default is blue (20).
;
; NO_FILL: Set this keyword to surpress filling of land masses and lakes with colors.
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; ROTATE: Set this keyword to a number of degree by which to rotate the coast
; clockwise. Make sure that you give the same number of degrees to
; MAP_PLOT_PANEL and all other plotting routines.
;
; NORTH: Set this keyword to overlay the northern hemisphere coast.
;
; SOUTH: Set this keyword to overlay the southern hemisphere coast.
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
; Based on Steve Milan's OVERLAY_POLAR_COAST.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro overlay_coast, coords=coords, jul=jul, silent=silent, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	hemisphere=hemisphere, north=north, south=south, rotate=rotate, no_fill=no_fill

if ~keyword_set(coords) then $
	coords = get_coordinates()

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if ~keyword_set(hemisphere) then begin
  if keyword_set(north) then $
    hemisphere = 1. $
  else if keyword_set(south) then $
    hemisphere = -1. $
  else $
    hemisphere = 1.
endif

if ~keyword_set(coast_linethick) then $
	coast_linethick = !p.thick

if n_elements(coast_linestyle) eq 0 then $
	coast_linestyle = 0

if n_elements(coast_linecolor) eq 0 then $
	coast_linecolor = get_foreground()

if n_elements(land_fillcolor) eq 0 then $
	land_fillcolor = get_green()

if n_elements(lake_fillcolor) eq 0 then $
	lake_fillcolor = get_blue()

if coords eq 'geog' then $
	overlay_geo_coast, silent=silent, no_fill=no_fill, $
		coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
		coast_linethick=coast_linethick, $
		land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
		hemisphere=hemisphere, rotate=rotate $
else if coords eq 'magn' then $
	overlay_mag_coast, silent=silent, no_fill=no_fill, $
		coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
		coast_linethick=coast_linethick, $
		land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
		hemisphere=hemisphere, rotate=rotate $
else if coords eq 'mlt' then begin
	if ~keyword_set(jul) then begin
		prinfo, 'You must provide a date/time for MLT plotting.'
		return
	endif
	overlay_mlt_coast, jul, silent=silent, no_fill=no_fill, $
		coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
		coast_linethick=coast_linethick, $
		land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
		hemisphere=hemisphere, rotate=rotate
endif else $
	prinfo, 'Coordinate system "'+coords+'" not (yet) allowed in OVERLAY_COAST.'

end
