;+ 
; NAME: 
; TEC_PLOT_PANEL
; 
; PURPOSE: 
; This procedure plots a stereographic map grid and overlays coast
; lines and currently loaded TEC data.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; TEC_PLOT_PANEL
;
; OPTIONAL INPUTS:
; Xmaps: The total number of columns of plots on the resulting page.
; Default is 1.
;
; Ymaps: The total number of rows of plots on the resulting page.
; Default is 1.
;
; Xmap: The current horizontal (column) index of this panel.
; Default is 0.
;
; Ymap: The current vertical (row) index of this panel.
; Default is 0.
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
; POSITION: Set this keyword to a 4-element vector holding the normalized
; coordinates of the ouput panel. Use this to override internal positioning.
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
; LAND_FILLCOLOR: Set this keyword to the color index to use for filling land masses.
; Default is green (123).
;
; LAKE_FILLCOLOR: Set this keyword to the color index to use for filling lakes.
; Default is blue (20).
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; NO_GRID: Set this keyword to suppress plotting latitude/longitude grid.
;
; ERROR: Set this keyword to plot TEC error values instead of TEC measurements.
;
; BLANK: Set this keyword to plot a blank map without any TEC values
;
; FOV: Set this keyword to plot radar FOV data.
;
; RADAR: Set this keyword to an array of station id's of radar data and fields
; of view to plot. Only used if FOV keyword is set.
;
; PARAM: Set this keyword to specify the radar parameter to plot. Allowable
; values are 'power','velocity', and 'none'. Default is 'velocity' and 'none' is used
; for plotting empty radar fields of view. Only used if FOV keyword is set.
;
; RSCALE: Set this keyword to change the scale of the plotted radar values. Only
; used if FOV keyword is set.
;
; SCATTER: Set this keyword to set the currently active scatter flag. 0: plot all 
; backscatter data 1: plot ground backscatter only 2: plot ionospheric backscatter
; only 3: plot all backscatter data with a ground backscatter flag. Scatter flags 0
; and 3 produce identical output unless the parameter plotted is velocity, in which
; case all ground backscatter data is identified by a grey colour. Ground backscatter
; is identified by a low velocity (|v| < 50 m/s) and a low spectral width. Only used
; if FOV keyword is set.
;
; EXCLUDE: Set to a 2-element array giving the lower and upper velocity limit 
; to plot.  Only used if FOV keyword is set.
;
; MARK_REGION: Set this to a nstat x 4-element vector holding information about
; the region to mark in each radar fov. nstat is the number of fovs to plot,
; i.e. the number of elements of IDS or NAMES. The 4 elements of the vector are
; start_beam, end_beam, start_gate, end_gate.
;
; MARK_FILLCOLOR: Set this keyword to a color index to use for filling marked regions.
; Default is gray (254).  Only used if MARK_REGION keyword is set.
;
; MAP: Set this keyword to plot convection map.
;
; HM: Set this keyword to overlay the Heppner-Maynard boundary.
;
; MEDIANF: Set this keyword to plot median filtered TEC data as colored rectangles
; instead of unfiltered colored dots.
;
; TERMINATOR: Set this keyword to overlay the day/night terminator.
;
; LABEL: Set this keyword to plot AM/PM labels for the terminator.
;
; COMMON BLOCKS:
; TEC_DATA_BLK: The common block holding GPS TEC data.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_POLAR.
; Written by Lasse Clausen, Nov, 24 2009
; Modified by Evan Thomas, June, 06 2011
;-
pro tec_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	scan_startjul=scan_startjul, $
	coords=coords, xrange=xrange, yrange=yrange, scale=scale, $
	silent=silent, exclude=exclude, $
	charthick=charthick, charsize=charsize, $ 
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	position=position, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, mark_fillcolor=mark_fillcolor, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, mark_region=mark_region, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor, $
	hemisphere=hemisphere, rotate=rotate, vector=vector, blank=blank, $
	force_data=force_data, north=north, south=south, error=error, $
	title=title, fov=fov, radar=radar, param=param, rscale=rscale, $
	scatter=scatter, map=map, hm=hm, no_grid=no_grid, st_ids=st_ids, $
	symsize=symsize, medianf=medianf, fixed_length=fixed_length, $
	fixed_color=fixed_color, gradient=gradient, terminator=terminator, $
	bw=bw

common tec_data_blk
common radarinfo
bw=0
if tec_info.nrecs eq 0L and ~keyword_set(force_data) then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data loaded.'
	endif
	return
endif

if n_params() lt 4 then begin
	if ~keyword_set(silent) and ~keyword_set(position) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

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

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

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
if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, /bar)

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

if ~keyword_set(radar) then $
	no_radar = 0 $
else $
	no_radar = 1

; Plot color bars
if keyword_set(fov) then begin
	if param eq 'power' and keyword_set(bw) then begin
		level_values = [0.0, 10.0, 20.0, 30.0]
		colorsteps=3.
	endif
	if no_radar gt 0 and param ne 'none' and keyword_set(bw) then $
		plot_colorbar,position=[.865,.205,.88,.765],scale=rscale,param=param,/left,charsize=charsize,level_values=level_values,colorsteps=colorsteps $
	else if no_radar gt 0 and param ne 'none' then $
		plot_colorbar,position=[.865,.205,.88,.765],scale=rscale,param=param,/left,charsize=charsize
endif
; loadct,5,file='/tmp/colors2.tbl'							;*** red-white colorscale for 2012 VSGC proposal ***
if ~keyword_set(blank) then begin
	scatterflag = rad_get_scatterflag()
	rad_set_scatterflag, 0
	if keyword_set(bw) then $
		rad_load_colortable,/bw
	if keyword_set(error) then $
		plot_colorbar,position=[.9,.205,.915,.765], scale=scale, legend='Differential TEC [TECU]',param='power',charsize=0.7 $
	else if keyword_set(gradient) then $
		plot_colorbar,position=[.9,.205,.915,.765], scale=scale, legend='TEC Gradient [TECU]',param='power',charsize=0.7 $
	else $
		plot_colorbar,position=[.9,.205,.915,.765], scale=scale, legend='Total Electron Content [TECU]',param='power',charsize=0.7
	if keyword_set(bw) then $
		rad_load_colortable,/bw
rad_set_scatterflag, scatterflag
endif
; rad_load_colortable,/aj											;*** red-white colorscale for 2012 VSGC proposal ***

map_plot_panel, xmaps, ymaps, xmap, ymap, $
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
; loadct,5,file='/tmp/colors2.tbl'			;*** red-white colorscale for 2012 VSGC proposal ***
; Plot TEC data
if keyword_set(bw) then $
	rad_load_colortable,/bw
if keyword_set(medianf) then $
	overlay_tec_median, date=date, time=time,  $
		scale=scale, coords=coords, jul=jul, $
		rotate=rotate, force_data=force_data, $
		startjul=startjul, silent=silent, $
		athreshold=athreshold, ascale=ascale, $
		grid_linestyle=grid_linestyle, $
		grid_linethick=grid_linethick, $
		grid_linecolor=grid_linecolor, $
		hemisphere=hemisphere, north=north, south=south, $
		gradient=gradient $
else $
	overlay_tec, coords=coords, time=time, date=date, jul=jul, $
		scale=scale, rotate=rotate, hemisphere=hemisphere, $
		force_data=force_data, startjul=startjul, $
		north=north, south=south, ascale=ascale, $
		symsize=symsize, silent=silent, error=error, blank=blank
if keyword_set(bw) then $
	rad_load_colortable,/aj
; rad_load_colortable,/aj					;*** red-white colorscale for 2012 VSGC proposal ***
overlay_coast, coords=coords, jul=jul, hemisphere=hemisphere, /no_fill
map_overlay_grid, grid_linestyle=grid_linestyle, grid_linethick=grid_linethick, grid_linecolor=grid_linecolor
map_label_grid, coords=coords, hemisphere=hemisphere, charsize=charsize

; Plot radar data
if keyword_set(fov) then begin
	if no_radar gt 0 then begin
		rad_fit_set_data_index,-1

		if ~keyword_set(param) then $
			param = 'velocity'

		if ~keyword_set(rscale) then begin
			if strcmp(get_parameter(), param) then $
				rscale = get_scale() $
			else $
				rscale = get_default_range(param)
		endif

		if keyword_set(scatter) then $
			rad_set_scatterflag, scatter $
		else $
			rad_set_scatterflag, 0
		
		if param ne 'none' then begin
			; Read radar data
			for i=0,n_elements(radar)-1 do begin
				rad_fit_read, date, radar[i], time=[_time,_time+10]

				; if plotting iono scatter only, impose harsher velocity restrictions
				if scatter eq 2 and param eq 'velocity' then begin
					ground=25
					no_plot_gnd_scatter=1
					rad_set_scatterflag,3
				endif

				; Overlay radar velocity measurements
				vector=1
				if ~keyword_set(fixed_length) then $
					fixed_length = 0.1
				if ~keyword_set(fixed_color) then $
					fixed_color = get_black()
				if param eq 'power' and keyword_set(bw) then begin
					set_colorsteps,3.
					rad_fit_overlay_scan_scaled,date=date,time=time,coords=coords,param=param,scale=rscale, $
						exclude=exclude,ground=ground,no_plot_gnd_scatter=no_plot_gnd_scatter,vector=vector, $
						fixed_length=fixed_length,symsize=0.160
					set_colorsteps,240.
				endif else begin
					rad_fit_overlay_scan,date=date,time=time,coords=coords,param=param,scale=rscale, $
						exclude=exclude,ground=ground,no_plot_gnd_scatter=no_plot_gnd_scatter,vector=vector, $
						fixed_length=fixed_length,fixed_color=fixed_color,symsize=0.295
					rad_fit_overlay_scan,date=date,time=time,coords=coords,param=param,scale=rscale, $
						exclude=exclude,ground=ground,no_plot_gnd_scatter=no_plot_gnd_scatter,vector=vector, $
						fixed_length=fixed_length,symsize=0.130
				endelse
			endfor
		endif

		if keyword_set(scatter) then $
			rad_set_scatterflag, scatter

		; Plot radar fields of view
		for i=0,n_elements(radar)-1 do begin
			if keyword_set(bw) then $
				fov_linethick = 1 $
			else $
				fov_linethick = 3
			if radar[i] eq 'fhe' or radar[i] eq 'fhw' then $
				overlay_fov,name=radar[i],fov_linethick=fov_linethick,nbeams=22,nranges=100,coords=coords,date=date,time=time,/no_fill $
			else if radar[i] eq 'cve' or radar[i] eq 'cvw' then $
				overlay_fov,name=radar[i],fov_linethick=fov_linethick,nbeams=24,nranges=75,coords=coords,date=date,time=time,/no_fill $
			else if radar[i] eq 'bks' and date ge 20110912 then $
				overlay_fov,name=radar[i],fov_linethick=fov_linethick,nbeams=24,nranges=75,coords=coords,date=date,time=time,/no_fill $
			else $	
				overlay_fov,name=radar[i],fov_linethick=fov_linethick,nbeams=16,nranges=75,coords=coords,date=date,time=time,/no_fill
		endfor
	endif
endif

; Highlight radar beam/range gate cells
if n_elements(mark_region) eq 4 then begin
	if mark_region[1] ne 0 then begin
		if keyword_set(fov) then begin
			if ~keyword_set(mark_fillcolor) then $
					no_mark_fill = 1

	
			for i=0,n_elements(radar)-1 do begin
				if radar[i] eq 'fhe' or radar[i] eq 'fhw' then $
					overlay_fov,name=radar[i],fov_linethick=.01,nbeams=22,nranges=75,coords=coords, no_mark_fill=no_mark_fill, $
						date=date,time=time,/no_fill,mark_region=mark_region,mark_fillcolor=mark_fillcolor $
				else if radar[i] eq 'cve' or radar[i] eq 'cvw' then $
					overlay_fov,name=radar[i],fov_linethick=.01,nbeams=24,nranges=75,coords=coords, no_mark_fill=no_mark_fill, $
						date=date,time=time,/no_fill,mark_region=mark_region,mark_fillcolor=mark_fillcolor $
				else if radar[i] eq 'bks' and date ge 20110912 then $
					overlay_fov,name=radar[i],fov_linethick=.01,nbeams=24,nranges=75,coords=coords, no_mark_fill=no_mark_fill, $
						date=date,time=time,/no_fill,mark_region=mark_region,mark_fillcolor=mark_fillcolor $				
				else $
					overlay_fov,name=radar[i],fov_linethick=.01,nbeams=16,nranges=75,coords=coords, no_mark_fill=no_mark_fill, $
						date=date,time=time,/no_fill,mark_region=mark_region,mark_fillcolor=mark_fillcolor
			endfor
		endif
	endif
endif

; Plot convection map and/or Hepner-Maynard Boundary
if keyword_set(map) or keyword_set(hm) then begin
	rad_map_read, date, time=[time,time+10], hemisphere=hemisphere
	
	if keyword_set(map) then $
		rad_map_overlay_contours,coords=coords,time=time,date=date,hemisphere=hemisphere,thick=3,c_charsize=0.5,neg_color=get_black(),pos_color=get_black()
	if keyword_set(hm) then $
		rad_map_overlay_hm_boundary, coords=coords, time=time, date=date, hemisphere=hemisphere, color=240, thick=3
endif


; Plot radar station names
if keyword_set(fov) then begin
	if no_radar gt 0 then $
		overlay_fov_name,name=radar,coords=coords,date=date,time=time,/annotate,charsize=0.5,bw=bw
endif

if keyword_set(terminator) then $
	overlay_terminator,date,time,coords=coords,hemisphere=hemisphere,linethick=4.,linestyle=1.,xrange=xrange,yrange=yrange;,/label

; Plot title
if keyword_set(medianf) then $
	tec_plot_title,'','Median Filtered, Threshold = '+string(athreshold,format='(F4.2)'),startjul=startjul $
else $
	tec_plot_title, startjul=startjul

; Plot axis
plot, [0,0], /nodata, xstyle=1, ystyle=1, $
	yrange=yrange, xrange=xrange, position=position, $
	xtitle=xtitle, ytitle=ytitle, $
	xtickname=replicate(' ', 50), ytickname=replicate(' ', 50), $
	color=get_foreground(), title=title

end
