;+
; NAME: 
; RAD_MAP_OVERLAY_SCAN
;
; PURPOSE: 
; This procedure overlays scan plots on a map. This routines differs from RAD_FIT_OVERLAY_SCAN 
; as it receives an array of numeric station ids and a julian day, reads the fit data for that
; radar and overlays the fan using RAD_FIT_OVERLAY_SCAN. This routines is intended to use in combination
; with the RAD_MAP_* routines rather than the RAD_FIT_* routines.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_OVERLAY_SCAN, St_ids, Jul
;
; INPUTS:
; St_ids: A scalar or array of numeric radar ids.
;
; Jul: A julian day number at which to read the data for the given radars.
;
; KEYWORD PARAMETERS:
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'mag', 'geo', 'range' and 'gate'.
; Default is 'gate'.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; ROTATE: Set this keyword to rotate the scan plot by 90 degree clockwise.
;
; COMMON BLOCKS:
; RADARINFO: The common block holding information about the radars.
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
; Based on Steve Milan's OVERLAY_FAN.
; Written by Lasse Clausen, Dec, 22 2009
;-
pro rad_map_overlay_scan, st_ids, jul, $
	channel=channel, scan_id=scan_id, $
	coords=coords, scale=scale, param=param, $
	silent=silent, freq_band=freq_band, $
	rotate=rotate, fov=fov

common radarinfo

if n_params() ne 2 then begin
	prinfo, 'Give St_ids and Jul.'
	return
endif

if ~keyword_set(param) then $
	param = get_parameter()

if ~is_valid_parameter(param) then begin
	prinfo, 'Invalid plotting parameter: '+param
	return
endif

if ~keyword_set(freq_band) then $
	freq_band = [3.0, 30.0]

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

if ~keyword_set(scale) then begin
	if strcmp(get_parameter(), param) then $
		scale = get_scale() $
	else $
		scale = get_default_range(param)
endif

for i=0, n_elements(st_ids)-1 do begin
	njul = jul+[-1.d,1.d]*2.d/1440.d
	sfjul, ndate, ntime, njul[0], njul[1], /jul_to
	dd = where(network[*].id eq st_ids[i], cr)
	if cr ne 1 then begin
		prinfo, 'Radar '+string(st_ids[i],format='(I02)')+' not in network or not unique.'
		continue
	endif
	nradar = network[dd].code[0]
	rad_fit_read, ndate, nradar, time=ntime
	rad_fit_overlay_scan, jul=jul, coords=coords, param=param, scale=scale, $
		channel=channel, scan_id=scan_id, freq_band=freq_band
	if keyword_set(fov) then $
		overlay_fov, jul=jul, coords=coords, ids=st_ids[i], /no_fill, fov_linecolor=get_gray()
endfor



end
