;+
; NAME: 
; OVERLAY_OVAL
;
; PURPOSE: 
; This procedure plots a model auroral oval position on a panel
; created by MAP_PLOT_PANEL. It used the model described in Feldstein et al., 1969
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; OVERLAY_OVAL, Date, Time
;
; INPUTS:
; Date: The date on which to plot the oval.
;
; Time: the time for which to plot the oval.
;
; KEYWORD PARAMETERS:
; KP: Set this keyword to the Kp index for which to plot the oval. You can use
; kpi_read to read KP indeces in DaViT.
;
; COORDS: Set this keyword to the coordinate system in which to plot the oval.
; Can be 'geog', 'magn' or 'mlt'.
;
; LINECOLOR: Set this keyword to set the line color used to plot the oval.
;
; LINESTYLE: Set this keyword to set the line style used to plot the oval.
;
; LINETHICK: Set this keyword to set the line thickness used to plot the oval.
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; NORTH: Set this keyword to overlay the oval in the northern hemisphere.
;
; SOUTH: Set this keyword to overlay the oval in the southern hemisphere.
;
; ROTATE: Set this keyword to a number of degree by which to rotate the oval
; clockwise. Make sure that you give the same number of degrees to
; MAP_PLOT_PANEL and all other plotting routines.
;
; SCALE: This is a fudge factor that allows you to hand-scale the oval size
; from its Kp=2 size.
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
; Written by Lasse Clausen, Dec, 4 2009
;-
pro overlay_oval, date, time, $
	coords=coords, Kp=Kp, $
	linecolor=linecolor, linestyle=linestyle, linethick=linethick, $
	north=north, south=south, hemisphere=hemisphere, rotate=rotate, scale=scale

if n_params() lt 2 then begin
	prinfo, 'Must give date and time.'
	return
endif

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~keyword_set(linethick) then $
	linethick = 1.

if ~keyword_set(linestyle) then $
	linestyle = 0.

if ~keyword_set(linecolor) then $
	linecolor = get_black()

if ~keyword_set(scale) then $
	scale = 1.

if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return
endif

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

OvalCoef=FLTARR(7,8,3)

; Coefficients for poleward edge of Feldstein Oval
OvalCoef[0,1:7,1]=[15.22, 2.41, 3.34, -0.85, 1.01, 0.32, 0.90]
OvalCoef[1,1:7,1]=[15.85, 2.70, 3.32, -0.67, 1.15, 0.49, 1.00]
OvalCoef[2,1:7,1]=[16.09, 2.51, 3.27, -0.56, 1.30, 0.42, 0.94]
OvalCoef[3,1:7,1]=[16.16, 1.92, 3.14, -0.46, 1.43, 0.32, 0.96]
OvalCoef[4,1:7,1]=[16.29, 1.41, 3.06, -0.09, 1.35, 0.40, 1.03]
OvalCoef[5,1:7,1]=[16.44, 0.81, 2.99,  0.14, 1.25, 0.48, 1.05]
OvalCoef[6,1:7,1]=[16.71, 0.37, 2.90,  0.63, 1.59, 0.60, 1.00]

; Coefficients for equatorward edge of Feldstein Oval
OvalCoef[0,1:7,2]=[17.36, 3.03, 3.46,  0.42,  2.11, -0.25,  1.13]
OvalCoef[1,1:7,2]=[18.66, 3.90, 3.37,  0.16,  2.55, -0.13,  0.96]
OvalCoef[2,1:7,2]=[19.73, 4.69, 3.34, -0.57, -1.41, -0.07,  0.75]
OvalCoef[3,1:7,2]=[20.63, 4.95, 3.31, -0.66, -1.28,  0.30, -0.58]
OvalCoef[4,1:7,2]=[21.56, 4.93, 3.31, -0.44, -0.81, -0.07, -0.75]
OvalCoef[5,1:7,2]=[22.32, 4.96, 3.29, -0.39, -0.72, -0.16, -0.52]
OvalCoef[6,1:7,2]=[23.18, 4.85, 3.34, -0.38, -0.62, -0.53, -0.16]

; Default Kp level is 2
IF ~KEYWORD_SET(Kp) THEN $
	Kp=2

IF Kp LT 0 OR Kp GT 4 THEN BEGIN
	prinfo, 'Kp out of range'
	return
ENDIF

sfjul, date, time, jul
ut = (jul -.5d - double(long(jul-.5d)))*24.
tmp = cnvcoord(0.0, 0.0, 1.0)
ut0 = tmp[1]/180.*12.

; Convert to Q index. Kp=0: Q=1; Kp>0: Q = Kp + 2
IF Kp EQ 0 THEN Q=1
IF Kp GT 0 THEN Q=Kp+2

if ~keyword_set(north) and ~keyword_set(south) and ~keyword_set(hemisphere) then $
	north = 1

if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1.
endif

FOR edge=1,2 DO BEGIN

	; Plot edge
	_mlt = FINDGEN(501)*!pi/250.
	coLat = REPLICATE(OvalCoef[Q,1,edge],501)
	coLat = coLat + OvalCoef[Q,2,edge]*COS(1*(_mlt+OvalCoef[Q,3,edge]))
	coLat = coLat + OvalCoef[Q,4,edge]*COS(2*(_mlt+OvalCoef[Q,5,edge]))
	coLat = coLat + OvalCoef[Q,6,edge]*COS(3*(_mlt+OvalCoef[Q,7,edge]))
	coLat = (edge eq 1 ? coLat/scale : coLat*scale )
	mlt = (12.*(_mlt + !pi)/!pi) mod 24.
	mlat = hemisphere*(90. - coLat)
	;Lon=(15*(12*(MLT+!pi)/!pi-UT+4.73)+360) MOD 360
	mlon = (15.*(12.*(_mlt+!pi)/!pi-ut+ut0)+360.) MOD 360.
	
	if strcmp(coords, 'geog', /fold) then begin
		glat = mlat
		glon = mlon
		for i=0, 500 do begin
			tmp = cnvcoord(mlat[i], mlon[i], 1., /geo)
			glat[i] = tmp[0]
			glon[i] = tmp[1]
		endfor
		tmp = calc_stereo_coords(glat, glon)
		xx = tmp[0,*]
		yy = tmp[1,*]
		if n_elements(rotate) ne 0 then begin
			_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
			_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
			xx = _x1
			yy = _y1
		endif
		;if keyword_set(rotate) then $
		;	swap, xx, yy, /right
		oplot, xx, yy, $
			color=get_white(), linestyle=linestyle, thick=3.*linethick
		oplot, xx, yy, $
			color=linecolor, linestyle=linestyle, thick=linethick
	endif
	
	if strcmp(coords, 'magn', /fold) then begin
		tmp = calc_stereo_coords(mlat, mlon)
		xx = tmp[0,*]
		yy = tmp[1,*]
		if n_elements(rotate) ne 0 then begin
			_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
			_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
			xx = _x1
			yy = _y1
		endif
		;if keyword_set(rotate) then $
		;	swap, xx, yy, /right
		oplot, xx, yy, $
			color=get_white(), linestyle=linestyle, thick=3.*linethick
		oplot, xx, yy, $
			color=linecolor, linestyle=linestyle, thick=linethick
	endif
	
	if strcmp(coords, 'mlt', /fold) then begin
		tmp = calc_stereo_coords(mlat, mlt, /mlt)
		xx = tmp[0,*]
		yy = tmp[1,*]
		if n_elements(rotate) ne 0 then begin
			_x1 = cos(rotate*!dtor)*xx - sin(rotate*!dtor)*yy
			_y1 = sin(rotate*!dtor)*xx + cos(rotate*!dtor)*yy
			xx = _x1
			yy = _y1
		endif
		;if keyword_set(rotate) then $
		;	swap, xx, yy, /right
;		oplot, xx, yy, $
;			color=get_white(), linestyle=linestyle, thick=3.*linethick
		oplot, xx, yy, $
			color=linecolor, linestyle=linestyle, thick=linethick
	endif

endfor

end
