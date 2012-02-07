pro rad_map_calc_poynting_flux
pro calc_poynting_flux, date=date, time=time, long=long, $
	index=index, north=north, south=south, hemisphere=hemisphere, $
	n_levels=n_levels, scale=scale, min_value=min_value, force=force, fill=fill

common amp_data_blk
common rad_data_blk

; get color preferences
foreground  = get_foreground()
ncolors     = get_ncolors()
bottom      = get_bottom()

if ~keyword_set(scale) then begin
	scale = [-10.,10.]
endif

if ~keyword_set(min_value) then begin
	min_value = 1.
endif

if ~keyword_set(n_levels) then begin
	n_levels = 10
endif

if n_elements(neg_color) eq 0 and n_elements(pos_color) eq 0 then begin
	ctname = get_colortable()
	rad_load_colortable, /bluewhitered
	ncol2 = ncolors/2
	neg_color = round(findgen(n_levels)/(n_levels-1.)*ncol2) + bottom
	neg_color[n_levels-1] -= 7
	pos_color = round(findgen(n_levels)/(n_levels-1.)*(ncol2-1)) + ncol2 + bottom + 1
	pos_color[0] += 7
	reset_colorbar = 1
endif else begin
	if n_elements(neg_color) eq 0 then $
		neg_color = 40
	if n_elements(pos_color) eq 0 then $
		pos_color = 253
endelse

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

; loaded data if user wants
if keyword_set(force) then begin
	rad_map_read, date, hemisphere=hemisphere
	amp_read, date, hemisphere=hemisphere
endif

if rad_map_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No SuperDARN data loaded.'
	return
endif

if amp_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No AMPERE data loaded.'
	return
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for map date.'
	caldat, (*amp_data[int_hemi]).sjuls[0], month, day, year
	ap_date = year*10000L + month*100L + day
	caldat, (*rad_map_data[int_hemi]).sjuls[0], month, day, year
	sd_date = year*10000L + month*100L + day
	if ap_date ne sd_date then begin
		prinfo, 'Data loaded from different days.'
		return
	endif
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
utsec = (jul - julday(1, 1, year, 0, 0))*86400.d

; calculate index from date and time for SuperDARN
dd = min( abs( (*rad_map_data[int_hemi]).mjuls-jul ), sd_index)
; check if time distance is not too big
if dd*1440.d gt 60. then $
	prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

; calculate index from date and time for ampere
dd = min( abs( (*amp_data[int_hemi]).mjuls-jul ), ap_index)
; check if time distance is not too big
if dd*1440.d gt 60. then $
	prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'

; get minimum latitude
latmin = (*rad_map_data[int_hemi]).latmin[sd_index]
; get the order of the fit
order = (*rad_map_data[int_hemi]).fit_order[sd_index]
; get coefficients of the expansion
coeffs = (*(*rad_map_data[int_hemi]).coeffs[sd_index])

; first make grid on which to evaluate the SD measurements
nlons = 24.
nlats = 90.-latmin
lats = fltarr(nlats, nlons)
for l=0, nlons-1 do $
	lats[*,l] = reverse(findgen(90.-latmin) + latmin)
lats = reform(lats, nlons*nlats)
lons = fltarr(nlons, nlats)
for l=0, nlats-1 do $
	lons[*,l] = findgen(nlons)*15. + mlt(year, utsec, 0.)
lons = reform(transpose(lons), nlons*nlats)

; evaluate the sd coefficients, efield is NS, EW
pos = transpose([[lats],[lons]])
dummy = rad_map_eval_grad_vecs( pos, coeffs, latmin, order, e_field=e_field )

; rotate this mlat/mlon coordinate system onto mlt grid from ampere
sd_mlts = round(mlt(replicate(year, nlons*nlats), replicate(utsec, nlons*nlats), lons)) mod 24.
sd_lats = lats

; get ampere data
ap_lats = 90.-reform((*amp_data[int_hemi]).colat[ap_index, *])
inds = where(ap_lats ge latmin, npdat)
ap_lats = ap_lats[inds]
ap_mlts = reform((*amp_data[int_hemi]).mlt[ap_index, inds])

if keyword_set(raw) then begin
	dbn = reform((*amp_data[int_hemi]).dbnorth1[ap_index, inds])
	dbe = reform((*amp_data[int_hemi]).dbeast1[ap_index, inds])
endif else begin
	dbn = reform((*amp_data[int_hemi]).dbnorth2[ap_index, inds])
	dbe = reform((*amp_data[int_hemi]).dbeast2[ap_index, inds])
endelse

;cp & plot, ap_mlts & oplot, sd_mlts, color=230
nlons = 24.
nlats = npdat/nlons

poynting = fltarr(nlats, nlons+1)
pxs = fltarr(nlats, nlons+1)
pys = fltarr(nlats, nlons+1)
; we need to find the corresponding mlts
for l=0, nlons do begin
	apl = (l mod nlons)
	sdinds = where( abs(sd_mlts - ap_mlts[(apl+1)*nlats-1]) lt .1, sdc)
	if sdc ne nlats then $
		prinfo, string(l)+' oh no, wrong dimension. again...'
	; behold the jabberw... no, the poynting flux
	poynting[*,l] = (e_field[0,sdinds]*dbe[apl*nlats:(apl+1)*nlats-1] - e_field[1,sdinds]*dbn[apl*nlats:(apl+1)*nlats-1])*1e-9*1e6
	tmp = calc_stereo_coords(ap_lats[apl*nlats:(apl+1)*nlats-1], ap_mlts[apl*nlats:(apl+1)*nlats-1], /mlt)
	pxs[*,l] = tmp[0,*]
	pys[*,l] = tmp[1,*]
endfor

cp

map_plot_panel, /no_fill, xrange=[-35,35], yrange=[-35,35], coords='mlt', jul=jul

if keyword_set(fill) then begin
	; negative
	contour, poynting, pxs, pys, $
		/overplot, xstyle=4, ystyle=4, noclip=0, $
		thick=thick, c_linestyle=neg_linestyle, c_color=neg_color, c_charsize=c_charsize, c_charthick=c_charthick, $
		levels=scale[0]+(-min_value-.01-scale[0])*findgen(n_levels)/float(n_levels-1.), /follow, $
		path_xy=path_xy, path_info=path_info
	for i = 0, n_elements(path_info) - 1 do begin
		if path_info[i].high_low eq 1b or abs(-path_info[i].value-min_value) lt 0.01 then $ ;
			continue
		s = [indgen(path_info[i].n), 0]
		; Plot the closed paths:
		polyfill, path_xy[*, path_info[i].offset + s], /norm, color=neg_color[path_info[i].level], noclip=0
	endfor
	; positive
	contour, poynting, pxs, pys, $
		/overplot, xstyle=4, ystyle=4, noclip=0, $
		thick=thick, c_linestyle=pos_linestyle, c_color=pos_color, c_charsize=c_charsize, c_charthick=c_charthick, $
		levels=min_value+.01+(scale[1]-min_value-.01)*findgen(n_levels)/float(n_levels-1.), /follow, $
		path_xy=path_xy, path_info=path_info
	for i = 0, n_elements(path_info) - 1 do begin
		if path_info[i].high_low eq 0b or abs(-path_info[i].value-min_value) lt 0.01 then $ ;
			continue
		s = [indgen(path_info[i].n), 0]
		; Plot the closed paths:
		polyfill, path_xy[*, path_info[i].offset + s], /norm, color=pos_color[path_info[i].level], noclip=0
	endfor
endif

if n_elements(reset_colorbar) ne 0 then $
	rad_load_colortable, ctname

amp_overlay_current, index=ap_index, coords='mlt'
amp_overlay_vectors, index=ap_index, coords='mlt'

rad_map_overlay_contours, index=sd_index, coords='mlt', jul=jul, thick=2

end