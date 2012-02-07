;+
; NAME:
; TEC_MOVIE
;
; PURPOSE:
; This procedure creates an animation of TEC panels.
;
; CATEGORY:
; Graphics
;
; CALLING SEQUENCE:
; TEC_MOVIE, Date
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; KEYWORD PARAMETERS:
; TIME: The time range for which to read data. Must be a 2-element vector in 
; HHII format, or HHIISS format if the LONG keyword is set. If TIME is not set
; the default value [0000,2400] is assumed.
;
; XRANGE: Set this keyword to change the range of the x axis.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SCALE: Set this keyword to change the scale of the plotted TEC values.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn' and 'geog'.
; Default is 'magn'.
;
; HEMISPHERE: Set this keyword to one to plot the Northern hemisphere, -1 for Southern.
; Default is 1 (Northern).
;
; ERROR: Set this keyword to plot TEC error values instead of TEC measurements.
;
; MAP: Set this keyword to plot convection map.
;
; HM: Set this keyword to overlay the Heppner-Maynard boundary. Only used if MAP
; keyword is set.
;
; FOV: Set this keyword to plot radar FOV data.
;
; RADAR: Set this keyword to an array of station id's of radar data and fields
; of view to plot. Only used if FOV keyword is set.
;
; PARAM: Set this keyword to specify the radar parameter to plot. Allowable
; values are 'power','velocity', and 'none'. Default is 'velocity' and 'none' is used
; for plotting empty radar fields of view. Only used if FOV keyword is set.
;
; RSCALE: Set this keyword to change the scale of the plotted radar values. Only
; used if FOV keyword is set.
;
; SCATTER: Set this keyword to set the currently active scatter flag. 0: plot all 
; backscatter data 1: plot ground backscatter only 2: plot ionospheric backscatter
; only 3: plot all backscatter data with a ground backscatter flag. Scatter flags 0
; and 3 produce identical output unless the parameter plotted is velocity, in which
; case all ground backscatter data is identified by a grey colour. Ground backscatter
; is identified by a low velocity (|v| < 50 m/s) and a low spectral width. Only used
; if FOV keyword is set.
;
; MARK_REGION: Set this to a nstat x 4-element vector holding information about
; the region to mark in each radar fov. nstat is the number of fovs to plot,
; i.e. the number of elements of IDS or NAMES. The 4 elements of the vector are
; start_beam, end_beam, start_gate, end_gate.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; TERMINATOR: Set this keyword to overlay the day/night terminator.
;
; WORLD: Set this keyword to plot a square world map instead (ignores coordinates/radar keywords).
;
; FOUR: Set this keyword to create a movie of the four plot overview (can be very slow)
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
; Written by Evan Thomas, Feb, 7 2011
; Modified Oct, 3 2011
;-
pro tec_movie,date,time=time,xrange=xrange,yrange=yrange, $
	scale=scale,coords=coords,hemisphere=hemisphere, $
	error=error,map=map,hm=hm,st_ids=st_ids,fov=fov, $
	param=param,rscale=rscale,scatter=scatter, $
	mark_region=mark_region, terminator=terminator, $
	symsize=symsize, medianf=medianf, gradient=gradient, $
	charsize=charsize, world=world, $
	four=four, vscale=vscale, pscale=pscale

if ~keyword_set(time) then $
	time = [0000,0100]

if ~keyword_set(yrange) then $
	yrange = [-50,10]

if ~keyword_set(xrange) then $
	xrange = [-50,30]

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~keyword_set(hemisphere) then $
	hemisphere = 1.

if ~keyword_set(error) then $
	error = 0

if ~keyword_set(mark_region) then $
	mark_region = [0,0]

if ~keyword_set(charsize) then $
	charsize = 0.6

if keyword_set(four) then begin
	set_format,/sardines
	if ~keyword_set(pscale) then $
		pscale = [0,30]
	if ~keyword_set(vscale) then $
		vscale = [-500,500]
endif

sfjul,date,time,sjul,fjul,long=long
jul = sjul+3/1440.

finish = (fjul-sjul)/5*1440.

time_label = [string(time[0],format='(I4)'),string(time[1],format='(I4)')]
for i=0,1 do begin
        time_label[i] = strtrim(time_label[i],1)
        if time[i] lt 10 then $
                time_label[i] = '0'+time_label[i]
        if time[i] lt 100 then $
                time_label[i] = '0'+time_label[i]
        if time[i] lt 1000 then $
                time_label[i] = '0'+time_label[i]
endfor

clear_page

for i=0,finish-1 do begin
	sfjul,_date,_time,jul,/jul_to_date

	; Draw progress bar
  XYOUTS,0.845,0.91,time_label[0],charsize=charsize,/normal
  XYOUTS,0.950,0.91,time_label[1],charsize=charsize,/normal
  
	probar = 0.850+i/(finish-1)*0.126
	polyfill,[0.850,0.850,0.851,0.851],[0.865,0.90,0.90,0.865],/normal
	polyfill,[0.850,0.850,0.976,0.976],[0.865,0.866,0.866,0.865],/normal
	polyfill,[0.850,0.850,0.976,0.976],[0.899,0.90,0.90,0.899],/normal
	polyfill,[0.975,0.975,0.976,0.976],[0.865,0.90,0.90,0.865],/normal
	polyfill,[0.850,0.850,probar,probar],[0.865,0.90,0.90,0.865],/normal

	if keyword_set(world) then $
		tec_plot_world_map,date=_date,time=_time,scale=scale,error=error, $
		xrange=xrange,yrange=yrange,charsize=0.7,/colorbar,/title, $
		terminator=terminator $
	else if keyword_set(four) then $
		tec_four_plot,date=_date,time=_time,scale=scale,coords=coords, $
		xrange=xrange,yrange=yrange,map=map,hm=hm,hemisphere=hemisphere, $
		scatter=scatter,st_ids=st_ids,vscale=vscale,pscale=pscale, $
		charsize=0.6 $
	else $
		tec_plot_panel,1,1,0,0,date=_date,time=_time,scale=scale,coords=coords, $
			xrange=xrange,yrange=yrange,hemisphere=hemisphere, $
			error=error,map=map,hm=hm,st_ids=st_ids,fov=fov,param=param, $
			rscale=rscale,scatter=scatter,mark_region=mark_region, $
			symsize=symsize,medianf=medianf,gradient=gradient,terminator=terminator, $
			charsize=0.7
	
	if i lt finish-1 then clear_page
	
	jul = jul+5/1440.
endfor

end

