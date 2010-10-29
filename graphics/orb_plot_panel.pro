;+ 
; NAME: 
; ORB_PLOT_PANEL
;
; PURPOSE: 
; The procedure plots an empty panel for orbit plots.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; ORB_PLOT_PANEL
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
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
;
; XRANGE: Set this keyword to change the range of the x axis.
;
; YRANGE: Set this keyword to change the range of the y axis.
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
; XTICKFORMAT: Set this keyword to change the formatting of the time fopr the x axis.
;
; YTICKFORMAT: Set this keyword to change the formatting of the y axis values.
;
; POSITION: Set this keyword to a 4-element vector of normalized coordinates 
; if you want to override the internal
; positioning calculations.
;
; FIRST: Set this keyword to indicate that this panel is the first panel in
; a ROW of plots. That will force Y axis labels.
;
; LAST: Set this keyword to indicate that this is the last panel in a column,
; hence XTITLE and XTICKNAMES will be set.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; INFO: Set this keyword to plot the panel above a panel which position has been
; defined using DEFINE_PANEL(XMAPS, YMAP, XMAP, YMAP, /WITH_INFO).
;
; EXAMPLE:
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2009.
;-
pro orb_plot_panel, xmaps, ymaps, xmap, ymap, $
	xrange=xrange, yrange=yrange, bar=bar, $
	xy=xy, xz=xz, yz=yz, coords=coords, $
	silent=silent, $
	charthick=charthick, charsize=charsize, $ 
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, no_earth=no_earth, $
	last=last, first=first, with_info=with_info, info=info, no_title=no_title

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(xy) and ~keyword_set(yz) and ~keyword_set(xz) then begin
	if ~keyword_set(silent) then $
		prinfo, 'XY, XZ and YZ not set, using XZ.'
	xz = 1
endif

if ~keyword_set(xrange) then begin
	if keyword_set(xy) then $
		xrange = [21,-21] $
	else if keyword_set(xz) then $
		xrange = [21,-21] $
	else if keyword_set(yz) then $
		xrange = [-21,21]
endif

if ~keyword_set(yrange) then begin
	if keyword_set(xy) then $
		yrange = [21,-21] $
	else if keyword_set(xz) then $
		yrange = [-21,21] $
	else if keyword_set(yz) then $
		yrange = [-21,21]
endif

if ~keyword_set(coords) then $
	coords = get_coordinates()

if strupcase(coords) ne 'GSE' and strupcase(coords) ne 'GSM' then begin
	prinfo, 'Coordinate system must be GSE or GSM, using GSM.'
	coords = 'GSM'
endif
_coords = strupcase(coords)

if ~keyword_set(xtitle) then begin
	if keyword_set(xy) then $
		_xtitle = 'X '+_coords+textoidl(' [R_e]') $
	else if keyword_set(xz) then $
		_xtitle = 'X '+_coords+textoidl(' [R_e]') $
	else if keyword_set(yz) then $
		_xtitle = 'Y '+_coords+textoidl(' [R_e]')
endif else $
	_xtitle = xtitle

if ~keyword_set(xtickname) then $
	_xtickname = '' $
else $
	_xtickname = xtickname

if ~keyword_set(ytitle) then begin
	if keyword_set(xy) then $
		_ytitle = 'Y '+_coords+textoidl(' [R_e]') $
	else if keyword_set(xz) then $
		_ytitle = 'Z '+_coords+textoidl(' [R_e]') $
	else if keyword_set(yz) then $
		_ytitle = 'Z '+_coords+textoidl(' [R_e]')
endif else $
	_ytitle = ytitle

if ~keyword_set(ytickname) then $
	_ytickname = '' $
else $
	_ytickname = ytickname

aspect = abs(float(xrange[1]-xrange[0])/float(yrange[1]-yrange[0]))
if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, bar=bar, no_title=no_title)

; check if format is sardines.
; if yes, loose the x axis information
; unless it is given
fmt = get_format(sardines=sd, tokyo=ty)
if (sd and ~keyword_set(last)) or keyword_set(info) then begin
	if ~keyword_set(xtitle) then $
		_xtitle = ' '
	if ~keyword_set(xtickname) then $
		_xtickname = replicate(' ', 60)
endif
if ty and ~keyword_set(first) then begin
	if ~keyword_set(ytitle) then $
		_ytitle = ' '
	if ~keyword_set(ytickname) then $
		_ytickname = replicate(' ', 60)
endif

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

; Plot axis
plot, [0,0], /nodata, xstyle=5, ystyle=5, $
	yrange=yrange, xrange=xrange, position=position

if ~keyword_set(no_earth) then $
	earth_plot, xy=xy, xz=xz, yz=yz

if ~keyword_set(no_axis) then begin
	; Plot axis
	plot, [0,0], /nodata, xstyle=1, ystyle=1, $
		yrange=yrange, xrange=xrange, position=position, $
		xtitle=_xtitle, ytitle=_ytitle, color=get_foreground(), $
		xtickname=_xtickname, ytickname=_ytickname, $
		xtickformat=xtickformat, ytickformat=ytickformat, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor
		
endif

end
