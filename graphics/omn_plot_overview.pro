;+ 
; NAME: 
; OMN_PLOT_OVERVIEW
;
; PURPOSE: 
; The procedure plots a overview of OMNI solar wind data. It plots, BX_GSE, BY_GSM, BZ_GSM, VT, NP and PD.
; It simply calls OMN_PLOT_PANEL.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; OMN_PLOT_OVERVIEW
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
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; PSYM: Set this keyword to change the symbol used for plotting.
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
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; EXAMPLE:
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2009.
;-
pro omn_plot_overview, $
	date=date, time=time, long=long, $
	silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info

common omn_data_blk

d = get_format(sard=sard, gupp=gupp)
set_format, /sardines
clear_page

omn_plot_panel, 1, 6, 0, 0, param='bx_gse', $
	date=date, time=time, long=long, $
	/bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first

omn_plot_panel, 1, 6, 0, 1, param='by_gsm', $
	date=date, time=time, long=long, $
	/bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first

omn_plot_panel, 1, 6, 0, 2, param='bz_gsm', $
	date=date, time=time, long=long, $
	/bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first

omn_plot_panel, 1, 6, 0, 3, param='vt', $
	date=date, time=time, long=long, $
	/bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first

omn_plot_panel, 1, 6, 0, 4, param='np', $
	date=date, time=time, long=long, $
	/bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first

omn_plot_panel, 1, 6, 0, 5, param='pd', $
	date=date, time=time, long=long, $
	/bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first, /last

; legend
position = define_panel(1, 6, 0, 5, /bar, with_info=with_info)
line_legend, [position[2]+0.01,position[1]], ['ACE','WIND'], $
	color=[120, 20], thick=linethick, $
	charthick=charthick, charsize=.6*charsize

plot_title, 'OMNI Overview', $
	top_right_title=format_juldate(omn_info.sjul)+'!C!5 to !C!5'+format_juldate(omn_info.fjul)

set_format, sard=sard, gupp=gupp
end
