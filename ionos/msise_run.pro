pro msise_run, date, time, pressure=pressure, density=density, temperature=temperature, altitude=altitude


; Position
glat = 40.
glon = -80.


; Input date and time
parse_date, date, year, month, day
doy = day_no(date)
hourut = time/100L

; Execute code
davit_lib = getenv("DAVIT_LIB")
input = STRTRIM(year,2)+','+STRTRIM(doy,2)+','+STRTRIM(hourut,2)+','+STRTRIM(glat,2)+','+STRTRIM(glon,2)
if file_test('inp_file') then $
	file_delete, 'inp_file'
spawn, 'echo '+input+' >> inp_file'
spawn, davit_lib+'/vt/fort/nrlmsis/msise < inp_file'
spawn, 'rm -f inp_file'

openr, unit, 'AtmProfile.dat', /get_lun
while ~eof(unit) do begin
	readf, unit, talt, tp, trho, tT, format='(F7.2,3E13.5)'
	IF N_ELEMENTS(altitude) NE 0 THEN altitude = [altitude, talt] ELSE altitude = talt
	IF N_ELEMENTS(pressure) NE 0 THEN pressure = [pressure, tp] ELSE pressure = tp
	IF N_ELEMENTS(density) NE 0 THEN density = [density, trho] ELSE density = trho
	IF N_ELEMENTS(temperature) NE 0 THEN temperature = [temperature, tT] ELSE temperature = tT
endwhile
FREE_LUN, unit

end