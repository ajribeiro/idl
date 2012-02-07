function calcTimeJulianCent, jd
	T = (jd - 2451545.0d)/36525.0d
	return, T
end

function calcGeomMeanLongSun, t
	L0 = 280.46646d + t * ( 36000.76983d + t*0.0003032d )
	while L0 gt 360.0d do $
		L0 -= 360.0d
	while L0 lt 0.0d do $
	L0 += 360.0d
	return, L0 ; in degrees
end

function calcGeomMeanAnomalySun, t
	M = 357.52911d + t * ( 35999.05029d - 0.0001537d * t)
  return, M ; in degrees
end

function calcEccentricityEarthOrbit, t
	e = 0.016708634d - t * ( 0.000042037d + 0.0000001267d * t)
	return, e ; unitless
end

function calcSunEqOfCenter, t
	mrad = calcGeomMeanAnomalySun(t)*!dtor
	sinm = sin(mrad)
	sin2m = sin(mrad+mrad)
	sin3m = sin(mrad+mrad+mrad)
	C = sinm * (1.914602d - t * (0.004817d + 0.000014d * t)) + sin2m * (0.019993d - 0.000101d * t) + sin3m * 0.000289d
	return, C ; in degrees
end

function calcSunTrueLong, t
	l0 = calcGeomMeanLongSun(t)
	c = calcSunEqOfCenter(t)
	O = l0 + c
	return, O ; in degrees
end

function calcSunTrueAnomaly, t
	m = calcGeomMeanAnomalySun(t)
	c = calcSunEqOfCenter(t)
	v = m + c
	return, v ; in degrees
end

function calcSunRadVector, t
	v = calcSunTrueAnomaly(t)
	e = calcEccentricityEarthOrbit(t)
	R = (1.000001018d * (1.d - e * e)) / ( 1.d + e * cos( v*!dtor ) )
	return, R ; n AUs
end

function calcSunApparentLong, t
	o = calcSunTrueLong(t)
	omega = 125.04d - 1934.136d * t
	lambda = o - 0.00569d - 0.00478d * sin(omega*!dtor)
	return, lambda ; in degrees
end

function calcMeanObliquityOfEcliptic, t
	seconds = 21.448d - t*(46.8150d + t*(0.00059d - t*(0.001813d)))
	e0 = 23.0d + (26.0d + (seconds/60.0d))/60.0d
	return, e0 ; in degrees
end

function calcObliquityCorrection, t
	e0 = calcMeanObliquityOfEcliptic(t)
	omega = 125.04d - 1934.136d * t
	e = e0 + 0.00256d * cos(omega*!dtor)
  return, e ; in degrees
end

function calcSunRtAscension, t
	e = calcObliquityCorrection(t)
	lambda = calcSunApparentLong(t)
	tananum = ( cos(e*!dtor) * sin(lambda*!dtor) )
	tanadenom = cos(lambda*!dtor)
	alpha = atan(tananum, tanadenom)*!radeg
	return, alpha ; in degrees
end

function calcSunDeclination, t
	e = calcObliquityCorrection(t)
	lambda = calcSunApparentLong(t)
	sint = sin(e*!dtor) * sin(lambda*!dtor)
	theta = asin(sint)*!radeg
	return, theta ; in degrees
end

function calcEquationOfTime, t
	epsilon = calcObliquityCorrection(t)
	l0 = calcGeomMeanLongSun(t)
	e = calcEccentricityEarthOrbit(t)
	m = calcGeomMeanAnomalySun(t)
	y = tan(epsilon*!dtor/2.0d)
	y *= y

	sin2l0 = sin(2.0d * l0*!dtor)
	sinm   = sin(m*!dtor)
	cos2l0 = cos(2.0d * l0*!dtor)
	sin4l0 = sin(4.0d * l0*!dtor)
	sin2m  = sin(2.0d * m*!dtor)

	Etime = y * sin2l0 - 2.0d * e * sinm + 4.0d * e * y * sinm * cos2l0 - 0.5d * y * y * sin4l0 - 1.25d * e * e * sin2m
	return, Etime*!radeg*4.0 ; in minutes of time
end

function calcHourAngleSunrise, lat, solarDec
	latRad = lat*!dtor
	sdRad  = solarDec*!dtor
	HAarg = cos(90.833d*!dtor) / ( cos(latRad)*cos(sdRad) ) - tan(latRad) * tan(sdRad)
	HA = acos(HAarg);
	return, HA ; in radians (for sunset, use -HA)
end

function calcSolNoon, jd, longitude, timezone, dst
	tnoon = calcTimeJulianCent(jd - longitude/360.0d)
	eqTime = calcEquationOfTime(tnoon)
	solNoonOffset = 720.0d - (longitude * 4.d) - eqTime ; in minutes
	newt = calcTimeJulianCent(jd + solNoonOffset/1440.0d)
	eqTime = calcEquationOfTime(newt)
	solNoonLocal = 720.0d - (longitude * 4.d) - eqTime + (timezone*60.0d) ; in minutes
	if dst then $
		solNoonLocal += 60.0d
; 	prinfo, 'Noon: '+string(solNoonLocal)
	return, solNoonLocal
end

function calcAzEl, output, t, localtime, latitude, longitude, zone
	eqTime = calcEquationOfTime(t)
	theta  = calcSunDeclination(t)
	;prinfo, 'EqT: '+string(floor(eqTime*100.d + 0.5d)/100.0d)
	;prinfo, 'The: '+string(floor(theta*100.d + 0.5d)/100.0d)

	solarTimeFix = eqTime + 4.0d * longitude - 60.0d * zone
	earthRadVec = calcSunRadVector(t)

	trueSolarTime = localtime + solarTimeFix
	while trueSolarTime gt 1440 do $
		trueSolarTime -= 1440.d

	hourAngle = trueSolarTime / 4.0d - 180.0d
	if hourAngle lt -180.d then $
		hourAngle += 360.0d

	haRad = hourAngle*!dtor
	csz = sin(latitude*!dtor) * sin(theta*!dtor) + cos(latitude*!dtor) * cos(theta*!dtor) * cos(haRad)
  if csz gt 1.0 then $
    csz = 1.0 $
	else if csz lt -1.0 then $
		csz = -1.0
	zenith = acos(csz)*!radeg
	azDenom = cos(latitude*!dtor) * sin(zenith*!dtor)
	if abs(azDenom) gt 0.001 then begin
		azRad = (( sin(latitude*!dtor) * cos(zenith*!dtor) ) - sin(theta*!dtor)) / azDenom
		if abs(azRad) gt 1.0d then begin
			if azRad lt 0.d then $
				azRad = -1.0d $
			else $
				azRad = 1.0d
		endif
		azimuth = 180.0d - acos(azRad)*!radeg
		if hourAngle gt 0.0d then $
			azimuth = -azimuth
	endif else begin
		if latitude gt 0.0d then $
			azimuth = 180.0d $
		else $
			azimuth = 0.0d
	endelse
	if azimuth lt 0.0d then $
	azimuth += 360.0d
	exoatmElevation = 90.0d - zenith

	; Atmospheric Refraction correction
	if exoatmElevation gt 85.0d then $
		refractionCorrection = 0.0d $
	else begin
		te = tan(exoatmElevation*!dtor)
		if exoatmElevation gt 5.0d then $
			refractionCorrection = 58.1d / te - 0.07d / (te*te*te) + 0.000086d / (te*te*te*te*te) $
		else if exoatmElevation gt -0.575d then $
			refractionCorrection = 1735.0d + exoatmElevation * (-518.2d + exoatmElevation * (103.4d + exoatmElevation * (-12.79d + exoatmElevation * 0.711d) ) ) $
		else $
			refractionCorrection = -20.774d / te
		refractionCorrection = refractionCorrection / 3600.0d
	endelse

	solarZen = zenith - refractionCorrection
	output = solarZen

; 	if solarZen gt 108.0d then $
; 		prinfo, 'Dark.' $
; 	else begin
; 		prinfo, 'Azm: '+string(floor(azimuth*100.d + 0.5d)/100.0d)
; 		prinfo, 'Zen: '+string(floor((90.0d - solarZen)*100.d + 0.5d)/100.0d)
; 	endelse
	return, azimuth
end

function calcSunriseSetUTC, rise, JD, latitude, longitude
	t = calcTimeJulianCent(JD)
;	print, 'julcent: ', t
	eqTime = calcEquationOfTime(t)
;	print, 'eqtime: ', eqTime
	solarDec = calcSunDeclination(t)
;	print, 'solardec: ', solarDec
	hourAngle = calcHourAngleSunrise(latitude, solarDec)
;	print, 'HA: ', hourAngle*!radeg
	if ~rise then $
		hourAngle = -hourAngle
	delta = longitude + hourAngle*!radeg
	timeUTC = 720.d - (4.0d * delta) - eqTime ; in minutes
	return, timeUTC
end

function getJD, day, month, year
	; print, day, month, year
	if month lt 2 then begin
		year -= 1
		month += 12
	endif
	A = floor(year/100.)
	B = 2.d - A + floor(A/4.d)
	JD = floor(365.25d*(year + 4716.d)) + floor(30.6001d*(month+1)) + day + B - 1524.5d
	return, JD
end

function calcSunriseSet, rise, JD, latitude, longitude, timezone, dst
	; rise = 1 for sunrise, 0 for sunset
	timeUTC    = calcSunriseSetUTC(rise, JD, latitude, longitude)
	; prinfo, 'TmUTC: '+string(timeUTC)
	newTimeUTC = calcSunriseSetUTC(rise, JD + timeUTC/1440.0d, latitude, longitude)
	; prinfo, 'nTmUTC: '+string(timeUTC)
	timeLocal = newTimeUTC + (timezone * 60.0d)
	riseT = calcTimeJulianCent(JD + newTimeUTC/1440.0d)
	riseAz = calcAzEl(0, riseT, timeLocal, latitude, longitude, timezone)
	timeLocal += ((dst) ? 60.0d : 0.0d)
	if timeLocal ge 0.0d and timeLocal lt 1440.0d then $
		return, timeLocal $
	else begin
		jday = JD
		increment = ((timeLocal lt 0.d) ? 1.d : -1.d)
		while timeLocal lt 0.0d or timeLocal ge 1440.0d do begin
			timeLocal += increment * 1440.0d
			jday -= increment
		endwhile
		return, timeLocal
	endelse
end

pro calculate_sunset, date, latitude, longitude, $
	timezone=timezone, dst=dst, $
	risetime=risetime, settime=settime, solnoon=solnoon

	if n_elements(timezone) eq 0 then $
		timezone = 0.d
	tz = double(timezone)

	dst = keyword_set(dst)

	if n_elements(date) eq 0 then begin
		prinfo, 'Must give date.'
		return
	endif

	parse_date, date, year, month, day
	jday = getJD(day, month, year)
	; ; calculate local sunrise time
	rise = calcSunriseSet(1, jday, latitude, longitude, tz, dst)
	set = calcSunriseSet(0, jday, latitude, longitude, tz, dst)
	noon = calcSolNoon(jday, longitude, tz, dst)

	risetime = long(rise/60.)*100 + round(rise mod 60L)
	settime =  long(set/60.)*100 + round(set mod 60L)
	solnoon = long(noon/60.)*100 + round(noon mod 60L)

end