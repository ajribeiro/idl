
if ~keyword_set(silent) and ~keyword_set(position) then begin
	prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif
	
if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

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


; Winter
sdate = 20091101
fdate = 20100228

; Summer
;sdate = 20090501
;fdate = 20090831

time = 0100
rtime = [0030,0130]

dlat = 1.
dlon = 2.
slat = 10.
threshold = 0.33

kp = [0.0,2.0]

scale=[0,16]

sfjul,sdate,0000,sjul
sfjul,fdate,2400,fjul

duration = fjul-sjul

j = 0
tec = fltarr(75,180,duration)
list = dblarr(duration)

for i=0,duration-1 do begin
	sfjul,date,asdftime,(sjul+i),/jul_to_date	
	kpi_read,date,time=rtime

	if kpi_data.kp_index[0] ge kp[0] and kpi_data.kp_index[0] lt kp[1] then begin
		list[j] = date

		tec_read,date,time=rtime
		tec_median_filter,dlat,dlon,slat=slat,threshold=threshold,time=time

		if j eq 0 then startjul = tec_median.juls[1]

		tec[*,*,j] = tec_median.medarr[*,*,1]

		j = j+1
	endif
endfor

if j eq 0 then begin
	prinfo, 'No dates found for given Kp range.'
	return
endif

endjul = tec_median.juls[1]

juls = tec_median.juls
lats = tec_median.lats
lons = tec_median.lons


; get color preferences
foreground  = get_foreground()
color_steps = get_colorsteps()
ncolors     = get_ncolors()
bottom      = get_bottom()

set_colorsteps,240

; Set color bar and levels
cin =    FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps

clear_page
map_plot_panel,xrange=[-50,30],yrange=[-50,10],/no_fill, $
	charthick=charthick, charsize=charsize, grid_charsize=1.0, $
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	grid_linestyle=grid_linestyle, grid_linecolor=grid_linecolor, $
	grid_linethick=grid_linethick, $
	coast_linestyle=coast_linestyle, coast_linecolor=coast_linecolor, $
	coast_linethick=coast_linethick, $
	land_fillcolor=land_fillcolor, lake_fillcolor=lake_fillcolor
	
for a=0,n_elements(lats)-2 do begin
	for o=0,n_elements(lons)-2 do begin
		count=0

		for i=0,j-1 do begin
			if tec[a,o,i] eq 0. then $
				count=count+1
		endfor

		if count/j ge 0.5 then $
			continue	

		value = mean(tec[a,o,0:j-1])

		if value eq 0. then $
			continue

		alats = lats[a+[0,0,1,1,0]]
		alons = lons[o+[0,1,1,0,0]]
		tmp = calc_stereo_coords(alats, alons)

		color_ind = (max(where(lvl le ((value > scale[0]) < scale[1])))) > bottom

		polyfill, tmp[0,*], tmp[1,*], color=cin[color_ind], noclip=0

	endfor
endfor

;overlay_terminator,list[0],time, coords='magn'
;overlay_terminator,list[j-1],time,coords='magn'

overlay_coast, coords='magn', /no_fill
map_overlay_grid, grid_linestyle=grid_linestyle, grid_linethick=grid_linethick, grid_linecolor=grid_linecolor
plot_colorbar,position=[.9,.205,.915,.765], scale=scale, legend='Total Electron Content [TECU]',param='power'
tec_plot_title,'',string(kp[0],format='(F3.1)')+' < Kp < '+string(kp[1],format='(F3.1)')+', Days Averaged: '+string(j,format='(I3)'),startjul=startjul,endjul=endjul

print,list[0:j-1]

end