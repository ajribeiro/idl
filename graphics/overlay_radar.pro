;+
; NAME:
; OVERLAY_FOV_NAME
;
; PURPOSE:
; This procedure overlays SuperDARN radar names on a stereographic map grid produced by
; MAP_PLOT_PANEL.
;
; CATEGORY:
; Graphics
;
; CALLING SEQUENCE:
;
; KEYWORD PARAMETERS:
; COORDS: Set this keyword to the coordinates in which to overlay the fields-of-view.
;
; DATE: Set this keyword to the date for which you want to overlay the FoV. Use this
; keyword together with TIME instead of the JUL keyword.
; This keyword only applies when using Magnetic Local Time coordinates.
;
; TIME: Set this keyword to the time for which you want to overlay the FoV. Use this
; keyword together with DATE instead of the JUL keyword.
; This keyword only applies when using Magnetic Local Time coordinates.
;
; JUL: Set this keyword to the Julian Day Number to use for the plotting of the fields-of-view. Use this
; keyword together instead of the DATE and TIME keyword.
; This keyword only applies when using Magnetic Local Time coordinates.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; NAMES: Set this to a scalar or array holding radar codes of radars of which
; the fov will be plotted.
;
; IDS: Set this to a scalar or array holding numeric ids of radars of which
; the fov will be plotted.
;
; ROTATE: Set this keyword to a number of degree by which to rotate the FoV
; clockwise. Make sure that you give the same number of degrees to
; MAP_PLOT_PANEL and all other plotting routines.
;
; PROJECT_TO_OTHER_HEMI: Set this keyword to project the FoV along a magnetic field
; model into the other hemisphere.
;
; EXTERNAL_MODEL: Set this to a string specifying the external magnetic field
; model used for the tracing of the FoV into the other hemipshere. Can be
; 'none', 't89', 't96', 't01', or 't04s' (default: none).
;
; INTERNAL_MODEL: Set this to a string specifying the internal magnetic field
; model used for the tracing of the FoV into the other hemisphere. Can be
; 'dipole', or 'igrf' (default: igrf).
;
; PARAMS: Parameter input for the external field model.
; If using t89 then it should be a single Kp value,
; if using t96,t01,t04s it should be a 10
; element array or a 1x10 element array. See the documentation
; for the Tsyganenko models to see what parameters must be passed.
;
; CHARSIZE: Set this keyword to the character size used for the
; annotation of the radar. Only takes effect if ANNOTATE is set.
;
; CHARTHICK: Set this keyword to the character thickness used for the
; annotation of the radar. Only takes effect if ANNOTATE is set.
;
; CHARCOLOR: Set this keyword to the character color used for the
; annotation of the radar. Only takes effect if ANNOTATE is set.
;
; ORIENTATION: Set this keyword to a value in degrees by which to rotate
; the radar label clockwise. Only takes effect if ANNOTATE is set.
;
; OFFSETS: This keyword determines the offset of the radar label from
; the radar position, in x and y direction. Default is [.5, -.5]. Set
; this either to a 2-elements vector that will be used for all radars
; or a Nx2 elements array where N is the number of radar FoVs to plot.
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
; Modified by Evan Thomas, Nov, 3, 2010
;-
pro overlay_radar, coords=coords, date=date, time=time, jul=jul, $
	silent=silent, $
	names=names, ids=ids,rotate=rotate, $
	project_to_other_hemi=project_to_other_hemi, external_model=external_model, internal_model=internal_model, param=param, $
	annotate=annotate, charsize=charsize, charthick=charthick, charcolor=charcolor, orientation=orientation, offsets=offsets

common radarinfo
common rad_data_blk

if ~keyword_set(coords) then $
	coords = get_coordinates()

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if ~keyword_set(orientation) then $
	orientation = 0.

if ~keyword_set(charsize) then $
	charsize = 1.

if ~keyword_set(charthick) then $
	charthick = !p.charthick

if ~keyword_set(charcolor) then $
	charcolor = get_foreground()

; we need this later
if coords eq 'mlt' then begin
	in_mlt = !true
	_coords = 'magn'
endif else begin
	_coords = coords
	in_mlt = !false
endelse

; check for jul, date and time keyword no matter what
; just to calculate jul
; might be needed for MLT or tracing
if ~keyword_set(jul) then begin
	if ~keyword_set(time) then $
		time = 1200
	if keyword_set(date) then $
		sfjul, date, time, jul
endif
if ~keyword_set(jul) then begin
	if in_mlt then begin
		prinfo, 'Need to set JUL or DATE/TIME keyword when using MLT coordinate system.'
		return
	endif
	jul = julday(1,1,2020)
endif
caldat, jul, mm, dd, year
yrsec = (jul-julday(1,1,year,0,0,0))*86400.d
s = TimeYrsecToYMDHMS(year, mm, dd, hh, ii, ss, yrsec)

if ~keyword_set(internal_model) then $
	internal_model = 'igrf'

if ~keyword_set(external_model) then $
	external_model = 't96'

if ~keyword_set(param) then begin
	par = fltarr(10)
	if external_model eq 't89' then $
		par[0] = 2.
	if external_model eq 't96' then begin
		par[0] = 2.
		par[1] = -10.
		par[2] = 0.001
		par[3] = 0.001
	endif
endif else $
	par = param

if strlowcase(external_model) eq 'none' then $
	rlim = 100.*!re $
else $
	rlim = 40.*!re

if keyword_set(names) and keyword_set(ids) then begin
	prinfo, 'You can only specify names OR ids'
	return
endif

if ~keyword_set(names) and ~keyword_set(ids) then $
	ids = (*rad_fit_info[rad_fit_get_data_index()]).id

if keyword_set(names) then begin
	radar_infos = make_array(n_elements(names), 8, /float)
	for i=0, n_elements(names)-1 do begin
		tmp = where(network[*].code[0] eq strlowcase(names[i]),count)
		if count eq 0 then begin
			prinfo, 'Could not find station '+strupcase(names[i])+'.'
			return
		endif
		site = RadarYMDHMSGetSite(network[tmp], year, mm, dd, hh, ii, ss)
		if size(site, /type) ne 8 then begin
			prinfo, 'No site found for '+strupcase(names[i])+' at '+format_juldate(jul)
			radar_infos[i,7] = -1.
		endif else begin
			radar_infos[i,0] = network[tmp].id
			radar_infos[i,1] = tmp
			radar_infos[i,2] = site.maxrange
			radar_infos[i,3] = ( keyword_set(nbeams) ? nbeams : site.maxbeam )
			radar_infos[i,4] = site.bmsep
			radar_infos[i,5] = site.geolat
			radar_infos[i,6] = site.geolon
			radar_infos[i,7] = +1.
		endelse
	endfor
	ids = reform(radar_infos[*,0])
endif else if keyword_set(ids) then begin
	radar_infos = make_array(n_elements(ids), 8, /float)
	for i=0, n_elements(ids)-1 do begin
		tmp = where(network[*].id eq ids[i],count)
		if count eq 0 then begin
			prinfo, 'Could not find id '+string(ids[i])+'.'
			return
		endif
		site = RadarYMDHMSGetSite(network[tmp], year, mm, dd, hh, ii, ss)
		if size(site, /type) ne 8 then begin
			prinfo, 'No site found for '+strupcase(names[i])+' at '+format_juldate(jul)
			radar_infos[i,7] = -1.
		endif else begin
			radar_infos[i,0] = network[tmp].id
			radar_infos[i,1] = tmp
			radar_infos[i,2] = site.maxrange
			radar_infos[i,3] = ( keyword_set(nbeams) ? nbeams : site.maxbeam )
			radar_infos[i,4] = site.bmsep
			radar_infos[i,5] = site.geolat
			radar_infos[i,6] = site.geolon
			radar_infos[i,7] = +1.
		endelse
	endfor
endif
ginds = where(radar_infos[*,7] eq 1., nstats)
if nstats eq 0 then $
	return $
else $
	radar_infos = radar_infos[ginds,*]

if keyword_set(offsets) then begin
	if n_elements(offsets) eq 2 then $
		_offsets = rebin(offsets, 2, nstats) $
	else if n_elements(offsets) eq 2*nstats then $
		_offsets = offsets $
	else begin
		prinfo, 'OFFSETS must be 2-element vector or 2xnstats element array.'
		return
	endelse
endif else $
	_offsets = rebin([.5,-3.], 2, nstats)

; check the time is set if tracing
if keyword_set(project_to_other_hemi) and ~keyword_set(jul) then begin
	prinfo, 'Must give JUL or DATE/TIME keyword for field line trace.'
	return
endif

; convert radar position if neccessary
for i=0, nstats-1 do begin
	if keyword_set(project_to_other_hemi) then begin
		if internal_model eq 'dipole' then begin
			tmp = cnvcoord(radar_infos[i,5], radar_infos[i,6], 0.5)
			tmp[0] = -tmp[0]
			if _coords eq 'geog' then $
				tmp = cnvcoord(tmp[0], tmp[1], tmp[2], /geo)
			radar_infos[i,5] = tmp[0]
			radar_infos[i,6] = tmp[1]
		endif else begin
			_lat = radar_infos[i,5]
			_lon = radar_infos[i,6]
			_x = (!re+200.)*cos(_lon*!dtor)*cos(_lat*!dtor)
			_y = (!re+200.)*sin(_lon*!dtor)*cos(_lat*!dtor)
			_z = (!re+200.)*sin(_lat*!dtor)
			in_arr = [ [_x], [_y], [_z] ]
			if _lat gt 0 then $
				_south = 1 $
			else $
				_south = 0
			tarr = [(jul - julday(1,1,1970,0))*86400.d]
			trace2iono, tarr, in_arr, out_arr, $
				in_coord='geo', out_coord='geo', $
				external=external_model, internal=internal_model, $
				par=par, south=_south, rlim=rlim, /km
			if n_elements(out_arr) lt 2 then $
				return
			if sqrt(total((out_arr/!re)^2)) gt 2. then begin
				radar_infos[i,5] = !values.f_nan
				radar_infos[i,6] = !values.f_nan
			endif else begin
				xyz_to_polar, out_arr/!re, mag=alt, theta=glat, phi=glon
				if _coords eq 'magn' then begin
					tmpp = cnvcoord(glat[0], glon[0], .5)
					radar_infos[i,5] = tmpp[0]
					radar_infos[i,6] = tmpp[1]
				endif else begin
					radar_infos[i,5] = glat
					radar_infos[i,6] = glon
				endelse
			endelse
		endelse
	endif else begin
		if _coords eq 'magn' then begin
			tmp = cnvcoord(radar_infos[i,5], radar_infos[i,6], 0.5)
			radar_infos[i,5] = tmp[0]
			radar_infos[i,6] = tmp[1]
		endif
	endelse
endfor

for i=0, nstats-1 do begin

	load_usersym, /circle
	;- plot the radar position
	if in_mlt then begin
		radar_infos[i,6] = mlt(year, yrsec, radar_infos[i,6])
	endif
	tmp = calc_stereo_coords(radar_infos[i,5],radar_infos[i,6],mlt=in_mlt)
	rxx = tmp[0]
	ryy = tmp[1]
	if n_elements(rotate) ne 0 then begin
		_x1 = cos(rotate*!dtor)*rxx - sin(rotate*!dtor)*ryy
		_y1 = sin(rotate*!dtor)*rxx + cos(rotate*!dtor)*ryy
		rxx = _x1
		ryy = _y1
	endif
	plots, rxx, ryy, psym=1, thick=3, noclip=0
	plots, rxx, ryy, psym=8, noclip=0, symsize=0.6

	if keyword_set(annotate) then begin
		tmp = where(network[*].id eq radar_infos[i,0])
		astring = strupcase(network[tmp].code[0])
		; shift the label for FHW a little to the left
		; so that it doesn't interfere with FHE
		; same for sto, bks and ksr
		align = 0.
 		if (radar_infos[i,0] eq 8 or radar_infos[i,0] eq 13 or radar_infos[i,0] eq 16 or radar_infos[i,0] eq 33 or radar_infos[i,0] eq 204 or radar_infos[i,0] eq 206) and ~keyword_set(offsets) then begin
			_offsets[0,i] = -.5
			align = 1.
		endif
		nxoff = _offsets[0,i]*cos(orientation*!dtor) - _offsets[1,i]*sin(orientation*!dtor)
		nyoff = _offsets[0,i]*sin(orientation*!dtor) + _offsets[1,i]*cos(orientation*!dtor)
		xyouts, rxx+nxoff, ryy+nyoff, astring, charthick=10.*charthick, $
			charsize=charsize, orientation=orientation, noclip=0, align=align, color=get_white()
		xyouts, rxx+nxoff, ryy+nyoff, astring, charthick=2.*charthick, $
			charsize=charsize, orientation=orientation, noclip=0, color=charcolor, align=align
	endif

endfor

end
