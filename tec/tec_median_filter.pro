;+ 
; NAME: 
; TEC_MEDIAN_FILTER
; 
; PURPOSE: 
; This procedure applies median filtering to the TEC data currently stored
; in the common block.
; 
; CATEGORY:  
; Input/Output
; 
; CALLING SEQUENCE: 
; TEC_MEDIAN_FILTER
;
; OPTIONAL INPUTS:
; DLAT: The latitude dimension of each bin in degrees.
;
; DLON: The longitude dimension of each bin in degrees.
;
; KEYWORD PARAMETERS:
; DATE: A scalar giving the date to plot, in YYYYMMDD format.
;
; TIME: A scalar giving the time to plot, in HHII format.
;
; SLAT: The lower boundary of the latitudes to which median filtering
; will be applied.
;
; THRESHOLD: Ratio which must be satisfied for a TEC value to be gridded
; for median filtering (see code).
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; ERROR: Set this keyword to median filter TEC error values instead of
; standard TEC measurements.
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
; Modified by Evan Thomas, April 6, 2011
;-
pro tec_median_filter, dlat, dlon, slat=slat, threshold=threshold, $
	date=date, time=time, silent=silent, error=error, $
	hemisphere=hemisphere, north=north, south=south

common tec_data_blk

if n_params() ne 2 then begin
	prinfo, 'Must give Dlat and Dlon. Choosing default: dlat=1, dlon=2'
	dlat = 1.
	dlon = 2.
endif

if tec_info.nrecs eq 0L and ~keyword_set(force_data) then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data loaded.'
	endif
	return
endif

;if ~keyword_set(dlon) then $
;	dlon = 2.

;if ~keyword_set(dlat) then $
;	dlat = 1.

if ~keyword_set(slat) then $
	slat = 10.
	
; Check hemisphere
if ~keyword_set(hemisphere) then begin
  if keyword_set(north) then $
    hemisphere = 1. $
  else if keyword_set(south) then $
    hemisphere = -1. $
  else $
    hemisphere = 1.
endif

if hemisphere eq -1 and slat gt 0 then $
	slat = -(slat)

nlat = round( (85. - abs(slat))/dlat )

if ~keyword_set(date) then begin
	caldat, tec_info.sjul, mm, dd, yy
	date = yy*10000L + mm*100L + dd
endif
if n_elements(time) eq 0 then $
	time = [0000,0100]


; Determine which/how many maps to median filter
sfjul, date, time, sjul, fjul
tmp1 = min(abs(tec_data.juls - sjul), minind1)
index1 = where(tec_data.juls eq tec_data.juls[minind1], sz)
smap = tec_data.map_no[index1[0]]-1

if smap lt 0 then smap=0
fmap = smap+2

if n_elements(time) eq 2 then begin
	tmp2 = min(abs(tec_data.juls - fjul), minind2)
	index2 = where(tec_data.juls eq tec_data.juls[minind2], sz2)
	fmap = tec_data.map_no[index2[0]]+1
endif

slon = 0.
nlon = round(360./dlon)

if ~keyword_set(threshold) then $
	threshold = .33

if hemisphere eq 1. then $
	lats = slat +findgen(nlat+1)*dlat $
else $
	lats = slat -findgen(nlat+1)*dlat

lons = slon +findgen(nlon+1)*dlon

nmap = fmap-smap+1

cntarr = intarr( nlat, nlon, nmap )
valarr = fltarr( nlat, nlon, nmap, 100 )
medarr = fltarr( nlat, nlon, nmap )
juls   = dblarr( nmap )

; bin data onto lat-lon grid
for m=smap, fmap do begin

	minds = where( tec_data[0].map_no eq m, mc )

	if mc eq 0 then $
		continue
	i=m-smap

	juls[i] = tec_data[0].juls[minds[0]]

	tmp = cnvcoord( float(tec_data[0].glat[minds]), float(tec_data[0].glon[minds]), replicate(100., mc) )
	pp = where( tmp[1,*] lt 0., ppc )
	if ppc gt 0 then $
		tmp[1,pp] += 360.

	for p=0L, mc-1L do begin

		if tmp[0,p] lt min(lats) then $
			continue

		if tmp[0,p] gt max(lats) then $
			continue

		difflat = abs(lats) - abs(tmp[0,p])
		ii = where(difflat gt 0.)
		latind = ii[0]-1
		if latind lt 0 then $
			continue

		difflon = lons - tmp[1,p]
		ii = where(difflon gt 0.)
		lonind = ii[0]-1
		if lonind lt 0 then $
			continue

		if keyword_set(error) then $
			valarr[ latind, lonind, i, cntarr[ latind, lonind, i ] ] = tec_data[0].dtec[minds[p]] $
		else $
			valarr[ latind, lonind, i, cntarr[ latind, lonind, i ] ] = tec_data[0].tec[minds[p]]
		cntarr[ latind, lonind, i ] += 1

	endfor

endfor

; now the median filtering
; total possible weight is
; in current map
; 1 center   : 1*5 =  5
; 4 adjacent : 4*3 = 12
; 4 diagonal : 4*2 =  8
; in previous and following map
; 2 center   : 2*3 =  6
; 8 adjacent : 8*2 = 16
; 8 diagonal : 8*1 =  8
;--------------------------
;                    55
twght = 55.

for m=1, nmap-2 do begin

	;print, m+smap

	for a=1, nlat-2 do begin

		for o=0, nlon-1 do begin

			omind = o-1
			if omind lt 0 then $
				omind = nlon-1
			opind = o+1
			if opind ge nlon-1 then $
				opind = 0

			mcnt = 0
			mvals = fltarr(1750)

			ccc = (cntarr[ a, o, m ] < 1)
			bbc = (cntarr[ a-1, o, m ] < 1)
			ttc = (cntarr[ a+1, o, m ] < 1)
			llc = (cntarr[ a, omind, m ] < 1)
			rrc = (cntarr[ a, opind, m ] < 1)
			lbc = (cntarr[ a-1, omind, m ] < 1)
			rbc = (cntarr[ a-1, opind, m ] < 1)
			ltc = (cntarr[ a+1, omind, m ] < 1)
			rtc = (cntarr[ a+1, opind, m ] < 1)

			ccp = (cntarr[ a, o, m-1 ] < 1)
			bbp = (cntarr[ a-1, o, m-1 ] < 1)
			ttp = (cntarr[ a+1, o, m-1 ] < 1)
			llp = (cntarr[ a, omind, m-1 ] < 1)
			rrp = (cntarr[ a, opind, m-1 ] < 1)
			lbp = (cntarr[ a-1, omind, m-1 ] < 1)
			rbp = (cntarr[ a-1, opind, m-1 ] < 1)
			ltp = (cntarr[ a+1, omind, m-1 ] < 1)
			rtp = (cntarr[ a+1, opind, m-1 ] < 1)

			ccn = (cntarr[ a, o, m+1 ] < 1)
			bbn = (cntarr[ a-1, o, m+1 ] < 1)
			ttn = (cntarr[ a+1, o, m+1 ] < 1)
			lln = (cntarr[ a, omind, m+1 ] < 1)
			rrn = (cntarr[ a, opind, m+1 ] < 1)
			lbn = (cntarr[ a-1, omind, m+1 ] < 1)
			rbn = (cntarr[ a-1, opind, m+1 ] < 1)
			ltn = (cntarr[ a+1, omind, m+1 ] < 1)
			rtn = (cntarr[ a+1, opind, m+1 ] < 1)

			;print,ccc,llc,rrc,bbc,ttc,lbc,ltc,rtc,rbc
			;print,ccp,llp,rrp,bbp,ttp,lbp,ltp,rtp,rbp
			;print,ccn,lln,rrn,bbn,ttn,lbn,ltn,rtn,rbn

			wght = $
				; center current map
				ccc*5. + $
				; 4 adjacent current map
				( llc + rrc + bbc + ttc )*3. + $
				; 4 diagonal current map
				( lbc + ltc + rtc + rbc )*2. + $
				; center previous map
				ccp*3. + $
				; 4 adjacent previous map
				( llp + rrp + bbp + ttp )*2. + $
				; 4 diagonal previous map
				( lbp + ltp + rtp + rbp )*1. + $
				; center next map
				ccn*3. + $
				; 4 adjacent next map
				( lln + rrn + bbn + ttn )*2. + $
				; 4 diagonal next map
				( lbn + ltn + rtn +rbn  )*1.

			;print, a, o, wght/twght

			if wght/twght gt threshold then begin
				;================
				; CENTER
				;================
				if ccc then begin
					for i=0,4 do begin
						mvals[mcnt:mcnt+cntarr[ a, o, m ]-1] = valarr[ a, o, m, 0:cntarr[ a, o, m ]-1 ]
						mcnt += cntarr[ a, o, m ]
					endfor
				endif
				if ccp then begin
					for i=0,2 do begin
						mvals[mcnt:mcnt+cntarr[ a, o, m-1 ]-1] = valarr[ a, o, m-1, 0:cntarr[ a, o, m-1 ]-1 ]
						mcnt += cntarr[ a, o, m-1 ]
					endfor
				endif
				if ccn then begin
					for i=0,2 do begin
						mvals[mcnt:mcnt+cntarr[ a, o, m+1 ]-1] = valarr[ a, o, m+1, 0:cntarr[ a, o, m+1 ]-1 ]
						mcnt += cntarr[ a, o, m+1 ]
					endfor
				endif
				;================
				; BOTTOM
				;================
				if bbc then begin
					for i=0,2 do begin
						mvals[mcnt:mcnt+cntarr[ a-1, o, m ]-1] = valarr[ a-1, o, m, 0:cntarr[ a-1, o, m ]-1 ]
						mcnt += cntarr[ a-1, o, m ]
					endfor
				endif
				if bbp then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a-1, o, m-1 ]-1] = valarr[ a-1, o, m-1, 0:cntarr[ a-1, o, m-1 ]-1 ]
						mcnt += cntarr[ a-1, o, m-1 ]
					endfor
				endif
				if bbn then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a-1, o, m+1 ]-1] = valarr[ a-1, o, m+1, 0:cntarr[ a-1, o, m+1 ]-1 ]
						mcnt += cntarr[ a-1, o, m+1 ]
					endfor
				endif
				;================
				; TOP
				;================
				if ttc then begin
					for i=0,2 do begin
						mvals[mcnt:mcnt+cntarr[ a+1, o, m ]-1] = valarr[ a+1, o, m, 0:cntarr[ a+1, o, m ]-1 ]
						mcnt += cntarr[ a+1, o, m ]
					endfor
				endif
				if ttp then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a+1, o, m-1 ]-1] = valarr[ a+1, o, m-1, 0:cntarr[ a+1, o, m-1 ]-1 ]
						mcnt += cntarr[ a+1, o, m-1 ]
					endfor
				endif
				if ttn then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a+1, o, m+1 ]-1] = valarr[ a+1, o, m+1, 0:cntarr[ a+1, o, m+1 ]-1 ]
						mcnt += cntarr[ a+1, o, m+1 ]
					endfor
				endif
				;================
				; RIGHT
				;================
				if rrc then begin
					for i=0,2 do begin
						mvals[mcnt:mcnt+cntarr[ a, opind, m ]-1] = valarr[ a, opind, m, 0:cntarr[ a, opind, m ]-1 ]
						mcnt += cntarr[ a, opind, m ]
					endfor
				endif
				if rrp then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a, opind, m-1 ]-1] = valarr[ a, opind, m-1, 0:cntarr[ a, opind, m-1 ]-1 ]
						mcnt += cntarr[ a, opind, m-1 ]
					endfor
				endif
				if rrn then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a, opind, m+1 ]-1] = valarr[ a, opind, m+1, 0:cntarr[ a, opind, m+1 ]-1 ]
						mcnt += cntarr[ a, opind, m+1 ]
					endfor
				endif
				;================
				; LEFT
				;================
				if llc then begin
					for i=0,2 do begin
						mvals[mcnt:mcnt+cntarr[ a, omind, m ]-1] = valarr[ a, omind, m, 0:cntarr[ a, omind, m ]-1 ]
						mcnt += cntarr[ a, omind, m ]
					endfor
				endif
				if llp then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a, omind, m-1 ]-1] = valarr[ a, omind, m-1, 0:cntarr[ a, omind, m-1 ]-1 ]
						mcnt += cntarr[ a, omind, m-1 ]
					endfor
				endif
				if lln then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a, omind, m+1 ]-1] = valarr[ a, omind, m+1, 0:cntarr[ a, omind, m+1 ]-1 ]
						mcnt += cntarr[ a, omind, m+1 ]
					endfor
				endif
				;================
				; BOTTOM-LEFT
				;================
				if lbc then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a-1, omind, m ]-1] = valarr[ a-1, omind, m, 0:cntarr[ a-1, omind, m ]-1 ]
						mcnt += cntarr[ a-1, omind, m ]
					endfor
				endif
				if lbp then begin
						mvals[mcnt:mcnt+cntarr[ a-1, omind, m-1 ]-1] = valarr[ a-1, omind, m-1, 0:cntarr[ a-1, omind, m-1 ]-1 ]
						mcnt += cntarr[ a-1, omind, m-1 ]
				endif
				if lbn then begin
						mvals[mcnt:mcnt+cntarr[ a-1, omind, m+1 ]-1] = valarr[ a-1, omind, m+1, 0:cntarr[ a-1, omind, m+1 ]-1 ]
						mcnt += cntarr[ a-1, omind, m+1 ]
				endif
				;================
				; BOTTOM-RIGHT
				;================
				if rbc then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a-1, opind, m ]-1] = valarr[ a-1, opind, m, 0:cntarr[ a-1, opind, m ]-1 ]
						mcnt += cntarr[ a-1, opind, m ]
					endfor
				endif
				if rbp then begin
						mvals[mcnt:mcnt+cntarr[ a-1, opind, m-1 ]-1] = valarr[ a-1, opind, m-1, 0:cntarr[ a-1, opind, m-1 ]-1 ]
						mcnt += cntarr[ a-1, opind, m-1 ]
				endif
				if rbn then begin
						mvals[mcnt:mcnt+cntarr[ a-1, opind, m+1 ]-1] = valarr[ a-1, opind, m+1, 0:cntarr[ a-1, opind, m+1 ]-1 ]
						mcnt += cntarr[ a-1, opind, m+1 ]
				endif
				;================
				; TOP-LEFT
				;================
				if ltc then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a+1, omind, m ]-1] = valarr[ a+1, omind, m, 0:cntarr[ a+1, omind, m ]-1 ]
						mcnt += cntarr[ a+1, omind, m ]
					endfor
				endif
				if ltp then begin
						mvals[mcnt:mcnt+cntarr[ a+1, omind, m-1 ]-1] = valarr[ a+1, omind, m-1, 0:cntarr[ a+1, omind, m-1 ]-1 ]
						mcnt += cntarr[ a+1, omind, m-1 ]
				endif
				if ltn then begin
						mvals[mcnt:mcnt+cntarr[ a+1, omind, m+1 ]-1] = valarr[ a+1, omind, m+1, 0:cntarr[ a+1, omind, m+1 ]-1 ]
						mcnt += cntarr[ a+1, omind, m+1 ]
				endif
				;================
				; TOP-RIGHT
				;================
				if rtc then begin
					for i=0,1 do begin
						mvals[mcnt:mcnt+cntarr[ a+1, opind, m ]-1] = valarr[ a+1, opind, m, 0:cntarr[ a+1, opind, m ]-1 ]
						mcnt += cntarr[ a+1, opind, m ]
					endfor
				endif
				if rtp then begin
						mvals[mcnt:mcnt+cntarr[ a+1, opind, m-1 ]-1] = valarr[ a+1, opind, m-1, 0:cntarr[ a+1, opind, m-1 ]-1 ]
						mcnt += cntarr[ a+1, opind, m-1 ]
				endif
				if rtn then begin
						mvals[mcnt:mcnt+cntarr[ a+1, opind, m+1 ]-1] = valarr[ a+1, opind, m+1, 0:cntarr[ a+1, opind, m+1 ]-1 ]
						mcnt += cntarr[ a+1, opind, m+1 ]
				endif
				medarr[ a, o, m ] = median(mvals[0:mcnt-1])
			endif else $
				medarr[ a, o, m ] = 0.

		endfor

	endfor

endfor

; Make new structure for data
ttec_median = { $
	medarr: fltarr(nlat, nlon, nmap), $
	lats: fltarr(n_elements(lats)), $
	lons: fltarr(n_elements(lons)), $
	juls: dblarr(n_elements(juls)), $
	map_no: intarr(n_elements(juls)) $
}

; Distribute data in structure
ttec_median.medarr = (medarr[0:nlat-1L,0:nlon-1L,0:nmap-1L])
ttec_median.lats = (lats[0:n_elements(lats)-1L])
ttec_median.lons = (lons[0:n_elements(lons)-1L])
ttec_median.juls = (juls[0:n_elements(juls)-1L])

; Calculate indices for each new map
tmp = uniq(ttec_median.juls)
ttec_median.map_no[0L:tmp[0]] = 0
for i=0, n_elements(tmp)-2 do begin
	ttec_median.map_no[tmp[i]+1L:tmp[i+1]] = i+1
endfor

; put new structure in common block
tec_median = ttec_median

; Populate with data
median_info.dlat = dlat
median_info.dlon = dlon
median_info.slat = slat
median_info.thresh = threshold


end
