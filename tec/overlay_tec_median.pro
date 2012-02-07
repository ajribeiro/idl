;+ 
; NAME: 
; OVERLAY_TEC_MEDIAN
; 
; PURPOSE: 
; This procedure overlays median filtered GPS TEC data on a stereographic polar map.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; OVERLAY_TEC_MEDIAN
;
; KEYWORD PARAMETERS:
; JUL: Set this to a julian day number to select the scan to plot as that
; nearest to this date/time. Can be used instead of a combination of DATE/TIME.
;
; DATE: A scalar or 2-element vector giving the date range, 
; in YYYYMMDD or MMMYYYY format. Can be used in combination with TIME
; instead of JUL.
;
; TIME: The time range for which to read data. Must be a 2-element vector in 
; HHII format, or HHIISS format if the LONG keyword is set. If TIME is not set
; the default value [0000,2400] is assumed. Can be used in combination with DATE
; instead of JUL.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn', 'geog', and 'mlt'.
; Default is 'magn'.
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; GRID_LINESTYLE: Set this keyword to change the style of the grid lines.
; Default is 0 (solid).
;
; GRID_LINECOLOR: Set this keyword to a color index to change the color of the grid lines.
; Default is black.
;
; GRID_LINETHICK: Set this keyword to change the thickness of the grid lines.
; Default is 1.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; GRADIENT: Set this keyword to plot TEC gradient instead of median values.
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
; Written by Evan Thomas, June, 07 2011
;-
pro overlay_tec_median, date=date, time=time,  $
	scale=scale, coords=coords, jul=jul, $
	rotate=rotate, force_data=force_data, $
	startjul=startjul, silent=silent, $
	athreshold=athreshold, ascale=ascale, $
	grid_linestyle=grid_linestyle, $
	grid_linethick=grid_linethick, $
	grid_linecolor=grid_linecolor, $
	hemisphere=hemisphere, north=north, south=south, $
	gradient=gradient

common tec_data_blk

if median_info.dlat eq 0L and ~keyword_set(force_data) then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data filtered.'
	endif
	return
endif

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return
endif

; check coordinate system
if coords ne 'magn' and coords ne 'geog' and coords ne 'mlt' then begin
	prinfo, 'Coordinate system not supported: '+coords
	prinfo, 'Using magnetic coordinates.'
	coords = 'magn'
endif

; Check hemisphere
if ~keyword_set(hemisphere) then begin
  if keyword_set(north) then $
    hemisphere = 1. $
  else if keyword_set(south) then $
    hemisphere = -1. $
  else $
    hemisphere = 1.
endif

; we need this later
if coords eq 'mlt' then begin
	in_mlt = !true
endif else begin
	in_mlt = !false
endelse

if ~keyword_set(date) then begin
	caldat, tec_info.sjul, mm, dd, yy
	date = yy*10000L + mm*100L + dd
endif

if ~keyword_set(time) and n_elements(time) eq 0 then begin
	caldat, tec_data.juls[0], month, day, year, hh, ii
	time= hh*100 + ii
endif

if ~keyword_set(jul) then $
	sfjul, date, time, jul

; get time
caldat, jul, mm, dd, year
yrsec = (jul-julday(1,1,year,0,0,0))*86400.d

medarr = tec_median.medarr
lats = tec_median.lats
lons = tec_median.lons
juls = tec_median.juls
dlat = median_info.dlat
dlon = median_info.dlon

dlat = dlat/2.
dlon = dlon/2.

threshold = median_info.thresh

sfjul, date, time, ajul
dd = min( abs( juls - ajul ), minind )

; get color preferences
foreground  = get_foreground()
color_steps = get_colorsteps()
ncolors     = get_ncolors()
bottom      = get_bottom()

if ~keyword_set(scale) then begin
	avg = round(mean(medarr[*,*,minind]))
	if keyword_set(gradient) then $
		scale = [0.0,avg+0.5*round(stddev(medarr[*,*,minind]))] $
	else $
		scale = [0.0,avg+3*round(stddev(medarr[*,*,minind]))]
endif

; Set color bar and levels
cin =    FIX(FINDGEN(color_steps)/(color_steps-1.)*(ncolors-1))+bottom
lvl = scale[0]+FINDGEN(color_steps)*(scale[1]-scale[0])/color_steps

if keyword_set(gradient) then $
	start_a = 1 $
else $
	start_a = 0

for a=start_a, n_elements(lats)-2 do begin
	for o=0, n_elements(lons)-2 do begin
		if medarr[ a, o, minind ] eq 0. then $
			continue

	if keyword_set(gradient) then begin
		if medarr[ a-1, o, minind ] eq 0. then $
			continue
		if medarr[ a+1, o, minind ] eq 0. then $
			continue
		
		value = abs(medarr[a-1,o,minind] - medarr[a+1,o,minind])
	endif else $
		value = medarr[a,o,minind]

; 		alats = lats[a+[0,0,1,1,0]]
; 		alons = lons[o+[0,1,1,0,0]]

		alats = lats[a]+[-dlat,-dlat,dlat,dlat,-dlat]
		alons = lons[o]+[-dlon,dlon,dlon,-dlon,-dlon]

		if strcmp(coords, 'geog') then begin
			tmp = CNVCOORD(alats,alons,[1.,1.,1.,1.,1.],geo=1)
			lat = reform(tmp[0,*])
			lon = reform(tmp[1,*])
		endif else if strcmp(coords, 'magn') then begin
			lat = alats
			lon = alons
		endif else if strcmp(coords, 'mlt') then begin
			lat = alats
			lon = fltarr(n_elements(alons))
			for i=0,n_elements(alons)-1 do $
				lon[i] = mlt(year, yrsec, alons[i])
		endif
		
		tmp = calc_stereo_coords(lat, lon, mlt=in_mlt)

		color_ind = (max(where(lvl le ((value > scale[0]) < scale[1])))) > bottom
		
		polyfill, tmp[0,*], tmp[1,*], color=cin[color_ind], noclip=0
	endfor
endfor

; This loop is used to check which maps were used for median filtering
;for i=0,n_elements(juls)-1 do begin
;	caldat, juls[i], mm, dd, yy, hh, ii
;	_date = yy*10000L + mm*100L + dd
;	_time= hh*100 + ii
;	print,_date,_time
;endfor

startjul = juls[minind]
ascale = scale
athreshold = threshold

if ~keyword_set(grid_linethick) then $
	grid_linethick = 1

if n_elements(grid_linestyle) eq 0 then $
	grid_linestyle = 0

if n_elements(grid_linecolor) eq 0 then $
	grid_linecolor = get_gray()

; I removed this here and put it in tec_plot_panel
;overlay_coast, coords=coords, jul=jul, hemisphere=hemisphere, /no_fill
;map_overlay_grid, grid_linestyle=grid_linestyle, grid_linethick=grid_linethick, grid_linecolor=grid_linecolor
;map_label_grid, coords=coords, hemisphere=hemisphere

end

