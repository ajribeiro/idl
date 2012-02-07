;+
; NAME:
; OVERLAY_TERMINATOR
;
; PURPOSE:
; This procedure overlays the day/night terminator on a stereographic map grid produced by
; MAP_PLOT_PANEL.
;
; CATEGORY:
; Graphics
;
; CALLING SEQUENCE:
;
; KEYWORD PARAMETERS:
; DATE: Set this keyword to the date for which you want to overlay the terminator.
;
; TIME: Set this keyword to the UT time for which you want to overlay the terminator.
;
; COORDS: Set this keyword to the coordinates in which to overlay the terminator.
;
; LINECOLOR: Set this keyword to set the line color used to plot the terminator.
;
; LINESTYLE: Set this keyword to set the line style used to plot the terminator.
;
; LINETHICK: Set this keyword to set the line thickness used to plot the terminator.
;
; LABEL: Set this keyword to plot AM/PM labels for the terminator.
;
; XRANGE: Set this keyword to the range of the x axis being used.
;
; YRANGE: Set this keyword to the range of the y axis being used.
;
; CHARSIZE: Set this keyword to change the terminator label font size.
;
; CHARTHICK: Set this keyword to change the terminator label font thickness.
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; NORTH: Set this keyword to overlay the northern hemisphere coast.
;
; SOUTH: Set this keyword to overlay the southern hemisphere coast.
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
; Based on Sebastien de Larquier's PLOT_SOLEL.
; Written by Evan Thomas, April, 20 2011
;-
pro overlay_terminator, date, time, coords=coords, $
	hemisphere=hemisphere, north=north, south=south, $
	linecolor=linecolor, linestyle=linestyle, $
	linethick=linethick, xrange=xrange, yrange=yrange, $
	label=label, charsize=charsize, charthick=charthick

if ~keyword_set(date) then begin
	prinfo, 'Must give date when overlaying terminator.'
	return
endif

if ~keyword_set(time) then begin
	time = 0000
endif

if ~keyword_set(coords) then $
	coords = get_coordinates()

; we need this later
if coords eq 'mlt' then begin
	in_mlt = !true
	_coords = 'magn'
endif else begin
	_coords = coords
	in_mlt = !false
endelse

if ~keyword_set(linethick) then $
	linethick = !p.thick

if n_elements(linestyle) lt 0 then $
	linestyle = 1.

if  n_elements(linecolor) lt 0 then $
	linecolor = get_black()

if ~keyword_set(hemisphere) then begin
  if keyword_set(north) then $
    hemisphere = 1. $
  else if keyword_set(south) then $
    hemisphere = -1. $
  else $
    hemisphere = 1.
endif

parse_date, date, year, month, day
jd = getJD(day, month, year)

hour = round(time/100)
mn = time-hour*100

latitude = -90. + findgen(181)*1.
longitude = findgen(360)*1.
localtime = hour*60.d + mn*1.d + fltarr(360)
t = calcTimeJulianCent(jd + localtime/1440.d)
zone = 0.
Zenarr = fltarr(360,181)
term = 90. + fltarr(360,2)

; Get yrsec for MLT plotting
sfjul, date, time, jul
caldat, jul, mm, dd, year
yrsec = (jul-julday(1,1,year,0,0,0))*86400.d

; Calculate terminator location in geographic coordinates
for nlon = 0,359 do begin
	for nlat = 0,180 do begin
		az = calcAzEl( solarZen, t[nlon], localtime[nlon], latitude[nlat], longitude[nlon], zone)
		Zenarr[nlon, nlat] = solarZen
		if abs(90.-solarZen) lt term[nlon,0] then begin
			term[nlon,0] = abs(90.-solarZen)
			term[nlon,1] = latitude[nlat]
		endif
	endfor
endfor

; Smooth terminator line
smooth_array = fltarr(360+11*2)
smooth_array[0:10] = term[349:359,1]
smooth_array[371:381] = term[0:10,1]
smooth_array[11:370] = term[*,1]

smooth_array = smooth(smooth_array, 11)

term[*,1] = smooth_array[11:370]

; Convert terminator line to appropriate coordinate system
for i=0,n_elements(longitude)-1 do begin
	if strcmp(coords, 'geog') then begin
		term[i,1] = term[i,1]
		longitude[i] = longitude[i]
	endif else if strcmp(coords, 'magn') then begin
		mag1 = CNVCOORD(term[i,1],longitude[i],1)
		term[i,1] = mag1[0]
		longitude[i] = mag1[1]
	endif else if strcmp(coords, 'mlt') then begin
		mag1 = CNVCOORD(term[i,1],longitude[i],1)
		term[i,1] = mag1[0]
 		longitude[i] = mlt(year, yrsec, mag1[1])
	endif
endfor

_latitude = dblarr(n_elements(longitude))
_longitude = dblarr(n_elements(longitude))
count = 0

; Keep terminator location for selected hemisphere only
for i=0,n_elements(longitude)-1 do begin
	if hemisphere eq 1. and term[i,1] gt 0. then begin
		_latitude[count] = term[i,1]
		_longitude[count] = longitude[i]
		count=count+1
	endif
	if hemisphere eq -1. and term[i,1] lt 0. then begin
		_latitude[count] = term[i,1]
		_longitude[count] = longitude[i]
		count=count+1
	endif
endfor

hemi = where(_latitude ne 0.,ind)

_lat = dblarr(ind)
_lon = dblarr(ind)

for i=0,ind-1 do begin
	_lat[i] = _latitude[i]
	_lon[i] = _longitude[i]
endfor

; Plot the terminator as one continuous line
location = min(abs(_lat),minind)

if minind+1 ge n_elements(_lon) then $
	next_ind = 0. $
else $
	next_ind = minind+1

if abs(_lon[minind]-_lon[next_ind]) gt 2. then $
	minind = next_ind

_lat = shift(_lat,-minind)
_lon = shift(_lon,-minind)

; Check to see if arrays have been over-shifted
if abs(_lon[ind-2]-_lon[ind-1]) gt 10. then begin
	_lat = shift(_lat,1)
	_lon = shift(_lon,1)
endif

; Check to see if arrays need one more shift
if abs(_lon[0]-_lon[1]) gt 10. then begin
	if abs(_lon[0]) lt 175. and abs(_lon[1]) lt 175. then begin
		_lat = shift(_lat,-1)
		_lon = shift(_lon,-1)
	endif
endif

tmp = calc_stereo_coords(_lat,_lon,mlt=in_mlt)

oplot,tmp[0,*],tmp[1,*],color=linecolor,linestyle=linestyle,thick=linethick


; Plot AM/PM labels on appropriate side of terminator (***under construction***)
if keyword_set(label) then begin
	if ~keyword_set(xrange) then $
		xrange = [-45,45]
	if ~keyword_set(yrange) then $
		yrange = [-45,45]

	if ~keyword_set(charsize) then $
		charsize = 0.5

	if ~keyword_set(charthick) then $
		charthick = !p.charthick

	xlabel = where(tmp[0,*] gt xrange[0] and tmp[0,*] lt xrange[1])
	ylabel = where(tmp[1,xlabel] gt yrange[0] and tmp[1,xlabel] lt yrange[1])

	if n_elements(ylabel) eq 1. then return

	xpos = tmp[0,xlabel[ylabel[*]]]
	ypos = tmp[1,xlabel[ylabel[*]]]
	ind = round(n_elements(ypos)/2)

	slope = (ypos[n_elements(ypos)-1]-ypos[0])/(xpos[n_elements(ypos)-1]-xpos[0])

	if slope le 0. then begin
		if abs(slope) ge 2.5 then begin
			xfactor1 = (slope)*0.8
			xfactor2 = -(slope)*0.5
			yfactor1 = (1/slope)*1
			yfactor2 = -(1/slope)*1
		endif else begin
			if abs(1/slope) ge 5. then $
				y_offset = -2.0 $
			else $
				y_offset = (1/slope)*0.7

			xfactor1 = (slope)*1
			xfactor2 = (slope)*0.9
			yfactor1 = y_offset
			yfactor2 = -y_offset
		endelse
	endif else begin
		if abs(slope) ge 2.5 then begin
			if abs(slope) ge 5. then $
				slope = 5.

			xfactor1 = -(slope)*0.8
			xfactor2 = (slope)*0.5
			yfactor1 = (1/slope)*1
			yfactor2 = -(1/slope)*1
		endif else begin
			if abs(1/slope) ge 5. then $
				y_offset = 2.0 $
			else $
				y_offset = (1/slope)*0.7

			xfactor1 = -(slope)*1.5
			xfactor2 = (slope)*0.9
			yfactor1 = y_offset
			yfactor2 = -y_offset
		endelse
	endelse

	if hemisphere eq 1. then $
		deg_offset = 90. $
	else $
		deg_offset = 0.

	geog1 = CNVCOORD(_lat[xlabel[ylabel[ind]]]+xfactor1,_lon[xlabel[ylabel[ind]]]+yfactor1,1.,/geo)
	if geog1[1] lt 0. then $
		geog1[1] = 360 + geog1[1]
	Zenarr1 = Zenarr[round(geog1[1]),round(geog1[0]+deg_offset)]

	geog2 = CNVCOORD(_lat[xlabel[ylabel[ind]]]+xfactor2,_lon[xlabel[ylabel[ind]]]+yfactor2,1.,/geo)
	if geog2[1] lt 0. then $
		geog2[1] = 360 + geog2[1]
	Zenarr2 = Zenarr[round(geog2[1]),round(geog2[0]+deg_offset)]

	if (90.-Zenarr1) le 0. and (90.-Zenarr2) le 0. then begin
		print,'asdf'
		Zenarr1 = (90.+Zenarr1)
		Zenarr2 = (90.+Zenarr2)
	endif

	print,90.-Zenarr1,90.-Zenarr2

	if (90.-Zenarr1) gt (90.-Zenarr2) then begin
		XYOUTS,xpos[ind]+xfactor1,ypos[ind]+yfactor1,'Day',charsize=charsize,charthick=10.*charthick,color=get_white(),noclip=0
		XYOUTS,xpos[ind]+xfactor2,ypos[ind]+yfactor2,'Night',charsize=charsize,charthick=10.*charthick,color=get_white(),noclip=0
		XYOUTS,xpos[ind]+xfactor1,ypos[ind]+yfactor1,'Day',charsize=charsize,noclip=0
		XYOUTS,xpos[ind]+xfactor2,ypos[ind]+yfactor2,'Night',charsize=charsize,noclip=0
	endif else begin
		XYOUTS,xpos[ind]+xfactor1,ypos[ind]+yfactor1,'Night',charsize=charsize,charthick=10.*charthick,color=get_white(),noclip=0
		XYOUTS,xpos[ind]+xfactor2,ypos[ind]+yfactor2,'Day',charsize=charsize,charthick=10.*charthick,color=get_white(),noclip=0
		XYOUTS,xpos[ind]+xfactor1,ypos[ind]+yfactor1,'Night',charsize=charsize,noclip=0
		XYOUTS,xpos[ind]+xfactor2,ypos[ind]+yfactor2,'Day',charsize=charsize,noclip=0
	endelse
endif

end
