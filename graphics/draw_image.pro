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
; NCOLORS: The number of colors to scale the values of teh "pixels" to.
;
; RANGE: The range of data values between which to scale the "pixel" values.
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
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro draw_image, image, xvalues, yvalues, $
    xrange=xrange, yrange=yrange, bottom=bottom, ncolors=ncolors, range=range, $
    no_plot=no_plot, xtickvalues=xtickvalues, position=position, $
    xtickformat=xtickformat, title=title, ytitle=ytitle, xtitle=xtitle, $
    overlay=overlay, _extra=_extra

dim = size(image, /n_dimension)
if dim ne 2 then begin
	prinfo, 'Image is not a 2D array.'
	return
endif

ndim = size(image, /dimension)
if ndim[0] eq 0 or ndim[1] eq 0 then begin
	prinfo, 'Image not really 2D, is it?'
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
	range = [mir, mar]
endif

nx = n_elements(xvalues)
if ~keyword_set(xrange) then $
	xrange = [xvalues[0], xvalues[nx-1L]]

ny = n_elements(yvalues)
if ~keyword_set(yrange) then $
	yrange = [yvalues[0], yvalues[ny-1L]]

if ndim[0] ne nx-1L then begin
	message, 'X dimensions do not agree.' + string(ndim[0]) + string(nx-1L), /info
	return
endif
if ndim[1] ne ny-1L then begin
	message, 'Y dimensions do not agree.' + string(ndim[1]) + string(ny-1L), /info
	return
endif

; scale image
cimage = bytscl(image, min=range[0], max=range[1], top=(ncolors - bottom - 1), $
	/nan) + bottom

;stop

if ~keyword_set(overlay) then begin
	;- establish a coordinate system without actually plotting the axes
	;- do not actually plot the axes because plotting of the
	;- rectangles would cover them
	plot, [0], xstyle=5, ystyle=5, xrange=xrange, yrange=yrange, $
		position=position, $
		title=title;, xtickname=replicate(' ',50), ytickname=replicate(' ',50), $
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
	pinds = array_indices(cimage, pinds)
;	help, pinds, n_elements(pinds)/2L
	pnx = n_elements(pinds)/2L
	;- plot using polyfill
	for i=0L, pnx-1L do begin
		if finite(image[pinds[0,i],pinds[1,i]]) then $
			polyfill, xvalues[pinds[0,i]+[0L,1L,1L,0L,0L]], $
				yvalues[pinds[1,i]+[0L,0L,1L,1L,0L]], /data, $
				color=cimage[pinds[0,i],pinds[1,i]], noclip=0
	endfor
endif else begin
	prinfo, 'No data to plot.'
endelse

if ~keyword_set(overlay) then begin
	;- "over"plot the axes
	plot, [0], xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, position=position, $
		_extra=_extra, xtick_get=xtickvalues, xticklen=-!p.ticklen, $
		yticklen=-!p.ticklen, /noerase, xtickformat=xtickformat, xtitle=xtitle, $
		ytitle=ytitle
endif

end
