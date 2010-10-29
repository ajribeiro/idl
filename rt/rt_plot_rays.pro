;+ 
; NAME: 
; RT_PLOT_RAYS
;
; PURPOSE: 
; This procedure reads in the rays.dat and plot the ray paths
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RT_PLOT_RAYS, max_range=max_range, max_height=maxh, position=position, 
;	dens_range=desn_range, bottom=bottom, ncolors=ncolors, $
;	gate_len=gate_len, d_gates=d_gates, plotrays=plotrays, radar=radar, bema=beam
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORDS:
;
; COMMON BLOCKS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
pro rt_plot_rays, max_range=max_range, max_height=max_height, position=position, $
	dens_range=desn_range, bottom=bottom, ncolors=ncolors, date=date, time=time, $
	gate_len=gate_len, d_gates=d_gates, plotrays=plotrays, radar=radar, beam=beam


; set default values
if ~keyword_set(dens_range) then $
	dens_range = [10.4,11.8]
if ~keyword_set(ncolors) then $
	ncolors = 255
if ~keyword_set(bottom) then $
	bottom = 1
if ~keyword_set(max_range) then $
	maxr = 2000.
if ~keyword_set(max_height) then $
	maxh = 400.
if ~keyword_set(gate_len) then $
	gate_len = 45.
if ~keyword_set(d_gates) then $
	d_gates = 10.
if keyword_set(date) then begin
	year 		= date/10000L
	month 		= (date - year*10000L)/100L
	day 		= date - (year*10000L + month*100L)
endif
hr=floor(time)
mn=ROUND((time-floor(time))*60.)
n_files = 1
files = ['rays.dat']

position=[.05, .15, .95, .85]

; define radar position
openr, unit, files[0], /get_lun
rt_read_header, unit, freq_beg, freq_stp, elev_beg, elev_stp, elev_end
rt_read_rays, unit, radpos, thtpos, phipos, grppth, gndflag
free_lun, unit

txrad = radpos[0]
txtht = thtpos[0]
txphi = phipos[0]
txmlon = txphi
txmlat = !pi/2.-txtht

; define plotting area
tht0 = (2.*txtht - maxr / txrad) / 2.

xmin = (txrad + maxh) * sin (tht0 - txtht)
xmax = (txrad + maxh) * sin (txtht - tht0)
xran = [xmin, xmax]

ymin = txrad * cos (tht0 - txtht)
ymax = txrad + maxh
yran = [ymin, ymax]

;create ps output
SET_PLOT,'ps'

DEVICE,FILE='raytrace.ps'   $
		,XOFFSET=0.01           $
		,XSIZE=8.5              $
		,YOFFSET=0.01           $
		,YSIZE=11.0             $
		,/INCHES                $
		,/COLOR                 $
		,SET_FONT = 'Times'     $
		,/TT_FONT               $
		,/ISOLATIN1             $
		,BITS_PER_PIXEL=4


title = 'Ray-tracing output!C'+STRTRIM(day,2)+'/'+STRTRIM(month,2)+'/'+STRTRIM(year,2)+' '+STRTRIM(hr,2)+':'+STRTRIM(mn,2)
xyouts, (position[2]+position[0])/2., .95, title, /norm, charthick=2, $
	charsize=1.5, align=.5

; ;- colorbar for e densities
rt_colorbar, bottom=bottom, ncolors=ncolors, /vert, /right, charthick=2, $
	div=2, scale=dens_range, $
	title='Log!I10!N(Electron Density [m!E-3!N])'

;- plot empty area for raytrace
plot, xran, yran, /nodata, xstyle=5, ystyle=5, /isotropic, $
	position=[.12,.1,.85,.9], charthick=2

;- plot background electron densities
rt_read_edens, edens, lats, lons, alts
edens = alog10(edens)
alts += 6370.
cols = bytscl(edens, min=dens_range[0], max=dens_range[1], top=ncolors) + bottom
dens_lats = cos (lats) * cos (txtht) + $
		sin (lats) * sin (txtht)
dens_lats = acos (dens_lats < 1.)
for l=0, n_elements(lats)-2 do begin
	for a=0, n_elements(alts)-2 do begin
		if dens_lats[l+1] le maxr / txrad and alts[a+1]-6370. le maxh then begin
			xx = [alts[a] * sin (tht0 - txtht + dens_lats[l]), $
				alts[a] * sin (tht0 - txtht + dens_lats[l+1]), $
				alts[a+1] * sin (tht0 - txtht + dens_lats[l+1]), $
				alts[a+1] * sin (tht0 - txtht + dens_lats[l]), $
				alts[a] * sin (tht0 - txtht + dens_lats[l]) $
			]
			yy = [alts[a] * cos (tht0 - txtht + dens_lats[l]), $
				alts[a] * cos (tht0 - txtht + dens_lats[l+1]), $
				alts[a+1] * cos (tht0 - txtht + dens_lats[l+1]), $
				alts[a+1] * cos (tht0 - txtht + dens_lats[l]), $
				alts[a] * cos (tht0 - txtht + dens_lats[l]) $
			]
			polyfill, xx, yy, color=cols[l,a], /data, noclip=0
		endif
	endfor
endfor

;- convert tx loocation to geographic coords
;- because next function uses geog position
txgpos = cnvcoord(txmlat/!dtor, txmlon/!dtor, 1., /geo)

;- range tickmarks
if maxr lt 1000. then $
	dr = 100. $
else if maxr lt 2000. then $
	dr = 200. $
else if maxr lt 5000. then $
	dr = 500. $
else $
	dr = 1000.
n_r = fix (maxr  / dr + .01)
for i = 0, n_r do begin
	tmp = dr * i / txrad - (txtht - tht0)
	oplot, ([0., -15.] + txrad) * sin (tmp), ([0., -15.] + txrad) * cos (tmp), $
		/noclip
	x = (txrad - 80.) * sin (tmp)
	y = (txrad - 80.) * cos (tmp)
	str = string (dr * i, format = '(i0)')
	ang = -tmp * !radeg
	xyouts, x, y, str, alignment=.5, orientation=ang, charthick=2
endfor
xyouts, .5 * (xmin + xmax), ymin - .25 * (ymax - ymin), 'Range [km]', $
	alignment=.5, charthick=2

;- plot rays
usersym, sin(2.*!pi*findgen(16)/15.), cos(2.*!pi*findgen(16)/15.) 
n_gates = 75.
gates = 180.+findgen(n_gates/d_gates+1)*d_gates*gate_len
openr, unit, files[0], /get_lun
rt_read_header, unit, freq_beg, freq_stp, elev_beg, elev_stp

cc = 0
while ~eof(unit) do begin
	rt_read_rays, unit, radpos, thtpos, phipos, grppth, gndflag
	if keyword_set(plotrays) then begin
		inds = where(plotrays eq cc+1, count)
		if count eq 0 then begin
			cc += 1
			continue
		endif
	endif
	angle = cos (thtpos) * cos (txtht) + $
		sin (thtpos) * sin (txtht) * cos (phipos - txphi)
	angle = acos (angle < 1.)
	ind = where (angle le maxr / txrad, count)
	if count ne 0 then begin
		angle = angle[ind]
		radpos = radpos[ind]
		grppth = grppth[ind]
		ind = where(grppth lt 180., dd)
		
		;- first the dashed path to the first range gate
		oplot, radpos[0:ind[dd-1]] * sin (tht0 - txtht + angle[0:ind[dd-1]]), $
			radpos[0:ind[dd-1]] * cos (tht0 - txtht + angle[0:ind[dd-1]]), $
			color=0, thick=2 
			
		;- then from there as solid line
		oplot, radpos[ind[dd-1]:*] * sin (tht0 - txtht + angle[ind[dd-1]:*]), $
			radpos[ind[dd-1]:*] * cos (tht0 - txtht + angle[ind[dd-1]:*]), $
			color=0, thick=2
	endif
	cc += 1
endwhile

free_lun, unit

;- plot graph limits
;- axis on left and right
x1 = txrad * sin (tht0 - txtht)
x2 = txrad * sin (txtht - tht0)
y1 = (txrad + maxh) * cos (tht0 - txtht)
oplot, [x1, xmin], [ymin, y1], thick=2
oplot, [x2, xmax], [ymin, y1], thick=2
;- bottom and top
lats_line = (findgen (101) / 50. - 1.) * (txtht - tht0)
oplot, txrad * sin (lats_line), txrad * cos (lats_line), thick=2
oplot, (txrad + maxh) * sin (lats_line), (txrad + maxh) * cos (lats_line), $
	/noclip, thick=2
n_h = fix (maxh / 100. - .001)
;- altitude labels and some additional altitude lines
for i = 1, n_h do begin
	oplot, (txrad + 100. * i) * sin (lats_line), $
		(txrad + 100. * i) * cos (lats_line), $;ps_close2
		linestyle=2, thick=1.5
	tmp = (tht0 - txtht) * [1.005, 1.]
	oplot, (txrad + 100. * i) * sin (tmp), (txrad + 100. * i) * cos (tmp), $
		/noclip
	x = (txrad + 100. * i - 10.) * sin (tht0 - txtht - .004)
	y = (txrad + 100. * i - 10.) * cos (tht0 - txtht - .004)
	str = string (100 * i, format = '(i0)')
	ang = (txtht - tht0) * !radeg
	xyouts, x, y, str, alignment = 1., orientation = ang, charthick=2

	if i eq round(n_h/2.) then begin
		;- axis label
		xyouts, xmin - .08 * (xmax - xmin), .5 * (ymin + ymax), $
			'Altitude [km]', alignment = .7, orientation = ang+90., charthick=2
	endif

endfor

;- oplot electron density height profile at tjornes
dd = min(abs(tht0 - txtht + dens_lats - 0.), minind) 
tjo_edens = reform(edens[1, *])
plot, tjo_edens, alts-6370., xstyle=9, xrange=dens_range, /ystyle, $
	position=[.1, .62, .3, .88], /noerase, yrange=[0, maxh], $
	xtickname=replicate(' ', 60), $
	ytitle='Altitude [km]', charthick=2, xticks=2, xmin=10
axis, /xaxis, /xstyle, charthick=2, xticks=2, xmin=10, $
	xtitle='Log of Electron Density [m!S!E-3!N]!C'

;- oplot electron density height profile at end of RT
end_edens = reform(edens[n_elements(lats)-1, *])
plot, end_edens, alts-6370., xstyle=9, xrange=dens_range, /ystyle, $
	position=[.7, .62, .9, .88], /noerase, yrange=[0, maxh], $
	xtickname=replicate(' ', 60), $
	ytitle='Altitude [km]', charthick=2, xticks=2, xmin=10
axis, /xaxis, /xstyle, charthick=2, xticks=2, xmin=10, $
	xtitle='Log of Electron Density [m!S!E-3!N]!C'

; - oplot electron density at 250km during the day
rt_read_edens_day, edensday, lat, lon, alt
; edensday=ALOG10(edensday)
hours=findgen(24)
plot, hours, edensday, xrange=[0.,24.], /xstyle, $
	position=[.15, .38, .45, .58], /noerase, yrange=[0, 4e11], $
	xtitle='Time [LT]', charthick=2, xticks=4, xmin=6, $
	ystyle=1, yticks=4, ymin=10, $
	ytitle='Electron Density [m!S!E-3!N]!C'
xyouts, 0.3, 0.56,STRTRIM(lat,2)+'N; '+STRTRIM(lon,2)+'E', $
	/norm, charthick=2, charsize=1., align=.5

; - oplot electron density at 200km through the radar range
edens_lon1 = reform(edens[*, round(250.-alts[0]+6370.)])
edens_lon1 = 10.^(edens_lon1)
edens_lon2 = reform(edens[*, round(150.-alts[0]+6370.)])
edens_lon2 = 10.^(edens_lon2)
range=findgen(500)*2000./500.
plot, range, edens_lon1, xrange=[0.,2000.], /xstyle, $
	position=[.6, .38, .9, .58], /noerase, yrange=[0, 5e11], $
	xtitle='Range [km]', charthick=2, xticks=4, xmin=6, $
	ystyle=1, yticks=4, ymin=10, $
	ytitle='Electron Density [m!S!E-3!N]!C'
plot, range, edens_lon2, xrange=[0.,2000.], /xstyle, $
	position=[.6, .38, .9, .58], /noerase, yrange=[0, 5e11], $
	xtitle='Range [km]', charthick=2, xticks=4, xmin=6, $
	ystyle=1, yticks=4, ymin=10, linestyle=2, $
	ytitle='Electron Density [m!S!E-3!N]!C'

;- Add information on RT
xyouts, 0.5, 0.3, 'Ray-tracing parameters:!C!C!7h!3!Ibeg!N='+ $
	STRTRIM(string(elev_beg*180./!PI,format='(g4.02)'),2)+ $
	', !7h!3!Iend!N = '+ $
	STRTRIM(string(elev_end*180./!PI,format='(g4.02)'),2)+ $
	', !7h!3!Istep!N = '+ $
	STRTRIM(string(elev_stp*180./!PI,format='(g4.02)'),2)+ $
	'!C!CRadar: '+radar+', beam '+STRTRIM(string(beam,format='(I0)'),2)+ $
	', Freq. = '+STRTRIM(string(freq_beg,format='(g4.02)'),2)+'MHz', $
	/norm, charthick=2, charsize=1., align=.5


DEVICE,/CLOSE
SET_PLOT,'X'

end
