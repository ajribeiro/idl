;+
; NAME: 
; AMP_OVERLAY_VECTORS
;
; PURPOSE: 
; This procedure overlays magnetic perturbation vectors from an AMPERE file on a map.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; AMP_OVERLAY_VECTORS
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
; INDEX: The index number of the map to plot. If not set, that map with the timestamp closest
; to the gien input date will be plotted.
;
; NORTH: Set this keyword to plot the magnetic perturbation vectors for the northern hemisphere.
;
; SOUTH: Set this keyword to plot the magnetic perturbation vectors for the southern hemisphere.
;
; HEMISPHERE: Set this to 1 for the northern and to -1 for the southern hemisphere.
;
; COORDS: Set this to a string containing the name of the coordinate system to plot the map in.
; Allowable systems are geographic ('geog'), magnetic ('magn') and magnetic local time ('mlt').
;
; SCALE: Set this keyword to a 2-element vector containing the minimum and maximum magnetic perturbation  
; used for coloring the vectors.
;
; FACTOR: Set this keyword to alter the length of vectors.
;
; SIZE: Set this keyword to adjust thickness of vector and size of dot.
;
; SILENT: Set this kewyword to surpress warning messages.
;
; COMMON BLOCKS:
; AMP_DATA_BLK: The common block holding magnetic perturbation data.
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
; Based on Adrian Grocott's OVERLAY_VECTORS.
; Written by Lasse Clausen, Dec, 22 2009
;-
pro amp_overlay_vectors, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, scale=scale, $
	factor=factor, thick=thick, symsize=symsize, $
	fixed_length=fixed_length, fixed_color=fixed_color, $
	raw=raw, fit=fit, $
	silent=silent, no_vector_scale=no_vector_scale

common amp_data_blk
common recent_panel

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'mlt',/fold) and ~strcmp(coords, 'magn',/fold) then begin
	prinfo, 'Coordinate system must be MLT or MAGN. Setting to MLT'
	coords = 'mlt'
endif

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

if amp_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if n_elements(index) gt 0 then begin

	sfjul, date, time, (*amp_data[int_hemi]).mjuls[index], /jul_to_date
	parse_date, date, year, month, day
	sfjul, date, time, jul

endif else begin

	if ~keyword_set(date) then begin
		if ~keyword_set(silent) then $
			prinfo, 'No DATE given, trying for map date.'
		caldat, (*amp_data[int_hemi]).sjuls[0], month, day, year
		date = year*10000L + month*100L + day
	endif
	parse_date, date, year, month, day

	if n_elements(time) lt 1 then $
		time = 0000

	if n_elements(time) gt 1 then begin
		if ~keyword_set(silent) then $
			prinfo, 'TIME must be a scalar, selecting first element: '+string(time[0], format='(I4)')
		time = time[0]
	endif
	sfjul, date, time, jul, long=long

	; calculate index from date and time
	dd = min( abs( (*amp_data[int_hemi]).mjuls-jul ), index)

	; check if time distance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

endelse

if strcmp(coords,'mlt',/fold) then $
	mlt0inmlonh = 0. $
else $
	mlt0inmlonh = -mlt(year,(jul-julday(1,1,year,0))*86400.d,0.)

if ~keyword_set(scale) then begin
	scale = [0,300]
endif

if ~keyword_set(fit) and ~keyword_set(raw) then begin
	prinfo, 'Must choose whether to plot raw or fitted data, choosing fit.'
	fit = 1
	raw = 0
endif

; utsec = (jul - julday(1, 1, year, 0, 0))*86400.d

if ~keyword_set(symsize) then $
	symsize = .5

if ~keyword_set(thick) then $
	thick = !p.thick

if ~keyword_set(factor) then $
	factor = 480. $
else $
	factor = factor*480.

; get color preferences
foreground  = get_foreground()
color_steps = 100.
ncolors     = get_ncolors()
bottom      = get_bottom()

; Set color bar and levels
cin = FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps

colats = reform((*amp_data[int_hemi]).colat[index, *])
mlts   = reform((*amp_data[int_hemi]).mlt[index, *])
if keyword_set(raw) then begin
	dbn = reform((*amp_data[int_hemi]).dbnorth1[index, *])
	dbe = reform((*amp_data[int_hemi]).dbeast1[index, *])
endif else begin
	dbn = reform((*amp_data[int_hemi]).dbnorth2[index, *])
	dbe = reform((*amp_data[int_hemi]).dbeast2[index, *])
endelse

; number of vectors
npdat = (*amp_data[int_hemi]).nlat[index] * (*amp_data[int_hemi]).nlon[index]

; load circle 
load_usersym, /circle

  FOR i=0, npdat-1 DO BEGIN

		plat = 90.-colats[i]
		plon   = (mlts[i] + mlt0inmlonh)*(strcmp(coords,'mlt',/fold) ? 1. : 15.)
		plen = sqrt(dbn[i]^2 + dbe[i]^2)
		pazm = atan(dbe[i], dbn[i])

		; check if vector lies underneath boundary
		; if so, plot it gray
		if n_elements(fixed_color) eq 0 then $
			_vec_col = cin[(MAX(where(lvl le ((plen > scale[0]) < scale[1]))) > 0)] $
		else $
			_vec_col = vec_col

		tmp = calc_stereo_coords(plat, plon, mlt=strcmp(coords,'mlt',/fold))
		x_pos_vec = tmp[0]
		y_pos_vec = tmp[1]

		vec_azm = pazm;  + ( hemisphere lt 0. ? !pi : 0. )
		vec_len = ( keyword_set(fixed_length) ? fixed_length : plen )*factor/!re/1e3 ;*hemisphere

		; Find latitude of end of vector
		vec_lat = asin( $
			( $
				( sin(plat*!dtor)*cos(vec_len) + $
					cos(plat*!dtor)*sin(vec_len)*cos(vec_azm) $
				) < 1. $
			) > (-1.) $
		)*!radeg

		; Find longitude of end of vector
		delta_lon = ( $
			atan( sin(vec_azm)*sin(vec_len)*cos(plat*!dtor), cos(vec_len) - sin(plat*!dtor)*sin(vec_lat*!dtor) ) $
		)

		vec_lon = plon + delta_lon*!radeg/(strcmp(coords,'mlt',/fold) ? 15. : 1.)

		; Find x and y position of end of vectors
		tmp = calc_stereo_coords(vec_lat, vec_lon, mlt=strcmp(coords,'mlt',/fold))
		new_x = tmp[0]
		new_y = tmp[1]

		oplot, [x_pos_vec], [y_pos_vec], psym=8, $
			symsize=1.4*symsize, color=get_background(), noclip=0
		oplot, [x_pos_vec,new_x], [y_pos_vec,new_y],$
			thick=2.*thick, COLOR=get_background(), noclip=0
		oplot, [x_pos_vec], [y_pos_vec], psym=8, $
			symsize=symsize, color=_vec_col, noclip=0
		oplot, [x_pos_vec,new_x], [y_pos_vec,new_y],$
 			thick=thick, COLOR=_vec_col, noclip=0

  ENDFOR

if ~keyword_set(no_vector_scale) then begin

	xorig = !x.crange[1]-.13*(!x.crange[1]-!x.crange[0])
	yorig = !y.crange[0]+.125*(!y.crange[1]-!y.crange[0])
	tmp = calc_stereo_coords(xorig, yorig, hemisphere=hemisphere, mlt=(coords eq 'mlt'), /inverse)
	latorig = tmp[0]
	lonorig = tmp[1]*(coords eq 'mlt' ? 15. : 1.) ; always in degree!
	;print, latorig, lonorig, tmp[1]
	tmp = calc_stereo_coords(xorig+10., yorig, hemisphere=hemisphere, mlt=(coords eq 'mlt'), /inverse)
	latdest = tmp[0]
	londest = tmp[1]*(coords eq 'mlt' ? 15. : 1.) ; always in degree!
	;print, latdest, londest, tmp[1]
	vec_azm = calc_vector_bearing( [latorig, latdest], [lonorig, londest] )*!dtor
	;print, vec_azm
	vec_len = factor*scale[1]/!re/1e3
	;print, vec_len
	; Find latitude of end of vector
	vec_lat = asin( $
		( $
			( sin(latorig*!dtor)*cos(vec_len) + $
				cos(latorig*!dtor)*sin(vec_len)*cos(vec_azm) $
			) < 1. $
		) > (-1.) $
	)*!radeg
	; Find longitude of end of vector
	delta_lon = ( $
		atan( sin(vec_azm)*sin(vec_len)*cos(latorig*!dtor), cos(vec_len) - sin(latorig*!dtor)*sin(vec_lat*!dtor) ) $
	)
	if coords eq 'mlt' then $
		vec_lon = (lonorig + delta_lon*!radeg)/15. $
	else $
		vec_lon = lonorig + delta_lon*!radeg
	; Find x and y position of end of vectors
	tmp = calc_stereo_coords(vec_lat, vec_lon, mlt=(coords eq 'mlt'))
	new_x = tmp[0]
	new_y = tmp[1]

	;print, vec_lat, vec_lon
	;print, xorig, yorig
	;print, new_x, new_y

	oplot, [xorig], [yorig], psym=8, $
		symsize=1.4*symsize, color=get_background(), noclip=0
	oplot, [xorig,new_x], [yorig,new_y],$
		thick=2*thick, COLOR=get_background(), noclip=0
	oplot, [xorig], [yorig], psym=8, $
		symsize=symsize, color=253, noclip=0
	oplot, [xorig,new_x], [yorig,new_y],$
		thick=thick, COLOR=253, noclip=0

	xyouts, xorig, yorig+.02*(!y.crange[1]-!y.crange[0]), strtrim(string(scale[1],format='(I)'),2)+'nT', $
		charsize=.75*get_charsize(rxmaps, rymaps), align=.1

endif

end
