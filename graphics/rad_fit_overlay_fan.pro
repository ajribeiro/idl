;+ 
; NAME: 
; RAD_FIT_OVERLAY_FAN
; 
; PURPOSE: 
; This procedure overlays a certain radar scan on a stereographic polar map.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_OVERLAY_FAN
;
; OPTIONAL INPUTS:
; Scan_number: The number of the scan to overlay. Set to -1 if you want to
; choose the scan number by providing a date/time via the JUL keyword.
;
; KEYWORD PARAMETERS:
; JUL: Set this to a julian day number to select the scan to plot as that
; nearest to this date/time.
;
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn', 'geog', 'range' and 'gate'.
; Default is 'gate'.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; SCAN_STARTJUL: Set this to a named variable that will contain the
; julian day number of the plotted scan.
;
; ROTATE: Set this keyword to rotate the scan plot by 90 degree clockwise.
;
; FORCE_DATA: Set this keyword to a [nb, ng] array holding the scan data to plot.
; this overrides the internal scan finding procedures. nb is the number of beams,
; ng is the number of gates.
;
; VECTOR: Set this keyword to plot colored vectors 
; (like in the map potential plots)
; instead of colored polygons.
;
; FACTOR: Set this keyword to alter the length of vectors - only valid
; when plotting vectors.
;
; SIZE: Set this keyword to adjust thickness of vector and size of dot - only valid
; when plotting vectors.
;
; EXCLUDE: Set to a 2-element array giving the lower and upper velocity limit 
; to plot.
;
; FIXED_LENGTH: Set this keyword to a velocity value such that all vectors will be drawn
; with a lentgh correponding to that value, however they will still be color-coded
; according to their actual velocity value.
;
; SYMSIZE: Size of the symbols used to mark the radar position.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's .
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_fit_overlay_fan, scan_number, coords=coords, time=time, date=date, jul=jul, $
	param=param, scale=scale, channel=channel, scan_id=scan_id, $
	freq_band=freq_band, rotate=rotate, force_data=force_data, $
	scan_startjul=scan_startjul, no_redefine=no_redefine, $
	vector=vector, factor=factor, size=size, exclude=exclude, $
	fixed_length=fixed_length, symsize=symsize

prinfo, 'DEPRECATED. Use RAD_FIT_OVERLAY_SCAN.'

rad_fit_overlay_scan, scan_number, coords=coords, time=time, date=date, jul=jul, $
	param=param, scale=scale, channel=channel, scan_id=scan_id, $
	freq_band=freq_band, rotate=rotate, force_data=force_data, $
	scan_startjul=scan_startjul, no_redefine=no_redefine, $
	vector=vector, factor=factor, size=size, exclude=exclude, $
	fixed_length=fixed_length, symsize=symsize

prinfo, 'DEPRECATED. Use RAD_FIT_OVERLAY_SCAN.'

end
