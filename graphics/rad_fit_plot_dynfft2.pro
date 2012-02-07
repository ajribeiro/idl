;+ 
; NAME: 
; RAD_FIT_PLOT_DYNFFT2
; 
; PURPOSE: 
; This procedure plots a dynamic FFT on a page. With title. With even more stuff than RAD_FIT_PLOT_DYNFFT.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_DYNFFT
;
; KEYWORD PARAMETERS:
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; TIME: A 2-element vector giving the time range to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; BEAMS: Set this keyword to a scalar or array of beam numbers to plot.
;
; GATES: Set this keyword to a scalar or array of gate numbers to plot.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; YRANGE: Set this keyword to change the range of the y axis of the dynamic FFT plot.  See RTI_YRANGE to change the y axis of the RTI plot.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; INTERPOLATE: Set this keyword to a time resolution in seconds to interpolate the input
; data.  Interpolation is required to place radar data onto a regular time grid before
; computing the FFT.  If INTERPOLATE is not set, a default value of 5 seconds is used.
; To disable interpolation (useful if data set is already uniform in time), set
; INTERPOLATE = -1.
;
; DETREND: Set this keyword to the degree polynomial to fit and then subtract from each set
; of windowed data.  By default, this is set to DETREND=1 which corresponds to a linear fit/
; detrending.  Set DETREND=0 to remove the average; set DETREND=-1 to disable detrending.
;
; WINDOWLENGTH: Set this keyword to set the length of the time window in seconds over which 
; to compute each FFT.  Default of WINDOWLENGTH = 600 s.
;
; STEPLENGTH: Set this keyword to set the length of the interval between FFT windows.  This valuel defaults to WINDOWLENGTH/2.
;
; MAGNITUDE: Set this keyword to return the unnormalized magnitude of the FFT.
;
; NORMALIZE: Set this keyword to return the normalized magnitude of the FFT.
;
; NO_TITLE: Set this keyword to surpress plotting of a title.
;
; COORDS: Set this keyword to a string naming the coordinate system
; of the y axis. Allowable inputs are 'magn', 'geog', 'rang' and 'gate'.
; Default is 'gate'.  This applies to the RTI portion of the plot only.
;
; RTI_SC_VALUES:
;
; RTI_SCALE:
;
; RTI_YRANGE: YRANGE of the RTI Plot.
;
; SUN: Set this keyword to overplot sunrise, sunset and solar noon times.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE: 
; 
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_RTI.
; Written by Lasse Clausen, Nov, 24 2009; Nathaniel A. Frissell, 2011
;-
PRO RAD_FIT_PLOT_DYNFFT2                        $
    ,date               = date                  $
    ,time               = time                  $
    ,long               = long                  $
    ,param              = param                 $
    ,beams              = beams                 $
    ,gates              = gates                 $
    ,channel            = channel               $
    ,scan_id            = scan_id               $
    ,yrange             = yrange                $
    ,INTERPOLATE        = interpolate           $
    ,WINDOWLENGTH       = windowLength          $
    ,STEPLENGTH         = stepLength            $
    ,DETREND            = detrend               $
    ,NORMALIZE          = normalize             $
    ,exclude            = exclude               $
    ,freq_band          = freq_band             $
    ,silent             = silent                $
    ,charthick          = charthick             $
    ,charsize           = charsize              $
    ,no_title           = no_title              $
    ,avg_gates          = avg_gates             $
    ,COORDS             = coords                $
    ,RTI_SC_VALUES      = rti_sc_values         $
    ,RTI_SCALE          = rti_scale             $
    ,RTI_YRANGE         = rti_range             $
    ,SUN                = sun

common rad_data_blk
bar     = 1
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

if ~keyword_set(param) then $
	param = get_parameter()

;if ~is_valid_parameter(param) then begin
;	prinfo, 'Invalid plotting parameter: >'+strjoin(param,'<>')+'<'
;	return
;endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, (*rad_fit_data[data_index]).juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

if n_elements(beams) eq 0 then $
	_beams = rad_get_beam() $
else $
	_beams = beams

if n_elements(gates) eq 0 then $
	_gates = [rad_get_gate()] $
else $
	_gates = [gates] ; ( n_elements(gates) eq 1 ? [gates] : gates )

nbeams = n_elements(_beams)
ngates = (keyword_set(avg_gates) ? 1L : n_elements(_gates))
nparams = n_elements(param)
npanels = max([nbeams, ngates, nparams])

if ngates gt 1 and nbeams gt 1 and ~keyword_set(avg_gates) then begin
	prinfo, 'You cannot plot multiple gates AND multiple beams.'
	return
endif

if ngates gt 1 and nparams gt 1 and ~keyword_set(avg_gates) then begin
	prinfo, 'You cannot plot multiple gates AND multiple parameters.'
	return
endif

if nbeams gt 1 and nparams gt 1 then begin
	prinfo, 'You cannot plot multiple beams AND multiple parameters.'
	return
endif

if nbeams eq 1 and ngates gt 1 then begin
	_beams = replicate(_beams, ngates)
	nbeams = ngates
	npanels = nbeams
endif

if ngates eq 1 and nbeams gt 1 then begin
	_gates = transpose(reform(rebin(_gates, n_elements(_gates)*nbeams, /sample), nbeams, n_elements(_gates)))
	ngates = nbeams
	npanels = nbeams
endif

if ngates eq 1 and nparams gt 1 then begin
	_gates = transpose(reform(rebin(_gates, n_elements(_gates)*nparams, /sample), nparams, n_elements(_gates)))
	ngates = nparams
	npanels = nparams
endif

;if nparams gt 1 then begin
;	if ngates gt 1 or nbeams gt 1 then begin
;		prinfo, 'If multiple params are set, beam and gate must be scalar.'
;		return
;	endif
;	npanels = nparams
;endif

; calculate number of panels per page
xmaps = floor(sqrt(npanels)) > 1
ymaps = ceil(npanels/float(xmaps)) > 1

; take into account format of page
; if landscape, make xmaps > ymaps
fmt = get_format(landscape=ls)
if ls then begin
	if ymaps gt xmaps then begin
		tt = xmaps
		xmaps = ymaps
		ymaps = tt
	endif
; if portrait, make ymaps > xmaps
endif else begin
	if xmaps gt ymaps then begin
		tt = ymaps
		ymaps = xmaps
		xmaps = tt
	endif
endelse

; for multiple parameter plot
; always stack them
if nparams gt 1 then begin
	ymaps = npanels
	xmaps = 1
endif

; for plots of less than 4 beams
; always stack them
if npanels lt 4 then begin
	ymaps = npanels
	xmaps = 1
endif

; set charsize of info panels smaller
ichars = (!d.name eq 'X' ? 1. : 1. ) * get_charsize(xmaps > 1, ymaps > 2)

; clear output area
clear_page
xmaps   = 1
ymaps   = 2
xmap    = 0
ymap    = 0

; plot noise and tfreq info panel
if ymap eq 0 then begin
        rad_fit_plot_scan_id_info_panel, xmaps, ymaps, xmap, ymap, bar=bar, $
                date=date, time=time, long=long, $
                charthick=charthick, charsize=ichars, $
                beam=abeam, channel=channel, /with_info, /legend
        rad_fit_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, bar=bar, $
                date=date, time=time, long=long, $
                charthick=charthick, charsize=ichars, $
                beam=abeam, channel=channel, scan_id=scan_id, /info, $
                last=last, first=first
        rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, bar=bar, $
                date=date, time=time, long=long, $
                charthick=charthick, charsize=ichars, $
                beam=abeam, channel=channel, scan_id=scan_id, /info, $
                last=last, first=first
endif

IF KEYWORD_SET(ascale) THEN BEGIN
IF ascale[0] EQ ascale[1] THEN ascale = 0
ENDIF

; plot an rti panel for each beam
first   = 1
last    = 0
rad_fit_plot_rti_panel, xmaps, ymaps, xmap, ymap        $
        ,/bar                                           $
        ,beam           = abeam                         $
        ,channel        = channel                       $
        ,charsize       = charsize                      $
        ,charthick      = charthick                     $
        ,coords         = coords                        $
        ,date           = date                          $
        ,exclude        = exclude                       $
        ,first          = first                         $
        ,freq_band      = freq_band                     $
        ,ground         = ground                        $
        ,last           = last                          $
        ,long           = long                          $
        ,param          = aparam                        $
        ,sc_values      = rti_sc_values                 $
        ,scale          = rti_scale                     $
        ,scan_id        = scan_id                       $
        ,silent         = silent                        $
        ,sun            = sun                           $
        ,time           = time                          $
        ,/with_info                                     $
        ,xticks         = xticks                        $
        ,yrange         = rti_yrange

PLOT_COLORBAR, xmaps, ymaps, xmap, ymap                 $
        ,scale          = rti_scale                     $
        ,param          = aparam                        $
        ,/with_info                                     $
        ,ground         = ground                        $
        ,sc_values      = rti_sc_values

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Plot DynFFT
++ymap
first   = 0
last    = 1
RAD_FIT_PLOT_DYNFFT_PANEL, xmaps, ymaps, xmap, ymap     $
        ,date           = date                          $
        ,time           = time                          $
        ,long           = long                          $
        ,param          = aparam                        $
        ,beam           = abeam                         $
        ,gate           = agate                         $
        ,avg_gates      = avg_gates                     $
        ,channel        = channel                       $
        ,scan_id        = scan_id                       $
        ,freq_band      = freq_band                     $
        ,yrange         = yrange                        $
        ,exclude        = exclude                       $
        ,silent         = silent                        $
        ,charthick      = charthick                     $
        ,charsize       = charsize                      $
        ,last           = last                          $
        ,first          = first                         $
        ,bar            = bar                           $
        ,INTERPOLATE    = interpolate                   $
        ,WINDOWLENGTH   = windowLength                  $
        ,STEPLENGTH     = stepLength                    $
        ,DETREND        = detrend                       $
        ,NORMALIZE      = normalize                     $
        ,ZRANGEOUT      = zRangeOut                     $
        ,/with_info

PLOT_COLORBAR,xmaps,ymaps,xmap,ymap                     $
        ,LEGEND         = 'FFT Magnitude'               $
        ,SCALE          = zRangeOut                     $
        ,LEVEL_FORMAT='(F6.2)'                          $
        ,/WITH_INFO                                     $
        ,/NO_ROTATE

if ~keyword_set(no_title) then $
rad_fit_plot_dynfft_title, xmaps, ymaps, xmap, ymap, $
        charthick=charthick, charsize=charsize, $
        freq_band=0, beam=abeam, gate=agate, /with_info, bar=bar


; plot a title for all panels
rad_fit_plot_title, 'Dynamic FFT of', scan_id=scan_id

end
