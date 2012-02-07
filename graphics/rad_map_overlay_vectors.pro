;+
; NAME: 
; RAD_MAP_OVERLAY_VECTORS
;
; PURPOSE: 
; This procedure overlays velocity vectors from a map file on a map.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_OVERLAY_VECTORS
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
; NORTH: Set this keyword to plot the convection pattern for the northern hemisphere.
;
; SOUTH: Set this keyword to plot the convection pattern for the southern hemisphere.
;
; HEMISPHERE: Set this to 1 for the northern and to -1 for the southern hemisphere.
;
; COORDS: Set this to a string containing the name of the coordinate system to plot the map in.
; Allowable systems are geographic ('geog'), magnetic ('magn') and magnetic local time ('mlt').
;
; SCALE: Set this keyword to a 2-element vector containing the minimum and maximum velocity 
; used for coloring the vectors.
;
; MODEL: Set this keyword to include velocity vectors added by the model.
;
; MERGE: Set this keyword to plot velocity vectors
;
; TRUE: Set this keyword to plot velocity vectors
;
; LOS: Set this keyword to plot velocity vectors
;
; IGNORE_BND: Set this keyword to ignore the HM boundary. If this keyword is NOT set, 
; velocity vectors below the HM boundary will be drawn in gray.
;
; GRAD: Set this keyword to plot velocity vectors calculated from the ExB drift using the coefficients
; of the potential.
;
; FACTOR: Set this keyword to alter the length of vectors.
;
; SYMSIZE: Set this keyword to adjust size of dot.
;
; RADAR_IDS: Set this keyword to a numeric id or an array of numeric ids 
; of a radar to only plot vectors originating from that radar.
;
; SILENT: Set this kewyword to surpress warning messages.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding map data.
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
; Edited by Bharat Kunduri, Feb 1, 2012 (added hemisphere term to calc_Stereo_coords in lines 398 and 426)
;-
pro rad_map_overlay_vectors, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	coords=coords, scale=scale, ignore_bnd=ignore_bnd, $
	model=model, merge=merge, true=true, los=los, grad=grad, $
	factor=factor, radar_ids=radar_ids, $
	silent=silent, symsize=symsize, thick=thick, $
	fixed_length=fixed_length, fixed_color=fixed_color, $
	no_plot_model_below_hmb=no_plot_model_below_hmb, $
	no_vector_scale=no_vector_scale

common rad_data_blk
common recent_panel
common radarinfo

if ~keyword_set(symsize) then $
	symsize = .5

if ~keyword_set(thick) then $
	thick = !p.thick

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~strcmp(coords, 'mlt') and ~strcmp(coords, 'magn') then begin
	prinfo, 'Coordinate system must be MLT or MAGN, setting to MLT'
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

if rad_map_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if n_elements(index) gt 0 then begin

	sfjul, date, time, (*rad_map_data[int_hemi]).mjuls[index], /jul_to_date
	parse_date, date, year, month, day
	sfjul, date, time, jul
	
endif else begin

	if ~keyword_set(date) then begin
		if ~keyword_set(silent) then $
			prinfo, 'No DATE given, trying for map date.'
		caldat, (*rad_map_data[int_hemi]).sjuls[0], month, day, year
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
	dd = min( abs( (*rad_map_data[int_hemi]).mjuls-jul ), index)

	; check if time distance is not too big
	if dd*1440.d gt 60. then $
		prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

endelse

if ~keyword_set(scale) then begin
	scale = get_default_range('velocity')
	scale -= min(scale)
endif

if n_elements(scale) ne 2 then begin
	prinfo, 'SCALE must be 2-element vector.'
	return
endif

; get longitude shift
lon_shft = (*rad_map_data[int_hemi]).lon_shft[index]

utsec = (jul - julday(1, 1, year, 0, 0))*86400.d
; calculate lon_shft, i.e. shift magnetic longitude into mlt coordinates
if coords eq 'mlt' then $
	lon_shft += mlt(year, utsec, 0.)*15.

; get boundary data
bnd = (*(*rad_map_data[int_hemi]).bvecs[index])
num_bnd = (*rad_map_data[int_hemi]).bndnum[index]

if ~keyword_set(size) then $
	size = 1.

if ~keyword_set(factor) then $
	factor = 480. $
else $
	factor = factor*480.

if ~keyword_set(radar_ids) then $
	r_ids = [0] $
else $
	r_ids = radar_ids

if ~keyword_set(los) and ~keyword_set(merge) and ~keyword_set(grad) and ~keyword_set(true) then $
	grad = 1

; get color preferences
foreground  = get_foreground()
color_steps = 100.
ncolors     = get_ncolors()
bottom      = get_bottom()

; Set color bar and levels
cin = FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps

ncols = 5

IF keyword_set(model) THEN BEGIN

	model_nvec = (*rad_map_data[int_hemi]).modnum[index]
	if model_nvec le 0 then begin
		prinfo, 'No model vectors found.'
		return
	endif
	; get model velocity data
	model_vec = (*(*rad_map_data[int_hemi]).mvecs[index])
	vdata = make_array(ncols, model_nvec, /float, value=-9999.9)
	vdata[0:1, *] = transpose([[model_vec[*].mlat], [model_vec[*].mlon]])
	vdata[2:3, *] = transpose([[model_vec[*].vel.median], [model_vec[*].azm]])
	npdat = model_nvec
	
ENDIF ELSE BEGIN

	real_nvec  = (*rad_map_data[int_hemi]).vcnum[index]
	if real_nvec le 0 then begin
		prinfo, 'No data vectors found.'
		return
	endif
	st_ids     = (*(*rad_map_data[int_hemi]).gvecs[index])[*].st_id
	if keyword_set(merge) then begin
		real = rad_map_calc_merge_vecs(int_hemi, index, indeces=indeces)
		real_nvec = (real.pos[0,0] eq -9999.9 ? 0 : n_elements(real.pos[0,*]))
		st_ids = st_ids[indeces]
		ncols = 6
		if real[0].pos[0] eq -9999.9 then $
			return
	endif else if keyword_set(true) then $
		real = rad_map_calc_true_vecs(int_hemi, index) $
	else if keyword_set(los) then $
		real = rad_map_calc_los_vecs(int_hemi, index) $
	else if keyword_set(grad) then $
		real = rad_map_calc_grad_vecs(int_hemi, index)
	vdata = make_array(ncols, real_nvec, /float, value=-9999.9)
	vdata[0:1, *] = real.pos
	vdata[2:3, *] = real.vectors
	if keyword_set(merge) then $
		vdata[4:5, *]   = st_ids $
	else $
		vdata[4, *]   = st_ids
	npdat = real_nvec

	; plot radar positions
	; that provides an easy view of who
	; contributed data.
	load_usersym, /circle
	sinds = sort(st_ids)
	uids = st_ids[ sinds[ uniq( st_ids[sinds] ) ] ]
	for i=0, n_elements(uids)-1 do begin
		caldat, jul, mm, dd, yy, hh, ii, ss
		rtmp = radargetradar(network, uids[i])
		site = radarymdhmsgetsite(rtmp, yy, mm, dd, hh, ii, ss)
		ttt = cnvcoord(site.geolat, site.geolon, 0.)
		mlat = ttt[0]
		mlon = ttt[1]
		if coords eq 'mlt' then $
			mlon = mlt(year, utsec, mlon)
		tt = calc_stereo_coords(mlat, mlon, mlt=(coords eq 'mlt'))
		plots, tt[0], tt[1], psym=1, thick=3, noclip=0
		plots, tt[0], tt[1], psym=8, noclip=0, symsize=0.6

		astring = strupcase(rtmp.code[0])
		; shift the label for FHW a little to the left
		; so that it doesn't interfere with FHE
		; same for sto, bks and ksr
		align = 0.
		offset = [.5,-3.]
			if (rtmp.id eq 8 or rtmp.id eq 13 or rtmp.id eq 16 or rtmp.id eq 33 or rtmp.id eq 204 or rtmp.id eq 206) then begin
				offset[0] = -.5
			align = 1.
		endif
		xyouts, tt[0]+offset[0], tt[1]+offset[1], astring, charthick=2.*!p.charthick, $
			charsize=.8*get_charsize(rxmaps, rymaps), orientation=orientation, noclip=0, align=align, color=get_white()
		xyouts, tt[0]+offset[0], tt[1]+offset[1], astring, charthick=!p.charthick, $
			charsize=.8*get_charsize(rxmaps, rymaps), orientation=orientation, noclip=0, align=align
	endfor

ENDELSE

; load circle 
load_usersym, /circle

no_plot_count = 0L

;vdata(0,*)=gmlong  vdata(1,*)=gmlat  vdata(2,*)=magnitude  vdata(3,*)=azimuth  vdata(4,*)=radar_id
if npdat gt 0 then begin
  FOR i=0, npdat-1 DO BEGIN
  
    if r_ids[0] ne 0 then begin
			if keyword_set(merge) then begin
				dd = where(r_ids eq vdata[4,i] or r_ids eq vdata[5,i], cc)
				if cc eq 0 then $
					continue
			endif else begin
				dd = where(r_ids eq vdata[4,i], cc)
				if cc eq 0 then $
					continue
			endelse
		endif

		lat = vdata[0,i]
		lon = ( vdata[1,i] + 360. ) mod 360.
		
		; check if vector lies underneath boundary
		; if so, plot it gray
		vec_col = cin[(MAX(where(lvl le ((vdata[2,i] > scale[0]) < scale[1]))) > 0)]
		if ~keyword_set(ignore_bnd) then begin
			dd = min(abs(bnd[*].lon-lon), minind)
			IF abs(lat) LT abs(bnd[minind].lat) THEN begin
				if keyword_set(no_plot_model_below_hmb) then begin
					no_plot_count += 1L
					continue
				endif
				vec_col = get_gray()
			endif
		endif
		if n_elements(fixed_color) gt 0 then $
			vec_col = fixed_color

		if coords eq 'mlt' then $
			plon = (lon+lon_shft)/15. $
		else $
			plon = (lon+lon_shft)
		lon_rad = (lon + lon_shft)*!dtor
		tmp = calc_stereo_coords(lat, plon, hemisphere=hemisphere, mlt=(coords eq 'mlt'))
		x_pos_vec = tmp[0]
		y_pos_vec = tmp[1]

		vec_azm = vdata[3,i]*!dtor + ( hemisphere lt 0. ? !pi : 0. )
		vec_len = (keyword_set(fixed_length) ? $
			factor*abs(fixed_length)/!re/1e3 : factor*vdata[2,i]/!re/1e3 );*hemisphere

		; Find latitude of end of vector
		vec_lat = asin( $
			( $
				( sin(lat*!dtor)*cos(vec_len) + $
					cos(lat*!dtor)*sin(vec_len)*cos(vec_azm) $
				) < 1. $
			) > (-1.) $
		)*!radeg

		; Find longitude of end of vector
		delta_lon = ( $
			atan( sin(vec_azm)*sin(vec_len)*cos(lat*!dtor), cos(vec_len) - sin(lat*!dtor)*sin(vec_lat*!dtor) ) $
		)

		if coords eq 'mlt' then $
			vec_lon = (lon_rad + delta_lon)*!radeg/15. $
		else $
			vec_lon = (lon_rad + delta_lon)*!radeg

		; Find x and y position of end of vectors
		tmp = calc_stereo_coords(vec_lat, vec_lon, hemisphere=hemisphere, mlt=(coords eq 'mlt'))
		new_x = tmp[0]
		new_y = tmp[1]

		oplot, [x_pos_vec], [y_pos_vec], psym=8, $
			symsize=1.4*symsize, color=get_background(), noclip=0
		oplot, [x_pos_vec,new_x], [y_pos_vec,new_y],$
			thick=2.*thick, COLOR=get_background(), noclip=0
		oplot, [x_pos_vec], [y_pos_vec], psym=8, $
			symsize=symsize, color=vec_col, noclip=0
		oplot, [x_pos_vec,new_x], [y_pos_vec,new_y],$
			thick=thick, COLOR=vec_col, noclip=0

  ENDFOR
ENDIF

if keyword_set(model) then $
	xyouts, !x.crange[1]-.05*(!x.crange[1]-!x.crange[0]), !y.crange[0]+.075*(!y.crange[1]-!y.crange[0]), $
		textoidl('n_{md}=')+strtrim(string(npdat-no_plot_count),2)+' pts', align=1, charsize=.75*get_charsize(rxmaps, rymaps) $
else $
	xyouts, !x.crange[1]-.05*(!x.crange[1]-!x.crange[0]), !y.crange[0]+.025*(!y.crange[1]-!y.crange[0]), $
		textoidl('n_{vc}=')+strtrim(string(npdat-no_plot_count),2)+' pts', align=1, charsize=.75*get_charsize(rxmaps, rymaps)

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

	xyouts, xorig, yorig+.02*(!y.crange[1]-!y.crange[0]), strtrim(string(scale[1],format='(I)'),2)+'m/s', $
		charsize=.75*get_charsize(rxmaps, rymaps), align=.1

endif

end
