;+ 
; NAME: 
; CLU_ORB_PLOT_PANEL
;
; PURPOSE: 
; The procedure plots a panel of Cluster orbit data.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; CLU_ORB_PLOT_PANEL
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
; SC: Set this to the number of the spacecraft you would like to plot data from. Can be an array.
;
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'bx_gse','by_gse','bz_gse','by_gsm','bz_gsm','bt'.
;
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
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
pro clu_orb_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	sc=sc, xrange=xrange, yrange=yrange, bar=bar, $
	xy=xy, xz=xz, yz=yz, coords=coords, $
	silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, no_map=no_map, $
	last=last, first=first, with_info=with_info, info=info

common clu_data_blk

if ~keyword_set(sc) then begin
	if ~keyword_set(silent) then $
		prinfo, 'SC not set, using 1.'
	sc = 1
endif

if sc lt 1 or sc gt 4 then  begin
	prinfo, 'Sc must be 1 <= sc <= 4.'
	return
endif

if clu_fgm_info[sc-1].nrecs eq 0L then begin
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

if ~keyword_set(xy) and ~keyword_set(xz) and ~keyword_set(yz) then begin
	if ~keyword_set(silent) then $
		prinfo, 'XY, XZ and YZ not set, using XZ.'
	xz = 1
endif

if ~keyword_set(date) then begin
	caldat, (*clu_fgm_data[sc-1]).juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long
jrange = [sjul, fjul]

if ~keyword_set(xrange) then begin
	if keyword_set(xy) then $
		xrange = [31,-31] $
	else if keyword_set(xz) then $
		xrange = [31,-31] $
	else if keyword_set(yz) then $
		xrange = [-31,31]
endif

if ~keyword_set(yrange) then begin
	if keyword_set(xy) then $
		yrange = [31,-31] $
	else if keyword_set(xz) then $
		yrange = [-31,31] $
	else if keyword_set(yz) then $
		yrange = [-31,31]
endif

if ~keyword_set(coords) then $
	coords = get_coordinates()

if strupcase(coords) ne 'GSE' and strupcase(coords) ne 'GSM' then begin
	prinfo, 'Coordinate system must be GSE or GSM, using GSM.'
	coords = 'GSE'
endif
_coords = strupcase(coords)

if ~keyword_set(xtitle) then begin
	if keyword_set(xy) then $
		_xtitle = 'X '+_coords $
	else if keyword_set(xz) then $
		_xtitle = 'X '+_coords $
	else if keyword_set(yz) then $
		_xtitle = 'Y '+_coords
endif else $
	_xtitle = xtitle

if ~keyword_set(ytitle) then begin
	if keyword_set(xy) then $
		_ytitle = 'Y '+_coords $
	else if keyword_set(xz) then $
		_ytitle = 'Z '+_coords $
	else if keyword_set(yz) then $
		_ytitle = 'Z '+_coords
endif else $
	_ytitle = ytitle

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(linethick) then $
	linethick = 1.

if ~keyword_set(linecolor) then $
	linecolor = clu_color(sc)

if ~keyword_set(no_map) then begin
	orb_plot_panel, xmaps, ymaps, xmap, ymap, $
		xrange=xrange, yrange=yrange, bar=bar, $
		xy=xy, xz=xz, yz=yz, coords=coords, $
		silent=silent, $
		charthick=charthick, charsize=charsize, $ 
		xtitle=xtitle, ytitle=ytitle, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		xtickformat=xtickformat, ytickformat=ytickformat, $
		xtickname=xtickname, ytickname=ytickname, $
		position=position, $
		last=last, first=first, with_info=with_info, info=info
endif

; get data
if keyword_set(xy) then begin
	xtag = 'px_gse'
	ytag = 'py_'+strlowcase(_coords)
endif else if keyword_set(xz) then begin
	xtag = 'px_gse'
	ytag = 'pz_'+strlowcase(_coords)
endif else if keyword_set(yz) then begin
	xtag = 'py_'+strlowcase(_coords)
	ytag = 'pz_'+strlowcase(_coords)
endif

if ~tag_exists((*clu_fgm_data[sc-1]), xtag) then begin
	prinfo, 'Parameter '+xtag+' does not exist in CLU_FGM_DATA.'
	return
endif
if ~tag_exists((*clu_fgm_data[sc-1]), ytag) then begin
	prinfo, 'Parameter '+ytag+' does not exist in CLU_FGM_DATA.'
	return
endif
dd = execute('xdata = (*clu_fgm_data[sc-1]).'+xtag)
dd = execute('ydata = (*clu_fgm_data[sc-1]).'+ytag)

; overplot data
oplot, xdata/!re, ydata/!re, $
	thick=linethick, color=linecolor, linestyle=linestyle, psym=psym

end
