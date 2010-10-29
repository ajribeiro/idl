;+ 
; NAME: 
; CLU_FGM_PLOT_OVERVIEW
;
; PURPOSE: 
; The procedure plots a overview of Cluster FGM data. It plots three panels, BX_GSE, BY_GSM, BZ_GSM, BT.
; If more than one spacecraft number is given, the data is for each parameter is
; overplotted in one panel. It simply calls CLU_FGM_PLOT_PANEL.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; CLU_FGM_PLOT_OVERVIEW
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
; Written by: Lasse Clausen, 2010.
;-
pro clu_fgm_plot_overview, $
	date=date, time=time, long=long, $
	sc=sc, silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info

common clu_data_blk

if ~keyword_set(sc) then begin
	if ~keyword_set(silent) then $
		prinfo, 'SC not set, using all.'
	sc = [1, 2, 3, 4]
endif
nsc = n_elements(sc)
if nsc gt 1 then $
	bar = 1 $
else $
	bar = 0

d = get_format(sard=sard, gupp=gupp)
set_format, /sardines
clear_page

for s=0, nsc-1 do begin

	if sc[s] lt 1 or sc[s] gt 4 then  begin
		prinfo, 'Sc must be 1 <= SC <= 4.'
		continue
	endif

	if clu_fgm_info[sc[s]-1].nrecs eq 0L then begin
		prinfo, 'No data loaded for SC: '+string(sc[s])
		continue
	endif

	xstyle = 5
	ystyle = 5
	if s eq 0 then begin
		xstyle = 1
		ystyle = 1
	endif

	clu_fgm_plot_panel, 1, 4, 0, 0, param='bx_gse', $
		date=date, time=time, long=long, $
		sc=sc[s], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first

	clu_fgm_plot_panel, 1, 4, 0, 1, param='by_gsm', $
		date=date, time=time, long=long, $
		sc=sc[s], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first

	clu_fgm_plot_panel, 1, 4, 0, 2, param='bz_gsm', $
		date=date, time=time, long=long, $
		sc=sc[s], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first

	clu_fgm_plot_panel, 1, 4, 0, 3, param='bt', $
		date=date, time=time, long=long, $
		sc=sc[s], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first, /last

endfor

if nsc gt 1 then begin
	position = define_panel(1, 4, 0, 0, bar=bar, with_info=with_info)
	line_legend, [position[2]+0.01,position[1]], ['C1','C2','C3','C4'], $
		color=[clu_color(1), clu_color(2), clu_color(3), clu_color(4)], thick=linethick, $
		charthick=charthick, charsize=.6*charsize
endif

plot_title, 'Cluster FGM Overview', $
	top_right_title=format_juldate(clu_fgm_info[sc[0]-1].sjul)+'!C!5 to !C!5'+format_juldate(clu_fgm_info[sc[0]-1].fjul)

set_format, sard=sard, gupp=gupp
end
