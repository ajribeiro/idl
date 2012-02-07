;+
; NAME: 
; CALC_STEREO_COORDS 
; 
; PURPOSE: 
; This function converts from geographic/geomagnetic coordinates 
; (lat and lon in degrees)
; to cartesian coords with the origin at the north geographic pole
; and +ve x pointing toward 90degE and +ve y pointing toward 
; 180degE. Intended for use when converting from geograghic coords
; to the plotting coordinate frame in a polar plot.
;
; If the INVERSE keyword is set, the latitude/longitude is calculated
; from the stereographic coordinates as input.
; 
; CATEGORY: 
; Map/Coordinates
; 
; CALLING SEQUENCE: 
; Result = CALC_STEREO_COORDS(Lat,Lon)
; 
; INPUTS: 
; Lat: The latitude of the point to convert. If the INVERSE keyword is set
; this is the X coordinate in stereographic coordinates.
;
; Lon: The longitude of the point to convert. If the INVERSE keyword is set
; this is the Y coordinate in stereographic coordinates.
;
; KEYWORD PARAMETERS: 
; MLT: Set this keyword to indicate that the value for Lon is in Magnetic 
; Local Time (MLT). Default is for the longitude to be in degrees.
;
; INVERSE: Set this keyword to calculate a latitude/longitude pair from
; stereographic coordinates. !!! When using the INVERSE keyword you need to
; set the HEMISPHERE keyword correctly !!!
;
; HEMISPHERE: When using the INVERSE keyword, set this keyword to an array of then
; same length as the input, -1 for southern hemisphere, +1 for northern hemisphere.
; 
; OUTPUTS: 
; This function returns a 2-element array containing plot position in cartesian
; x and y coords.
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
; Written by: Jim Wild, 25/10/00.
; Added vector support, Hohoho, Lasse Clausen, 12/21/2009
;-
FUNCTION CALC_STEREO_COORDS, lat, lon, mlt=mlt, inverse=inverse, hemisphere=hemisphere

if keyword_set(inverse) then begin

	if ~keyword_set(hemisphere) then begin
		prinfo, 'When using the INVERSE keyword in CALC_STEREO_COORDS '+$
			'you must set the HEMIPSHERE keyword.', /force
		return, [-1., -1.]
	endif

	nn = n_elements(lat)
	if nn gt 1L and n_elements(hemisphere) eq 1L then $
		_hemisphere = replicate(hemisphere, nn) $
	else $
		_hemisphere = hemisphere

	rlat = (90. - sqrt(reform(lat)^2 + reform(lon)^2))*_hemisphere
	if keyword_set(mlt) then begin
		ninds = lindgen(nn)
		nc = nn
		sc = 0L
	endif else $
		sinds = where(_hemisphere lt 0, sc, complement=ninds, ncomplement=nc)
	rlon = rlat
	if sc gt 0 then $
		rlon[sinds] = reform(-atan(-lat[sinds], lon[sinds])*!radeg)
	if nc gt 0 then $
		rlon[ninds] = reform(atan(lat[ninds], -lon[ninds])*!radeg)

	ninds = where(rlon lt 0., nc)
	if nc gt 0 then $
		rlon[ninds] = 360. + rlon[ninds]

	if keyword_set(mlt) then $
		rlon /= 15.

	return, transpose([[rlat],[rlon]])

endif else begin

	nn = n_elements(lat)
	hemisphere = replicate(1., nn)
	inds = where(lat LT 0.0, cc)
	if ~keyword_set(mlt) and cc gt 0L then $
		hemisphere[inds] = -1.

	;IF (lat LT 0.0) AND NOT KEYWORD_SET(mlt) then $
	;	hemisphere=-1. $
	;ELSE $
	;	hemisphere=1.

	IF KEYWORD_SET(mlt) THEN $
		_lon = lon*15.0 $
	else $
		_lon = lon

	x =  (90.-ABS(lat))*SIN(_lon*!pi/180.)
	y = -(90.-ABS(lat))*COS(_lon*!pi/180.)*hemisphere

	RETURN, transpose([[x],[y]])

endelse

END
