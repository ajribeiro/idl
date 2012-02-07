pro rad_raw_plot_acf, date=date, time=time, long=long, $
	beam=beam, gates=gates

common rad_data_blk

; get index for current data
	
if rad_raw_info.nrecs eq 0L then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data in RAD_RAW_DATA.'
		rad_raw_info
	endif
	return
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, rad_raw_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = 1200

if n_elements(time) ne 1 then begin
	prinfo, 'TIME must be scalar, using first element.'
	time = time[0]
endif

sfjul, date, time, ajul, long=long

if ~keyword_set(beam) then $
	beam = rad_get_beam()

if ~keyword_set(gates) then $
	gates = indgen(40)
ngates = n_elements(gates)

columns = ceil(ngates/10.) > 1
rows    = (10 < ngates)

clear_page
set_format, /sard, /kansas

for g=0, ngates-1 do begin
	scan_id = -1
	col = g/rows
	row = g mod rows
	pos = define_panel(columns, rows, col, row)
	posl = [pos[0], pos[1], (pos[0]+pos[2])/2., pos[3]]
	posr = [(pos[0]+pos[2])/2., pos[1], pos[2], pos[3]]
	rad_raw_plot_acf_panel, date=date, time=time, long=long, $
		position=posl, beam=beam, gate=gates[g], yticks=2, $
		charsize=get_charsize(columns, rows), /main, $
		ytickformat='(e8.1)', symsize=.5, linestyle=linestyle
	plot_panel_title, position=posl, /silent, $
		lefttitle='Main', charsize=get_charsize(columns, rows), $
		righttitle='(Gate: '+STRTRIM(string(gates[g]),2)+')'
	rad_raw_plot_acf_panel, date=date, time=time, long=long, $
		position=posr, beam=beam, gate=gates[g], yticks=2, $
		charsize=get_charsize(columns, rows), /inter, $
		ytickname=replicate(' ', 60), ystyle=9, scan_id=scan_id, $
		symsize=.5, linestyle=linestyle
	axis, /yaxis, /ystyle, yrange=!y.crange, $
		charsize=get_charsize(columns, rows), yticks=1, $
		ytickformat='(e8.1)', $
		ytickv=!y.crange[0]+[1.,2.]/3.*(!y.crange[1]-!y.crange[0])
	plot_panel_title, position=posr, /silent, $
		lefttitle='Inter.', charsize=get_charsize(columns, rows), $
		righttitle='(SCID: '+STRTRIM(string(scan_id),2)+')'
endfor

rad_raw_plot_title, righttitle=format_juldate(ajul)

XYOUTS, 0.87, 0.91, 'Real', align=.5, $
		/NORMAL, CHARSIZE=.7, COLOR=get_foreground()
plots, 0.87+[-.05,.05], [0.91,0.91]-0.01, color=30, $
	linestyle=linestyle, /norm
plots, 0.87-.05, 0.91-0.01, color=30, $
	psym=-2, symsize=symsize, /norm
XYOUTS, 0.87, 0.88, 'Imaginary', align=.5, $
		/NORMAL, CHARSIZE=.7, COLOR=get_foreground()
plots, 0.87+[-.05,.05], [0.88,0.88]-0.01, color=250, $
	linestyle=linestyle, /norm
plots, 0.87-.05, 0.88-0.01, color=250, $
	psym=-5, symsize=symsize, /norm

end