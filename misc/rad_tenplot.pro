pro rad_tenplot, date

common rad_data_blk

if n_params() eq 0 then $
	date = format_juldate(systime(/julian), /short_date)

; load AJ's colortable
rad_load_colortable, /default

; what radars to include
radars = ['kap','gbr','sas','sto','bks','wal','fhw','fhe','cvw','cve']
longrd = ['Kapuskasing','Goose Bay','Saskatoon','Stokkseyri','Blackstone','Wallops Island','Fort Hays West','Fort Hays East','Christmas Valley West','Christmas Valley East']
; what beams
beams  = [  7,    7,    7,    7,   15,    7,     7,    7,   12,   12]
; what vel scale
wvelc  = [  0,    0,    0,    0,    1,    1,     1,    1,    1,    1]
; what is ground scatter
wgrnd  = [  0,    0,    0,    0,    1,    1,     1,    1,    1,    1]

; Mike's special velocity scale
vel_scale = [ $
	; high lats
	[-1500,-1000,-500,-100,0,100,500,1000,1500], $
	;low lats
	[ -300, -200,-100, -50,0, 50,100, 200, 300] $
]

; power threshold
min_power = 3.

;ground scatter limits highlats, lowlats
gnd_lim = [25, 15]
set_colorsteps, 8
set_format, /sardines

nrad = n_elements(radars)

for i=0,nrad-1 do begin
	rad_fit_set_data_index, -1
	rad_fit_read, date, radars[i], /force
	if (*rad_fit_info[0]).nrecs eq 0L then begin
		ps_open, '~/'+radars[i]+string(date,format='(I8)')+'.ps'
		rad_fit_plot_rti_empty, date=date, time=[0,2400], param=['power','velocity'], beam=beams[i], titlestr=longrd[i]+' (no data)'
		ps_close,/no_file
		continue
	endif
	; plot a title and colorbar for all panels
	if (*rad_fit_info[0]).fitex then $
		fitstr = 'fitEX'
	if (*rad_fit_info[0]).fitacf then $
		fitstr = 'fitACF'
	if (*rad_fit_info[0]).fit then $
		fitstr = 'fit'
	beamstr = string(beams[i], format='(I02)')
	ps_open, '~/'+radars[i]+string(date,format='(I8)')+'.ps'
	; set charsize of info panels smaller
	ichars = get_charsize(1, 2)
	rad_fit_plot_scan_id_info_panel, 1, 2, 0, 0, /bar, $
		charsize=ichars, beam=beams[i], $
		/with_info, charthick=4
	rad_fit_plot_tfreq_panel, 1, 2, 0, 0, /bar, /horizontal_ytitle, ystyle=9, $
		charsize=ichars, beam=beams[i], /info, yrange=[10,16], yticks=1, yminor=3, linethick=4
	rad_fit_plot_nave_panel, 1, 2, 0, 0, /bar, /horizontal_ytitle, $
		charsize=ichars, beam=beams[i], /info, linestyle=1, $
		/rightyaxis, yticks=1, yminor=3, linethick=4
	rad_fit_plot_noise_panel, 1, 2, 0, 0, /bar, /horizontal_ytitle, $
		charsize=ichars, beam=beams[i], /info, linethick=4, $
		/search, /rightyaxis, linestyle=1
	rad_fit_plot_noise_panel, 1, 2, 0, 0, /bar, /horizontal_ytitle, $
		charsize=ichars, beam=beams[i], /info, title='!5Beam '+beamstr+'!3', linethick=4, $
		/sky
	rad_fit_plot_rti_panel, 1, 2, 0, 0, param='power', $
		scale=[0,32], beam=beams[i], /with_info, /bar, min_power=min_power
	plot_colorbar, 1, 2, 0, 0, param='power', scale=[0,32], $
		/with_info, /bar
	rad_fit_plot_rti_panel, 1, 2, 0, 1, param='velocity', $
		sc_values=vel_scale[*,wvelc[i]], beam=beams[i], ground=gnd_lim[wgrnd[i]], $
		/with_info, /bar, /last, min_power=min_power
	plot_colorbar, 1, 2, 0, 1, param='velocity', sc_values=vel_scale[*,wvelc[i]], $
		ground=gnd_lim[wgrnd[i]], /with_info, /bar
	titlestr = (*rad_fit_info[0]).name + $
		' ('+fitstr+')'
	rad_fit_plot_title, ' ', titlestr, scan_id=scan_id, date=date, time=time
	ps_close,/no_file
endfor

rad_fit_clear_data

for i=0,nrad-1 do begin
	rad_fit_set_data_index, -1
	rad_fit_read, date, radars[i], /filter, /force
	if (*rad_fit_info[0]).nrecs eq 0L then begin
		ps_open, '~/'+radars[i]+string(date,format='(I8)')+'.f.ps'
		rad_fit_plot_rti_empty, date=date, time=[0,2400], param=['power','velocity'], beam=beams[i], titlestr=longrd[i]+' (no data)'
		ps_close,/no_file
		continue
	endif
	; plot a title and colorbar for all panels
	if (*rad_fit_info[0]).fitex then $
		fitstr = 'fitEX'
	if (*rad_fit_info[0]).fitacf then $
		fitstr = 'fitACF'
	if (*rad_fit_info[0]).fit then $
		fitstr = 'fit'
	beamstr = string(beams[i], format='(I02)')
	ps_open, '~/'+radars[i]+string(date,format='(I8)')+'.f.ps'
	; set charsize of info panels smaller
	ichars = get_charsize(1, 2)
	rad_fit_plot_scan_id_info_panel, 1, 2, 0, 0, /bar, $
		charsize=ichars, beam=beams[i], $
		/with_info, charthick=4
	rad_fit_plot_tfreq_panel, 1, 2, 0, 0, /bar, /horizontal_ytitle, ystyle=9, $
		charsize=ichars, beam=beams[i], /info, yrange=[10,16], yticks=1, yminor=3, linethick=4
	rad_fit_plot_nave_panel, 1, 2, 0, 0, /bar, /horizontal_ytitle, $
		charsize=ichars, beam=beams[i], /info, linestyle=1, $
		/rightyaxis, yticks=1, yminor=3, linethick=4
	rad_fit_plot_noise_panel, 1, 2, 0, 0, /bar, /horizontal_ytitle, $
		charsize=ichars, beam=beams[i], /info, linethick=4, $
		/search, /rightyaxis, linestyle=1
	rad_fit_plot_noise_panel, 1, 2, 0, 0, /bar, /horizontal_ytitle, $
		charsize=ichars, beam=beams[i], /info, title='!5Beam '+beamstr+'!3', linethick=4, $
		/sky
	rad_fit_plot_rti_panel, 1, 2, 0, 0, param='power', $
		scale=[0,32], beam=beams[i], /with_info, /bar, min_power=min_power
	plot_colorbar, 1, 2, 0, 0, param='power', scale=[0,32], $
		/with_info, /bar
	rad_fit_plot_rti_panel, 1, 2, 0, 1, param='velocity', $
		sc_values=vel_scale[*,wvelc[i]], beam=beams[i], ground=gnd_lim[wgrnd[i]], $
		/with_info, /bar, /last, min_power=min_power
	plot_colorbar, 1, 2, 0, 1, param='velocity', sc_values=vel_scale[*,wvelc[i]], $
		ground=gnd_lim[wgrnd[i]], /with_info, /bar
	titlestr = (*rad_fit_info[0]).name + $
		' ('+fitstr+')'
	rad_fit_plot_title, ' ', titlestr, scan_id=scan_id, date=date, time=time
	ps_close,/no_file
endfor

end
