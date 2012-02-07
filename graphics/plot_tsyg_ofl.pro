;+
; NAME: 
; PLOT_TSYG_OFL
;
; PURPOSE: 
; This procedure overlays open field lines predicted by Tsyganenko magnetic models (T89,T96,T01,TS04) on a map.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; PLOT_TSYG_OFL
;
; KEYWORD PARAMETERS:
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD.
;
; TIME: A 1-element vector giving the time plot, in HHII format.
;
; NORTH: Set this keyword to plot the convection pattern for the northern hemisphere.
;
; SOUTH: Set this keyword to plot the convection pattern for the southern hemisphere.
;
; HEMISPHERE: Set this to 1 for the northern and to -1 for the southern hemisphere.
;
; COORDS: Set this to a string containing the name of the coordinate system to plot the map in.
; Allowable systems are magnetic ('magn') and magnetic local time ('mlt').
;
; EXTMODEL: Tsyganenko model to be used, options - T89,T96,T01,T04S, default is 'T01'
; Note : Internal model is set to IGRF by default
;
; SYMSIZE: Set this keyword to adjust size of dot.
;
; GMAGPAR: An array of 5 parameters representing geomagnetic conditions ([pdyn,dst,imf-by,imf-bz,g1,g2]) 
;         default values are - [2.0, -10., -5., -13.0, 0.5, 1.1]
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
; Written by Bharat Kunduri, Feb 1, 2012
;-
pro plot_tsyg_ofl, date, time, hemisphere=hemisphere, coords=coords, $
      extmodel=extmodel, north=north, south=south,symsize=symsize, $
      thick=thick, gmagpar=gmagpar

if ~keyword_set(symsize) then $
	symsize = .5

if ~keyword_set(thick) then $
	thick = !p.thick

if ~keyword_set(coords) then $
	coords = 'mlt'

if ~strcmp(coords, 'mlt') and ~strcmp(coords, 'magn') then begin
	prinfo, 'Coordinate system must be MLT or MAGN, setting to MLT'
	coords = 'mlt'
endif



   if ~keyword_set(gmagpar) then $
	gmagpar =[2.0, -10., -5., -13.0, 0.5, 1.1]
 


   if ~keyword_set(extmodel) then $
	extmodel ='t01'
    

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

date=date
timesel=time

usr_set_coords=coords

coords='magn'
internal_model='igrf'
external_model=extmodel
par = fltarr(10)
par[0:5]=gmagpar

rlim = 40.*!re
_coords = coords
in_mlt = !false
project_to_other_hemi=1;


sfjul, date,time,sjul
jul=sjul
time = time
caldat, jul, mm, dd, year



lat_ofl=fltarr(30)
lon_ofl=fltarr(361)

if hemisphere eq -1 then begin

for la=0,29 do begin 
      lat_ofl[la]=-60-la
endfor

for ln=0,360 do begin
      lon_ofl[ln]=ln
endfor

endif else begin 

for la=0,29 do begin 
      lat_ofl[la]=60+la
endfor

for ln=0,360 do begin
      lon_ofl[ln]=ln
endfor

endelse

pro_oh = make_array(2, $
	max(size(lat_ofl)), max(size(lon_ofl)), /float)


print,'Calculating the location of open field lines, the procedure will take a few min ...'

for b=0, max(size(lat_ofl))-1 do begin
        for r=0, max(size(lon_ofl))-1 do begin
            lat = lat_ofl[b]
            lon = lon_ofl[r]
            if keyword_set(project_to_other_hemi) then begin
                if internal_model eq 'dipole' then begin
                    if _coords ne 'magn' then begin
                        tmpp = cnvcoord(lat, lon, [200.])
                        _lat = tmpp[0]
                        _lon = tmpp[1]
                    endif else begin
                        _lat = lat
                        _lon = lon
                    endelse
                    _lat = -_lat
                    if _coords ne 'magn' then begin
                        tmpp = cnvcoord(_lat, _lon, 200., /geo)
                        lat = tmpp[0]
                        lon = tmpp[1]
                    endif else begin
                        lat = _lat
                        lon = _lon
                    endelse
                    lon = in_mlt ? mlt(year, yrsec, lon) : lon
                    pro_oh[0,b,r]=lat
                    pro_oh[1,b,r]=lon
                endif else begin
                    if _coords eq 'magn' then begin
                        tmpp = cnvcoord(lat, lon, 200., /geo)
                        _lat = tmpp[0]
                        _lon = tmpp[1]
                    endif else begin
                        _lat = lat
                        _lon = lon
                    endelse
                    _x = (!re+200.)*cos(_lon*!dtor)*cos(_lat*!dtor)
                    _y = (!re+200.)*sin(_lon*!dtor)*cos(_lat*!dtor)
                    _z = (!re+200.)*sin(_lat*!dtor)
                    in_arr = [ [_x], [_y], [_z] ]
                    if _lat gt 0 then $
                        _south = 1 $
                    else $
                        _south = 0
                    tarr = [(jul - julday(1,1,1970,0))*86400.d]
                    print,'internal model-', internal_model,' external_model-', external_model
                    trace2iono, tarr, in_arr, out_arr, $
                        in_coord='geo', out_coord='geo', $
                        external=external_model, internal=internal_model, $
                        par=par,south=_south, rlim=rlim, /km
                    if sqrt(total((out_arr/!re)^2)) gt 2. then begin
    ;                    print, out_arr[0]/!re, out_arr[1]/!re, out_arr[2]/!re
                        pro_oh[*,b,r] = replicate(!values.f_nan, 2)
                    endif else begin
                        xyz_to_polar, out_arr/!re, mag=alt, theta=glat, phi=glon
                        if _coords eq 'magn' then begin
                            tmpp = cnvcoord(glat, glon, [200.])
                            lat = tmpp[0]
                            lon = tmpp[1]
                        endif else begin
                            lat = glat
                            lon = glon
                        endelse
                        lon = in_mlt ? mlt(year, yrsec, lon) : lon
                        pro_oh[0,b,r]=lat
                        pro_oh[1,b,r]=lon
                    endelse
                endelse
            endif else begin
                lon = in_mlt ? mlt(year, yrsec, lon) : lon
                pro_oh[0,b,r]=lat
                pro_oh[1,b,r]=lon
            endelse
        endfor
    endfor



pos_ocflb=make_array(2,max(size(lat_ofl))*max(size(lon_ofl)))

aa=0
for b=0, max(size(lat_ofl))-1 do begin
        for r=0, max(size(lon_ofl))-1 do begin

               if (~finite(pro_oh[0,b,r]) or ~finite(pro_oh[1,b,r])) then begin
               
                            pos_ocflb[0,aa]= lat_ofl[b]
                            pos_ocflb[1,aa]= lon_ofl[r]
                            aa=aa+1
                             
               endif                              

        endfor
endfor


lat_ocf2=fltarr(aa)
lon_ocf2=fltarr(aa)
mlt_ocf2=fltarr(aa)
mlt_pos_ocflb=fltarr(aa)
mlt_lat_ocf2=fltarr(aa)


sfjul, date,time,eventjul

caldat,eventjul,evnt_month,evnt_day,evnt_year,strt_hour,strt_min,strt_sec



for kk=0,aa-1 do begin

       loc_ocf2=calc_stereo_coords(pos_ocflb[0,kk],pos_ocflb[1,kk],mlt=in_mlt)
       lat_ocf2[kk]=loc_ocf2[0]
       lon_ocf2[kk]=loc_ocf2[1]
       mlt_pos_ocflb[kk]=mlt(evnt_year,timeymdhmstoyrsec(evnt_year,evnt_month,evnt_day,strt_hour,strt_min,strt_sec),pos_ocflb[1,kk])
       mlt_loc_ocf2=calc_stereo_coords(pos_ocflb[0,kk],mlt_pos_ocflb[kk],/mlt)
       mlt_ocf2[kk]=mlt_loc_ocf2[1]
       mlt_lat_ocf2[kk]=mlt_loc_ocf2[0]

endfor


         


if (usr_set_coords eq 'magn') then begin

   plots,lat_ocf2,lon_ocf2,psym=3,symsize=symsize

endif else begin

   plots,mlt_lat_ocf2,mlt_ocf2,psym=3,symsize=symsize

endelse

end



