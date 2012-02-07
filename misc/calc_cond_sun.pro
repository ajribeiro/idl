;+
; NAME: 
; CALC_COND_SUN
;
; PURPOSE: 
; This function calculates the height-integrated conductivity of the ionosphere based on solar and euv galactic flux 
;
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE:  
; Result=CALC_COND_SUN(date, time, mlat, mlong, f107flux, cond_type)
;
; INPUTS:
; Date: The date for which to calculate conductivity.
;
; Time: the time for which to calculate conductivity.
;
; KEYWORD PARAMETERS:
; MLAT: Magnetic latitude of the location to calculate conductivity.
; 
; MLONG: Magnetic latitude of the location to calculate conductivity
; 
; F107FLUX: Solar 10.7 flux
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
; Written by Bharat Kunduri, Feb 3 2012
;-



function calc_cond_sun, date, time, mlat, mlong, f107flux, cond_type



;;;;;;;;;;;;;;;;;;;;;;;;;;CALC SUB-SOLAR POINT;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;CALC SUB-SOLAR POINT;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;CALC SUB-SOLAR POINT;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sfjul, date,time,sjul
jul=sjul
time = time
caldat, jul, mmonth, dday, yyear,hhour,mmin,ssec


DoY=julday(mmonth, dday, yyear,hhour,mmin,ssec)-julday(1,0,1994)


nday=[  1.0,   6.0,  11.0,  16.0,  21.0,  26.0,  31.0,  36.0,  41.0,  46.0,$
       51.0,  56.0,  61.0,  66.0,  71.0,  76.0,  81.0,  86.0,  91.0,  96.0,$
      101.0, 106.0, 111.0, 116.0, 121.0, 126.0, 131.0, 136.0, 141.0, 146.0,$
      151.0, 156.0, 161.0, 166.0, 171.0, 176.0, 181.0, 186.0, 191.0, 196.0,$
      201.0, 206.0, 211.0, 216.0, 221.0, 226.0, 231.0, 236.0, 241.0, 246.0,$
      251.0, 256.0, 261.0, 266.0, 271.0, 276.0, 281.0, 286.0, 291.0, 296.0,$
      301.0, 306.0, 311.0, 316.0, 321.0, 326.0, 331.0, 336.0, 341.0, 346.0,$
      351.0, 356.0, 361.0, 366.0]

eqt=[ -3.23, -5.49, -7.60, -9.48,-11.09,-12.39,-13.34,-13.95,-14.23,-14.19,$
     -13.85,-13.22,-12.35,-11.26,-10.01, -8.64, -7.18, -5.67, -4.16, -2.69,$
      -1.29, -0.02,  1.10,  2.05,  2.80,  3.33,  3.63,  3.68,  3.49,  3.09,$
       2.48,  1.71,  0.79, -0.24, -1.33, -2.41, -3.45, -4.39, -5.20, -5.84,$
      -6.28, -6.49, -6.44, -6.15, -5.60, -4.82, -3.81, -2.60, -1.19,  0.36,$
       2.03,  3.76,  5.54,  7.31,  9.04, 10.69, 12.20, 13.53, 14.65, 15.52,$
      16.12, 16.41, 16.36, 15.95, 15.19, 14.09, 12.67, 10.93,  8.93,  6.70,$
       4.32,  1.86, -0.62, -3.23]

dec=[-23.06,-22.57,-21.91,-21.06,-20.05,-18.88,-17.57,-16.13,-14.57,-12.91,$
     -11.16, -9.34, -7.46, -5.54, -3.59, -1.62,  0.36,  2.33,  4.28,  6.19,$
       8.06,  9.88, 11.62, 13.29, 14.87, 16.34, 17.70, 18.94, 20.04, 21.00,$
      21.81, 22.47, 22.95, 23.28, 23.43, 23.40, 23.21, 22.85, 22.32, 21.63,$
      20.79, 19.80, 18.67, 17.42, 16.05, 14.57, 13.00, 11.33,  9.60,  7.80,$
       5.95,  4.06,  2.13,  0.19, -1.75, -3.69, -5.62, -7.51, -9.36,-11.16,$
     -12.88,-14.53,-16.07,-17.50,-18.81,-19.98,-20.99,-21.85,-22.52,-23.02,$
     -23.33,-23.44,-23.35,-23.06]




day=DoY
time=hhour
geo_coord_pnt=cnvcoord(mlat, mlong,200.,/geo)
lat=geo_coord_pnt[0]
lon=geo_coord_pnt[1]


;
; compute the subsolar coordinates
;

tt=((fix(day)+time/24.-1.) mod 365.25) +1.  ;; fractional day number
                                            ;; with 12am 1jan = 1.

if n_elements(tt) gt 1 then begin
  eqtime=tt-tt                              ;; this used to be day-day, caused 
  decang=eqtime                             ;; error in eqtime & decang when a
  ii=sort(tt)                               ;; single integer day was input
  eqtime(ii)=spline(nday,eqt,tt(ii))/60.    
  decang(ii)=spline(nday,dec,tt(ii))
endif else begin
  eqtime=spline(nday,eqt,tt)/60.
  decang=spline(nday,dec,tt)
endelse  
latsun=decang

if keyword_set(local) then begin
  lonorm=((lon + 360 + 180 ) mod 360 ) - 180.
  tzone=fix((lonorm+7.5)/15)
  index = where(lonorm lt 0, cnt)
  if (cnt gt 0) then tzone(index) = fix((lonorm(index)-7.5)/15)
  ut=(time-tzone+24.) mod 24.                  ; universal time
  noon=tzone+12.-lonorm/15.                    ; local time of noon
endif else begin
  ut=time
  noon=12.-lon/15.                             ; universal time of noon
endelse

lonsun=-15.*(ut-12.+eqtime)


ss_mag_coord=cnvcoord(latsun,lonsun,200.)

magcolat_ss=90.-ss_mag_coord[0]
mlon_ss=ss_mag_coord[1]

mlt_pnt=mlt(yyear,timeymdhmstoyrsec(yyear,mmonth,dday,hhour,mmin,ssec),mlong)
mlt_ss=mlt(yyear,timeymdhmstoyrsec(yyear,mmonth,dday,hhour,mmin,ssec),mlon_ss)


;;;;;;;;;;;;;;;;;;;;;;;;;;CALC SUB-SOLAR POINT;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;CALC SUB-SOLAR POINT;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;CALC SUB-SOLAR POINT;;;;;;;;;;;;;;;;;;;;;;;;;;;;


mlat=(90-mlat)
con_s= 0.

sz=sin(mlat*!dtor)
cz=cos(mlat*!dtor)

coschi=cos((mlt_ss-mlt_pnt)*!dtor)*sz*sin(magcolat_ss*!dtor)+cz*cos(magcolat_ss*!dtor)

fcosx=0.06+exp(1.803*tanh(3.833*coschi)+0.5*coschi-2.332)

;;;;;;;;;;;;;;;;;;;;;;;;;;HALL CONDUCTIVITY;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;HALL CONDUCTIVITY;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (cond_type eq 0) then begin

bb_hall=sqrt(1.0-0.01504*(1.-cz) - 0.97986*sz*sz)*(1+0.3*cz*cz)

Hall_cond=17.0*sqrt(f107flux/180.)*fcosx/bb_hall

Out_cond=Hall_cond

endif
;;;;;;;;;;;;;;;;;;;;;;;;;;HALL CONDUCTIVITY;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;HALL CONDUCTIVITY;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;PEDERSEN CONDUCTIVITY;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;PEDERSEN CONDUCTIVITY;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (cond_type eq 1) then begin
bb_ped=sqrt(1.0-0.99524*sz*sz)*(1.0+0.3*cz*cz)

Ped_cond=12.5*sqrt(f107flux/180.)*fcosx/bb_ped
Out_cond=Ped_cond
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;PEDERSEN CONDUCTIVITY;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;PEDERSEN CONDUCTIVITY;;;;;;;;;;;;;;;;;;;;;;;;;;;;


return, Out_cond

end
