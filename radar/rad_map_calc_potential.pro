;+
; NAME: 
; RAD_MAP_CALC_POTENTIALS
;
; PURPOSE: 
; This function calculates the electric potential from the harmonic expansion coefficients
; on a latitude-longitude grid used for overlaying the potential contours.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; Result = RAD_MAP_CALC_POTENTIALS(Int_hemi, Index)
;
; INPUTS:
; Int_hemi: An integer indicating the hemisphere, 0 for north, 1 for south.
;
; Index: The index number of the coefficients to calculate.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding map data.
;
; MODIFICATION HISTORY: 
; Based on get_electric_potentials in the leicester world
; Written by Lasse Clausen, Dec, 11 2009
;-
function rad_map_calc_potential, int_hemi, index

common rad_data_blk

if n_elements(int_hemi) eq 0 then $
	int_hemi = 0

if n_elements(index) eq 0 then $
	index = 0

; get the order of the fit
order = (*rad_map_data[int_hemi]).fit_order[index]

; get latitude shift
lat_shft = (*rad_map_data[int_hemi]).lat_shft[index]

; get latitude shift
lon_shft = (*rad_map_data[int_hemi]).lon_shft[index]

; get minimum latitude
latmin = (*rad_map_data[int_hemi]).latmin[index]
tmax      = (90.0 - abs(latmin))*!dtor

; get coefficients of the expansion
coeffs = (*(*rad_map_data[int_hemi]).coeffs[index])

plot_lat_min = 30.

; initialize the grid on which to 
; evaluated the potential
latstep   =  1.0				;points in plotting coords
longstep  =  2.0
nlats     =  fix((90.-plot_lat_min)/latstep)
nlongs    =  fix(360./longstep)+1
zat_arr   =  (findgen(nlats)*latstep + plot_lat_min);*( int_hemi eq 0 ? 1. : -1. )
zon_arr   =  findgen(nlongs)*longstep
grid      =  transpose([[reform(rebin(zat_arr, nlats, nlongs), nlats*nlongs)], $
	[rebin(zon_arr, nlats*nlongs, /sample)]])
pot_arr   =  fltarr(nlongs,nlats)

; convert to spherical coordinates
; i.e. azimuth and polar angle
theta  = (90.-reform(grid[0,*]))*!dtor
phi    = reform(grid[1,*])*!dtor
tprime =  norm_theta(theta, tmax)
x      =  cos(tprime)
plm    =  eval_legendre(order, x)
v      =  rad_map_eval_potential(coeffs[*,2], plm, phi)
pot_arr = transpose(reform(v, nlats, nlongs))/1000.

if (lat_shft eq 0) then iflg_coord = 1
if (lat_shft ne 0) then iflg_coord = 0

if (iflg_coord eq 1) then begin			;plot in primed coords

  q = where(zat_arr le abs(latmin), qc)		;set to zero below latmin
  if (qc ne 0) then pot_arr[*,q[0]:q[qc-1]] = 0.

endif

if (iflg_coord eq 0) then begin			;plot in unprimed coords

  npnts      =  nlongs * nlats
  kaz        =  fltarr(npnts)
  grid = crd_shft(grid, lon_shft, lat_shft, kaz)
  xon_arr_p  =  fltarr(nlongs,nlats)
  xat_arr_p  =  fltarr(nlongs,nlats)
	xon_arr_p = transpose(reform(reform(grid[1,*], nlats, nlongs)))
	xat_arr_p = transpose(reform(reform(grid[0,*], nlats, nlongs)))

  q = where(xat_arr_p le abs(latmin), qc)		;zero pot below latmin
  if (qc ne 0) then pot_arr[q] = 0.

endif

return, {potarr:pot_arr, zatarr:zat_arr, zonarr:zon_arr}

end