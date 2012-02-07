;+ 
; NAME: 
; RAD_FIT_PLOT_DYNFFT_TITLE
; 
; PURPOSE: 
; This procedure plots a more specific title on the top of a DYNFFT panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_DYNFFT_TITLE
;
; OPTIONAL INPUTS:
; Xmaps: The total number of columns of plots on the resulting page.
; Default is 1.
;
; Ymaps: The total number of rows of plots on the resulting page.
; Default is 1.
;
; Xmap: The current horizontal (column) index of this panel.
; Default is 0.
;
; Ymap: The current vertical (row) index of this panel.
; Default is 0.
;
; KEYWORD PARAMETERS:
; BEAM: Set this keyword to the beam number.
;
; GATE: Set this keyword to the gate number.
;
; PARAM_INFO: Set this keyword to print the radar name and parameter info on the left-hand side.
;
; PARAMETER: Set this keyword to the desired radar parameter.  If not set, the value from GET_PARAMETER() will be used.
; 
; BAR: Set this keyword to indicate that the panel areas are calculated by taking
; into account space for a color bar.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size.
;
; NO_GATE: Set this keyword to supress the printing of the range gate.
;
; NO_BEAM: Set this keyword to supress the printing of the beam number.
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
; Written by Lasse Clausen, Nov, 30 2009; Nathaniel A. Frissell, 2011
;-
pro rad_fit_plot_dynfft_title, xmaps, ymaps, xmap, ymap, $
	beam=beam, gate=gate, param_info=param_info, PARAMETER=param, bar=bar, with_info=with_info, $
	charsize=charsize, charthick=charthick, NO_BEAM=no_beam, NO_GATE=no_gate

COMMON rad_data_blk

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if n_elements(beam) eq 0 then $
	beam = rad_get_beam()

if n_elements(gate) eq 0 then $
	gate = rad_get_gate()

foreground  = get_foreground()

pos = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info)

fmt = get_format(sardines=sd)
;if sd then $
;	ypos = pos[3]-.02 $
;else $
;	ypos = pos[3]-.03
	ypos = pos[3]+0.02
;xpos = pos[0]+0.01
xpos = pos[0]+0.11
xpos = 0.8*pos[2]
xpos = pos[2] - 0.01

gatebeam$ = ''
IF ~KEYWORD_SET(no_beam) THEN gateBeam$ = gateBeam$ +   $
	'Beam '+string(beam, format='(I02)')
        
IF ~KEYWORD_SET(no_beam) AND ~KEYWORD_SET(no_gate) THEN gateBeam$ = gateBeam$ + ', '

IF ~KEYWORD_SET(no_gate) THEN gateBeam$ = gateBeam$ +   $
	'Gate '+strjoin(string(gate, format='(I03)'),'-')

XYOUTS, xpos, ypos, gateBeam$           $
    ,COLOR      = foreground            $
    ,SIZE       = 0.75*charsize         $
    ,CHARTHICK  = charThick             $
    ,/NORMAL                            $
    ,/ALIGN

IF KEYWORD_SET(param_info) THEN BEGIN
    data_index = RAD_FIT_GET_DATA_INDEX()
    IF ~KEYWORD_SET(param) THEN param = GET_PARAMETER()
    fitstr = 'N/A'
    if (*rad_fit_info[data_index]).fitex then $
            fitstr = 'fitEX'

    if (*rad_fit_info[data_index]).fitacf then $
            fitstr = 'fitACF'

    if (*rad_fit_info[data_index]).fit then $
            fitstr = 'fit'

    if (*rad_fit_info[data_index]).filtered then $
            filterstr = 'filtered ' $
    else $
            filterstr = ''
    rdrName$ = (*rad_fit_info[data_index]).name+': '+param+' ('+filterstr+fitstr+')'
    xyouts, pos[0]+0.01, ypos, rdrName$, $
		/NORMAL, COLOR=foreground, SIZE=0.75*charsize, charthick=charthick, align=0.
endif
end
