;+ 
; NAME: 
; TEC_PLOT_WORLD_MAP
; 
; PURPOSE: 
; This procedure plots a square world map grid and overlays coast
; lines and currently loaded TEC data.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; TEC_PLOT_WORLD_MAP
;
; KEYWORD PARAMETERS:
; DATE: A scalar giving the date to plot, in YYYYMMDD format.
;
; TIME: A scalar giving the time to plot, in HHII format.
;
; SCALE: Set this keyword to change the scale of the plotted TEC values.
;
; XRANGE: Set this keyword to change the range of the x axis (geo. longitude).
;
; YRANGE: Set this keyword to change the range of the y axis (geo. latitude).
;
; ERROR: Set this keyword to plot TEC error values instead of TEC measurements.
;
; LOG: Set this keyword to plot the TEC values using a logarithmic scale.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARSIZE: Set this keyword to change the font size.
;
; POSITION: Set this keyword to a 4-element vector holding the normalized
; coordinates of the ouput panel. Use this to override internal positioning.
;
; TITLE: Set this keyword to plot a title at the top of the page.
;
; COLORBAR: Set this keyword to plot a colorbar.
;
; BLANK: Set this keyword to plot a blank map without any TEC values.
;
; COUNTRIES: Set this keyword to draw political boundries as of 1993.
;
; USA: Set this keyword to draw borders for each state in the US.
;
; TERMINATOR: Set this keyword to overlay the day/night terminator.
;
; COMMON BLOCKS:
; TEC_DATA_BLK: The common block holding GPS TEC data.
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
; Based on Sebastien de Larquier's PLOT_MAP_DATA.
; Written by Evan Thomas, Aug, 09 2011
;-
pro tec_plot_world_map, date=date, time=time, scale=scale, $
	xrange=xrange, yrange=yrange, $
	position=position, log=log, error=error, $
	color_steps=color_steps, charsize=charsize, $
	title=title, colorbar=colorbar, silent=silent, $
	blank=blank, countries=countries, usa=usa, $
	terminator=terminator

common tec_data_blk

if tec_info.nrecs eq 0L and ~keyword_set(force_data) then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data loaded.'
	endif
	return
endif

if ~keyword_set(xrange) then $
	xrange = [-180,179]

if ~keyword_set(yrange) then $
	yrange = [-90,90]

if xrange[1] gt 179 then $
	xrange[1] = 179

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, tec_data.juls[0], month, day, year, hh, ii
	date = year*10000L + month*100L + day
endif

if n_elements(time) eq 0 and ~keyword_set(time) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No TIME given, trying for scan date.'
	caldat, tec_data.juls[0], month, day, year, hh, ii
	time= hh*100 + ii
endif

sfjul, date, time, sjul, fjul
tmp1 = min(abs(tec_data.juls - sjul), minind1)
index1 = where(tec_data.juls eq tec_data.juls[minind1], sz)
smap = tec_data.map_no[index1[0]]

if smap lt 0 then smap=0
fmap = smap

nlats = 181
nlons = 360
data = fltarr(nlons, nlats)

lats = findgen(nlats)-90.
lons = findgen(nlons)-180.

; bin data onto lat-lon grid
minds = where( tec_data[0].map_no eq smap, mc )

for p=0L, mc-1L do begin
	glat = tec_data[0].glat[minds[p]]
	latind = where(lats eq glat)


	glon = tec_data[0].glon[minds[p]]
	lonind = where(lons eq glon)

	if keyword_set(error) then $
		data[lonind,latind] = tec_data[0].dtec[minds[p]] $
	else $
		data[lonind,latind] = tec_data[0].tec[minds[p]]

	if keyword_set(log) then $
		data[lonind,latind] = alog10(data[lonind,latind])
endfor

; Plot a title
if keyword_set(title) then $
	tec_plot_title, startjul=tec_data[0].juls[minds[0]]

; XYranges
limit = [lats[0],lons[0], lats[nlats-1],lons[nlons-1]]
reslons = 360./(nlons-1)
reslats = 180./(nlats-1)

minlon = where(lons eq xrange[0])
maxlon = where(lons eq xrange[1])
minlat = where(lats eq yrange[0])
maxlat = where(lats eq yrange[1])

limit = [lats[minlat],lons[minlon],lats[maxlat],lons[maxlon]]

; position axis
if ~keyword_set(position) then begin
    xmaps = 1
    ymaps = 1
    xmap = 0
    ymap = 0
    position = define_panel(xmaps, ymaps, xmap, ymap, /bar, with_info=with_info)
    if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)
endif
bpos = define_cb_position(position, /vertical, gap=0.01, width=0.01) 

; Calculate grid line positions
x = [lons[minlon],lons[maxlon]]
y = [lats[minlat],lats[maxlat]]

if x[1] eq 179 then $
	x[1] = 180

x_dist = abs(x[1]-x[0])/6.
y_dist = abs(y[1]-y[0])/6.

MAP_SET,0,lons[nlons/2],0, /cylindrical, /noerase, charsize=charsize, $
	position=position, limit=limit, /noborder

if ~keyword_set(scale) then begin
	avg=round(mean(tec_data.tec[minds]))
	if keyword_set(log) then $
		scale = [0.0,1.5] $
	else $
		scale = [0.0,avg+2*stddev(tec_data.tec[minds])]
endif

if ~keyword_set(color_steps) then $
	color_steps = 240.

if ~keyword_set(blank) then begin
	for nlat=minlat[0],maxlat[0] do begin
			slat = lats[nlat]-reslats/2.
			blat = lats[nlat]+reslats/2.
			for nlon=minlon[0],maxlon[0] do begin
				slong = lons[nlon]-reslons/2.
				blong = lons[nlon]+reslons/2.
				col = get_color_index(data[nlon,nlat], param='power',scale=scale,colorsteps=color_steps)
	
				if data[nlon,nlat] eq 0. then $
					continue

				if slat le -90.0 then $
					continue

				; finally plot the point
				POLYFILL,[slong,slong,blong,blong], [slat,blat,blat,slat], $
					COL=col,NOCLIP=0
			endfor
	endfor
endif
MAP_CONTINENTS, countries=countries, usa=usa, /coast, /NOERASE

deg=textoidl('\circ')

; Generate labels for x and y axes
xnames = round(x[0]+x_dist*findgen(7))
ynames = round(y[0]+y_dist*findgen(7))

_xtickname = strarr(n_elements(xnames))
for ii=0,n_elements(xnames)-1 do begin
	if xnames[ii] gt 0. then $
		_xtickname[ii] = strtrim(string(xnames[ii]),2)+deg+'E' $
	else if xnames [ii] lt 0. then $
		_xtickname[ii] = strtrim(string(abs(xnames[ii])),2)+deg+'W' $
	else $
		_xtickname[ii] = strtrim(string(xnames[ii]),2)+deg
endfor

_ytickname = strarr(n_elements(ynames))
for ii=0,n_elements(ynames)-1 do begin
	if ynames[ii] gt 0. then $
		_ytickname[ii] = strtrim(string(ynames[ii]),2)+deg+'N' $
	else if ynames [ii] lt 0. then $
		_ytickname[ii] = strtrim(string(abs(ynames[ii])),2)+deg+'S' $
	else $
		_ytickname[ii] = strtrim(string(ynames[ii]),2)+deg
endfor

MAP_GRID, lons=xnames, lats=ynames

; Overlay terminator
if keyword_set(terminator) then begin
	parse_date, date, year, month, day
	jd = getJD(day, month, year)
	hr = round(time/100)
	mn = time-hr*100

	localtime = hr*60.d + mn*1.d +fltarr(nlons)
	t = calcTimeJulianCent(jd + localtime/1440.d)
	zone = 0.

	Zenarr = fltarr(nlons,nlats)
	term = 90. + fltarr(nlons,2)

	for ii=0,nlats-1 do begin
		for jj=0,nlons-1 do begin
			az = calcAzEl( solarZen, t[jj], localtime[jj], lats[ii], lons[jj], zone)
			Zenarr[jj, ii] = solarZen
			if abs(90.-solarZen) lt term[jj,0] then begin
				term[jj,0] = abs(90.-solarZen)
				term[jj,1] = lats[ii]
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

	oplot, lons, term[*,1], thick=2
endif

; Overplot the axis with labels
plot, [0,0], /nodata, position=position, xcharsize=charsize, xticks=6, $ 
	xticklen=0.000001, xtickname=_xtickname, ycharsize=charsize, $
	yticks=6, yticklen=0.000001, ytickname=_ytickname

; Plot a colorbar
if keyword_set(colorbar) then begin
	set_colorsteps,color_steps
	if keyword_set(log) then $
		plot_colorbar, scale=scale, legend='Log10[TECU]',param='power',charsize=charsize $
	else if keyword_set(error) then $
		plot_colorbar, scale=scale, legend='Differential TEC [TECU]',param='power',charsize=charsize $
	else $
		plot_colorbar, scale=scale, legend='Total Electron Content [TECU]',param='power',charsize=charsize
endif

end

