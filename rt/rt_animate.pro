pro	rt_animate, date=date, radar=radar, beam=beam, time=time, silent=silent

common rt_data_blk

if ~file_test('/tmp/rt/animate', /dir) then begin
  FILE_MKDIR, '/tmp/rt/animate'
endif
if file_test('/tmp/rt/animate/slide.ps') then begin
  FILE_DELETE, '/tmp/rt/animate/slide.ps'
endif

if ~keyword_set(radar) then begin
	radar=rt_info.name
endif

if ~keyword_set(beam) then begin
	beam=rt_info.beam
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, rt_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then begin
	caldat, rt_info.sjul, mm, dd, yy, shr, smn
	caldat, rt_info.fjul, mm, dd, yy, fhr, fmn
	time = [shr*100L+smn, fhr*100L+fmn]
endif
tarr_hr = rt_data.juls
for n=0,n_elements(tarr_hr)-1 do begin
	caldat, tarr_hr[n], tmm, tdd, tyy, thr, tmn
	tarr_hr[n] = thr+tmn*1./60.
	if (tdd gt day) then begin
		arr_hr=tarr_hr[0:n-1]
		break
	endif
endfor
tz = rt_info.timez

for n=0,n_elements(arr_hr)-1 do begin
	dirname='/tmp/rt/ray_'+radar+STRTRIM(beam,2)+'_'+STRTRIM(date,2)+'_'+ $
		STRTRIM(STRING(floor(arr_hr[n])*100L + ROUND((arr_hr[n]-floor(arr_hr[n]))*60.),format='(I04)'),2)+tz
	FILE_COPY, dirname+'/raytrace.ps', '/tmp/rt/animate/r'+STRTRIM(n+1,2)+'.ps', /overwrite
endfor

CD, '/tmp/rt/animate/', current=old_dir
mergeps='r1.ps'
for n=1,n_elements(arr_hr)-1 do begin
	mergeps=mergeps+' r'+STRTRIM(n+1,2)+'.ps'
endfor
spawn, 'psmerge -oslide.ps '+mergeps
spawn, 'ps2pdf slide.ps slide.pdf'
CD, old_dir

END