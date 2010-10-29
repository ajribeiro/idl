function get_electric_potentials,index=index

COMMON new_to_old

IF NOT keyword_set(map_open_flag) THEN BEGIN
  print,'You have to read in the MAP file first!'
  print,'OPEN_MAP_POT,fname   (where fname includes the directory string if not in current directory)'
  return,-1
ENDIF

IF keyword_set(index) THEN set_up_arrays,index
IF NOT keyword_set(time_spec_flag) THEN set_up_arrays,0

plot_lat_min=latzer_ref
latmin=latzer_ref


latstep   =  1.0				;points in plotting coords
longstep  =  2.0
nlats     =  fix((90.-plot_lat_min)/latstep)
nlongs    =  fix(360./longstep)
lats      =  findgen(nlats)*latstep + plot_lat_min
longs     =  findgen(nlongs+1)*longstep
grid      =  create_grid(plot_lat_min, latstep, longstep)

xxx_arr   =  reform(grid(1,*))
zon_arr   = [xxx_arr(uniq(xxx_arr)),360.]
zat_arr   =  reform(grid(0,0:nlats-1))

pot_arr1   =  fltarr(nlongs+1,nlats)


if (lat_shft eq 0) then iflg_coord = 1
if (lat_shft ne 0) then iflg_coord = 0

if (iflg_coord eq 1) then begin			;plot in primed coords

  convert_pos,grid,th,ph

  tmax      = (90.0 - latmin)*!dtor
  tprime    =  norm_theta(th,tmax)
  x         =  cos(tprime)
  plm       =  eval_legendre(order, x)
  v         =  eval_potential(solution(2,*),plm,ph)

  for i = 0,nlongs-1 do begin
    jl  =   i*nlats
    ju  =   i*nlats + (nlats-1)
    pot_arr1(i,*) = v(jl:ju)/1000.
  endfor

  pot_arr1(nlongs,*) =  pot_arr1(0,*)

  q = where(zat_arr le latmin, qc)		;set to zero below latmin
  if (qc ne 0) then pot_arr1(*,q(0):q(qc-1)) = 0.

endif

if (iflg_coord eq 0) then begin			;plot in unprimed coords

  npnts      =  nlongs * nlats			
  kaz        =  fltarr(npnts)
  crd_shft,lon_shft,lat_shft,npnts,grid,kaz

  xon_arr_p  =  fltarr(nlongs+1,nlats)
  xat_arr_p  =  fltarr(nlongs+1,nlats)
  for i = 0,nlongs-1 do begin			;find prime coords (latmin chk)
    jl  = i*nlats
    ju  = jl + nlats-1
    xon_arr_p(i,*) = grid(1,jl:ju)
    xat_arr_p(i,*) = grid(0,jl:ju)
  endfor

  convert_pos,grid,th,ph

  tmax      = (90.0 - latmin)*!dtor
  tprime    =  norm_theta(th,tmax)
  x         =  cos(tprime)
  plm       =  eval_legendre(order, x)
  v         =  eval_potential(solution(2,*),plm,ph)

  for i = 0,nlongs-1 do begin
    jl  =   i*nlats
    ju  =   i*nlats + (nlats-1)
    pot_arr1(i,*) = v(jl:ju)/1000.
  endfor

  q = where(xat_arr_p le latmin, qc)		;zero pot below latmin
  if (qc ne 0) then pot_arr1(q) = 0.

  pot_arr1(nlongs,*)      =  pot_arr1(0,*)

endif

return, {potarr:pot_arr1, zatarr:zat_arr, zonarr:zon_arr}

end