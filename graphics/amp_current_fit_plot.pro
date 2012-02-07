pro amp_current_fit_plot, date=date, time=time, index=index, $
	north=north, south=south, hemisphere=hemisphere, $
	r1_only=r1_only, r1_color=r1_color, $
	r2_only=r2_only, r2_color=r2_color, $
	include_jr=include_jr

common amp_data_blk

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
		time = 1200

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

if n_elements(r1_color) lt 1 then $
	r1_color = get_red()

if n_elements(r2_color) lt 1 then $
	r2_color = get_blue()

dlat = 5.
w1 = exp( -( (findgen(12)-6.)/3. )^2 )
wei = [w1, w1]
nfit = 1000.
xx = findgen(24)
nxx = findgen(nfit)/(nfit-1.)*24.

; current locations
yy_r1 = reform((*amp_data[int_hemi]).jr_fit_pos_r1[index,*,0])
yy_r2 = reform((*amp_data[int_hemi]).jr_fit_pos_r2[index,*,0])

; current locations in stereo coords
inp_r1 = calc_stereo_coords(90.-yy_r1, xx, /mlt)
inp_r2 = calc_stereo_coords(90.-yy_r2, xx, /mlt)

; initial fit at 1 hour MLT resolution
yfiti_r1  = mfiti(xx,  (*amp_data[int_hemi]).jr_fit_coeffs_r1[index,0:2,0])
yfiti_r2  = mfiti(xx,  (*amp_data[int_hemi]).jr_fit_coeffs_r2[index,0:2,0])
; initial fit in high-MLT resolution
cyfiti_r1 = mfiti(nxx, (*amp_data[int_hemi]).jr_fit_coeffs_r1[index,0:2,0])
cyfiti_r2 = mfiti(nxx, (*amp_data[int_hemi]).jr_fit_coeffs_r2[index,0:2,0])
; final fit in high-MLT resolution
yfit_r1   = mfit (nxx, (*amp_data[int_hemi]).jr_fit_coeffs_r1[index,0:2*(*amp_data[int_hemi]).jr_fit_order[index],1])
yfit_r2   = mfit (nxx, (*amp_data[int_hemi]).jr_fit_coeffs_r2[index,0:2*(*amp_data[int_hemi]).jr_fit_order[index],1])

if int_hemi eq 0 then $
	xrange = [60,90] $
else $
	xrange = [-60,-90]

clear_page

plot, [0,0], /yno, charsize=get_charsize(1,1), $
	yrange=xrange, /nodata, /xstyle, xrange=[0,24], xticks=4, $
	xtitle='MLT', ytitle=textoidl('Latitude [\circ]'), pos=df(2,1,0,0,aspect=1.)

pos = df(2,1,0,0)
fmt = get_format(sardines=sd)
if sd then $
	ypos = pos[3]-.03 $
else $
	ypos = pos[3]+.01
xyouts, pos[0]+0.01, ypos, $
	( keyword_set(north) ? 'Northern' : 'Southern' )+' Hemisphere', /NORMAL, $
	COLOR=get_foreground(), SIZE=charsize, charthick=charthick

if ~keyword_set(r2_only) then $
	oplot, xx, 90.-yy_r1, color=r1_color, linestyle=2
if ~keyword_set(r1_only) then $
	oplot, xx, 90.-yy_r2, color=r2_color, linestyle=2

; throw away all points that are more than 2 degrees of circle fit
ginds_r1 = where( abs( yy_r1-yfiti_r1 ) le dlat and finite(yy_r1), cc_r1, complement=ninds_r1, ncomplement=nin_r1)
ginds_r2 = where( abs( yy_r2-yfiti_r2 ) le dlat and finite(yy_r2), cc_r2, complement=ninds_r2, ncomplement=nin_r2)

; plot input points with size of weights
load_usersym, /circle
if ~keyword_set(r2_only) then $
	for p=0, cc_r1-1 do $
		plots, xx[ginds_r1[p]], 90.-yy_r1[ginds_r1[p]], psym=8, color=r1_color, symsize=sqrt(wei[ginds_r1[p]])
if ~keyword_set(r1_only) then $
	for p=0, cc_r2-1 do $
		plots, xx[ginds_r2[p]], 90.-yy_r2[ginds_r2[p]], psym=8, color=r2_color, symsize=sqrt(wei[ginds_r2[p]])

; overplot points that were not included
load_usersym, /circle, /no_fill
if ~keyword_set(r2_only) then $
	if nin_r1 gt 0 then $
		plots, xx[ninds_r1], 90.-yy_r1[ninds_r1], psym=8, color=r1_color
if ~keyword_set(r1_only) then $
	if nin_r2 gt 0 then $
		plots, xx[ninds_r2], 90.-yy_r2[ninds_r2], psym=8, color=r2_color

; overplot initial and final fit for R1
if cc_r1 gt (*amp_data[int_hemi]).jr_fit_order[index]*2+1 then begin
	if ~keyword_set(r2_only) then begin
		oplot, nxx, 90.-cyfiti_r1, color=get_gray(), linestyle=2
		plots, nxx, 90.-yfit_r1, color=r1_color
	endif
	fit_r1  = calc_stereo_coords(90.-yfit_r1, nxx, /mlt)
	fiti_r1 = calc_stereo_coords(90.-cyfiti_r1, nxx, /mlt)
endif else begin
	fit_r1 = -1.
endelse

; overplot initial and final fit for R2
if cc_r2 gt (*amp_data[int_hemi]).jr_fit_order[index]*2+1 then begin
	if ~keyword_set(r1_only) then begin
		oplot, nxx, 90.-cyfiti_r2, color=get_gray()
		oplot, nxx, 90.-yfit_r2, color=r2_color
	endif
	fit_r2  = calc_stereo_coords(90.-yfit_r2, nxx, /mlt)
	fiti_r2 = calc_stereo_coords(90.-cyfiti_r2, nxx, /mlt)
endif else begin
	fit_r2 = -1.
endelse

map_plot_panel, date=date, time=time, coords='mlt', /no_coast, pos=df(2,1,1,0,aspect=1.), /silent

if keyword_set(include_jr) then $
	amp_overlay_current, date=date, time=time, coords='mlt', index=index, $
		north=north, south=south, hemisphere=hemisphere, neg_color=get_black(), pos_color=get_black()

amp_plot_title, pos=df(2,1,1,0), index=index, /silent

if ~keyword_set(r2_only) then begin
	load_usersym, /circle, /no_fill
	if nin_r1 gt 0 then begin
		plots, inp_r1[*,ninds_r1], psym=8, color=get_foreground(), thick=1.5*!p.thick
		plots, inp_r1[*,ninds_r1], psym=8, color=r1_color
	endif
	load_usersym, /circle
	for p=0, cc_r1-1 do begin
		plots, inp_r1[0,ginds_r1[p]], inp_r1[1,ginds_r1[p]], psym=8, color=get_foreground(), symsize=sqrt(wei[ginds_r1[p]])+.3
		plots, inp_r1[0,ginds_r1[p]], inp_r1[1,ginds_r1[p]], psym=8, color=r1_color, symsize=sqrt(wei[ginds_r1[p]])
	endfor
	if fit_r1[0] ne -1. then begin
		plots, fiti_r1, color=get_gray(), linestyle=2
		plots, fit_r1, color=r1_color
	endif
endif

if ~keyword_set(r1_only) then begin
	load_usersym, /circle, /no_fill
	if nin_r2 gt 0 then begin
		plots, inp_r2[*,ninds_r2], psym=8, color=get_foreground(), thick=1.5*!p.thick
		plots, inp_r2[*,ninds_r2], psym=8, color=r2_color
	endif
	load_usersym, /circle
	for p=0, cc_r2-1 do begin
		plots, inp_r2[0,ginds_r2[p]], inp_r2[1,ginds_r2[p]], psym=8, color=get_foreground(), symsize=sqrt(wei[ginds_r2[p]])+.3
		plots, inp_r2[0,ginds_r2[p]], inp_r2[1,ginds_r2[p]], psym=8, color=r2_color, symsize=sqrt(wei[ginds_r2[p]])
	endfor
	if fit_r2[0] ne -1. then begin
		plots, fiti_r2, color=get_gray()
		plots, fit_r2, color=r2_color
	endif
endif

info_str = 'Order: '+string((*amp_data[int_hemi]).jr_fit_order[index],format='(I1)')
xyouts, !x.crange[0]-.01*(!x.crange[1]-!x.crange[0]), !y.crange[0]+.01*(!y.crange[1]-!y.crange[0]), $
	info_str, orient=90, charsize=get_charsize(1,3)


end