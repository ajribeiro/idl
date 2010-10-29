;+ 
; NAME: 
; AUR_PLOT_PANEL
;
; PURPOSE: 
; 
; CATEGORY: 
; 
; CALLING SEQUENCE:  
; Graphics
; 
; CALLING SEQUENCE: 
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
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; TIME: A 2-element vector giving the time range to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; PSYM: Set this keyword to change the symbol used for plotting.
;
; XSTYLE: Set this keyword to change the style of the x axis.
;
; YSTYLE: Set this keyword to change the style of the y axis.
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
; LINESTYLE: Set this keyword to change the style of the line.
; Default is 0 (solid).
;
; LINECOLOR: Set this keyword to a color index to change the color of the line.
; Default is black.
;
; LINETHICK: Set this keyword to change the thickness of the line.
; Default is 1.
;
; XTICKFORMAT: Set this keyword to change the formatting of the time fopr the x axis.
;
; YTICKFORMAT: Set this keyword to change the formatting of the y axis values.
;
; POSITION: Set this keyword to a 4-element vector of normalized coordinates 
; if you want to override the internal
; positioning calculations.
;
; LAST: Set this keyword to indicate that this is the last panel in a column,
; hence XTITLE and XTICKNAMES will be set.
;
; EXAMPLE:
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2009.
;-
pro aur_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	yrange=yrange, bar=bar, $
	silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	linestyle=linestyle, linethick=linethick, $
	xtickformat=xtickformat, ytickformat=ytickformat, position=position, $
	last=last, first=first, with_info=with_info, info=info, no_title=no_title, $
	aur=aur, sym=sym

common aur_data_blk

if aur_info.nrecs eq 0L then begin
	prinfo, 'No data loaded.'
	return
endif

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

_sym = !false
_aur = !false

if keyword_set(sym) then $
	_sym = !true

if keyword_set(aur) then $
	_aur = !true

if ~keyword_set(aur) and ~keyword_set(sym) then begin
	_sym = !true
	_aur = !true
endif

if ~keyword_set(position) then begin
	if keyword_set(info) then begin
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, /with_info)
		position = [position[0], position[3], $
			position[2], position[3]+0.05]
	endif else $
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info,no_title=no_title)
endif

p1 = [position[0], position[1], position[2], position[1]+.49*(position[3]-position[1])]
p2 = [position[0], position[1]+.51*(position[3]-position[1]), position[2], position[3]]

if ~keyword_set(date) then begin
	caldat, aur_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long
xrange = [sjul, fjul]

if ~keyword_set(xtitle) then $
	_xtitle = 'Time UT' $
else $
	_xtitle = xtitle

if ~keyword_set(xtickformat) then $
	_xtickformat = 'label_date' $
else $
	_xtickformat = xtickformat

if ~keyword_set(xtickname) then $
	_xtickname = '' $
else $
	_xtickname = xtickname

if keyword_set(ytitle) then $
	_ytitle = ytitle

if ~keyword_set(ytickformat) then $
	_ytickformat = '' $
else $
	_ytickformat = ytickformat

if ~keyword_set(ytickname) then $
	_ytickname = '' $
else $
	_ytickname = ytickname

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

if keyword_set(yrange) then $
	_yrange = yrange

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(linethick) then $
	linethick = 1.

if ~keyword_set(linecolor) then $
	linecolor = get_foreground()

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

if ~keyword_set(xticks) then $
	xticks = get_xticks(sjul, fjul, xminor=_xminor)

if keyword_set(xminor) then $
	_xminor = xminor

; get data
xtag = 'juls'
dd = execute('xdata = aur_data.'+xtag)
if _aur then begin
	ytag1 = 'au_index'
	ytag2 = 'al_index'
	ytag3 = 'ae_index'
	ytag4 = 'ao_index'
	if ~tag_exists(aur_data, xtag) then begin
		prinfo, 'Parameter '+xtag+' does not exist in AUR_DATA.'
		return
	endif
	if ~tag_exists(aur_data, ytag1) then begin
		prinfo, 'Parameter '+ytag1+' does not exist in AUR_DATA.'
		return
	endif
	if ~tag_exists(aur_data, ytag2) then begin
		prinfo, 'Parameter '+ytag2+' does not exist in AUR_DATA.'
		return
	endif
	if ~tag_exists(aur_data, ytag3) then begin
		prinfo, 'Parameter '+ytag3+' does not exist in AUR_DATA.'
		return
	endif
	if ~tag_exists(aur_data, ytag4) then begin
		prinfo, 'Parameter '+ytag4+' does not exist in AUR_DATA.'
		return
	endif
	dd = execute('ydata1 = aur_data.'+ytag1)
	dd = execute('ydata2 = aur_data.'+ytag2)
	dd = execute('ydata3 = aur_data.'+ytag3)
	dd = execute('ydata4 = aur_data.'+ytag4)

	if ~keyword_set(ytitle) then $
		_ytitle = 'AU, AL, AE, AO [nT]'
	
	if ~keyword_set(yrange) then $
		_yrange = [-500,500]
	
	if ~_sym then $
		p1 = position
	
	; set up coordinate system for plot
	plot, [0,0], /nodata, position=p1, $
		charthick=charthick, charsize=(keyword_set(info) ? .6 : 1.)*charsize, $ 
		xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
		xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
		xtickformat=_xtickformat, ytickformat=_ytickformat, $
		xtickname=_xtickname, ytickname=_ytickname, $
		xrange=xrange, yrange=_yrange, $
		color=get_foreground()
	
	; overplot data
	oplot, xdata, ydata1, $
		thick=linethick, color=get_foreground(), linestyle=linestyle, psym=psym
	oplot, xdata, ydata2, $
		thick=linethick, color=250, linestyle=linestyle, psym=psym
	oplot, xdata, ydata3, $
		thick=linethick, color=100, linestyle=linestyle, psym=psym
	oplot, xdata, ydata4, $
		thick=linethick, color=30, linestyle=linestyle, psym=psym
	
	; legend
	line_legend, [p1[2]+0.01,p1[1]], ['AU','AL','AE','AO'], $
		color=[get_foreground(), 250, 100, 30], thick=linethick, $
		charthick=charthick, charsize=.6*charsize
endif
if _sym then begin
	ytag5 = 'sym_h'
	ytag6 = 'sym_d'
	ytag7 = 'asy_h'
	ytag8 = 'asy_d'
	if ~tag_exists(aur_data, ytag5) then begin
		prinfo, 'Parameter '+ytag1+' does not exist in AUR_DATA.'
		return
	endif
	if ~tag_exists(aur_data, ytag6) then begin
		prinfo, 'Parameter '+ytag2+' does not exist in AUR_DATA.'
		return
	endif
	if ~tag_exists(aur_data, ytag7) then begin
		prinfo, 'Parameter '+ytag3+' does not exist in AUR_DATA.'
		return
	endif
	if ~tag_exists(aur_data, ytag8) then begin
		prinfo, 'Parameter '+ytag4+' does not exist in AUR_DATA.'
		return
	endif
	dd = execute('ydata5 = aur_data.'+ytag5)
	dd = execute('ydata6 = aur_data.'+ytag6)
	dd = execute('ydata7 = aur_data.'+ytag7)
	dd = execute('ydata8 = aur_data.'+ytag8)

	if ~keyword_set(ytitle) then $
		_ytitle = 'SYM H/D, ASY H/D [nT]'
	
	if ~keyword_set(yrange) then $
		_yrange = [-50,50]

	if ~_aur then $
		p2 = position
	
	; set up coordinate system for plot
	plot, [0,0], /nodata, position=p2, $
		charthick=charthick, charsize=(keyword_set(info) ? .6 : 1.)*charsize, $ 
		xstyle=xstyle, ystyle=ystyle, xtitle='', ytitle=_ytitle, $
		xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
		xtickformat='', ytickformat=_ytickformat, $
		xtickname=replicate(' ', 60), ytickname=_ytickname, $
		xrange=xrange, yrange=_yrange, $
		color=get_foreground()
	
	oplot, xdata, ydata5, $
		thick=linethick, color=get_foreground(), linestyle=linestyle, psym=psym
	oplot, xdata, ydata6, $
		thick=linethick, color=250, linestyle=linestyle, psym=psym
	oplot, xdata, ydata7, $
		thick=linethick, color=100, linestyle=linestyle, psym=psym
	oplot, xdata, ydata8, $
		thick=linethick, color=30, linestyle=linestyle, psym=psym
	
	; legend
	line_legend, [p2[2]+0.01,p2[1]], ['SYM H','SYM D','ASY H','ASY D'], $
		color=[get_foreground(), 250, 100, 30], thick=linethick, $
		charthick=charthick, charsize=.6*charsize
endif

end
