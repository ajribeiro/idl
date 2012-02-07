pro amp_download_data, date, force=force

; this is the JavScript function that is called when you click the button on the website:
; getdata="/www/ampere/script/download.data"
;
;getdata="/project/ampere/www/script/download.data"
;
;function downloadData() {
;
;    el=document.getElementById("comment");
;
;    if (el.value.length==0) {
;      alert("Please provide a description of how you intend to use this data");
;      return;
;    }
;
;   tval=new Date();
;   tval.setFullYear(Time.getFullYear());
;   tval.setMonth(Time.getMonth());
;   tval.setDate(Time.getDate());
;
;   if (mo<10) mostr="0"+mo;
;   else mostr=""+mo;
;   if (dy<10) dystr="0"+dy;
;   else dystr=""+dy;
;
;    URL="/cgi-bin/cgiwrap.cgi?command"
;      URL=URL+"="+getdata+"&cli=";
;    URL=URL+yrmody+"+"+Projection.pole+"+"+logon+"+"+escape(el.value);
;
;    document.location.href=URL;
;
;}

; some pre-defines values

; ULR of the ampere website
baseurl = 'http://ampere.jhuapl.edu'

; login used for the ampere website
amp_username = 'lbnc'
getdata = "%2Fproject%2Fampere%2Fwww%2Fscript%2Fdownload.data"
baseurl = baseurl + "/cgi-bin/cgiwrap.cgi?command" + "=" + getdata + "&cli="

; login used to upload data to sd-data
data_username = 'sd-data'

; hardcode the path to the data (remote)
outdir = '/sd-data/ampere'

; temporary (local) data storage
tmp_outdir = '/tmp'
if ~file_test(tmp_outdir, /write) then begin
	prinfo, 'You do not have write access to the local output directory: '+tmp_outdir
	return
endif

; check input
if n_params() ne 1 then begin
	prinfo, 'Must give date.'
	return
endif

; check if wget is available
spawn, 'wget --help', res, erres
if strlen(erres) gt 0 then begin
	prinfo, 'Cannot execute wget: '+strjoin(erres, ' ')
	return
endif

; calculate number of days to download
sfjul, date, [0,2400], sjul, fjul, no_days=nd

for i=0, nd-1 do begin
	caldat, sjul+double(i), mm, dd, yy
	adate = string(yy*10000L + mm*100L + dd, format='(I8)')
	stryear = string(yy, format='(I4)')
	foutdir = outdir+'/'+stryear
	for h=0, 1 do begin
		hemi = h eq 0 ? 'north' : 'south'
		fname = adate+'.ampere.'+hemi+'.netcdf'
		if file_test(foutdir+'/'+hemi+'/'+fname) and ~keyword_set(force) then begin
			prinfo, 'File exists: '+foutdir+'/'+fname
			continue
		endif
		dataurl = baseurl + adate + '+'+hemi+'+'+amp_username+'+compareSD'
		outfile = tmp_outdir+'/'+fname
		wget_cmd = 'wget --progress=bar:force -O '+outfile+' "'+dataurl+'"'
		print, wget_cmd
		spawn, wget_cmd
		if (file_info(outfile)).size lt 2L^20 then begin
			continue
		endif
		copy_cmd = 'scp '+outfile+' '+data_username+'@sd-data:'+foutdir+'/'+hemi+'/'
		print, copy_cmd
		spawn, copy_cmd
		file_delete, outfile
	endfor
endfor

end