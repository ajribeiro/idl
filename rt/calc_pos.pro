
; ! ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
; ! Converts between geocentric coordinates and geodetic (World Geodetic System 1984 (WGS84))
; ! iopt: -1, geocentric to geodetic
; ! 			+1, geodetic to geocentric
; ! ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
function CALC_GD2GC, iopt, gdlat, gdlon, rho, glat, glon

	Rav = 6370.						; Earth radius [_km]
	a = 6378.137					; Equatorial radius [_km]
	f = 1./298.257223563			; Flattening of the Earth		

; ! semi-minor axis (polar radius)
	b = a*(1. - f)

; ! first eccentricity squared
	e2 = a^2./b^2. - 1.

; ! geodetic to geocentric
	case iopt of
		1: 	begin
				glat = atan( b^2./a^2. * tan(gdlat*!dtor) ) * !radeg
				glon = gdlon
				if (glon gt 180.) then glon = glon - 360.
			end
; ! geocentric to geodetic
		-1:	begin
				gdlat = atan( a^2./b^2. * tan(glat*!dtor) ) * !radeg
				gdlon = glon
			end
		else: print, 'CALC_GD2GC: wrong argument iopt = ', iopt
	endcase

; ! calculate Earth radius at point (uses geocentric latitude)
	rho = a / sqrt( 1. + e2*sin(glat*!dtor)^2. )

	success = 1
	return, success

END; CALC_GD2GC


; ! ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
; ! Calculates azimuth and elevation for oblate Earth. 
; ! Input and output positions are in degrees
; ! ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
function CALC_AZEL, lati, longi, azim, elev, gaz, gel


; ! Converts from geodetic to geocentric and find Earth radius
	is = CALC_GD2GC(1, lati, longi, Re, glat, glon)
	del = lati - glat

; ! Ray k-vector
	kxg = cos(elev*!dtor) * sin(azim*!dtor)
	kyg = cos(elev*!dtor) * cos(azim*!dtor)
	kzg = sin(elev*!dtor)

; ! Correction to the k-vector due to oblateness
	kxr = kxg
	kyr = kyg * cos(del*!dtor) + kzg * cos(del*!dtor)
	kzr = -kyg * sin(del*!dtor) + kzg * sin(del*!dtor)

; ! Finally compute corrected elevation and azimuth
	gaz = atan(kxr,kyr) * !radeg
	gel = atan(kzr / sqrt(kxr^2. + kyr^2.) ) * !radeg

	success = 1
	return, success

END; CALC_AZEL

function calc_pos, lati, longi, alti, azim, dist, elev, latiout, longiout

; ! Converts from geodetic to geocentric and find Earth radius
	is = CALC_GD2GC(1, lati, longi, Re, glat, glon)

; ! Adjusts azimuth and elevation for the oblateness of the Earth
	is = CALC_AZEL(lati, longi, azim, elev, gaz, gel)

; ! Pre-calculate sin and cos of lat and lon
	coslat = cos(glat*!dtor)
	sinlat = sin(glat*!dtor)
	coslon = cos(glon*!dtor)
	sinlon = sin(glon*!dtor)

; ! Convert from glabal spherical to global cartesian
	rx = (Re + alti) * coslat * coslon
	ry = (Re + alti) * coslat * sinlon
	rz = (Re + alti) * sinlat

; ! Convert from local spherical to local cartesian
	sx = -dist * cos(gel*!dtor) * cos(gaz*!dtor)
	sy = dist * cos(gel*!dtor) * sin(gaz*!dtor)
	sz = dist * sin(gel*!dtor)

; ! Convert from local cartesian to global cartesian
	tx = sinlat * sx + coslat * sz
	ty = sy
	tz = -coslat * sx + sinlat * sz
	sx = coslon * tx - sinlon * ty
	sy = sinlon * tx + coslon * ty
	sz = tz

; ! Add vectors in global cartesian system
	tx = rx + sx
	ty = ry + sy
	tz = rz + sz

; ! Convert from global cartesian to global spherical
	rho = sqrt( tx^2. + ty^2. + tz^2. )
	glat = 90. - acos(tz/rho)*!radeg
	glon = atan(ty, tx)*!radeg

; ! Compute geodetic coordinates and Earth radius at new point
	is = CALC_GD2GC(-1, latiout, longiout, Re, glat, glon)

	success = 1
	return, success

end


