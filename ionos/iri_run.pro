;+
; NAME:
; IRI_RUN
;
; PURPOSE:
; This function runs the IRI model
;
; CATEGORY:
; Ionospheric models
;
; CALLING SEQUENCE:
; IRI_RUN, date, time, ut=ut, param=param, $
; 				lati=lati, longi=longi, alti=alti, $
; 				nel=nel, nmf2=nmf2, hmf2=hmf2, tec=tec
;
; INPUTS:
; DATE: YYYYMMDD
;
; TIME: HHMM
;
; KEYWORD PARAMETERS:
; UT: set this keyword to use UT time instead of LT
;
; PARAM: 'lati', 'longi', 'alti'. If unspecified, both latitude and longitude are used.
;
; LATI: latitude value. Can be an array if PARAM='lati', or if PARAM is unspecified.
; The array values have to be monotically increasing and the array size should not exceed 360
;
; LONGI: longitude value. Can be an array if PARAM='longi', or if PARAM is unspecified.
;
; ALTI: altitude value in km. Can be an array if PARAM='alti'.
;
; NEL: output array of electron density in 10^(-11) [m^-3]
;
; HMF2: output array of altitude of the F2 layer peak densities in [km]
;
; NMF2: output array of F2 layer peak densities in 10^(-11) [m^-3]
;
; TEC: Total electron content in TEC units
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
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED,
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
pro		iri_run, date, time, param=param, ut=ut, $
					lati=lati, longi=longi, alti=alti, $
					nel=nel, nmf2=nmf2, hmf2=hmf2, tec=tec

; Position if not provided
if ~keyword_set(alti) then $
	alti = 300.
if ~keyword_set(lati) then $
	lati = 0.
if ~keyword_set(longi) then $
	longi = 0.
if ~keyword_set(ut) then $
	ut = 0

; date and time (in decimal hour +25 if UT)
parse_date, date, year, month, day
parse_time, time, hour, minutes
dhour = hour + minutes/60.

; Make sure that the variable chosen with ivar matches the array of positions
; Find initial, final and step value of desired variable
case param of
; case of both latitudinal and longitudinal variations
	0: 	begin
			if ~keyword_set(longi) then begin
				print, 'no array provided for longitude, using default'
				lati = [-180.,180.]
			endif
			; In this case, we will run the fortran code along longitude lines
			; and step in latitude with the idl code
			nvar = 180
			vbeg = longi[0]
			vend = longi[1]
			vstep = (vend-vbeg)/nvar
			ivar = 3
			if ~keyword_set(lati) then begin
				print, 'no array provided for latitude, using default'
				lati = [-90.,90.]
			endif
			latiA = lati[0] + findgen(90)*(lati[1]-lati[0])/90.
		end
; case of latitude variations
	'lati':	begin
				if ~keyword_set(lati) then begin
					print, 'no array provided, using default'
					lati = [-90.,90.]
				endif
				nvar = 90
				vbeg = lati[0]
				vend = lati[1]
				vstep = (vend-vbeg)/nvar
				ivar = 2
			end
; case of longitude variations
	'longi':begin
				if ~keyword_set(longi) then begin
					print, 'no array provided, using default'
					longi = [-180.,180.]
				endif
				nvar = 180
				vbeg = longi[0]
				vend = longi[1]
				vstep = (vend-vbeg)/nvar
				ivar = 3
			end
; case of altitude variations
	'alti':	begin
				if ~keyword_set(alti) then begin
					print, 'no array provided, using default'
					alti = [100.,500.]
				endif
				nvar = 500
				vbeg = alti[0]
				vend = alti[1]
				vstep = (vend-vbeg)/nvar
				ivar = 1
			end
	else:	stop, 'parameter not accepted'
endcase

; Now run the fortran code (has to be different for param=0)
; inputs for fortran code are: lati,longi,alti,iyyyy,mmdd,iut,dhour,ivar,vbeg,vend,vstp
case param of
; case of both latitudinal and longitudinal variations
	0: 	begin
		nel = fltarr(90,180)
		hmf2 = fltarr(90,180)
		nmf2 = fltarr(90,180)
		tec = fltarr(90,180)
		; iterate over longitudes
		for nlat=0,n_elements(latiA)-1 do begin
			spawn, 'rm inp_file'
			; lati,longi,alti
			rpos = STRTRIM(latiA[nlat],2)+','+STRTRIM(longi[0],2)+','+STRTRIM(alti[0],2)
			; iyyyy,mmdd,iut,dhour
			rdate = STRTRIM(year,2)+','+STRTRIM(month*100L+day,2)+','+STRTRIM(ut,2)+','+STRTRIM(dhour,2)
			; 'begin, end, and stepsize for the selected variable'
			rvar = '3,'+STRTRIM(vbeg,2)+','+STRTRIM(vend,2)+','+STRTRIM(vstep,2)
			spawn, 'echo '+rpos+','+rdate+','+rvar+' >> inp_file'
			spawn, '/davit/lib/vt/fort/iri/iri < inp_file'

			iri_read, nmf2=tnmf2, hmf2=thmf2, nel=tnel, tec=ttec
			
			hmf2[nlat,*] = thmf2
			nmf2[nlat,*] = tnmf2*1e-11
			nel[nlat,*] = tnel*1e-11
			tec[nlat,*] = ttec*1e-16
		endfor
	end
	else: begin
		spawn, 'rm inp_file'
		; lati,longi,alti
		rpos = STRTRIM(lati[0],2)+','+STRTRIM(longi[0],2)+','+STRTRIM(alti[0],2)
		; iyyyy,mmdd,iut,dhour
		rdate = STRTRIM(year,2)+','+STRTRIM(month*100L+day,2)+','+STRTRIM(ut,2)+','+STRTRIM(dhour,2)
		; 'begin, end, and stepsize for the selected variable'
		rvar = STRTRIM(ivar,2)+','+STRTRIM(vbeg,2)+','+STRTRIM(vend,2)+','+STRTRIM(vstep,2)
		spawn, 'echo '+rpos+','+rdate+','+rvar+' >> inp_file'
		spawn, '/davit/lib/vt/fort/iri/iri < inp_file'

		iri_read, nmf2=nmf2, hmf2=hmf2, nel=nel, tec=tec

		nmf2 = nmf2*1e-11
		nel = nel*1e-11
		tec = tec*1e-16
	end
endcase

end