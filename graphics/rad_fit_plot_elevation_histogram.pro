pro rad_fit_plot_elevation_histogram, date=date, time=time, long=long, $
	param=param, beams=beams, allbeams=allbeams, channel=channel, scan_id=scan_id, $
	coords=coords, xrange=xrange, yrange=yrange, scale=scale, $
	normalize=normalize, $
	freq_band=freq_band, silent=silent, $
	charthick=charthick, charsize=charsize, $
	no_title=no_title

common rad_data_blk

; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	return

if (*rad_fit_info[data_index]).nrecs eq 0L then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data in index '+string(data_index)
		rad_fit_info
	endif
	return
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, (*rad_fit_data[data_index]).juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

if ~keyword_set(param) then $
	param = 'elevation'
binds = where(~strcmp(param, 'elevation', /fold) and ~strcmp(param, 'phi0', /fold), bc)
if bc gt 0 then begin
	prinfo, 'PARAM must be "phi0" or "elevation".'
	return
endif
npanels = n_elements(param)

if n_elements(beams) eq 0 then $
	beams = rad_get_beam()
if keyword_set(allbeams) then $
	beams = indgen(16)
nbeams = n_elements(beams)

if ~keyword_set(coords) then $
	coords = 'gate'
if ~strcmp(coords, 'gate', /fold) and ~strcmp(coords, 'rang', /fold) then begin
	prinfo, 'COORDS must be "gate" or "rang".'
	return
endif

; for multiple parameter plot
; always stack them
ymaps = npanels
xmaps = 1

; set format to sardines
set_format, /sardines

; clear output area
clear_page

; loop through panels
for b=0, npanels-1 do begin

	ascale = 0

	aparam = param[b]
	if keyword_set(scale) then $
		ascale = scale[b*2:b*2+1]
	if keyword_set(yrange) then $
		ayrange = yrange[b*2:b*2+1]

	xmap = b mod xmaps
	ymap = b/xmaps

	first = 0
	if xmap eq 0 then $
		first = 1

	last = 0
	if ymap eq ymaps-1 then $
		last = 1

	; plot an rti panel for each beam
	rad_fit_plot_elevation_histogram_panel, xmaps, ymaps, xmap, ymap, /bar, $
		date=date, time=time, long=long, $
		param=aparam, beams=beams, allbeams=allbeams, $
		normalize=normalize, $
		channel=channel, scan_id=scan_id, $
		coords=coords, xrange=xrange, yrange=ayrange, scale=ascale, $
		freq_band=freq_band, silent=silent, $
		charthick=charthick, charsize=charsize, $
		last=last, first=first

	;only plot tfreq noise panel once
	if b eq 0 then begin
		if ~keyword_set(no_title) then $
			rad_fit_plot_rti_title, xmaps, ymaps, xmap, ymap, /bar, $
				charthick=charthick, charsize=charsize, $
				freq_band=freq_band, beam=beams
	endif
	
	plot_colorbar, xmaps, ymaps, xmap, ymap, scale=ascale, $
		param=aparam, legend='Count', level_format=( keyword_set(normalize) ? '(F4.2)' : '(I)' )

endfor

; plot a title and colorbar for all panels

if (*rad_fit_info[data_index]).fitex then $
	fitstr = 'fitEX'

if (*rad_fit_info[data_index]).fitacf then $
	fitstr = 'fitACF'

if (*rad_fit_info[data_index]).fit then $
	fitstr = 'fit'

if n_elements(param) gt 1 then $
	rad_fit_plot_title, 'SUPERDARN PARAMETER PLOT', (*rad_fit_info[data_index]).name+': ('+fitstr+')', scan_id=scan_id $
else $
	rad_fit_plot_title, scan_id=scan_id, param=param[0]

end