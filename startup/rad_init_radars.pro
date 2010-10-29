;+ 
; NAME: 
; RAD_INIT_RADARS
; 
; PURPOSE: 
; This is procedure reads hardware parameter and information on radars including 
; numeric and character identifiers, the
; radar name, boresite, location, beam separation etc. It is essentially the same as
; is the RST.
; 
; CATEGORY: 
; Startup
; 
; CALLING SEQUENCE: 
; RAD_INIT_RADARS
;
; COMMON BLOCKS:
; RADARINFO: The common block holding data about all radar sites (from RST).
; 
; MODIFICATION HISTORY: 
; Based on by 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_init_radars

common radarinfo

rname=getenv('SD_RADAR')
if (strlen(rname) eq 0) then begin
  prinfo, 'Environment Variable SD_RADAR must be defined.'
  return
endif

openr,inp,rname,/get_lun
network = RadarLoad(inp)
free_lun,inp

hname = getenv('SD_HDWPATH')
if (strlen(hname) eq 0) then begin
  prinfo, 'Environment Variable SD_HDWPATH must be defined.'
  return
endif
s=RadarLoadHardware(network,path=getenv('SD_HDWPATH'))
if (s ne 0) then begin
  prinfo, 'Could not load hardware information'
  return
endif

END
