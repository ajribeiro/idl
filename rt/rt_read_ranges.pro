;+ 
; NAME: 
; RT_READ_RANGES
;
; PURPOSE: 
; This procedure reads ranges.dat: ground scatter predictions.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_READ_RANGES, rantheta, grpran, ranhour, ranazim, ranelv, ranalt, ran, grndran, dir=dir
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORDS:
;
; COMMON BLOCKS:
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
; Written by Sebastien de Larquier, Aug. 2011
;-
pro 	rt_read_ranges, rantheta, grpran, ranhour, ranazim, ranelv, ranalt, ran, grndran, lat=lat, lon=lon, dir=dir, silent=silent


; Read rays.dat header to format output arrays
rt_read_header, txlat, txlon, azim_beg, azim_end, azim_stp, $
		elev_beg, elev_end, elev_stp, freq, $
		year, mmdd, hour_beg, hour_end, hour_stp, $
		nhour, nazim, nelev, dir=dir

if ~keyword_set(dir) then $
	filename = 'ranges.dat' $
else $
	filename = dir+'/ranges.dat'

tr = 0.
ttheta = 0.
tgrpran = 0.
trayhour = 0.
trayazim = 0.
trayelev = 0.
tran = 0.
tlat = 0.
tlon = 0.

; Count lines first
openr, lun, filename, /get_lun
nr = 0L
while ~eof(lun) do begin
	readu, lun, tr, ttheta, tgrpran, trayhour, trayazim, trayelev, tran, tlat, tlon
	nr = nr + 1
endwhile
free_lun, lun

; Save to arrays
openr, lun, filename, /get_lun
IF nr GT 1 THEN BEGIN
	rantheta = fltarr(nhour, nazim, nelev)
	grpran = fltarr(nhour, nazim, nelev)
	ranhour = fltarr(nhour, nazim, nelev)
	ranazim = fltarr(nhour, nazim, nelev)
	ranelv = fltarr(nhour, nazim, nelev)
	ranalt = fltarr(nhour, nazim, nelev)
	ran = fltarr(nhour, nazim, nelev)
	lat = fltarr(nhour, nazim, nelev)
	lon = fltarr(nhour, nazim, nelev)
	
	nr = 0L
	nh = 0L
	na = 0L
	nev = 0L
	while ~eof(lun) do begin
		readu, lun, tr, ttheta, tgrpran, trayhour, trayazim, trayelev, tran, tlat, tlon
			
		nh = round((trayhour - hour_beg)/hour_stp)
		if (trayhour lt hour_beg) then $
                    nh = round((24. - hour_beg)/hour_stp + trayhour/hour_stp)
                na = round((trayazim - azim_beg)/azim_stp)
		nev = round((trayelev - elev_beg)/elev_stp)
		
		rantheta[nh,na,nev] = ttheta
		grpran[nh,na,nev] = tgrpran
		ranhour[nh,na,nev] = trayhour
		ranazim[nh,na,nev] = trayazim
		ranelv[nh,na,nev] = trayelev
		ranalt[nh,na,nev] = tr*1e-3 - 6370.
		ran[nh,na,nev] = tran
		lat[nh,na,nev] = tlat
		lon[nh,na,nev] = tlon

		nr = nr + 1
	endwhile
	
	grndran = 6370.*rantheta

ENDIF ELSE BEGIN
	grpran = fltarr(nhour, nazim)
	ranhour = fltarr(nhour, nazim)
	ranazim = fltarr(nhour, nazim)
	ranelv = fltarr(nhour, nazim)
	ranalt = fltarr(nhour, nazim)
	ran = fltarr(nhour, nazim)
	grndran = fltarr(nhour, nazim)
	lat = fltarr(nhour, nazim)
	lon = fltarr(nhour, nazim)
ENDELSE
free_lun, lun


END
