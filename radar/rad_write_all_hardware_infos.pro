pro rad_write_all_hardware_infos, indir=indir, outdir=outdir

if ~keyword_set(indir) then $
	indir = '/davit/lib/rst/tables/superdarn/hdw'

if ~file_test(indir, /dir) then begin
	prinfo, 'Input directory does not exist: '+indir
	return
endif

if ~keyword_set(outdir) then $
	outdir = '/var/www/hdw'

if ~file_test(outdir, /dir) then begin
	prinfo, 'Output directory does not exist: '+outdir
	return
endif

files = file_search(indir+'/hdw.dat.???', count=fc)
if fc lt 1 then begin
	prinfo, 'No hardware files found: '+indir+'/hdw.dat.???'
	return
endif

rad_write_general_hardware_info, outdir=outdir
for i=0, fc-1 do begin
	;prinfo, 'Doing '+files[i]
	rad_prettyprint_hardware_info, files[i]
	rad_write_hardware_info, files[i], outdir=outdir
	sid = strmid(file_basename(files[i]), 8, 3)
	ihtmlfilename = outdir+'/'+file_basename(files[i])+'.html'
	ohtmlfilename = ihtmlfilename+'.tmp'
	line = ''
	in_table = !false
	openw, olun, ohtmlfilename, /get_lun
	printf, olun, '<html><body><link rel="stylesheet" href="http://vt.superdarn.org/styles/vtsuperdarn.css" type="text/css" media="screen" />'
	openr, ilun, ihtmlfilename, /get_lun
	while ~eof(ilun) do begin
		readf, ilun, line
		if (pos = strpos(line, '<table')) ne -1 then begin
			line = strmid(line, pos)
			in_table = !true
		endif
		if in_table then begin
			if strpos(line, 'PDF') ne -1 then $
				continue
			if (pos = strpos(line, '</table>')) ne -1 then begin
				line = strmid(line, 0, pos+8)
				printf, olun, line
				break
			endif
			printf, olun, line
		endif
	endwhile
	free_lun, ilun
	printf, olun, '<p />'
	filename = 'hdw.general.html'
	ihtmlfilename = outdir+'/'+file_basename(filename)
	openr, ilun, ihtmlfilename, /get_lun
	while ~eof(ilun) do begin
		readf, ilun, line
		if (pos = strpos(line, '<table')) ne -1 then begin
			line = strmid(line, pos)
			in_table = !true
		endif
		if in_table then begin
			if strpos(line, 'PDF') ne -1 then $
				continue
			if (pos = strpos(line, '</table>')) ne -1 then begin
				line = strmid(line, 0, pos+8)
				printf, olun, line
				break
			endif
			printf, olun, line
		endif
	endwhile
	free_lun, ilun
	printf, olun, '</body></html>'
	free_lun, olun
	html2ps = '/usr/bin/html2ps'
	if ~file_test(html2ps) then begin
		prinfo, 'Cannot find html2ps.'
		return
	endif
	opsfilename = outdir+'/'+file_basename(ohtmlfilename, '.html.tmp')+'.ps'
	print, ohtmlfilename+' -> '+opsfilename
	spawn, html2ps+' '+ohtmlfilename+' > '+opsfilename
	file_delete, ohtmlfilename
	ps2pdf = '/usr/bin/ps2pdf'
	if ~file_test(ps2pdf) then begin
		prinfo, 'Cannot find ps2pdf.'
		file_delete, opsfilename
		return
	endif
	opdffilename = outdir+'/'+file_basename(ohtmlfilename, '.html.tmp')+'.pdf'
	print, opsfilename+' -> '+opdffilename
	spawn, ps2pdf+' '+opsfilename+' > '+opdffilename
	file_delete, opsfilename
endfor

end