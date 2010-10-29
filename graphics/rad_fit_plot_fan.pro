;+ 
; NAME: 
; RAD_FIT_PLOT_FAN
; 
; PURPOSE: 
; This procedure plots a stereographic map grid and overlays coast
; lines and the currently loaded radar data. This routine will call
; RAD_FIT_PLOT_FAN_PANEL multiple times if need be.
;
; The scan that will be plot is either chosen by its number (set keyword
; SCAN_NUMBER), the date and time closest to an available scan 
; (set DATE and TIME keywords) or the Juliand Day in SCAN_STARTJUL.
;
; NSCANS then determines how many sequential fan plots are put on one page.
; 
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_FAN
;
; KEYWORD PARAMETERS:
; DATE: A scalar giving the date to plot, in YYYYMMDD format.
;
; TIME: A scalar giving the time to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn' and 'geog'.
;
; XRANGE: Set this keyword to change the range of the x axis.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SCALE: Set this keyword to change the scale of the plotted values.
;
; SCAN_STARTJUL: Set this to a Julian Day determining the scan to plot.
;
; SCAN_NUMBER: Set this to a numer specifying the scan to plot.
;
; NSCANS: Set this to the number of sequential scans to plot. Default is 1.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; NO_FILL: Set this keyword to surpress filling of land masses and lakes with colors.
;
; NO_TITLE: Set this keyword to omit individual titles for the plots.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_POLAR.
; Written by Lasse Clausen, Nov, 24 2009
;-
pro rad_fit_plot_fan, date=date, time=time, long=long, $
	param=param, scale=scale, channel=channel, scan_id=scan_id, $
	scan_startjul=scan_startjul, nscans=nscans, $
	coords=coords, xrange=xrange, yrange=yrange, $
	charthick=charthick, charsize=charsize, $
	scan_number=scan_number, $
	freq_band=freq_band, silent=silent, no_fill=no_fill, no_title=no_title

prinfo, 'DEPRECATED. Use RAD_FIT_PLOT_SCAN.'

rad_fit_plot_scan, date=date, time=time, long=long, $
	param=param, scale=scale, channel=channel, scan_id=scan_id, $
	scan_startjul=scan_startjul, nscans=nscans, $
	coords=coords, xrange=xrange, yrange=yrange, $
	charthick=charthick, charsize=charsize, $
	scan_number=scan_number, $
	freq_band=freq_band, silent=silent, no_fill=no_fill, no_title=no_title

prinfo, 'DEPRECATED. Use RAD_FIT_PLOT_SCAN.'

end
