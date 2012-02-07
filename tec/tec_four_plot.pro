;+ 
; NAME: 
; TEC_FOUR_PLOT
; 
; PURPOSE: 
; This procedure plots four overview panels of TEC and radar data.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; TEC_FOUR_PLOT
;
; KEYWORD PARAMETERS:
; DATE: A scalar giving the date to plot, in YYYYMMDD format.
;
; TIME: A scalar giving the time to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn', 'geog', and 'mlt'.
; Default is 'magn'.
;
; XRANGE: Set this keyword to change the range of the x axis.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SCALE: Set this keyword to change the scale of the plotted TEC values.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; XTITLE: Set this keyword to change the title of the x axis.
;
; YTITLE: Set this keyword to change the title of the y axis.
;
; XTICKS: Set this keyword to change the number of major x tick marks.
;
; XMINOR: Set this keyword to change the number of minor x tick marks.
;
; YTICKS: Set this keyword to change the number of major y tick marks.
;
; YMINOR: Set this keyword to change the number of minor y tick marks.
;
; GRID_LINESTYLE: Set this keyword to change the style of the grid lines.
; Default is 0 (solid).
;
; GRID_LINECOLOR: Set this keyword to a color index to change the color of the grid lines.
; Default is black.
;
; GRID_LINETHICK: Set this keyword to change the thickness of the grid lines.
; Default is 1.
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; NO_GRID: Set this keyword to suppress plotting latitude/longitude grid.
;
; RADAR: Set this keyword to an array of station id's of radar data and fields
; of view to plot.
;
; VSCALE: Set this keyword to change the scale of the plotted radar velocity values.
;
; PSCALE: Set this keyword to change the scale of the plotted radar power values.
;
; SCATTER: Set this keyword to set the currently active scatter flag. 0: plot all 
; backscatter data 1: plot ground backscatter only 2: plot ionospheric backscatter
; only 3: plot all backscatter data with a ground backscatter flag. Scatter flags 0
; and 3 produce identical output unless the parameter plotted is velocity, in which
; case all ground backscatter data is identified by a grey colour. Ground backscatter
; is identified by a low velocity (|v| < 50 m/s) and a low spectral width. 
;
; EXCLUDE: Set to a 2-element array giving the lower and upper velocity limit 
; to plot.
;
; MAP: Set this keyword to plot convection map.
;
; HM: Set this keyword to overlay the Heppner-Maynard boundary.
;
; LINEAR: Set this keyword to plot radar velocities using a linear scale.
;
; COMMON BLOCKS:
; TEC_DATA_BLK: The common block holding GPS TEC data.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_POLAR.
; Written by Evan Thomas, Sep, 22, 2011
;-
pro tec_four_plot, date=date, time=time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, scale=scale, $
	silent=silent, exclude=exclude, $
	charthick=charthick, charsize=charsize, $ 
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, map=map, hm=hm, $
	hemisphere=hemisphere, rotate=rotate, $
	force_data=force_data, north=north, south=south, $
	title=title, radar=radar, vscale=vscale, pscale=pscale, $
	scatter=scatter, no_grid=no_grid, st_ids=st_ids, $
	symsize=symsize, fixed_length=fixed_length, $
	fixed_color=fixed_color, linear=linear

common tec_data_blk
common radarinfo

if tec_info.nrecs eq 0L and ~keyword_set(force_data) then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data loaded.'
	endif
	return
endif

set_colorsteps,240

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, tec_data.juls[0], month, day, year, hh, ii
	date = year*10000L + month*100L + day
	_time = hh*100 + ii
endif

if n_elements(time) eq 0 and ~keyword_set(time) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No TIME given, trying for scan date.'
	caldat, tec_data.juls[0], month, day, year, hh, ii
	time= hh*100 + ii
endif

if n_elements(time) ne 0 then $
	_time = time

sfjul, date, _time, jul, long=long
_jul = jul

if ~keyword_set(charsize) then $
	charsize = get_charsize(2, 2)

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return
endif

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

if ~keyword_set(yrange) then $
	yrange = [-50,10]

if ~keyword_set(xrange) then $
	xrange = [-50,30]

aspect = float(xrange[1]-xrange[0])/float(yrange[1]-yrange[0])

if ~keyword_set(grid_linethick) then $
	grid_linethick = 1

if n_elements(grid_linestyle) eq 0 then $
	grid_linestyle = 0

if n_elements(grid_linecolor) eq 0 then $
	grid_linecolor = get_gray()

if ~keyword_set(coast_linethick) then $
	coast_linethick = 3

if n_elements(coast_linestyle) eq 0 then $
	coast_linestyle = 0

if n_elements(coast_linecolor) eq 0 then $
	coast_linecolor = get_gray()

if n_elements(land_fillcolor) eq 0 then $
	land_fillcolor = 123

if n_elements(lake_fillcolor) eq 0 then $
	lake_fillcolor = 20

if n_elements(scatter) eq 0 then $
	scatter = 0

if ~keyword_set(hemisphere) then begin
  if keyword_set(north) then $
    hemisphere = 1. $
  else if keyword_set(south) then $
    hemisphere = -1. $
  else $
    hemisphere = 1.
endif

if keyword_set(st_ids) then begin
	radar = strarr(n_elements(st_ids))
		for i=0,n_elements(st_ids)-1 do begin
			tmp = where(network[*].id eq st_ids[i], cc)
			if cc ne 0 then $
				radar[i] = network[tmp].code[0]
		endfor
endif

if n_elements(radar) eq 0 and hemisphere eq 1 then $
	radar = 'bks' $
else if n_elements(radar) eq 0 then $
	radar = 'tig'

if ~keyword_set(pscale) then $
	pscale = [0,30]

plevel_values = [0.0, 10.0, 20.0, 30.0]
vlevel_values = [-1000.,-500.,-250.,-100.,-25.,0.,25.,100.,250.,500.,1000.]

; Plot colorbars
rad_set_scatterflag,0
plot_colorbar,2,2,0,0, scale=scale, legend='Total Electron Content [TECU]',param='power',charsize=charsize
plot_colorbar,2,2,0,1, scale=scale, legend='Total Electron Content [TECU]',param='power',charsize=charsize

rad_load_colortable,/bw
plot_colorbar,position=[.95,.135,.965,.435], scale=scale, legend='Total Electron Content [TECU]',param='power',charsize=charsize
rad_load_colortable,/aj
rad_set_scatterflag,scatter

rad_load_colortable,/default
if keyword_set(linear) then $
	plot_colorbar,position=[.915,.515,.93,.815],scale=vscale,param='velocity',charsize=charsize $
else $
	plot_colorbar,position=[.915,.515,.93,.815],scale=vscale,param='velocity',charsize=charsize,level_values=vlevel_values,/drop_first_last_label
rad_load_colortable,/aj

colorsteps=3.
plot_colorbar,position=[.915,.135,.93,.435],scale=pscale,param='power',/left,charsize=charsize,level_values=plevel_values,colorsteps=colorsteps
colorsteps=240.


; Plot raw TEC data panel
position = define_panel(2, 2, 0, 0, aspect=aspect, /bar)
map_plot_panel, 2, 2, 0, 0, $
	date=date, time=_time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	position=position, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	hemisphere=hemisphere, rotate=rotate, /no_fill, /no_axis, south=south, no_grid=no_grid, /no_label

overlay_tec, coords=coords, time=time, date=date, jul=jul, $
	scale=scale, rotate=rotate, hemisphere=hemisphere, $
	force_data=force_data, startjul=startjul, $
	north=north, south=south, ascale=ascale, $
	symsize=symsize, silent=silent

overlay_coast, coords=coords, jul=jul, hemisphere=hemisphere, /no_fill
map_overlay_grid, grid_linestyle=grid_linestyle, grid_linethick=grid_linethick, grid_linecolor=grid_linecolor
map_label_grid, coords=coords, hemisphere=hemisphere, charsize=charsize, /no_label_lons

xpos = !x.crange[0] - .02*(!x.crange[1]-!x.crange[0])
ypos = !y.crange[0] + 0.7*(!y.crange[1]-!y.crange[0])
xyouts, xpos, ypos, orientation=90.,'Unfiltered Data', /data, charsize=.5

plot, [0,0], /nodata, xstyle=1, ystyle=1, $
	yrange=yrange, xrange=xrange, position=position, $
	xtitle=xtitle, ytitle=ytitle, $
	xtickname=replicate(' ', 50), ytickname=replicate(' ', 50), $
	color=get_foreground(), title=title


; Plot median filtered TEC panel
position = define_panel(2, 2, 0, 1, aspect=aspect, /bar)
map_plot_panel, 2, 2, 0, 1, $
	date=date, time=_time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	position=position, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	hemisphere=hemisphere, rotate=rotate, /no_fill, /no_axis, south=south, no_grid=no_grid, /no_label

overlay_tec_median, date=date, time=_time,  $
	scale=scale, coords=coords, jul=jul, $
	rotate=rotate, force_data=force_data, $
	startjul=startjul, silent=silent, $
	athreshold=athreshold, ascale=ascale, $
	grid_linestyle=grid_linestyle, $
	grid_linethick=grid_linethick, $
	grid_linecolor=grid_linecolor, $
	hemisphere=hemisphere, north=north, south=south

; Plot convection map and/or Hepner-Maynard Boundary
if keyword_set(map) or keyword_set(hm) then begin
	rad_map_read, date, time=[time,time+10], hemisphere=hemisphere

	if keyword_set(map) then $
		rad_map_overlay_contours,coords=coords,time=time,date=date,hemisphere=hemisphere,thick=3,c_charsize=0.5,neg_color=get_black(),pos_color=get_black(),/no_legend
	if keyword_set(hm) then $
		rad_map_overlay_hm_boundary, coords=coords, time=time, date=date, hemisphere=hemisphere, color=240, thick=3
endif

overlay_coast, coords=coords, jul=jul, hemisphere=hemisphere, /no_fill
map_overlay_grid, grid_linestyle=grid_linestyle, grid_linethick=grid_linethick, grid_linecolor=grid_linecolor
map_label_grid, coords=coords, hemisphere=hemisphere, charsize=charsize

xpos = !x.crange[0] - .02*(!x.crange[1]-!x.crange[0])
ypos = !y.crange[0] + 0.30*(!y.crange[1]-!y.crange[0])
xyouts, xpos, ypos, orientation=90.,'Median Filtered, Threshold = '+string(athreshold,format='(F4.2)'), /data, charsize=.5

plot, [0,0], /nodata, xstyle=1, ystyle=1, $
	yrange=yrange, xrange=xrange, position=position, $
	xtitle=xtitle, ytitle=ytitle, $
	xtickname=replicate(' ', 50), ytickname=replicate(' ', 50), $
	color=get_foreground(), title=title


; Plot radar velocity panel
position = define_panel(2, 2, 1, 0, aspect=aspect, /bar)
position[0] = position[0] + 0.03
position[2] = position[2] + 0.03
map_plot_panel, 2, 2, 1, 0, $
	date=date, time=_time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	position=position, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	hemisphere=hemisphere, rotate=rotate, /no_fill, /no_axis, south=south, no_grid=no_grid, /no_label

overlay_coast, coords=coords, jul=jul, hemisphere=hemisphere, /no_fill

rad_fit_set_data_index,-1
param = 'velocity'
if ~keyword_set(vscale) then begin
	if strcmp(get_parameter(), param) then $
		vscale = get_scale() $
	else $
		vscale = get_default_range(param)
endif

if keyword_set(scatter) then $
	rad_set_scatterflag, scatter $
else $
	rad_set_scatterflag, 0

; Read radar data
rad_load_colortable,/default
for i=0,n_elements(radar)-1 do begin
	if _time lt 10 then begin
		_jul = _jul-1
		sfjul,rdate,rtime,_jul,/jul_to_date
		;print,rdate,[2350,0010]
		rad_fit_read, rdate, radar[i], time=[2350,0010];,/silent
	endif else $
		rad_fit_read, date, radar[i], time=[_time-10,_time+10];,/silent

	; if plotting iono scatter only, impose harsher velocity restrictions
	if scatter eq 2 then begin
		;ground=25
		no_plot_gnd_scatter=1
		rad_set_scatterflag,3
	endif

	if ~keyword_set(fixed_length) then $
		fixed_length = 0.1
	if ~keyword_set(fixed_color) then $
		fixed_color = get_black()

	if keyword_set(linear) then $
		rad_fit_overlay_scan_scaled,date=date,time=time,coords=coords,param=param,scale=vscale, $
			exclude=exclude,ground=ground,no_plot_gnd_scatter=no_plot_gnd_scatter $
	else $
		rad_fit_overlay_scan_scaled,date=date,time=time,coords=coords,param=param,scale=vscale, $
			exclude=exclude,ground=ground,no_plot_gnd_scatter=no_plot_gnd_scatter,sc_values=vlevel_values

; 	rad_fit_overlay_scan,date=date,time=time,coords=coords,param=param,scale=vscale, $
; 		exclude=exclude,ground=ground,no_plot_gnd_scatter=no_plot_gnd_scatter,/vector, $
; 		fixed_length=fixed_length,fixed_color=fixed_color,symsize=0.275
; 	rad_fit_overlay_scan,date=date,time=time,coords=coords,param=param,scale=vscale, $
; 		exclude=exclude,ground=ground,no_plot_gnd_scatter=no_plot_gnd_scatter,/vector, $
; 		fixed_length=fixed_length,symsize=0.110
endfor
rad_load_colortable,/aj
if keyword_set(scatter) then $
	rad_set_scatterflag, scatter

; Plot radar fields of view
for i=0,n_elements(radar)-1 do begin
	if radar[i] eq 'fhe' or radar[i] eq 'fhw' then $
		overlay_fov,name=radar[i],fov_linethick=1,nbeams=22,nranges=100,coords=coords,date=date,time=time,/no_fill $
	else if radar[i] eq 'cve' or radar[i] eq 'cvw' then $
		overlay_fov,name=radar[i],fov_linethick=1,nbeams=24,nranges=75,coords=coords,date=date,time=time,/no_fill $
	else if radar[i] eq 'bks' and date ge 20110912 then $
		overlay_fov,name=radar[i],fov_linethick=fov_linethick,nbeams=24,nranges=75,coords=coords,date=date,time=time,/no_fill $
	else $	
		overlay_fov,name=radar[i],fov_linethick=1,nbeams=16,nranges=75,coords=coords,date=date,time=time,/no_fill
endfor

overlay_fov_name,name=radar,coords=coords,date=date,time=time,/annotate,charsize=0.4

map_overlay_grid, grid_linestyle=grid_linestyle, grid_linethick=grid_linethick, grid_linecolor=grid_linecolor
map_label_grid, coords=coords, hemisphere=hemisphere, charsize=charsize, /no_label_lons

plot, [0,0], /nodata, xstyle=1, ystyle=1, $
	yrange=yrange, xrange=xrange, position=position, $
	xtitle=xtitle, ytitle=ytitle, $
	xtickname=replicate(' ', 50), ytickname=replicate(' ', 50), $
	color=get_foreground(), title=title


; Plot radar power/grayscale TEC panel
position = define_panel(2, 2, 1, 1, aspect=aspect, /bar)
position[0] = position[0] + 0.03
position[2] = position[2] + 0.03
map_plot_panel, 2, 2, 1, 1, $
	date=date, time=_time, long=long, $
	coords=coords, xrange=xrange, yrange=yrange, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	position=position, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	hemisphere=hemisphere, rotate=rotate, /no_fill, /no_axis, south=south, no_grid=no_grid, /no_label

rad_load_colortable,/bw
overlay_tec_median, date=date, time=_time,  $
	scale=scale, coords=coords, jul=jul, $
	rotate=rotate, force_data=force_data, $
	startjul=startjul, silent=silent, $
	athreshold=athreshold, ascale=ascale, $
	grid_linestyle=grid_linestyle, $
	grid_linethick=grid_linethick, $
	grid_linecolor=grid_linecolor, $
	hemisphere=hemisphere, north=north, south=south
rad_load_colortable,/aj

overlay_coast, coords=coords, jul=jul, hemisphere=hemisphere, /no_fill
map_overlay_grid, grid_linestyle=grid_linestyle, grid_linethick=grid_linethick, grid_linecolor=grid_linecolor
map_label_grid, coords=coords, hemisphere=hemisphere, charsize=charsize

param = 'power'

set_colorsteps,3.
for i=0,n_elements(radar)-1 do begin
		rad_fit_set_data_index,i

	rad_fit_overlay_scan_scaled,date=date,time=_time,coords=coords,param=param,scale=pscale, $
		exclude=exclude,ground=ground,no_plot_gnd_scatter=no_plot_gnd_scatter,/vector, $
		fixed_length=fixed_length,symsize=0.160
endfor
set_colorsteps,240.

if keyword_set(scatter) then $
	rad_set_scatterflag, scatter

; Plot radar fields of view
for i=0,n_elements(radar)-1 do begin
	if radar[i] eq 'fhe' or radar[i] eq 'fhw' then $
		overlay_fov,name=radar[i],fov_linethick=1,nbeams=22,nranges=100,coords=coords,date=date,time=time,/no_fill $
	else if radar[i] eq 'cve' or radar[i] eq 'cvw' then $
		overlay_fov,name=radar[i],fov_linethick=1,nbeams=24,nranges=75,coords=coords,date=date,time=time,/no_fill $
	else if radar[i] eq 'bks' and date ge 20110912 then $
		overlay_fov,name=radar[i],fov_linethick=fov_linethick,nbeams=24,nranges=75,coords=coords,date=date,time=time,/no_fill $
	else $	
		overlay_fov,name=radar[i],fov_linethick=1,nbeams=16,nranges=75,coords=coords,date=date,time=time,/no_fill
endfor

overlay_fov_name,name=radar,coords=coords,date=date,time=time,/annotate,/bw,charsize=0.4

plot, [0,0], /nodata, xstyle=1, ystyle=1, $
	yrange=yrange, xrange=xrange, position=position, $
	xtitle=xtitle, ytitle=ytitle, $
	xtickname=replicate(' ', 50), ytickname=replicate(' ', 50), $
	color=get_foreground(), title=title

; Plot title
tec_plot_title,'TEC Four Plot','',startjul=startjul

end
