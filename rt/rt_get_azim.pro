;+ 
; NAME: 
; RT_GET_AZIM
;
; PURPOSE: 
; Returns beam azimuth for a given radar and beam
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_GET_AZIM
;
; INPUTS:
; RADAR
; BEAM
;
; OPTIONAL INPUTS:
;
; KEYWORDS:
;
; COMMON BLOCKS:
; RT_DATA_BLK, RADARINFO
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
function	rt_get_azim, radar, beam
; Returns beam azimuth for a given radar and beam

common	rt_data_blk
common	radarinfo

if (beam lt 0 OR beam gt 16) then begin
	print, 'Beam must be a numerical value between 0 and 15.' 
	beam = 7 
	print, 'Default:', beam
endif

; Read radar location and boresight
radID = where(network.code[0,*] eq radar)
radarsite = network[radID].site[where(network[radID].site.tval eq -1)]

; FOV half angle
fov_ang = (radarsite.maxbeam-1)*radarsite.bmsep/2L

; Azimuth of first beam
b0 = radarsite.boresite - fov_ang

; Azimuth of required beam
baz = b0 + beam*radarsite.bmsep

return, baz

END