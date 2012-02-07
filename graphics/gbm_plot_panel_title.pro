pro gbm_plot_panel_title, xmaps, ymaps, xmap, ymap, $
	bar=bar, with_info=with_info, $
	charsize=charsize, charthick=charthick, $
	mag=mag, geo=geo

common gbm_data_blk

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(charthick) then $
	charthick = !p.charthick

foreground  = get_foreground()
background  = get_background()

pos = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info)

fmt = get_format(sardines=sd)
if sd then $
	ypos = pos[3]-.025*charsize $
else $
	ypos = pos[3]+.005

tstr = textoidl($
		(keyword_set(mag) ? '('+string(gbm_info.mlat,format='(F6.1)')+'\circ!5, '+string(gbm_info.mlon,format='(F6.1)')+'\circ!5) magn, ' : '')+$
		(keyword_set(geo) ? '('+string(gbm_info.glat,format='(F6.1)')+'\circ!5, '+string(gbm_info.glon,format='(F6.1)')+'\circ!5) geog, ' : '')+$
		'L = '+string(gbm_info.l_value,format='(F4.1)'))

xyouts, pos[0]+0.01, ypos, $
	strupcase(gbm_info.station)+': '+tstr, /NORMAL, $
	COLOR=background, SIZE=charsize, charthick=6*(!d.name eq 'X' ? 1 : 2)
xyouts, pos[0]+0.01, ypos, $
	strupcase(gbm_info.station)+': '+tstr, /NORMAL, $
	COLOR=foreground, SIZE=charsize, charthick=charthick

end