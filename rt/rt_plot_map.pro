pro rt_plot_map, time, ground=ground, ionos=ionos, param=param

common rt_data_blk
common radarinfo

; Set plot parameters
if ~keyword_set(param) then $
	param = 'elevation'

; Retrieve raytracing parameters from structure
radar = rt_info.name
caldat, rt_data.juls[*,0], month, day, year, hours, minutes
tdate 	= year*10000L + month*100L + day
date = tdate[0]

; Find time index
parse_time, time, hour, minute
if ~keyword_set(date) then $
	date = tdate[0]
timeind = where(tdate eq date and hours eq hour and minutes eq minute)
juls = julday(month[timeind], day[timeind], year[timeind], hours[timeind], minutes[timeind])

; Find hardware parameters
if rt_info.name ne 'custom' then begin
	radID = where(network.ID eq rt_info.id)
	tval = TimeYMDHMSToEpoch(year[0], month[0], day[0], 0, 0, 0)
	for s=0,31 do begin
		if (network[radID].site[s].tval eq -1) then break
		if (network[radID].site[s].tval ge tval) then break
	endfor
	radarsite = network[radID].site[s]
	nbeams = radarsite.maxbeam
	hbw = radarsite.bmsep/2.
endif else begin
	nbeams = n_elements(rt_data.beam[0,*])
	hbw = 3.3
endelse

; Select parameter to plot
s = execute('ydata = rt_data.'+param)
case param of
	'power':	begin
						legend = 'Power'
						scale = [0., 1.]
					end
	'elevation':	begin
						legend = 'Elevation'
						scale = [10., 45.]
					end
	'altitude':		begin
						legend = 'Altitude [km]'
						scale = [100., 500.]
					end
	'valtitude':	begin
						legend = 'Virtual height [km]'
						scale = [100., 500.]
					end
	'nr':			begin
						legend = 'Refractive index'
						scale = [.8, 1.]
					end
endcase

; Set plot area
set_format, /landscape
clear_page
position = define_panel(1,1,0,0, /bar)
map_plot_panel, 1, 1, 0, 0, date=date, coords='magn', /bar, /iso, /no_fill, yrange=[-50., 0.]

lati = rt_info.glat
longi = rt_info.glon
fov_loc_full = fltarr(2,4,rt_info.ngates,nbeams)
for ib=0,nbeams-1 do begin
	for ng=0,rt_info.ngates-1 do begin
		if rt_data.grange[timeind[0],ib,ng] gt 0. then begin
		; Calculate range-cell position
			success = calc_pos(lati, longi, 0., rt_data.azim[timeind[0],ib]-hbw, rt_data.grange[timeind[0],ib,ng]-22.5, 0., latiout, longiout)
			if success eq 1 then begin
				magco = cnvcoord(latiout, longiout, 0.)
				proj = calc_stereo_coords(magco[0], magco[1])
				fov_loc_full[0,0,ng] = proj[0]
				fov_loc_full[1,0,ng] = proj[1]
			endif
			success = calc_pos(lati, longi, 0., rt_data.azim[timeind[0],ib]-hbw, rt_data.grange[timeind[0],ib,ng]+22.5, 0., latiout, longiout)
			if success eq 1 then begin
				magco = cnvcoord(latiout, longiout, 0.)
				proj = calc_stereo_coords(magco[0], magco[1])
				fov_loc_full[0,1,ng] = proj[0]
				fov_loc_full[1,1,ng] = proj[1]
			endif
			success = calc_pos(lati, longi, 0., rt_data.azim[timeind[0],ib]+hbw, rt_data.grange[timeind[0],ib,ng]+22.5, 0., latiout, longiout)
			if success eq 1 then begin
				magco = cnvcoord(latiout, longiout, 0.)
				proj = calc_stereo_coords(magco[0], magco[1])
				fov_loc_full[0,2,ng] = proj[0]
				fov_loc_full[1,2,ng] = proj[1]
			endif
			success = calc_pos(lati, longi, 0., rt_data.azim[timeind[0],ib]+hbw, rt_data.grange[timeind[0],ib,ng]-22.5, 0., latiout, longiout)
			if success eq 1 then begin
				magco = cnvcoord(latiout, longiout, 0.)
				proj = calc_stereo_coords(magco[0], magco[1])
				fov_loc_full[0,3,ng] = proj[0]
				fov_loc_full[1,3,ng] = proj[1]
			endif

		; Plot range cell
			if ydata[timeind[0],ib,ng] gt 0. then begin
				col = bytscl(ydata[timeind[0],ib,ng], min=scale[0], max=scale[1], top=251) + 3b

				polyfill, reform(fov_loc_full[0,*,ng]), $
						reform(fov_loc_full[1,*,ng]), color=col
			endif

		endif
	endfor
endfor

; overlay_fov, names=radar, coords='magn', date=date, /no_fill, nranges=rt_info.ngates
magco = cnvcoord(rt_info.glat, rt_info.glon, 0.)
proj = calc_stereo_coords(magco[0], magco[1])
load_usersym, /circle
plots, proj[0], proj[1], psym=8

; Plot colorbar
plot_colorbar, /vert, charthick=charthick, /continuous, $
	nlevels=4, scale=scale, position=[position[2]+.01,position[1],position[2]+.03,position[3]], charsize=!P.charsize, $
	legend=legend, /no_rotate, $
	level_format='(F4.1)', /keep_first_last_label



end