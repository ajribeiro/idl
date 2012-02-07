pro rad_fit_histogram, date, radar, oldfit=oldfit, fitex=fitex, fitacf=fitacf, range=range, binsize=binsize

common rad_data_blk

if ~keyword_set(fitex) and ~keyword_set(fitacf) then $
	fitex = !true

if keyword_set(fitex) then $
	fitacf = !false

if keyword_set(fitacf) then $
	fitex = !false

if ~keyword_set(range) then $
	range = [-200.,200.]

if ~keyword_set(binsize) then $
	binsize = 2.

nbeams = 16
nbins = (range[1]-range[0])/binsize
dbins = 50.

sfjul, [sdate,ndate], [11,11], sjul, fjul, no_days=nd

bhist = make_array(nbins, 16, value=0.001, /float)
shist = make_array(nbins, 16, value=0.001, /float)
fhist = make_array(nbins, 16, value=0.001, /float)
scan_ids = 0.

for d=0, nd-1 do begin

	sfjul, date, 11, sjul+double(d), /jul

	_fitex  = fitex
	_fitacf = fitacf
	bks_files = rad_fit_find_files(date, radar, time=[0,1400], file_count=fc, fitacf=_fitacf, fitex=_fitex)
	if fc lt 1 then begin
		prinfo, 'No files.'
		continue
	endif

	_fitex  = fitex
	_fitacf = fitacf
	rad_fit_read, date, radar, time=[0,1400], /force, fitacf=_fitacf, fitex=_fitex
	
	for b=0, nbeams-1 do begin
		binds = where(rad_fit_data.beam eq b, nn)
		if nn lt 10 then $
			continue
		velocity = rad_fit_data.velocity[binds, *]
		velocity = float(reform(velocity, n_elements(velocity)))
		bhist[*,b] += histogram(velocity, min=range[0], max=range[1], nbins=nbins, loc=loc)
	endfor
	
	for s=0, n_elements(rad_fit_info.scan_ids)-1 do begin
		ascan = rad_fit_info.scan_ids[s]
		if scan_ids[0] eq 0 then begin
			scan_ids[0] = ascan
			ind = 0
		endif else begin
			ind = where(scan_ids eq ascan, cc)
			if cc eq 0 then begin
				scan_ids = [scan_ids, ascan]
				ind = where(scan_ids eq ascan, cc)
			endif
		endelse
		sinds = where(rad_fit_data.scan_id eq ascan, nn)
		if nn lt 10 then $
			continue
		velocity = rad_fit_data.velocity[sinds, *]
		velocity = float(reform(velocity, n_elements(velocity)))
		shist[*,ind] += histogram(velocity, min=range[0], max=range[1], nbins=nbins, loc=loc)
	endfor
	
	for f=0, 8 do begin
		finds = where(rad_fit_data.tfreq/1e3 ge 7.5+f and rad_fit_data.tfreq/1e3 lt 8.5+f, nn)
		if nn lt 10 then $
			continue
		velocity = rad_fit_data.velocity[finds, *]
		velocity = float(reform(velocity, n_elements(velocity)))
		fhist[*,f] += histogram(velocity, min=range[0], max=range[1], nbins=nbins, loc=loc)
	endfor

endfor

ps_open, 'hist_'+radar+'_'+( fitex ? 'fitex' : 'fitacf' ) +'.ps'
set_format, /sard

clear_page
plot_title, strupcase(radar)+' '+( fitex ? 'fitex' : 'fitacf' ), format_juldate(sjul)+ ' - '+format_juldate(sjul+double([nd]))

plot, loc, bhist[*,0], psym=10, pos=define_panel(2,2,0,0), xrange=range, /ylog, yrange=[1,1e6], $
	ytitle='Count', xtickname=replicate(' ', 30), /xstyle, /ystyle
for b=1, nbeams-1 do begin
	oplot, loc, bhist[*,b], color=get_ncolors()/nbeams*b, psym=10
endfor
for i=0, range[1]/dbins do begin
	oplot, replicate(i*dbins, 2), 10.^!y.crange, linestyle=2, color=get_gray()
	oplot, replicate(-i*dbins, 2), 10.^!y.crange, linestyle=2, color=get_gray()
endfor

plot, loc, shist[*,0], psym=10, pos=define_panel(2,2,0,1), xrange=range, /ylog, yrange=[1,1e6], $
	ytitle='Count', xtitle='Velocity', /xstyle, /ystyle
for b=1, n_elements(scan_ids)-1 do begin
	oplot, loc, shist[*,b], color=get_ncolors()/n_elements(scan_ids)*b, psym=10
endfor
for i=0, range[1]/dbins do begin
	oplot, replicate(i*dbins, 2), 10.^!y.crange, linestyle=2, color=get_gray()
	oplot, replicate(-i*dbins, 2), 10.^!y.crange, linestyle=2, color=get_gray()
endfor
pos=define_panel(2,2,0,1)
line_legend, [pos[2]-.1, pos[1]], string(scan_ids,format='(I6)'), $
	color=get_ncolors()/n_elements(scan_ids)*indgen(n_elements(scan_ids)), charsize=.5

plot, loc, fhist[*,0], psym=10, pos=define_panel(2,2,1,0), xrange=range, /ylog, yrange=[1,1e6], $
	ytickname=replicate(' ', 30), xtickname=replicate(' ', 30), /xstyle, /ystyle
for f=1, 8 do begin
	oplot, loc, fhist[*,f], color=get_ncolors()/8*f, psym=10
endfor
for i=0, range[1]/dbins do begin
	oplot, replicate(i*dbins, 2), 10.^!y.crange, linestyle=2, color=get_gray()
	oplot, replicate(-i*dbins, 2), 10.^!y.crange, linestyle=2, color=get_gray()
endfor

plot, loc, total(bhist, 2), psym=10, pos=define_panel(2,2,1,1), xrange=range, /ylog, yrange=[1,1e6], $
	ytickname=replicate(' ', 30), xtitle='Velocity', /xstyle, /ystyle
oplot, loc, total(shist, 2), psym=10
oplot, loc, total(fhist, 2), psym=10
for i=0, range[1]/dbins do begin
	oplot, replicate(i*dbins, 2), 10.^!y.crange, linestyle=2, color=get_gray()
	oplot, replicate(-i*dbins, 2), 10.^!y.crange, linestyle=2, color=get_gray()
endfor

ps_close
end
