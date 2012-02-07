;+
; NAME: 
; OVERLAY_BS
;
; PURPOSE: 
; This procedure plots a model bow shock position on an orbit panel, 
; like those produces by ORB_PLOT_PANEL. The model used is described
; in Peredo et al., 1995.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; OVERLAY_BS
;
; KEYWORD PARAMETERS:
; BT: Set this keyword to the solar wind magnetic field strength used to parametrize
; the bow shock position.
;
; VT: Set this keyword to the solar wind absolute velocity used to parametrize
; the bow shock position.
;
; NP: Set this keyword to the solar wind number density used to parametrize
; the bow shock position.
;
; XY: Set this keyword to plot the bow shock in the XY plane.
;
; XZ: Set this keyword to plot the bow shock in the XZ plane.
;
; YZ: Set this keyword to plot the bow shock in the YZ plane.
;
; LINECOLOR: Set this keyword to set the line color used to plot the bow shock.
;
; LINESTYLE: Set this keyword to set the line style used to plot the bow shock.
;
; LINETHICK: Set this keyword to set the line thickness used to plot the bow shock.
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
; Written by Lasse Clausen, Dec, 4 2009
;-
pro overlay_bs, bt=bt, vt=vt, np=np, $
	xy=xy, xz=xz, yz=yz, $
	linecolor=linecolor, linestyle=linestyle, linethick=linethick

if ~keyword_set(xy) and ~keyword_set(yz) and ~keyword_set(xz) then begin
	if ~keyword_set(silent) then $
		prinfo, 'XY, XZ and YZ not set, using XZ.'
	xz = 1
endif

if n_elements(linecolor) eq 0 then $
	linecolor = get_foreground()

if n_elements(linestyle) eq 0 then $
	linestyle = 2

if n_elements(linethick) eq 0 then $
	linethick = 1

if n_elements(bt) eq 0 then $
	bt = 2.

if n_elements(vt) eq 0 then $
	vt = 400.

if n_elements(np) eq 0 then $
	np = 2.

;function shock_nose,Y_gse,Btot,Np,Vsw
; calculate the radius (rho) of the bow shock:  rho2 = Y^2+Z^2
;
; Input Parameters:  X_gse = x pos on shock [Re]
;                     Btot = upstream IMF magnitude [nT]
;                       Np = upstream proton number density [cm^-3]
;                      Vsw = upstream solar wind speed [km/s]
;
; Model:  Peredo et al., JGR, 1995
;
; We have simplified the model to assume axial symmetry based on X-Y plane, 
; i.e. rho = y_gse (at least for now).

ma = 0.01*sqrt(vt^2*4.*!pi*1.67*np/bt^2)
a1  = [0.0189,0.02372,-0.0774,0.03537]
a3  = [0.808,0.847295,0.88375,1.076124]
a4  = [-0.2672,-0.01525,-0.0032,0.1384]
a7  = [63.045963,51.360733,45.653996,49.363392]
a8  = [-0.080003,-1.607507,0.019997,0.323747]
a10 = [-885.576782,-678.071411,-691.855774,-772.589233]
if ma lt 5 then i = 0
if ma ge 5 and ma lt 8 then i = 1
if ma ge 8 and ma lt 13 then i = 2
if ma ge 13 then i = 3
coeffs = [a1[i],a3[i],a4[i],a7[i],a8[i],a10[i]]


; Now plot the bow shock (Peredo et al). Frist the xy and xz frames. 	
if keyword_set(xy) or keyword_set(xz) then begin
	aa = coeffs[0]
	bb = coeffs[3]
	cc = coeffs[5]
	val = bb*bb - 4.*aa*cc
	if val lt 0 then $
		sn = -9999.0 $
	else $
		sn = (-1.0*bb+sqrt(val))/(2.*aa)
	xbspos = sn - findgen(400)/8.
	ybspos = xbspos
	aa = replicate(1.0, 400)
  bb = coeffs[2]*xbspos + coeffs[4]
  cc = coeffs[0]*xbspos^2 + coeffs[3]*xbspos + coeffs[5]
  val = bb*bb - 4.*aa*cc
	inds = where(val ge 0., cc, complement=ninds, ncomplement=nc)
	if cc gt 0L then $
		ybspos[inds] = ((-bb[inds]+sqrt(val[inds]))/(2.*aa[inds]) > (-bb[inds]-sqrt(val[inds]))/(2.*aa[inds])) > 0.
	if nc gt 0L then $
		ybspos[ninds] = 0.
	xbspos = [reverse(xbspos), xbspos]
	ybspos = [-reverse(ybspos), ybspos]
endif

; Now for the yz frame	
if keyword_set(yz) then begin
	aa = 1.0
  bb = coeffs[4]
  cc = coeffs[5]
  val = bb*bb - 4.*aa*cc
	if val lt 0. then $
		rad = 0. $
	else $
		rad = ((-bb+sqrt(val))/(2.*aa) > (-bb-sqrt(val))/(2.*aa)) > 0.
	phi = 2.*!pi*findgen(360)
	xbspos = rad*cos(phi)
	ybspos = rad*sin(phi)
endif
	
; Plot the output		
oplot, xbspos, ybspos, $
	color=linecolor, linestyle=linestyle, thick=linethick, $
	noclip=0

; put a little legend on the plot to indicate input parameters
xpos = !x.crange[1] + .03*(!x.crange[1]-!x.crange[0])
ypos = !y.crange[0]
xyouts, xpos, ypos, orientation=90., $
	textoidl('B_t='+string(bt, format='(F03.1)')+'nT, V_t='+string(vt, format='(I4)')+'km/s, n_p='+string(np, format='(F03.1)')+'cm^{-3}') + $
	' Peredo et al., 1995', $
	/data, charsize=.5

end
