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
