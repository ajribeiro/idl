pro disk_usage, fname=fname, ofile=ofile, ylog=ylog

if ~keyword_set(ofile) then $
	ofile = '/home/davit/scripts/disk_usage.ps'

if ~keyword_set(fname) then $
	fname = '/home/davit/fsize.dat'

if ~file_test(fname) then begin
	prinfo, 'Save file not found: '+fname
	return
endif

restore, fname

tt = size(filesize, /dim)
nformats = tt[0]
if nformats ne n_elements(formats) then begin
	prinfo, 'Number of formats does not match array size.'
	return
endif
nyears = tt[1]
if nyears ne n_elements(years) then begin
	prinfo, 'Number of years does not match array size.'
	return
endif
ncols = n_elements(colsss[0,*])
if ncols ne nformats then begin
	prinfo, 'Number of colors does not match number of formats.'
	return
endif

fsize = filesize/1024.^3
tot = total(fsize, 1)

pos = define_panel(1,1,0,0)

if keyword_set(ylog) then $
	ymin = 0.1 $
else $
	ymin = 0.

ps_open, ofile

; load colors
rad_load_colortable
tvlct, rr, gg, bb, /get
for i=0, ncols-1 do begin
	rr[i+1] = colsss[0,i]
	gg[i+1] = colsss[1,i]
	bb[i+1] = colsss[2,i]
endfor
tvlct, rr, gg, bb

set_format, /land
clear_page

; plot legend
plot, [0,0], /nodata, xstyle=5, yrange=[0,1], $
	ystyle=5, xrange=[0,nformats], $
	pos=[pos[0]+0.02, pos[3]+.09, pos[2]-0.02, pos[3]+.1]
for f=0, nformats-1 do begin
	polyfill, [f,f,f+1,f+1,f], [0,1,1,0,0], color=f+1
endfor
plot, [0,0], /nodata, xstyle=9, yrange=[0,1], $
	/ystyle, xrange=[0,nformats], $
	pos=[pos[0]+0.02, pos[3]+.09, pos[2]-0.02, pos[3]+.1], $
	ytickname=replicate(' ', 20), yticks=1, xtickname=replicate(' ', 20), xthick=3, ythick=3
axis, /xaxis, /xstyle, xrange=[0,nformats], xticks=nformats-1, $
	xtickname=formats, charsize=1., charthick=3, xtickv=(findgen(nformats)+.5), $
	xticklen=-.5, xthick=3

plot, [0,0], /nodata, xstyle=5, ystyle=5, pos=pos, $
	yrange=[ymin,max(tot)+.25*max(tot)], xrange=[0, nyears+1], ylog=ylog
for y=0, nyears-1 do begin
	if keyword_set(ylog) then $
		fsort = sort(reform(fsize[*,y])) $
	else $
		fsort = indgen(nformats)
	sfsize = fsize[fsort,y]
	scols  = (indgen(nformats)+1)[fsort]
	yoff = -1.
	for f=0, nformats-1 do begin
		if sfsize[f] eq 0. then $
			continue
		yoff = ( yoff eq -1. ? ymin/100. : total(sfsize[0:f-1])+ymin/100. )
		polyfill, y+1.+[-.25,.25,.25,-.25,-.25], yoff+[0.,0.,sfsize[f],sfsize[f],0.], color=scols[f], /data, noclip=0
	endfor
endfor
plot, [0,0], /nodata, xstyle=9, ystyle=9, pos=pos, $
	ylog=ylog, yrange=[ymin,max(tot)+.25*max(tot)], xrange=[0, nyears+1], ytitle='GByte', $
	xtitle='Year', xticks=nyears+1, $
	xtickname=[' ', "'"+strmid(years,2,2), ' '], xthick=3, ythick=3, charthick=3, $
	title='As of '+cdate+' UTC', ytick_get=ytickvals
for i=0, n_elements(ytickvals)-1 do $
	if ytickvals[i] gt 0. then $
		oplot, !x.crange, replicate(ytickvals[i],2), linestyle=2, color=get_gray(), thick=3
for y=0, nyears-1 do begin
	if tot[y] gt 1000. then $
		totstr = strtrim(string(tot[y]/1024.,format='(F5.1)')+'TB',2) $
	else $
		totstr = strtrim(string(tot[y],format='(F5.1)')+'GB',2)
	xyouts, y+.82, tot[y]+.02*max(tot), totstr, /data, align=1., charthick=4, $
		charsize=-1., orient=-90., width=strwidth
	tmp = convert_coord([0.,0.],.2+[0., strwidth], /norm, /to_data)
	strwidth = 1.3*abs(tmp[1,1]-tmp[1,0])
	polyfill, y+1.+[-.35,.35,.35,-.35,-.35], tot[y]+.02*max(tot)+[0., 0., strwidth, strwidth, 0.], color=get_background()
	xyouts, y+.82, tot[y]+.02*max(tot), totstr, /data, align=1., charthick=4, $
		charsize=1., orient=-90., width=strwidth
endfor

line_legend, [.15, .6], $
	['Total File Size:', string(total(fsize),format='(F7.1)')+' GByte', ' ', 'Total Disk Size:  ', string(27.*1e12/1024.^3,format='(F7.1)')+' GByte'], $
	/no_bullet, charthick=3, charsize=1.


clear_page

; plot legend
plot, [0,0], /nodata, xstyle=5, yrange=[0,1], $
	ystyle=5, xrange=[0,nformats], $
	pos=[pos[0]+0.02, pos[3]+.09, pos[2]-0.02, pos[3]+.1]
for f=0, nformats-1 do begin
	polyfill, [f,f,f+1,f+1,f], [0,1,1,0,0], color=f+1
endfor
plot, [0,0], /nodata, xstyle=9, yrange=[0,1], $
	/ystyle, xrange=[0,nformats], $
	pos=[pos[0]+0.02, pos[3]+.09, pos[2]-0.02, pos[3]+.1], $
	ytickname=replicate(' ', 20), yticks=1, xtickname=replicate(' ', 20), xthick=3, ythick=3
axis, /xaxis, /xstyle, xrange=[0,nformats], xticks=nformats-1, $
	xtickname=formats, charsize=1., charthick=3, xtickv=(findgen(nformats)+.5), $
	xticklen=-.5, xthick=3

plot, [0,0], /nodata, xstyle=5, ystyle=5, pos=pos, $
	yrange=[0,100], xrange=[0, nyears+1]
for y=0, nyears-1 do begin
	for f=0, nformats-1 do begin
		yoff = ( f eq 0 ? 0. : total(fsize[0:f-1,y])/tot[y]*100. )
		polyfill, y+1.+[-.25,.25,.25,-.25,-.25], yoff+[0.,0.,fsize[f,y],fsize[f,y],0.]/tot[y]*100., color=f+1, /data
	endfor
endfor
plot, [0,0], /nodata, xstyle=9, ystyle=9, pos=pos, $
	yrange=[0,100], xrange=[0, nyears+1], ytitle='%', $
	xtitle='Year', xticks=nyears+1, $
	xtickname=[' ', "'"+strmid(years,2,2), ' '], xthick=3, ythick=3, charthick=3, $
	title='As of '+cdate+' UTC', ytick_get=ytickvals
for i=0, n_elements(ytickvals)-1 do $
	if ytickvals[i] gt 0. then $
		oplot, !x.crange, replicate(ytickvals[i],2), linestyle=2, color=get_gray(), thick=3

clear_page

; plot legend
plot, [0,0], /nodata, xstyle=5, yrange=[0,1], $
	ystyle=5, xrange=[0,nformats], $
	pos=[pos[0]+0.02, pos[3]+.09, pos[2]-0.02, pos[3]+.1]
for f=0, nformats-1 do begin
	polyfill, [f,f,f+1,f+1,f], [0,1,1,0,0], color=f+1
endfor
plot, [0,0], /nodata, xstyle=9, yrange=[0,1], $
	/ystyle, xrange=[0,nformats], $
	pos=[pos[0]+0.02, pos[3]+.09, pos[2]-0.02, pos[3]+.1], $
	ytickname=replicate(' ', 20), yticks=1, xtickname=replicate(' ', 20), xthick=3, ythick=3
axis, /xaxis, /xstyle, xrange=[0,nformats], xticks=nformats-1, $
	xtickname=formats, charsize=1., charthick=3, xtickv=(findgen(nformats)+.5), $
	xticklen=-.5, xthick=3

relfsize = total(filesize, 2)/total(filesize)*100.d
pie_chart, relfsize, colors=indgen(nformats)+1, $
	thick=3, /outline

plot, [0,0], /nodata, xstyle=5, ystyle=5, pos=pos, $
	title='As of '+cdate+' UTC', charthick=3

rad_load_colortable

ps_close, /no_file


end
