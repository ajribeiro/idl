;+ 
; NAME: 
; GET_COLOR_INDEX
; 
; PURPOSE: 
; This function calculates the color index for a given data value.
; The color index depends on the index of the first color to use
; (BOTTOM), the number of colors in the color table (NCOLORS) and the
; number of color steps (COLORSTEPS). It also depends on the SCALE and
; the SCALE_VALUES. 
; Depending on the parameter to which the data values belong, the color indeces
; are shifted or rotated.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; Result = GET_COLOR_INDEX(Values)
;
; INPUTS:
; Values: A scalar or array of numeric values for which to find the
; correct color index.
;
; OUTPUTS:
; This function returns the color index to use if the value is plotted.
;
; KEYWORD PARAMETERS:
; PARAM: Set this keyword to a string containing the parameter name of the
; data values. This keyword is important when calculating color indeces for
; velocity values as the indeces are rotated or shifted. Default is taken
; from GET_PARAMETER().
;
; COLORSTEPS: The number of steps in the color table. Default is taken from
; GET_COLORSTEPS().
;
; NCOLORS: The number of usable colors in the color table. Default is taken
; from GET_NCOLORS().
;
; BOTTOM: The first color index of the color table to use. Default is taken
; from GET_BOTTOM().
;
; SCALE: A 2-element value giving the minimum and maximum value
; to which to scale the data value. Default is taken from GET_SCALE(). If you
; set this keyword, the global SCALE_VALUES will be overwritten.
;
; SCALE_VALUES: The values in the color scale. Usually, the values are scaled
; linearly between MINVAL and MAXVAL
;  SCALE_VALUES = SCALE[0] + FINDGEN(COLORSTEPS) * ( SCALE[1] - SCALE[0] ) / COLORSTEPS
; However, by setting this keyword to a numeric array of values, you can force
; non-linear scaling. The number of elements of SCALE_VALUES must be the same as
; COLORSTEPS+1. If you set this keyword, SCALE will be reset by the first and last value
; of SCALE_VALUES.
;
; ROTATE: The color table loaded in IDL is NEVER changed by DaViT. However, when plotting
; velocities, it is usually desired that the order of the colors is changed. Set this keyword
; to rotate the color values, i.e. the colors at low indeces are used for high data values
; and the colors at high indeces are used for low data values. This option
; is the default for color tables LEICESTER, BLUEWHITERED and DEFAULT.
;
; SHIFT: The color table loaded in IDL is NEVER changed by DaViT. However, when plotting
; velocities, it is usually desired that the order of the colors is changed. Set this keyword
; to shift the color values, i.e. the color indeces previously associated with low and high
; data values are now associated with values close to the middle of the value scale. This option
; is the default for color tables AJ, BW and WHITERED.
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
;-
function get_color_index, values, param=param, $
	scale=scale, sc_values=sc_values, $
	colorsteps=colorsteps, ncolors=ncolors, bottom=bottom, $
	rotate=rotate, shift=shift, nonlinear=nonlinear

; we need to see what color table is loaded
ct = get_colortable()
rot = 0
shi = 0
if strcmp(ct, 'bluewhitered', /fold) or strcmp(ct, 'leicester', /fold) or strcmp(ct, 'default', /fold) then $
	rot = 1
if strcmp(ct, 'aj', /fold) or strcmp(ct, 'bw', /fold) or strcmp(ct, 'whitered', /fold) then $
	shi = 1

if ~keyword_set(param) then $
	param = get_parameter()

if n_elements(rotate) ne 0 then $
	_rotate = rotate $
else begin
	if strcmp(param, 'velocity', /fold_case) then $
		_rotate = rot
endelse

if n_elements(shift) ne 0 then $
	_shift = shift $
else begin
	if strcmp(param, 'velocity', /fold_case) then $
		_shift = shi
endelse

if ~keyword_set(colorsteps) then $
	_colorsteps = get_colorsteps() $
else $
	_colorsteps = colorsteps

if ~keyword_set(ncolors) then $
	ncolors = get_ncolors()

if n_elements(bottom) eq 0 then $
	bottom = get_bottom()

if ~keyword_set(scale) then $
	_scale = get_default_range(param) $
else $
	_scale = scale

if ~keyword_set(sc_values) then $
	sc_values = scale[0] + FINDGEN(_colorsteps+1)*(_scale[1] - _scale[0])/float(_colorsteps) $
else begin
	if keyword_set(colorsteps) then begin
		if colorsteps ne n_elements(sc_values)-1 then $
			prinfo, 'Number of values in SC_VALUES is not equal to COLOSTEPS, adjusting.'
	endif
	_colorsteps = n_elements(sc_values)-1
	_scale = [min(sc_values), max(sc_values)]
endelse

; these are the indeces in the color table that are
; available for plotting
cin = FIX( FINDGEN(_colorsteps)/(_colorsteps-1.)*(ncolors-1) )+bottom

; shift or rotate the color indeces
if keyword_set(_rotate) then $
	cin = rotate(cin, 2)
if keyword_set(_shift) then $
	cin = shift(cin, _colorsteps/2)

; get color index within cin
_values = (values > _scale[0]) < _scale[1]
ret = bytarr(n_elements(values))
for i=0, _colorsteps-1 do begin
	tmp = where( _values ge sc_values[i] and _values lt sc_values[i+1], ng )
	if ng gt 0 then $
		ret[tmp] = cin[i]
endfor
tmp = where( _values eq sc_values[i], ng )
if ng gt 0 then $
	ret[tmp] = cin[i-1]

if n_elements(ret) eq 1 then $
	ret = ret[0]

return, ret

end