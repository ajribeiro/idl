pro radrt_map, date, radar

common rt_data_blk
common rad_data_blk


rad_fit_read, date, radar, /filter

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	stop
; juls = (*rad_fit_data[data_index]).juls[uniq(sort((*rad_fit_data[data_index]).juls))]
; caldat, (*rad_fit_data[data_index]).juls, month, day, year, hour, minute
; ttime = hour*100L + minute
; hour = hour[uniq(ttime, sort(ttime))]
; minute = minute[uniq(ttime, sort(ttime))]
; ttime = 0

dir = '~/Desktop/'
for it=0,48 do begin;n_elements(hour)-1 do begin
	time = hour[it]*100L + minute[it]
	timert = hour[it] + round(minute[it]/30.)*.5
	timert = floor(timert)*100L + round(timert - floor(timert))*30L MOD 2400L
	print, time, timert

	; Set plot area
	ps_open, 'tmp.ps'
	set_format, /landscape
	clear_page
	position = define_panel(1,1,0,0, /bar)
	map_plot_panel, 1, 1, 0, 0, date=date, coords='magn', /bar, /iso, /no_fill, yrange=[-50., 0.]

	rad_fit_overlay_scan, time=time, date=date, param='power', coords='magn'

	overlay_rt, timert, thick=2

	overlay_fov, names=radar, coords='magn', date=date, /no_fill, nranges=rt_info.ngates

	ps_close
	spawn, 'ps2png.sh ~/tmp.ps'
	spawn, 'rm -f ~/tmp.ps'
	filen = strtrim(string(it,format='(I04)'),2)
	spawn, 'mv tmp.png '+filen+'.png' 
endfor

spawn, 'convert -delay 50 ????.png '+dir+'radrt_map.gif'
spawn, 'rm -f ????.png'
	


end