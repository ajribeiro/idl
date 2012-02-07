;+
; NAME: 
; GBM_READ_POS
;
; PURPOSE: 
; This procedure reads the geodetic or geomagnetic coordinates of all supported ground-based
; magnetometer stations from a file. Default is geodetic coordinates.
; 
; CATEGORY: 
; Ground-Based Magnetometers
; 
; CALLING SEQUENCE:  
; GBM_READ_POS 
;
; OPTIONAL OUTPUTS:
; Suppstats: Set this to a named variable which will contain the station abbreviations of 
; ground-based magnetometer stations.
;
; Supplats: Set this to a named variable which will contain the geodetic/geomagnetic latitudes of
; ground-based magnetometer stations. Depends on keyword CGM.
;
; Supplons: Set this to a named variable which will contain the geodetic/geomagnetic longitudes of
; ground-based magnetometer stations. Depends on keyword CGM.
;
; KEYWORD PARAMETERS:
; CHAINS: Set this keyword to named variable which will contain a number specifying the cahin to which the
; station belongs. Use the system variables !CARISMA, !IMAGE, !SAMNET, !GREENLAND, !ANTARCTICA, !GIMA, !JAPMAG,
; !SAMBA, !INTERMAGNET, !MACCS and !NIPR to find the right stations.
;
; COORDS: Set this to a string specifying the coordinate system, either 'geog' or 'magn'. 
; Default is geodetic coordinates.
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
; Written by Lasse Clausen, Dec, 4 2009
;-
pro gbm_read_pos, suppstats, supplats, supplons, chains=chains, coords=coords, $
	date=date, time=time, long=long, jul=jul

if ~keyword_set(coords) then $
	coords = get_coordinates()
	
if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return
endif

if  strcmp(strlowcase(coords), 'mlt') then begin
	if ~keyword_set(date) and ~keyword_set(jul) then begin
		prinfo, 'Must give date or jul when using MLT.'
		return
	endif
	if ~keyword_set(time) then $
		time=1200
	if ~keyword_set(jul) then $
		sfjul, date, time, jul, long=long
endif

if strcmp(strlowcase(coords), 'geog') then $
	ioff = 0 $
else if  strcmp(strlowcase(coords), 'magn') then $
;	ioff = 2 $
	ioff = 0 $
else if  strcmp(strlowcase(coords), 'mlt') then $
;	ioff = 2 $
	ioff = 0 $
else begin
	prinfo, 'Coordinate system not supported: '+coords
	return
endelse

line = ''
count = 0
length = -1

filename = getenv("RAD_RESOURCE_PATH")+'/gbm_stations.dat'
if ~file_test(filename) then begin
	prinfo, 'Cannot read station file: '+filename
	return
endif

; open file with station abbreviations, glat, glon, mlat and mlon
openr, ilun, filename, /get_lun
; read header
readf, ilun, line
; read number of stations in file
readf, ilun, length

suppstats = make_array(length, /string)
supplats = make_array(length, /float)
supplons = make_array(length, /float)
chains = make_array(length, /int)

while not(eof(ilun)) do begin
    readf, ilun, line
    if strpos(line, '$') ne -1 then begin
    	if strcmp(line, '$CARISMA') then achain=!CARISMA else $
    	if strcmp(line, '$IMAGE') then achain=!IMAGE else $
    	if strcmp(line, '$GREENLAND') then achain=!GREENLAND else $
    	if strcmp(line, '$SAMNET') then achain=!SAMNET else $
    	if strcmp(line, '$ANTARCTICA') then achain=!ANTARCTICA else $
    	if strcmp(line, '$GIMA') then achain=!GIMA else $
    	if strcmp(line, '$JAPMAG') then achain=!JAPMAG else $
    	if strcmp(line, '$SAMBA') then achain=!SAMBA else $
    	if strcmp(line, '$INTERMAGNET') then achain=!INTERMAGNET else $
    	if strcmp(line, '$MACCS') then achain=!MACCS else $
    	if strcmp(line, '$NIPR') then achain=!NIPR else $
    	if strcmp(line, '$GBM_THEMIS') then achain=!GBM_THEMIS
    endif else begin
    	tmp = strsplit(line, ' ', /extract)
    	suppstats[count] = strupcase(strtrim(tmp[0]))
    	supplats[count] = float(tmp[1+ioff])
    	supplons[count] = float(tmp[2+ioff])
    	chains[count] = achain
    	count = count + 1
    endelse
;		print, count
endwhile
close, ilun
free_lun, ilun

if  strcmp(strlowcase(coords), 'magn') then begin
	for i=0, length-1 do begin
;		print, suppstats[i], supplats[i], supplons[i]
		tmp = cnvcoord(supplats[i], supplons[i], 1.)
		supplats[i] = tmp[0]
		supplons[i] = tmp[1]
	endfor
endif

if  strcmp(strlowcase(coords), 'mlt') then begin
	caldat, jul, mm, dd, yy
	for i=0, length-1 do begin
		tmp = cnvcoord(supplats[i], supplons[i], 1.)
		tmp[1] = mlt(yy, (jul-julday(1,1,yy,0))*86400.d, tmp[1])
		supplats[i] = tmp[0]
		supplons[i] = tmp[1]
	endfor
endif

end
