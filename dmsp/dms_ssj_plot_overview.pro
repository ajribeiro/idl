pro dms_ssj_plot_overview, date=date, time=time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, mark_interval=mark_interval

common dms_data_blk

if ~keyword_set(yrange) then $
	yrange = [-31,31]

if ~keyword_set(xrange) then $
	xrange = [-46,46]

aspect = float(xrange[1]-xrange[0])/float(yrange[1]-yrange[0])

if ~keyword_set(coords) then $
	coords = 'mlt'

if ~keyword_set(mark_interval) then $
	mark_interval = 2./60.

clear_page
set_format, /sard

dms_ssj_plot_spectrum_panel, 1, 3, 0, 1, /bar, /no_title, /electrons, $
	date=date, time=time, long=long, scale=escale, mark_interval=mark_interval
plot_colorbar, 1, 3, 0, 1, /no_title, scale=escale, param='power', legend='Log Energy Flux (electrons)'


dms_ssj_plot_spectrum_panel, 1, 3, 0, 2, /bar, /no_title, /ions, $
	date=date, time=time, long=long, scale=iscale, mark_interval=mark_interval, /last
plot_colorbar, 1, 3, 0, 2, /no_title, scale=iscale, param='power', legend='Log Energy Flux (ions)'

pos = define_panel(2, 3, 1, 0, aspect=aspect, /no_title, /bar) - [0.05, 0, 0.05, 0]
dms_track_plot_panel, position=pos, coords=coords, xrange=xrange, yrange=yrange, $
	date=date, time=time, long=long, mark_interval=mark_interval, mark_charsize=.55*(strupcase(!d.name) eq 'X' ? 2. : 1.)

xyouts, .25, .85, 'F'+string(dms_ssj_info.sat,format='(I02)'), charthick=3, charsize=3, /norm, align=.5
xyouts, .25, .75, format_date(date, /hum)+'!C'+format_time(time), charthick=2, charsize=2, /norm, align=.5

end