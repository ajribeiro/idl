;+ 
; NAME: 
; WND_PLOT_OVERVIEW
;
; PURPOSE: 
; The procedure plots a overview of Wind solar wind data. It plots, BX_GSE, BY_GSM, BZ_GSM, VT, NP and PD.
; It simply calls WND_MAG_PLOT_PANEL or WND_SWE_PLOT_PANEL, depending on the parameter.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; WND_PLOT_OVERVIEW
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
pro wnd_plot_overview, $
	date=date, time=time, long=long, $
	bar=bar, $
	silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info

common wnd_data_blk

clear_page

wnd_mag_plot_panel, 1, 6, 0, 0, param='bx_gse', $
	date=date, time=time, long=long, $
	bar=bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first

wnd_mag_plot_panel, 1, 6, 0, 1, param='by_gsm', $
	date=date, time=time, long=long, $
	bar=bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first

wnd_mag_plot_panel, 1, 6, 0, 2, param='bz_gsm', $
	date=date, time=time, long=long, $
	bar=bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first

wnd_swe_plot_panel, 1, 6, 0, 3, param='vt', $
	date=date, time=time, long=long, $
	bar=bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first

wnd_swe_plot_panel, 1, 6, 0, 4, param='np', $
	date=date, time=time, long=long, $
	bar=bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first

wnd_swe_plot_panel, 1, 6, 0, 5, param='pd', $
	date=date, time=time, long=long, $
	bar=bar, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info, /first, /last

plot_title, 'Wind Overview', $
	top_right_title=format_juldate(wnd_mag_info.sjul)+'!C!5 to !C!5'+format_juldate(wnd_mag_info.fjul)

end
