;+ 
; NAME: 
; ACE_PLOT_PANEL
;
; PURPOSE: 
; The procedure plots a panel of ACE solar wind data. It simply calls ACE_MAG_PLOT_PANEL or ACE_SWE_PLOT_PANEL, depending on the parameter.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; ACE_PLOT_PANEL
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
; LAG: Set this keyword to the number of minutes you want to lag the 
; ACE data when plotting. +ve lag means ACE measurements are shifted
; to account for the travel time towards Earth.
;
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'bx_gse','by_gse','bz_gse','by_gsm','bz_gsm','bt',
; 'cone_angle', clock_angle', 
; 'ex_gse','ey_gse','ez_gse','ey_gsm','ez_gsm','et','beta',
; 'vx_gse','vy_gse','vz_gse','vy_gsm','vz_gsm','vt','np' and 'pd'.
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
; XTICKNAME: Set this keyword to an array of strings to put on the major tickmarks of the x axis.
;
; YTICKNAME: Set this keyword to an array of strings to put on the major tickmarks of the x axis.
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
; and frequency info panels. Of course, this keyword only takes
; effect if you do not use the position keyword.
;
; INFO: Set this keyword to plot the panel above a panel which position has been
; defined using DEFINE_PANEL(XMAPS, YMAP, XMAP, YMAP, /WITH_INFO). Of course, this keyword only takes
; effect if you do not use the position keyword.
;
; NO_TITLE: If this keyword is set, the panel size will be calculated without 
; leaving space for a big title on the page. Of course, this keyword only takes
; effect if you do not use the position keyword.
;
; EXAMPLE:
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2009.
;-
pro ace_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, lag=lag, $
	param=param, yrange=yrange, bar=bar, $
	silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, $
	last=last, first=first, with_info=with_info, info=info, no_title=no_title

common ace_data_blk

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(param) then $
	param = 'bx_gse'

ind = where(ace_mag_info.parameters eq strlowcase(param),cc)
if cc gt 0 then begin
	ace_mag_plot_panel, xmaps, ymaps, xmap, ymap, $
		date=date, time=time, long=long, lag=lag, $
		param=param, yrange=yrange, bar=bar, $
		silent=silent, $
		charthick=charthick, charsize=charsize, psym=psym, $ 
		linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
		xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		xtickformat=xtickformat, ytickformat=ytickformat, $
		xtickname=xtickname, ytickname=ytickname, $
		position=position, $
		last=last, first=first, with_info=with_info, info=info, no_title=no_title
	return
endif

ind = where(ace_swe_info.parameters eq strlowcase(param),cc)
if cc gt 0 then $
	ace_swe_plot_panel, xmaps, ymaps, xmap, ymap, $
		date=date, time=time, long=long, lag=lag, $
		param=param, yrange=yrange, bar=bar, $
		silent=silent, $
		charthick=charthick, charsize=charsize, psym=psym, $ 
		linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
		xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		xtickformat=xtickformat, ytickformat=ytickformat, $
		xtickname=xtickname, ytickname=ytickname, $
		position=position, $
		last=last, first=first, with_info=with_info, info=info, no_title=no_title

if cc eq 0 then $
	prinfo, 'Parameter "'+param+'" not found.'

end
