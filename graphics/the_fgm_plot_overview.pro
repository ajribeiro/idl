;+ 
; NAME: 
; THE_FGM_PLOT_OVERVIEW
;
; PURPOSE: 
; The procedure plots a overview of Themis FGM data. It plots three panels, BX_GSE, BY_GSM, BZ_GSM, BT.
; If more than one spacecraft number is given, the data is for each parameter is
; overplotted in one panel. It simply calls THE_FGM_PLOT_PANEL.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; THE_FGM_PLOT_OVERVIEW
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
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2010.
;-
pro the_fgm_plot_overview, $
	date=date, time=time, long=long, $
	probe=probe, silent=silent, coords=coords, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	with_info=with_info

common the_data_blk

if ~keyword_set(probe) then begin
	if ~keyword_set(silent) then $
		prinfo, 'PROBE not set, using all.'
	_probe = ['a', 'b', 'c', 'd', 'e']
endif else $
	_probe = strlowcase(probe)
npr = n_elements(_probe)
if npr gt 1 then $
	bar = 1 $
else $
	bar = 0

num_probe = byte(_probe) - (byte('a'))[0]

d = get_format(sard=sard, gupp=gupp)
set_format, /sardines
clear_page

for p=0, npr-1 do begin


	if n_elements(linecolor) gt 0 then $
		_linecolor = linecolor $
	else $
		_linecolor = the_color(num_probe[p])

	if num_probe[p] lt 0 or num_probe[p] gt 4 then  begin
		prinfo, 'PROBE must be a <= PROBE <= e.'
		continue
	endif

	if the_fgm_info[num_probe[p]].nrecs eq 0L then begin
		prinfo, 'No data loaded for PROBE: '+string(_probe[p])
		continue
	endif

	xstyle = 5
	ystyle = 5
	if p eq 0 then begin
		xstyle = 1
		ystyle = 1
	endif

	the_fgm_plot_panel, 1, 4, 0, 0, param='bx_gse', $
		date=date, time=time, long=long, coords=coords, $
		probe=_probe[p], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=_linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first

	the_fgm_plot_panel, 1, 4, 0, 1, param='by_gsm', $
		date=date, time=time, long=long, coords=coords, $
		probe=_probe[p], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=_linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first

	the_fgm_plot_panel, 1, 4, 0, 2, param='bz_gsm', $
		date=date, time=time, long=long, coords=coords, $
		probe=_probe[p], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=_linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first

	the_fgm_plot_panel, 1, 4, 0, 3, param='bt', $
		date=date, time=time, long=long, coords=coords, $
		probe=_probe[p], silent=silent, bar=bar, $
		charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
		linestyle=linestyle, linecolor=_linecolor, linethick=linethick, $
		xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
		with_info=with_info, xstyle=xstyle, ystyle=ystyle, /first, /last

endfor

if npr gt 1 then begin
	position = define_panel(1, 4, 0, 0, bar=bar, with_info=with_info)
	line_legend, [position[2]+0.01,position[1]], ['ThA','ThB','ThC','ThD','ThE'], $
		color=[the_color(0), the_color(1), the_color(2), the_color(3), the_color(4)], thick=linethick, $
		charthick=charthick, charsize=.6*charsize
endif

plot_title, 'Themis FGM Overview', $
	top_right_title=format_juldate(the_fgm_info[num_probe[0]].sjul)+'!C!5 to !C!5'+format_juldate(the_fgm_info[num_probe[0]].fjul)

set_format, sard=sard, gupp=gupp
end
