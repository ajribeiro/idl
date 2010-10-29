;+ 
; NAME: 
; GBM_PLOT_OVERVIEW
; 
; PURPOSE: 
; This procedure plots an overview the time series of a GBM.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; GBM_PLOT_OVERVIEW
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
; XTICKS: Set this keyword to change the number of major x tick marks.
;
; XMINOR: Set this keyword to change the number of minor x tick marks.
;
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
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
; XTICKFORMAT: Set this keyword to change the formatting of the time for the x axis.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2009.
;-
pro gbm_plot_overview, $
	date=date, time=time, long=long, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, xtitle=xtitle, $
	xticks=xticks, xminor=xminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, $
	xtickname=xtickname, $
	with_info=with_info

common gbm_data_blk

clear_page

gbm_plot_panel, 1, 4, 0, 0, param='bx_mag', $
	date=date, time=time, long=long, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, xtitle=xtitle, $
	xticks=xticks, xminor=xminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, $
	xtickname=xtickname, $
	with_info=with_info, /first

gbm_plot_panel, 1, 4, 0, 1, param='by_mag', $
	date=date, time=time, long=long, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, xtitle=xtitle, $
	xticks=xticks, xminor=xminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, $
	xtickname=xtickname, $
	with_info=with_info, /first

gbm_plot_panel, 1, 4, 0, 2, param='bz_mag', $
	date=date, time=time, long=long, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, xtitle=xtitle, $
	xticks=xticks, xminor=xminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, $
	xtickname=xtickname, $
	with_info=with_info, /first

gbm_plot_panel, 1, 4, 0, 3, param='bt_mag', $
	date=date, time=time, long=long, $
	silent=silent, bar=bar, $
	charthick=charthick, charsize=charsize, psym=psym, $ 
	xstyle=xstyle, xtitle=xtitle, $
	xticks=xticks, xminor=xminor, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, $
	xtickname=xtickname, $
	with_info=with_info, /last, /first

plot_title, strupcase(gbm_info.station), $
	textoidl($
		'('+string(gbm_info.mlat,format='(F6.1)')+'\circ!5, '+string(gbm_info.mlon,format='(F6.1)')+'\circ!5) magn, '+$
		'('+string(gbm_info.glat,format='(F6.1)')+'\circ!5, '+string(gbm_info.glon,format='(F6.1)')+'\circ!5) geog, '+$
		'L = '+string(gbm_info.l_value,format='(F4.1)')), $
	top_right_title=format_juldate(gbm_info.sjul)+'!C!5 to !C!5'+format_juldate(gbm_info.fjul)

end
