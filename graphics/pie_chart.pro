; $Id: pie_chart.pro,v 1.0 1994/10/20 12:27:30 idl Exp $

; Copyright 1994 Jason Mathews
; Unpublished work.
; Permission granted to use and modify this program so long as the
; copyright above is maintained, modifications are documented, and
; credit is given for any use of the program..

;+
; NAME:
;	PIE_CHART
;
; PURPOSE:
;	Create a pie chart, or overplot on an existing one.
;
; CATEGORY:
;	Graphics.
;
; CALLING SEQUENCE:
;	PIE_CHART, Values
;
; INPUTS:
;	Values:	A vector containing the values to be represented by the pie
;		slices.  Each element in VALUES corresponds to a single pie
;		slice in the output.
;
; KEYWORD PARAMETERS:
;      COLORS:	A vector, the same size as VALUES, containing the color index
;		to be used for each bar.  If not specified, the colors are
;		selected based on spacing the color indices as widely as
;		possible within the available colors (specified by D.N_COLORS).
;
;    PIENAMES:	A string array, containing one string label per slice.
;
;	TITLE:	A string containing the main title for the pie chart.
;
;    SUBTITLE:	A string containing the subtitle for the pie chart.
;
;      RADIUS:  Radius of pie chart (default = 38% of window size)
;
;       LOTUS:	If set, this keyword specifies that the pie slices are
;		labeled like Lotus 1-2-3 with each pie slice with its data
;		value and percentage.
;
;     NOTICKS:  If set, this keyword specifies that the tickmarks on each
;		pie slice will not be drawn.
;
;      NOFILL:  If set, this keyword specifies that the pie slices are
;		not filled in (the default is to fill in each slice
;		with a different color).
;
;     OUTLINE:	If set, this keyword specifies that an outline should be
;		drawn around each slice.
;
;    OVERPLOT:	If set, this keyword specifies that the pie chart should be
;		overplotted on an existing graph.
;
;  BACKGROUND:	A scalar that specifies the color index to be used for
;		the background color.  By default, the normal IDL background
;		color is used.
;
; OUTPUTS:
;	A pie chart is created, or an existing one is overplotted.
;
; EXAMPLE:
;	To create a simple pie chart:
;
;	PIE_CHART, [25, 75], TITLE='Simple Pie Chart'
;
; MODIFICATION HISTORY:
;	Written by:	Jason Mathews
;			National Space Science Data Center (NSSDC)
;			NASA/Goddard Space Flight Center, Code 633
;			Greenbelt, MD  20771-0001 USA
;			mathews@nssdc.gsfc.nasa.gov
;			October, 1994
;
;-

pro pie_chart, values, colors=colors, pienames=pienames, $
	title=title, subtitle=subtitle, outline=outline, $
	overplot=overplot, background=background, $
	noticks=noticks, lotus=lotus, nofill=nofill, $
	thick=thick, charthick=charthick, charsie=charsize, $
	position=position

if (n_params() ne 1) then Message, 'Incorrect number of arguments.'

nvals = n_elements(values)	; Determine number of pie slices

; We need the window dimensions (dx, dy) to compute the pie size
; that will fit into that window.

; if X device and no window is open then use predefined window size
; otherwise use device x/y size.
if !d.name eq 'X' and !d.window eq -1L then begin dx = 640 & dy = 512
endif else begin dx = !d.x_size & dy = !d.y_size & endelse

print, dx, dy

; Center x/y coordinates
cx = dx/2 & cy = dy/2

; Pie radius
if not(keyword_set(radius)) then $
	radius = 3 * min([dx,dy]) / 8	; radius = 75% window size / 2

; Main title
if not(keyword_set(title)) then title = ''

; Subtitle
if not(keyword_set(subtitle)) then subtitle = ''

; Outline of slices; default is none
outline = keyword_set(outline) OR keyword_set(nofill)

; Fill in pie slices; default is on
piefill = NOT(keyword_set(nofill))

; Inhibit tick marks; default is enabled
noticks = keyword_set(noticks)

; Background color index; defaults to 0 (usually black) if not specified
if not(keyword_set(background)) then background=0

if ~keyword_set(charsize) then $
	charsize = !p.charsize

if ~keyword_set(charthick) then $
	charthick = !p.charthick

if ~keyword_set(thick) then $
	thick = !p.thick

; Define math constants
PI = atan(1) * 4.D
rads = PI / 180.D		; degrees-radians conversion factor

; Create new plot, no data
if not keyword_set(overplot) then $
	plot, [0, dx], [0, dy], /NODATA, XSTYLE=5, YSTYLE=5, TITLE=title, $
	SUBTITLE=subtitle, BACKGROUND=background, /iso, $
		position=position

if (nvals ne 0) then begin
	; Default colors spaced evenly in current color table
	if n_elements(colors) eq 0 then $
		colors = (!d.n_colors / float(nvals)) * (indgen(nvals)+0.5)

	sum = abs(values(0))
	for i=1, nvals-1 do sum = sum + abs(values(i))
endif else sum = 0

; If the sum of values is zero then we cannot display a percentage
; used by each element.

if (sum ne 0) then begin

; Define more constants

factor = rads * 360.D / sum
two_pi = 2.D * PI
angle = PI/2.D & oa = angle

if keyword_set(pienames) then $
	textwidth = charsize * !d.x_ch_size * (Max(StrLen(pienames)) > 1) $
else if keyword_set(lotus) then begin
	pienames = StrTrim(Fix(values),1) + ' (' + StrTrim(Fix(100*values/sum), 1) + '%)'
	textwidth = !d.x_ch_size * (6 + StrLen(StrTrim(sum, 1)))
endif

num_names = n_elements(pienames)

; # extra intervals for sampling the arc
if (nvals eq 1) then extra = 1 else extra = 2

for i = 0, nvals-1 do begin
	angle = angle + abs(values(i)) * factor
	x = cx + radius * sin(angle)
	y = cy + radius * cos(angle)

	if (piefill) then begin
	; fill in pie piece with next color
	ints = ((angle - oa) / rads + extra) > 1
	angles = oa + indgen(ints + 1) * rads
	xv = cx + radius * sin(angles)
	yv = cy + radius * cos(angles)
	xv(ints) = cx & yv(ints) = cy 	; set end point at pie center
	PolyFill, xv, yv, COLOR = colors(i), thick=thick
	endif

	if (outline and nvals ne 1) then begin
	oplot, [ cx, x ], [ cy, y ], thick=1.5*thick, color=get_background()
	oplot, [ cx, x ], [ cy, y ], thick=thick, color=get_foreground()
	endif

	; Draw tick marks
	oa = (oa + angle) / 2.D
	sa = sin(oa) & ca = cos(oa)
	if not noticks then begin
		xtickv = cx + [radius-4, radius+4] * sa
		ytickv = cy + [radius-4, radius+4] * ca
		oplot, xtickv, ytickv, thick=thick
	endif

	; Draw labels if label name is defined
	if (i lt num_names) then begin
		x = cx + (radius+5) * sa & y = cy + (radius+5) * ca
		; shift label to the left if on left half of pie
		if (oa gt PI AND oa lt TWO_PI) then x = x - textwidth $
		else if (oa eq PI OR oa eq TWO_PI) then x = x - textwidth/2
		; shift label up or down if on top or bottom respectively
		if (oa ge 2.356194D AND oa le 3.92691D) then y = y - !d.y_ch_size $
		else if (oa ge 5.4977873D AND oa le 7.0685837D) then y = y + !D.y_ch_size
		xyouts, x, y, pienames(i), charthick=charthick, charsize=charsize
	endif
	oa = angle
endfor
endif

; draw outline of circle

if (sum eq 0 OR outline) then begin
xold = 0 & yold = radius
for a = 1, 180 do begin
	angle = double(a) * rads
	x = radius * sin(angle) & y = radius * cos(angle)
	oplot, cx - [xold, x], cy - [yold, y], thick=4*thick, color=get_background()
	oplot, cx + [xold, x], cy - [yold, y], thick=4*thick, color=get_background()
	oplot, cx - [xold, x], cy - [yold, y], thick=thick, color=get_foreground()
	oplot, cx + [xold, x], cy - [yold, y], thick=thick, color=get_foreground()
	xold = x & yold = y
endfor
endif

end
