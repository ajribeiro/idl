pro dms_ssj_download_files, date, silent=silent

;http://sd-www.jhuapl.edu/Aurora/data/ssj/2008/mar/2008mar29.f13.gz

base_url = 'http://sd-www.jhuapl.edu/Aurora/data/ssj'

str_date = format_date(date, /dmsp)
str_year = strmid(str_date, 0, 4)
str_mon  = strmid(str_date, 4, 3)

prinfo, 'Downloading DMSP data.'

for i=10, 18 do begin
	str_sat = 'f'+string(i,format='(I02)')
	outdi = '/tmp'
	if ~file_test(outdi, /dir) then begin
		prinfo, '/tmp/ directory does not exist.'
		return
	endif
	fname = str_date+'.'+str_sat+'.gz'
	cmd = 'wget -P '+outdi+' '+base_url+'/'+str_year+'/'+str_mon+'/'+fname
	if keyword_set(silent) then $
		spawn, cmd, outps, outpe $
	else $
		spawn, cmd
	if ~file_test(outdi+'/'+fname) then $
		continue
	if (file_info(outdi+'/'+fname)).size lt 1000 then $
		file_delete, outdi+'/'+fname $
	else begin
		cmd = 'scp '+outdi+'/'+fname+' sd-data@sd-data:/sd-data/dmsp/ssj/'+str_year+'/'
		if keyword_set(silent) then $
			spawn, cmd, outps, outpe $
		else $
			spawn, cmd
	endelse
endfor

wait, 5

end