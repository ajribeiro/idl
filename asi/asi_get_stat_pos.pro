;+
; NAME: 
; ASI_GET_STAT_POS
;
; PURPOSE: 
; This procedure returns the geodetic or geomagnetic latitudes of ground-based
; all-sky imager stations. Default is geodetic coordinates.
; 
; CATEGORY: 
; All-Sky Imager
; 
; CALLING SEQUENCE:  
; Result = ASI_GET_STAT_POS(Stats)
;
; OPTIONAL INPUTS:
; Stats: Set this to a named variable with the station abbreviations of 
; ground-based magnetometer stations for which the positions will be returned.
;
; KEYWORD PARAMETERS:
; LONGITUDE: Set this to a named variable that wil contain the longitudes of the specified
; stations.
;
; COORDS: Set this to a string specifying the coordinate system, either 'geog' or 'magn'. 
; Default is geodetic coordinates.
;
; GET: Set this keyword in conjunction with the chain or ALL keywords. If this keyword is set, 
; all positions of magnetometers belonging to the specified chain are returned, as well as their
; abbreviations in Stats.
;
; ALL: Set this keyword to return the positions of all supported magnetometers.
;
; OUTPUTS:
; Returns the geodetic or geomagnetic latitudes of ground-based
; all-sky imager stations.
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
function asi_get_stat_pos, stats, longitude=longitude, coords=coords, $
    get=get, all=all, themis=themis

if ~keyword_set(coords) then $
	coords = get_coordinates()

if ~is_valid_coord_system(coords) then begin
	prinfo, 'Invalid coordinate system: '+coords
	return, -1
endif

if strcmp(strlowcase(coords), 'geog') then $
	ioff = 0 $
else if  strcmp(strlowcase(coords), 'magn') then $
	ioff = 2 $
else begin
	prinfo, 'Coordinate system not supported: '+coords
	return, -1
endelse

asi_read_stat_pos, suppstats, supplats, supplons, chains=chains, coords=coords
inds = -1

if keyword_set(get) then begin
	if keyword_set(themis) then $
		inds = ( inds[0] eq -1 ? where(chains eq !ASI_THEMIS) : [inds, where(chains eq !ASI_THEMIS)] )
	if keyword_set(all) then $
		inds = indgen(n_elements(suppstats))
	if inds[0] eq -1 then $
		return, -1.
	stats = suppstats[inds]
	longitude = supplons[inds]
	return, supplats[inds]
endif else begin
	nn = n_elements(stats)
	if nn lt 1 then begin
		prinfo, 'No station names given. Give station names or set GET keyword.'
		return, -1.
	endif
	longitude = replicate(-1., nn)
	latitudes = replicate(-1., nn)
	for i=0, nn-1 do begin
		tmp = where(strupcase(stats[i]) eq suppstats)
		if tmp[0] ne -1 then begin
			longitude[i] = supplons[tmp[0]]
			latitudes[i] = supplats[tmp[0]]
		endif
	endfor
	return, latitudes
endelse

end
