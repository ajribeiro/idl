pro	rad_plot_fov, radar, date=date, beam=beam, coords=coords, $
								yrange=yrange, xrange=xrange, grid=grid, ps=ps

common radarinfo

; For now we limit to ine radar per plot
if n_elements(radar) gt 1 then begin
	print, 'One radar at a time please!'
	return
endif

; First find radar site structure
radID = where(network.code[0,*] eq radar, cc)
if cc le 0 then begin
	print, 'Unknown radar'
	return
end

; Set coordinate system
if ~keyword_set(coords) then $
	coords = 'magn'
if coords ne 'magn' and coords ne 'geog' then begin
	print, 'Invalid coordinate system. Using magn'
	coords = 'magn'
endif

; Find range-gate locations
if ~keyword_set(date) then $
	ajul = systime(/julian, /utc) $
else $
	ajul = calc_jul(date,1200)
caldat, ajul, mm, dd, year
tval = TimeYMDHMSToEpoch(year, mm, dd, 12, 0, 0)
if tval lt network[radID].st_time then begin
	tval = network[radID].st_time
	jul0 = julday(1,1,1970)
	ajul = (jul0 + tval/86400.d)
	caldat, ajul, mm, dd, year
endif
for s=0,31 do begin
	if (network[radID].site[s].tval eq -1) then break
	if (network[radID].site[s].tval ge tval) then break
endfor
radarsite = network[radID].site[s]
yrsec = (ajul-julday(1,1,year,0,0,0))*86400.d
ngates = 75
nbeams = radarsite.maxbeam
rad_define_beams, network[radID].id, nbeams, ngates, year, yrsec, coords=coords, $
		/normal, fov_loc_full=fov_loc_full

; +1 for North hemisphere, -1 for south
hemi = fix( radarsite.geolat/abs(radarsite.geolat) )

; Calculate stereographic projection and plot
for ib=0,nbeams do begin
	for ig=0,ngates do begin
		for p=0,3 do begin
			lat = fov_loc_full[0,p,ib,ig]
			lon = fov_loc_full[1,p,ib,ig]
			tmp = calc_stereo_coords(lat, lon)
			fov_loc_full[0,p,ib,ig] = tmp[0]
			fov_loc_full[1,p,ib,ig] = tmp[1]
		endfor
	endfor
endfor

; Set plot limits
if ~keyword_set(xrange) then $
	xrange = [min(fov_loc_full[0,*,*,*],xmin)-5, max(fov_loc_full[0,*,*,*],xmax)+5]
if ~keyword_set(yrange) then $
	yrange = [min(fov_loc_full[1,*,*,*],ymin)-5, max(fov_loc_full[1,*,*,*],ymax)+5]
; Adjust plot limits so that they cover the same extent
ext = abs(abs(xrange[1]-xrange[0]) - abs(yrange[1]-yrange[0]))
if abs(xrange[1]-xrange[0]) gt abs(yrange[1]-yrange[0]) then begin
	yrange[1] = yrange[1] + ext/2.
	yrange[0] = yrange[0] - ext/2.
endif else if abs(xrange[1]-xrange[0]) lt abs(yrange[1]-yrange[0]) then begin
	xrange[1] = xrange[1] + ext/2.
	xrange[0] = xrange[0] - ext/2.
endif

; Set plot area
set_format, /landscape
if keyword_set(ps) then $
	ps_open, '~/Desktop/rad_plot_fov.ps', /no_init
clear_page
loadct, 0
map_plot_panel, 1, 1, 0, 0, coords=coords, /iso, yrange=yrange, xrange=xrange, hemi=hemi, $
	coast_linecolor=150, grid_linecolor=200, lake_fillcolor=255
overlay_radar, name=radar, /anno, coords=coords

; Calculate stereographic projection and plot
loadct,8
xx = fltarr(4)
yy = fltarr(4)
for ib=0,nbeams-1 do begin
	for ig=0,ngates-1 do begin
		xx = reform(fov_loc_full[0,*,ib,ig])
		yy = reform(fov_loc_full[1,*,ib,ig])
		; Highlight selected beam
		if n_elements(beam) eq 1 then begin
			if (ib eq beam) then begin
				polyfill, xx, yy, col=220
				plots, xx[1:2], yy[1:2], thick=2
				plots, [xx[0],xx[3]], [yy[0],yy[3]], thick=2
			endif
		endif
		if keyword_set(grid) then $
					plots, [xx, xx[0]], [yy, yy[0]], thick=.25
		; Plot fov limits
		if ib eq 0 then $
			plots, [xx[0],xx[3]], [yy[0],yy[3]], thick=2
		if (ib eq nbeams-1) then $
			plots, xx[1:2], yy[1:2], thick=2
		if (ig eq ngates-1) then $
			plots, xx[2:3], yy[2:3], thick=2
		if (ig eq 0) then $
			plots, xx[0:1], yy[0:1], thick=2
	endfor
endfor

loadct, 0
map_plot_panel, 1, 1, 0, 0, coords=coords, /iso, /no_fill, yrange=yrange, xrange=xrange, hemi=hemi, $
	coast_linecolor=150, /no_grid

if keyword_set(ps) then $
	ps_close, /no_filename, /no_init

end