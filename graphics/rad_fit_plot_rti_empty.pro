pro rad_fit_plot_rti_empty, date=date, time=time, param=param, beams=beams, all=all, $
		coords=coords, yrange=yrange, scale=scale, xticks=xticks, $
		charthick=charthick, charsize=charsize, $
		no_title=no_title, ground=ground, sc_values=sc_values, titlestr=titlestr

if ~keyword_set(coords) then $
	coords = get_coordinates()

if keyword_set(all) then $
	beams = indgen(16)

if n_elements(beams) eq 0 then $
	beams = rad_get_beam()

if ~keyword_set(param) then $
	param = get_parameter()

if ~is_valid_coord_system(coords) then begin
	prinfo, 'Not a valid coordinate system: '+coords
	prinfo, 'Using gate.'
	coords = 'gate'
endif

if n_elements(param) gt 1 then begin
	npanels = n_elements(param)
	if n_elements(beams) gt 1 then begin
		prinfo, 'Cannot set multiple beams and multiple params.'
		return
	endif
	if n_elements(sc_values) gt 0 then begin
		prinfo, 'Cannot set SC_VALUES and multiple params.'
		return
	endif
endif else $
	npanels = n_elements(beams)

; calculate number of panels per page
xmaps = floor(sqrt(npanels)) > 1
ymaps = ceil(npanels/float(xmaps)) > 1

; take into account format of page
; if landscape, make xmaps > ymaps
fmt = get_format(landscape=ls, sardines=sd)
if ls then begin
	if ymaps gt xmaps then begin
		tt = xmaps
		xmaps = ymaps
		ymaps = tt
	endif
; if portrait, make ymaps > xmaps
endif else begin
	if xmaps gt ymaps then begin
		tt = ymaps
		ymaps = xmaps
		xmaps = tt
	endif
endelse

; for multiple parameter plot
; always stack them
if n_elements(param) gt 1 then begin
	ymaps = npanels
	xmaps = 1
endif

; for plots of less than 4 beams
; always stack them
if n_elements(beams) lt 4 then begin
	ymaps = npanels
	xmaps = 1
endif

; set format to sardines
set_format, /sardines

; clear output area
clear_page

; set charsize of info panels smaller
ichars = (!d.name eq 'X' ? 1. : 1. ) * get_charsize(xmaps > 1, ymaps > 2)

beamstr = strjoin(string(beams, format='(I02)'), ', ')

if n_elements(titlestr) eq 0 then $
	titlestr = 'No Data ()'

plot_title, ' ', titlestr

if n_elements(param) eq 1 then begin
	plot_colorbar, xmaps, 1, xmaps-1, 0, scale=scale, param=param[0], /with_info, ground=ground, sc_values=sc_values
endif

; loop through panels
for b=0, npanels-1 do begin

	ascale = 0

	if n_elements(param) gt 1 then begin
		aparam = param[b]
		abeam = beams[0]
		if keyword_set(scale) then $
			ascale = scale[b*2:b*2+1]
	endif else begin
		aparam = param[0]
		abeam = beams[b]
		if keyword_set(scale) then $
			ascale = scale
	endelse

	if n_elements(sc_values) gt 0 then $
		asc_values = sc_values $
	else $
		asc_values = 0

	xmap = b mod xmaps
	ymap = b/xmaps

	first = 0
	if xmap eq 0 then $
		first = 1

	last = 0
	if ymap eq ymaps-1 then $
		last = 1

	if n_elements(param) gt 1 then begin
		;only plot tfreq noise panel once
		if b eq 0 then begin
			tposition = define_panel(xmaps, ymaps, xmap, ymap, /bar, /with_info, no_title=no_title)
			position = [tposition[0], tposition[3]+0.012, tposition[2], tposition[3]+0.048]
			; set up coordinate system for plot
			plot, [0,0], /nodata, position=position, $
				xstyle=5, ystyle=5, $
				xrange=xrange, yrange=[0,60]
			align = 1
			xpos = position[0] - 0.09*(position[2]-position[0])
			loff = 0.
			ypos = (position[1]+position[3])/2. - 0.2*(position[3]-position[1]) + loff
			xyouts, xpos, ypos, 'CPID', /norm, charsize=ichars, width=strwidth, align=align
			position = define_panel(xmaps, ymaps, xmap, ymap, /bar, /with_info, no_title=no_title)
			position = [position[0], position[3]+0.05, $
				position[2], position[3]+0.09]
			plot, [0,1], /nodata, position=position, $
				yticks=1, xtickname=replicate(' ',40), charsize=ichars, $
				xstyle=1, ystyle=9, xticklen=-!p.ticklen, yticklen=-!p.ticklen
			align = 1
			xpos = position[0] - 0.09*(position[2]-position[0])
			loff = .02*ichars
			ypos = (position[1]+position[3])/2. - 0.2*(position[3]-position[1]) + loff
			xyouts, xpos, ypos, 'Freq!C[MHz]', /norm, charsize=ichars, width=strwidth, align=align
			plots, xpos+(1.-2.*align)*[strwidth/4., 3./4.*strwidth], ypos-0.01-1.2*loff, /norm
			axis, /yaxis, ystyle=1, yrange=!y.crange, $
				charsize=ichars, yticks=1, yticklen=-!p.ticklen
			align = 0
			xpos = position[2] + 0.09*(position[2]-position[0])
			loff = 0.
			ypos = (position[1]+position[3])/2. - 0.2*(position[3]-position[1]) + loff
			xyouts, xpos, ypos, 'Nave', /norm, charsize=ichars, width=strwidth, align=align
			plots, xpos+(1.-2.*align)*[strwidth/4., 3./4.*strwidth], ypos-0.01-1.2*loff, /norm, linestyle=1
			position = define_panel(xmaps, ymaps, xmap, ymap, /bar, /with_info, no_title=no_title)
			position = [position[0], position[3]+0.1, $
				position[2], position[3]+0.14]
			plot, [0,1], /nodata, position=position, $
				yticks=1, xtickname=replicate(' ',40), charsize=ichars, $
				xstyle=1, ystyle=9, xticklen=-!p.ticklen, yticklen=-!p.ticklen, title='Beam'+(n_elements(beams) gt 1 ? 's' : '')+' '+beamstr
			align = 1
			xpos = position[0] - 0.09*(position[2]-position[0])
			loff = .0
			ypos = (position[1]+position[3])/2. - 0.2*(position[3]-position[1]) + loff
			xyouts, xpos, ypos, 'N.Sky', /norm, charsize=ichars, width=strwidth, align=align
			plots, xpos+(1.-2.*align)*[strwidth/4., 3./4.*strwidth], ypos-0.01-1.2*loff, /norm
			axis, /yaxis, ystyle=1, yrange=!y.crange, $
				charsize=ichars, yticks=1, yticklen=-!p.ticklen
			align = 0
			xpos = position[2] + 0.09*(position[2]-position[0])
			loff = 0.
			ypos = (position[1]+position[3])/2. - 0.2*(position[3]-position[1]) + loff
			xyouts, xpos, ypos, 'N.Search', /norm, charsize=ichars, width=strwidth, align=align
			plots, xpos+(1.-2.*align)*[strwidth/4., 3./4.*strwidth], ypos-0.01-1.2*loff, /norm, linestyle=1
		endif
		plot_colorbar, xmaps, ymaps, xmap, ymap, scale=ascale, param=aparam, /with_info, ground=ground, sc_values=sc_values
	endif else begin
		; plot noise and tfreq info panel
		if ymap eq 0 then begin
			tposition = define_panel(xmaps, ymaps, xmap, ymap, /bar, /with_info, no_title=no_title)
			position = [tposition[0], tposition[3]+0.012, tposition[2], tposition[3]+0.048]
			; set up coordinate system for plot
			plot, [0,0], /nodata, position=position, $
				xstyle=5, ystyle=5, $
				xrange=xrange, yrange=[0,60]
			position = define_panel(xmaps, ymaps, xmap, ymap, /bar, /with_info, no_title=no_title)
			position = [position[0], position[3]+0.05, $
				position[2], position[3]+0.09]
			plot, [0,1], /nodata, position=position, $
				yticks=1, xtickname=replicate(' ',40), $
				xstyle=1, ystyle=9, xticklen=-!p.ticklen, yticklen=-!p.ticklen
			align = 1
			xpos = position[0] - 0.09*(position[2]-position[0])
			loff = .02*ichars
			ypos = (position[1]+position[3])/2. - 0.2*(position[3]-position[1]) + loff
			xyouts, xpos, ypos, 'Freq!C[MHz]', /norm, charsize=ichars, width=strwidth, align=align
			plots, xpos+(1.-2.*align)*[strwidth/4., 3./4.*strwidth], ypos-0.01-1.2*loff, /norm
			axis, /yaxis, ystyle=1, yrange=!y.crange, $
				charsize=ichars, yticks=1, yticklen=-!p.ticklen
			align = 0
			xpos = position[2] + 0.09*(position[2]-position[0])
			loff = 0.
			ypos = (position[1]+position[3])/2. - 0.2*(position[3]-position[1]) + loff
			xyouts, xpos, ypos, 'Nave', /norm, charsize=ichars, width=strwidth, align=align
			plots, xpos+(1.-2.*align)*[strwidth/4., 3./4.*strwidth], ypos-0.01-1.2*loff, /norm, linestyle=1
			position = define_panel(xmaps, ymaps, xmap, ymap, /bar, /with_info, no_title=no_title)
			position = [position[0], position[3]+0.1, $
				position[2], position[3]+0.14]
			plot, [0,1], /nodata, position=position, $
				yticks=1, xtickname=replicate(' ',40), $
				xstyle=1, ystyle=9, xticklen=-!p.ticklen, yticklen=-!p.ticklen, title='Beam'+(n_elements(beams) gt 1 ? 's' : '')+' '+beamstr
			align = 1
			xpos = position[0] - 0.09*(position[2]-position[0])
			loff = .0
			ypos = (position[1]+position[3])/2. - 0.2*(position[3]-position[1]) + loff
			xyouts, xpos, ypos, 'N.Sky', /norm, charsize=ichars, width=strwidth, align=align
			plots, xpos+(1.-2.*align)*[strwidth/4., 3./4.*strwidth], ypos-0.01-1.2*loff, /norm
			axis, /yaxis, ystyle=1, yrange=!y.crange, $
				charsize=ichars, yticks=1, yticklen=-!p.ticklen
			align = 0
			xpos = position[2] + 0.09*(position[2]-position[0])
			loff = 0.
			ypos = (position[1]+position[3])/2. - 0.2*(position[3]-position[1]) + loff
			xyouts, xpos, ypos, 'N.Search', /norm, charsize=ichars, width=strwidth, align=align
			plots, xpos+(1.-2.*align)*[strwidth/4., 3./4.*strwidth], ypos-0.01-1.2*loff, /norm, linestyle=1
		endif
	endelse

	charsize = get_charsize(xmaps, ymaps)
	
	_xtitle = 'Time UT'
	_xtickname = ''
	_ytitle = get_default_title(coords)

	; check if format is sardines.
	; if yes, loose the x axis information
	; unless it is given
	fmt = get_format(sardines=sd, tokyo=ty)
	if sd and ~keyword_set(last) then begin
		if ~keyword_set(xtitle) then $
			_xtitle = ' '
		if ~keyword_set(xtickformat) then $
			_xtickformat = ''
		if ~keyword_set(xtickname) then $
			_xtickname = replicate(' ', 60)
	endif
	if ty and ~keyword_set(first) then begin
		if ~keyword_set(ytitle) then $
			_ytitle = ' '
		if ~keyword_set(ytickformat) then $
			_ytickformat = ''
		if ~keyword_set(ytickname) then $
			_ytickname = replicate(' ', 60)
	endif

	position = define_panel(xmaps, ymaps, xmap, ymap, /bar, /with_info, no_title=no_title)
	
	; "over"plot axis
	plot, [0,0], /nodata, position=position, $
		charthick=charthick, charsize=charsize, $
		yrange=yrange, xrange=xrange, $
		xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
		xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
		xtickformat=_xtickformat, ytickformat=_ytickformat, $
		xtickname=_xtickname, ytickname=_ytickname, $
		color=get_foreground(), title=title, $
		xticklen=-!p.ticklen, yticklen=-!p.ticklen

	;xyouts, .5, .2, 'No Data', align=.5, charsize=5.*( strcmp(!d.name,'x',/fold) ? 1. : .5), charthick=5.*(strcmp(!d.name,'x',/fold) ? 1. : 2.)

endfor

end