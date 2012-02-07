;+ 
; NAME: 
; DRAW_IMAGE
; 
; PURPOSE: 
; This procedure plots a 2D array. It does so by using POLYFILL to plot each
; "pixel" of the image. The color of each pixel is determined by its value.
; Using POLYFILL is slower than TV or TVSCL and it creates larger PostScript
; files, however putting axes around the plot and plotting "pixel"
; of different sizes is childplay.
; This procedure can be used to plot any "pixel" data, i.e. All-Sky-Imager
; data, dynamic spectra etc.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; DRAW_IMAGE, Image
;
; INPUTS:
; Image: A 2D numeric array.
;
; OPTIONAL INPUTS:
; Xvalues: The x values of each pixel. Must contain one element more than
; the first dimension of Image. If omitted, FINDGEN is used to generate
; the x values.
;
; Yvalues: The y values of each pixel. Must contain one element more than
; the second dimension of Image. If omitted, FINDGEN is used to generate
; the y values.
;
; KEYWORD PARAMETERS:
; XRANGE: The x range of the plot.
;
; YRANGE: The y range of the plot.
;
; BOTTOM: The lowest color index to use for coloring of the "pixels".
;
; NCOLORS: The number of colors to scale the values of the "pixels" to.
;
; RANGE: The range of data values between which to scale the "pixel" values.
;
; SCALE: Same as RANGE.
;
; NO_PLOT: An array of color indeces which will not be plotted.
;
; XTICKVALUES: The values of the major tickmarks on the x axis.
;
; XTICKFORMAT: The format of the major tickmarks on the x axis.
;
; POSITION: The position of the plot in normalized coordinates.
;
; TITLE: The title of the plot.
;
; XTITLE: The title of the x axis.
;
; YTITLE: The title of teh y axis.
;
; ISO: Set this keyword to make the plot isotropic (force the scaling of the X and Y axes to be equal).
;
; NO_SCALE: Set this keyword to indicate that the image has already been converted to the desired color indices.  GET_COLOR_INDEX() may be used for this purpose and offer more utility than than the scaling functions built into DRAW_IMAGE.  If this keyword is set, the RANGE, SCALE, NCOLORS, and BOTTOM keywords will be ignored.
;
; OVERLAY: The default behaviour of DRAW_IMAGE is to plot a coordinate system
; in which the "pixel" data is placed. If such a coordinate system is
; already established and you want to overlay the image in that
; coordinate system, set this keyword.
;
; _EXTRA: This keyword allows the user to pass keywords to the 
; PLOT command used for establishing the coordinate system 
; without explicitly naming them.
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
; Written by Lasse Clausen, Nov, 24 2009
;-
pro draw_image, image, xvalues, yvalues, $
    xrange=xrange, yrange=yrange, bottom=bottom, ncolors=ncolors, range=range, scale=scale, $
    no_plot=no_plot, xtickvalues=xtickvalues, position=position, $
    xtickformat=xtickformat, title=title, ytitle=ytitle, xtitle=xtitle, $
    overlay=overlay, iso=iso, no_scale=no_scale, _extra=_extra

dim = size(image, /n_dimension)
if dim ne 2 then begin
	prinfo, 'Image is not a 2D array.'
	if ~keyword_set(overlay) then begin
		;- "over"plot the axes
		plot, [0], xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, position=position, $
			_extra=_extra, xtick_get=xtickvalues, xticklen=-!p.ticklen, $
			yticklen=-!p.ticklen, /noerase, xtickformat=xtickformat, xtitle=xtitle, $
			ytitle=ytitle, iso=iso
	endif
	return
endif

ndim = size(image, /dimension)
if ndim[0] eq 0 or ndim[1] eq 0 then begin
	prinfo, 'Image not really 2D, is it?'
	if ~keyword_set(overlay) then begin
		;- "over"plot the axes
		plot, [0], xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, position=position, $
			_extra=_extra, xtick_get=xtickvalues, xticklen=-!p.ticklen, $
			yticklen=-!p.ticklen, /noerase, xtickformat=xtickformat, xtitle=xtitle, $
			ytitle=ytitle, iso=iso
	endif
	return
endif

if n_params() eq 1 then begin
	xvalues = findgen(ndim[0]+1L)
	yvalues = findgen(ndim[1]+1L)
endif

if ~keyword_set(title) then $
	title=''

if ~keyword_set(position) then $
	position = define_panel(1,1,0,0)

if ~keyword_set(bottom) then $
	bottom=get_bottom()

if ~keyword_set(ncolors) then $
	ncolors=get_ncolors()

if ~keyword_set(range) then begin
	mir = min(image, max=mar, /nan)
	_range = [mir, mar]
endif else $
	_range = range

if keyword_set(scale) then $
	_range = scale

nx = n_elements(xvalues)
if ~keyword_set(xrange) then $
	xrange = [xvalues[0], xvalues[nx-1L]]

ny = n_elements(yvalues)
if ~keyword_set(yrange) then $
	yrange = [yvalues[0], yvalues[ny-1L]]

if ndim[0] ne nx-1L then begin
	prinfo, 'X dimensions do not agree.' + string(ndim[0]) + string(nx-1L)
	if ~keyword_set(overlay) then begin
		;- "over"plot the axes
		plot, [0], xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, position=position, $
			_extra=_extra, xtick_get=xtickvalues, xticklen=-!p.ticklen, $
			yticklen=-!p.ticklen, /noerase, xtickformat=xtickformat, xtitle=xtitle, $
			ytitle=ytitle, iso=iso
	endif
	return
endif
if ndim[1] ne ny-1L then begin
	prinfo, 'Y dimensions do not agree.' + string(ndim[1]) + string(ny-1L)
	if ~keyword_set(overlay) then begin
		;- "over"plot the axes
		plot, [0], xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, position=position, $
			_extra=_extra, xtick_get=xtickvalues, xticklen=-!p.ticklen, $
			yticklen=-!p.ticklen, /noerase, xtickformat=xtickformat, xtitle=xtitle, $
			ytitle=ytitle, iso=iso
	endif
	return
endif

; scale image
IF ~KEYWORD_SET(no_scale) THEN BEGIN
    cimage = bytscl(image,min=_range[0],max=_range[1],top=(ncolors - bottom - 1),/nan) + bottom
ENDIF ELSE cimage = image

;stop

if ~keyword_set(overlay) then begin
	;- establish a coordinate system without actually plotting the axes
	;- do not actually plot the axes because plotting of the
	;- rectangles would cover them
	plot, [0], xstyle=5, ystyle=5, xrange=xrange, yrange=yrange, $
		position=position, $
		title=title, iso=iso;, xtickname=replicate(' ',50), ytickname=replicate(' ',50), $
;		_extra=_extra
endif

;- find indeces not to plot
if n_elements(no_plot) ne 0 then begin
	where_str = 'pinds = where('
	for n=0, n_elements(no_plot)-1 do begin
		if n eq 0 then $
			where_str += 'cimage ne no_plot['+string(n,format='(I03)')+']+bottom' $
		else $
			where_str += ' and cimage ne no_plot['+string(n,format='(I03)')+$
				']+bottom'
	endfor
	where_str += ')'
	s = execute(where_str)
endif else $
	pinds = lindgen(n_elements(cimage))

if pinds[0] ne -1 then begin
	; take only those indeces which are within the
	; plotting area
	pinds = array_indices(cimage, pinds)
	if yrange[0] lt yrange[1] then begin
		apinds = where(xvalues[pinds[0,*]] ge xrange[0] and xvalues[pinds[0,*]] le xrange[1] and $
			yvalues[pinds[1,*]] ge yrange[0] and yvalues[pinds[1,*]] le yrange[1] and finite(image[pinds[0,*],pinds[1,*]]), nc)
	endif else begin
		apinds = where(xvalues[pinds[0,*]] ge xrange[0] and xvalues[pinds[0,*]] le xrange[1] and $
			yvalues[pinds[1,*]] le yrange[0] and yvalues[pinds[1,*]] ge yrange[1] and finite(image[pinds[0,*],pinds[1,*]]), nc)
	endelse
	if nc eq 0L then begin
		prinfo, 'No valid points found in x/yrange.'
		if ~keyword_set(overlay) then begin
			;- "over"plot the axes
			plot, [0], xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, position=position, $
				_extra=_extra, xtick_get=xtickvalues, xticklen=-!p.ticklen, $
				yticklen=-!p.ticklen, /noerase, xtickformat=xtickformat, xtitle=xtitle, $
				ytitle=ytitle, iso=iso
		endif
		return
	endif
	pnx = nc
	;- plot using polyfill
	for i=0L, pnx-1L do begin
			polyfill, xvalues[pinds[0,apinds[i]]+[0L,1L,1L,0L,0L]], $
				yvalues[pinds[1,apinds[i]]+[0L,0L,1L,1L,0L]], /data, $
				color=cimage[pinds[0,apinds[i]],pinds[1,apinds[i]]], noclip=0
	endfor
endif else begin
	prinfo, 'No data to plot.'
endelse

if ~keyword_set(overlay) then begin
	;- "over"plot the axes
	plot, [0], xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, position=position, $
		_extra=_extra, xtick_get=xtickvalues, xticklen=-!p.ticklen, $
		yticklen=-!p.ticklen, /noerase, xtickformat=xtickformat, xtitle=xtitle, $
		ytitle=ytitle, iso=iso
endif

end
