;+
; NAME: 
; CRD_SHFT
;
; PURPOSE: 
; This function shifts all input points by a certain amount in latitude and longitude.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE:
; Result = CRD_SHFT(Grid, Lon_shft, Lat_shft, Kaz)
;
; INPUTS:
; Grid: A (2,N) element vector containing the latitude and logitude coordinates
; of N point in the grid to shift.
;
; Lon_shft: The shift in longitude in degree.
;
; Lat_shft: The shift in latitude in degree.
;
; Kaz: Something...
;
; KEYWORD PARAMETERS:
; NKAZ: Set this to a named variable that will contain the new values from kaz.
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Dec, 11 2009
;-
function crd_shft, grid, lon_shft, lat_shft, kaz, nkaz=nkaz

ss = size(grid, /dim)
npnts = ss[1]

lat   =  fltarr(npnts)
lon   =  fltarr(npnts)
vazm  =  fltarr(npnts)
lat   =  grid[0,0:npnts-1]
lon   =  grid[1,0:npnts-1]
vazm  =  kaz[0:npnts-1]
ngrid = grid

lon_min  =    0.
lon_max  =  360.

lon      =  lon + lon_shft
lon = check_lon(lon, lon_min, lon_max)

if (lat_shft eq 0.) then begin
	print,' lat_shift is set to zero!'
	print,' this call to crd_shft is unneccesary..but continuing..'
endif else begin 
	a_side = (90.-lat) * !pi/180.				;colat
	B_angl = (180.-lon) * !pi/180.				;lon
	d_side =  lat_shft * !pi/180.				;shift

	arg    =  cos(a_side)*cos(d_side) + sin(a_side)*sin(d_side)*cos(B_angl)
	q = where (abs(arg) gt 1., qcnt)
	if (qcnt ne 0) then arg[q] = arg[q]/abs(arg[q]) 

	b_side =  acos(arg)
	q = where(b_side eq 0., qc)			;adjust for point on pole
	if (qc ne 0) then b_side[q] = 0.1

	arg    = (cos(a_side)-cos(b_side)*cos(d_side))/(sin(b_side)*sin(d_side))
	q      =  where (abs(arg) gt 1., qcnt)
	if (qcnt ne 0) then arg[q] = arg[q]/abs(arg[q]) 

	A_angl =   acos(arg)

	q      =  where (lon gt 180., qcnt)			;acos ambiguity
	if (qcnt ne 0) then A_angl[q] = 2*!pi - A_angl[q]

	lon    =  A_angl * 180/!pi
	lat    =  (!pi/2.-b_side) * 180./!pi

	arg    = (cos(d_side)-cos(a_side)*cos(b_side))/(sin(a_side)*sin(b_side))
	q      =  where (abs(arg) gt 1., qcnt)
	if (qcnt ne 0) then arg[q] = arg[q]/abs(arg[q]) 

	C_angl =  acos(arg)
	sign_d =  d_side/abs(d_side)

	q      =  where (lon le 180., qcnt)			
	if (qcnt ne 0) then vazm[q] = vazm[q] - sign_d*C_angl[q]*180./!pi

	q      =  where (lon gt 180., qcnt)			
	if (qcnt ne 0) then vazm[q] = vazm[q] + sign_d*C_angl[q]*180./!pi

endelse

lon    =  lon - lon_shft
lon = check_lon(lon, lon_min, lon_max)

ngrid[0,0:npnts-1] = lat
ngrid[1,0:npnts-1] = lon
nkaz               = vazm

END