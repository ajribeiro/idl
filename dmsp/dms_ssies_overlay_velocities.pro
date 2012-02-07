;+
; NAME: 
; DMS_SSIES_OVERLAY_VELOCITIES
; 
; PURPOSE:
; This procedure overlays the footprint and the driftmeter velocities
; for the currently loaded DMSP data on a panel
; created by MAP_PLOT_PANEL. It simply calls DMS_SSJ_TRACK_PLOT_PANEL with the NO_MAP keyword set.
; 
; CATEGORY:
; DMSP
; 
; CALLING SEQUENCE: 
; DMS_SSIES_OVERLAY_VELOCITIES
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
; Must be the same as used in the MAP_PLOT_PANEL command.
;
; SILENT: Set this keyword to surpress messages.
;
; SYMSIZE: The size of the symbols used for marking the footprint.
;
; MARK_INTERVAL: The time step between time markers on the DMSP footprint, 
; in (decimal) hours. To set it to 2 minutes, set MARK_INTERVAL to 2./60.
;
; MARK_CHARSIZE: The charsize used for the footprint markers.
;
; MARK_CHARTHICK: The charthick used for the footprint markers.
;
; ROTATE: Set this keyword to a number of degrees by which to rotate the map clockwise.
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
pro dms_ssies_overlay_velocities, $
	date=date, time=time, long=long, $
	hemisphere=hemisphere, coords=coords, $
	silent=silent, $
	factor=factor, $
	symsize=symsize, $
	mark_interval=mark_interval, $
	mark_charsize=mark_charsize, mark_charthick=mark_charthick, $
	rotate=rotate, linecolor=linecolor, linethick=linethick, thick=thick

common dms_data_blk

if ~keyword_set(thick) then $
	thick = 1.

if ~keyword_set(linecolor) then $
	linecolor = 253

if ~keyword_set(date) then begin
	caldat, dms_ssj_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long

if ~keyword_set(factor) then $
	factor = 480.

if ~keyword_set(coords) then $
	coords = get_coordinates()

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

if ~keyword_set(linethick) then $
	linethick = 1.

if ~keyword_set(symsize) then $
	symsize = .75

if ~keyword_set(mark_interval) then $
	mark_interval = -1

if ~keyword_set(mark_charsize) then $
	mark_charsize = get_charsize(xmaps, ymaps)

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif
jinds = where(dms_ssies_data.juls ge sjul and dms_ssies_data.juls le fjul and dms_ssies_data.hemi eq hemisphere, cc)
if cc eq 0L then begin
	prinfo, 'No data loaded for interval or for hemisphere.'
	return
endif
juls = dms_ssies_data.juls[jinds]
dt = mean(deriv((juls-juls[0])*1440.d))

if coords eq 'geog' then begin
	lat = dms_ssies_data.glat[jinds]
	lon = dms_ssies_data.glon[jinds]
	azm = dms_ssies_data.gazm[jinds]
endif else if coords eq 'magn' then begin
	lat = dms_ssies_data.mlat[jinds]
	lon = dms_ssies_data.mlon[jinds]
	azm = dms_ssies_data.mazm[jinds]
endif else if coords eq 'mlt' then begin
	lat = dms_ssies_data.mlat[jinds]
	lon = dms_ssies_data.mlts[jinds]
	azm = dms_ssies_data.lazm[jinds]
endif else begin
	prinfo, 'Coordinate system not supported: '+coords
	return
endelse
vh = dms_ssies_data.vh[jinds]

tmp = calc_stereo_coords(lat, lon, mlt=(coords eq 'mlt'))
xpos = tmp[0,*]
ypos = tmp[1,*]
if n_elements(rotate) ne 0 then begin
	_x1 = cos(rotate*!dtor)*xpos - sin(rotate*!dtor)*ypos
	_y1 = sin(rotate*!dtor)*xpos + cos(rotate*!dtor)*ypos
	xpos = _x1
	ypos = _y1
endif
;oplot, xpos, ypos, color=get_white(), thick=2.*linethick
oplot, xpos, ypos, color=linecolor, thick=linethick

load_usersym, /circle

for i=0L, cc-1L do begin
	if finite(vh[i]) then begin

		vec_len = factor*vh[i]/!re/1e3 ;*hemisphere

		; Find latitude of end of vector
		vec_lat = asin( $
			( $
				( sin(lat[i]*!dtor)*cos(vec_len) + $
					cos(lat[i]*!dtor)*sin(vec_len)*cos(azm[i]*!dtor) $
				) < 1. $
			) > (-1.) $
		)*!radeg

		; Find longitude of end of vector
		delta_lon = ( $
			atan( sin(azm[i]*!dtor)*sin(vec_len)*cos(lat[i]*!dtor), cos(vec_len) - sin(lat[i]*!dtor)*sin(vec_lat*!dtor) ) $
		)*!radeg

		if coords eq 'mlt' then $
			vec_lon = lon[i] + delta_lon/15. $
		else $
			vec_lon = lon[i] + delta_lon

		; Find x and y position of end of vectors
		tmp = calc_stereo_coords(vec_lat, vec_lon, mlt=(coords eq 'mlt'))
		new_x = tmp[0]
		new_y = tmp[1]
		if n_elements(rotate) ne 0 then begin
			_x1 = cos(rotate*!dtor)*new_x - sin(rotate*!dtor)*new_y
			_y1 = sin(rotate*!dtor)*new_x + cos(rotate*!dtor)*new_y
			new_x = _x1
			new_y = _y1
		endif

		;oplot, [xpos[i]], [ypos[i]], psym=8, $
		;	symsize=2*symsize, color=get_background(), noclip=0
		;oplot, [xpos[i],new_x], [ypos[i],new_y],$
		;	thick=2*thick, COLOR=get_background(), noclip=0
		;oplot, [xpos[i]], [ypos[i]], psym=8, $
		;	symsize=symsize, color=vec_col, noclip=0
		oplot, [xpos[i],new_x], [ypos[i],new_y],$
			thick=thick, COLOR=vec_col, noclip=0
	endif
endfor

if mark_interval ne -1 then begin
	dx = deriv(xpos)
	dy = deriv(ypos)
	mark_every = round(mark_interval*60./dt)
	n_dots = n_elements(xpos)/mark_every+1L
	ind_dots = (lindgen(n_dots)*mark_every) < (cc-1L)
	mark_every = floor(230./n_dots)
;		col_dots = lindgen(n_dots)*mark_every+10L
	plots, xpos[ind_dots], ypos[ind_dots], $
		color=get_foreground(), $
		psym=8, noclip=0, symsize=symsize
;	plots, xpos[ind_dots], ypos[ind_dots], $
;		color=col_dots, $
;		psym=8, noclip=0, symsize=1.5*symsize
	angs = -atan(dx[ind_dots], dy[ind_dots])*!radeg
	for k=0, n_dots-1 do $
		xyouts, xpos[ind_dots[k]], ypos[ind_dots[k]], format_juldate(juls[ind_dots[k]], /short_time), /data, $
			orient=angs[k], charthick=mark_charthick, charsize=mark_charsize, color=linecolor, noclip=0
endif

end
