;+ 
; NAME: 
; ionos_plot_sigalt_panel
;
; PURPOSE: 
; This function plots ionospheric conductivities vs altitude: 
; sig0 = longitudinal or direct conductivity
; sig1 = Pedersen conductivity
; sig2 = Hall conductivity
; 
; CATEGORY: 
; Ionospheric models
; 
; CALLING SEQUENCE:
; ionos_plot_sigalt_panel, date, time, glat, glon, $
;		xmap=xmap, ymap=ymap, xmaps=xmaps, ymaps=ymaps
;
; INPUTS:
; DATE: YYYYMMDD
;
; TIME: HHMM in UT (for now the model has a 1HR time resolution)
;
; GLAT and GLON: latitude and longitude in geographic coordinates
;
; OPTIONAL INPUTS:
;
; KEYWORDS:
;
; COMMON BLOCKS:
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
; Written by Sebastien de Larquier, Feb. 2011
;-
pro		ionos_plot_sigalt_panel, date, time, glat, glon, $
			xmap=xmap, ymap=ymap, xmaps=xmaps, ymaps=ymaps

; Call ionos calc for model output
ionos_calc_sig, date, time, glat, glon, $
		sig0=sig0, Isig0=Isig0, $
		sig1=sig1, Isig1=Isig1, $
		sig2=sig2, Isig2=Isig2, $
		alt=alt

; Define plotting area
if ~keyword_set(xmap) then $
	xmap = 1
if ~keyword_set(ymap) then $
	ymap = 1
if ~keyword_set(xmaps) then $
	xmaps = 0
if ~keyword_set(ymaps) then $
	ymaps = 0
position = define_panel(xmap,ymap,xmaps,ymaps)
charsize = get_charsize(xmap,ymap)*.6
xrange = [1e-8,1e3]
yrange = [120.,620.]
xtitle = 'Conductivity (S/m)'
ytitle = 'Altitude (km)'
title = '!4r!3!I0!N='+STRTRIM(string(Isig0,'(e9.3)'),2)+ $
	', !4r!3!I1!N='+STRTRIM(string(Isig1,'(e9.3)'),2)+ $
	', !4r!3!I2!N='+STRTRIM(string(Isig2,'(e9.3)'),2)

; Plot
plot, sig0, alt, /xlog, $
	position=position, charsize=charsize, $
	xstyle=1, ystyle=1, $
	xrange=xrange, yrange=yrange, $
	xtitle=xtitle, ytitle=ytitle, $
	title=title
oplot, sig1, alt, col=50
oplot, sig2, alt, col=250

header = format_date(date, /human)+'  '+ $
	format_time(time, /human)+'UT  ('+ $
	STRTRIM(string(glat,'(f5.1)'),2)+' , '+ $
	STRTRIM(string(glon,'(f5.1)'),2)+')'
xyouts, .5, .92, header,/normal, $
	charsize=charsize*1.2, align=.5

end