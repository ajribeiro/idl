pro ssn_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	yrange=yrange, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, $
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, panel_position=panel_position, $
	last=last, first=first, with_info=with_info, info=info, no_title=no_title, $
	title=title, horizontal_ytitle=horizontal_ytitle, leftyaxis=leftyaxis

if n_params() lt 4 then begin
	if ~keyword_set(silent) and ~keyword_set(position) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(date) then begin
	curjul = systime(/julian)
	caldat, curjul, month, day, year
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, using 1749-2011.'
	date = [17490101, year*10000L + month*100L + day]
endif

if ~keyword_set(time) then $
	time = [0000,2400]
sfjul, date, time, sjul, fjul, long=long, no_month=nm, no_year=ny

xrange = [sjul, fjul]

if n_elements(xtitle) eq 0 then $
	_xtitle = 'Time' $
else $
	_xtitle = xtitle

if n_elements(xtickformat) eq 0 then $
	_xtickformat = 'label_date' $
else $
	_xtickformat = xtickformat

if n_elements(xtickname) eq 0 then $
	_xtickname = '' $
else $
	_xtickname = xtickname

if n_elements(ytitle) eq 0 then $
	_ytitle = 'Sunspot Number' $
else $
	_ytitle = ytitle

if n_elements(ytickformat) eq 0 then $
	_ytickformat = '' $
else $
	_ytickformat = ytickformat

if n_elements(ytickname) eq 0 then $
	_ytickname = '' $
else $
	_ytickname = ytickname

if n_elements(yticks) eq 0 then $
	_yticks = ( keyword_set(info) ? 1 : 0 ) $
else $
	_yticks = yticks

if ~keyword_set(position) then begin
	if keyword_set(info) then begin
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, /with_info, no_title=no_title)
		position = [position[0], position[3]+0.03, $
			position[2], position[3]+0.07]
	endif else if keyword_set(panel_position) then $
		position = [panel_position[0], panel_position[3]+0.03, panel_position[2], panel_position[3]+0.07] $
	else $
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info, no_title=no_title)
endif

; check if format is sardines.
; if yes, loose the x axis information
; unless it is given
fmt = get_format(sardines=sd, tokyo=ty)
if (sd and ~keyword_set(last)) or keyword_set(info) then begin
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

if ~keyword_set(xstyle) then $
	xstyle = ( keyword_set(leftyaxis) ? 5 : 1 )

if ~keyword_set(ystyle) then $
	ystyle = ( keyword_set(leftyaxis) ? 5 : 1 )

if ~keyword_set(yrange) then $
	yrange = [0,300]

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(linethick) then $
	linethick = 1.

if ~keyword_set(linecolor) then $
	linecolor = get_foreground()

if ~keyword_set(xticks) then begin
	if ny ge 100 then begin
		dd = label_date(date_format='%m!C%Y')
		xtickv = timegen(start=sjul, final=fjul, unit='Y', step=50)
		xticks =  n_elements(xtickv)-1
	endif else if ny ge 20 then begin
		dd = label_date(date_format='%m!C%Y')
		xtickv = timegen(start=sjul, final=fjul, unit='Y', step=10)
		xticks =  n_elements(xtickv)-1
	endif else if ny ge 2 then begin
		dd = label_date(date_format='%m!C%Y')
		xtickv = timegen(start=sjul, final=fjul, unit='Y', step=1)
		xticks =  n_elements(xtickv)-1
	endif else if nm ge 12 then begin
		dd = label_date(date_format='%m!C%Y')
		xtickv = timegen(start=sjul, final=fjul, unit='M', step=2)
		xticks =  n_elements(xtickv)-1
	endif else if nm ge 6 then begin
		dd = label_date(date_format='%m!C%Y')
		xtickv = timegen(start=sjul, final=fjul, unit='M', step=1)
		xticks =  n_elements(xtickv)-1
	endif else if nm ge 1 then begin
		dd = label_date(date_format='%d-%n!C%Y')
		xtickv = timegen(start=sjul, final=fjul, unit='M', step=.5)
		xticks = n_elements(xtickv)-1
	endif else begin
		dd = label_date(date_format='%h:%i')
		xticks = get_xticks(sjul, fjul, xminor=_xminor)
	endelse
endif

if keyword_set(xminor) then $
	_xminor = xminor

if ~keyword_set(yminor) then $
	yminor = 6

if ~keyword_set(psym) then begin
	load_usersym, /circle
	psym = 8
endif

; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=charsize, $
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=( keyword_set(horizontal_ytitle) ? ' ' : _ytitle ), $
	xticks=xticks, xminor=_xminor, yticks=_yticks, yminor=yminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xrange=xrange, yrange=yrange, $
	color=get_foreground(), title=title, xticklen=-!p.ticklen, yticklen=-!p.ticklen, xtickv=xtickv

if keyword_set(info) then $
	xyouts, position[0]-.05*(position[2]-position[0]), $
		(position[1]+position[3])/2., ytitle, align=1, /norm, $
		charsize=.6*charsize

; get data
fname = getenv('SSN_DATA_PATH')+'/spot_num.txt'
if ~file_test(fname) then begin
	prinfo, 'Sunspot number file not found. Run get_ssn.sh in /sd-data/ssn: '+fname
	return
endif
nrecs = file_lines(fname)-1
juls = dblarr(nrecs)
ssn  = fltarr(nrecs)
stde = fltarr(nrecs)
header = ''
ayr = 0
amn = 0
assn = 0.
astd = 0.
openr, ilun, fname, /get_lun
readf, ilun, header
for i=0, nrecs-1 do begin
	readf, ilun, ayr, amn, assn, astd
	juls[i] = julday(amn, 1, ayr, 0)
	ssn[i] = assn
	stde[i] = astd
endfor
free_lun, ilun

; overplot data
oplot, juls, ssn, $
	thick=linethick, color=linecolor, linestyle=linestyle, psym=psym
for i=0, nrecs-1 do $
	oplot, replicate(juls[i],2), ssn[i]+[-1.,1.]*stde[i],thick=linethick/3.

if keyword_set(leftyaxis) then $
	axis, /yaxis, ystyle=1, yrange=!y.crange, $
	charthick=charthick, charsize=charsize, ytitle=( keyword_set(horizontal_ytitle) ? ' ' : _ytitle ), $
	yticks=_yticks, yminor=yminor, ytickformat=_ytickformat, ytickname=_ytickname, $
	color=get_foreground(), yticklen=-!p.ticklen

if (ystyle and 4) gt 0 then $
	return

if keyword_set(horizontal_ytitle) then begin
	xoff = ( strcmp(!d.name, 'ps', /fold) ? 0.075 : 0.09 )
	if keyword_set(leftyaxis) then $
		xpos = position[2] + (1.45+( strcmp(!d.name, 'ps', /fold) ? 0.0 : 0.2 ))*xoff*(position[2]-position[0]) $
	else $
		xpos = position[0] - xoff*(position[2]-position[0])
	ypos = (position[1]+position[3])/2. + (keyword_set(info) ? 0.2*(position[3]-position[1]) : 0.)
	xyouts, xpos, ypos, _ytitle, align=1., /norm, charthick=charthick, charsize=charsize
endif

end