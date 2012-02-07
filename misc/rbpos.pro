;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	rbpos
;
; PURPOSE:
;
;	Calculate the geographic or geomagnetic position of radar range/beam
;	cells.
;
; CALLING SEQUENCE:
;
;	  pos = rbpos(range,[height=height],[station=station_id],
;		[beam=beam_number],[lagfr=lag_to_first_range],
;		[smsep=sample_separation],[data=data_ptr],[/CENTER],[/GEO])
;
;		inputs:  the range number (first range =1).  This may be
;				a vector containing a list of ranges.
;			 if the height is not specified a value of 300 km is
;				used.
;			 the following keywords specify the station id, 
;				beam number, lag to the first range, 
;				and lag separation:  "station",
;				"beam", "lagfr", "smsep".  If these keywords 
;				are not specified, their values are taken from
;				the data structure pointed to by the
;				keyword "data" or from "fit_data" if no
;				data structure is specified.
;			 if the keyword data is given a value, the information
;				on the bmnum, smsep, etc. is taken from the
;				structure pointed to by that keyword.
;				Otherwise, the data structure "fit_data"
;				is assummed.
;			 if the keyword CENTER is set, only the position of
;			    the center of the cell is return
;			 if the keyword GEO is set, the coordinates are
;			    returned in geographic, otherwise PACE geomagnetic
;			    coordinates are used.
;
;------------------------------------------------------------------------------
;

function rbpos, range, height=height, beam=beam, lagfr=lagfr, smsep=smsep, $
	rxrise=rxrise, station=station, center=center, geo=geo, year=year, yrsec=yrsec

  common radarinfo, network

; load the hardware data if we haven't done so already

 if (n_elements(network) eq 0) then begin
    rname=getenv('SD_RADAR')
    if (strlen(rname) eq 0) then begin
      print, 'Environment Variable SD_RADAR must be defined.'
      stop
    endif

    openr,inp,rname,/get_lun
    network=RadarLoad(inp)
    free_lun,inp

    hname=getenv('SD_HDWPATH')
    if (strlen(hname) eq 0) then begin
      print, 'Environment Variable SD_HDWPATH must be defined.'
      stop
    endif
    s=RadarLoadHardware(network,path=getenv('SD_HDWPATH'))
    if (s ne 0) then begin
      print, 'Could not load hardware information'
      stop
    endif
  endif

  s    = TimeYrsecToYMDHMS(year,mo,dy,hr,mt,sc,yrsec)
  rid  = RadarGetRadar(network,station)
  site = RadarYMDHMSGetSite(rid,year,mo,dy,hr,mt,sc)

  frang = lagfr*0.15
  rsep  = smsep*0.15

	if n_elements(recrise) eq 0 then $
		recrise = site.recrise

	if n_elements(height) eq 0 then $
		height = 300.
;
;	if the center keyword is set then we return a 3 element array,
;	otherwise we return an array of 3,2,2
;

	if keyword_set(center) then $
		pos = fltarr(3,n_elements(range)) $
	else $
		pos = fltarr(3,2,2,n_elements(range))

  if (keyword_set(geo)) then mgflag = 0 else mgflag = 1
  if (keyword_set(center)) then cflag = 1 else cflag = 0
  pos1 = fltarr(3,2,2)

  for i=0, n_elements(range)-1 do begin
    if n_elements(range) EQ 1 then r = fix(range) else r=fix(range(i))
    if (cflag eq 1) then begin         
      s=RadarPos(1,beam,r-1,site,frang,rsep,recrise,height,rho,lat,lon)
      if (mgflag eq 1) then begin
        s=AACGMConvert(lat,lon,height,mlat,mlon,rad)
        lat=mlat
        lon=mlon
      endif
      pos1[0,0,0]=lat
      pos1[1,0,0]=lon
      pos1[2,0,0]=rho
    endif else begin
      s=RadarPos(0,beam,r-1,site,frang,rsep,recrise,height,rho,lat,lon)
      if (mgflag eq 1) then begin
        s=AACGMConvert(lat,lon,height,mlat,mlon,rad)
        lat=mlat
        lon=mlon
      endif
      pos1[0,0,0]=lat
      pos1[1,0,0]=lon
      pos1[2,0,0]=rho
      s=RadarPos(0,beam+1,r-1,site,frang,rsep,recrise,height,rho,lat,lon)
      if (mgflag eq 1) then begin 
        s=AACGMConvert(lat,lon,height,mlat,mlon,rad)
        lat=mlat
        lon=mlon
      endif
        pos1[0,1,0]=lat
        pos1[1,1,0]=lon
        pos1[2,1,0]=rho
        s=RadarPos(0,beam,r,site,frang,rsep,recrise,height,rho,lat,lon)
      if (mgflag eq 1) then begin
        s=AACGMConvert(lat,lon,height,mlat,mlon,rad)
        lat=mlat
        lon=mlon
      endif
        pos1[0,0,1]=lat
        pos1[1,0,1]=lon
        pos1[2,0,1]=rho
        s=RadarPos(0,beam+1,r,site,frang,rsep,recrise,height,rho,lat,lon)
        if (mgflag eq 1) then begin
          s=AACGMConvert(lat,lon,height,mlat,mlon,rad)
          lat=mlat
          lon=mlon
       endif
        pos1[0,1,1]=lat
        pos1[1,1,1]=lon
        pos1[2,1,1]=rho
      endelse
    if (n_elements(range) GT 1) then $
      if (keyword_set(center)) then pos(*,i)=pos1(*,0,0) else $
      pos(*,*,*,i)=pos1 else $
      if (keyword_set(center)) then pos=pos1(*,0,0) else $
      pos = pos1
  endfor
  pos=reform(pos)
  return,pos
end