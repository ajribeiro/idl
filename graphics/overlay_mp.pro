;+
; NAME: 
; OVERLAY_MP
;
; PURPOSE: 
; This procedure plots a model magnetopause position on an orbit panel, 
; like those produces by ORB_PLOT_PANEL. The model used is described
; in Shue et al., 1997.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; OVERLAY_MP
;
; KEYWORD PARAMETERS:
; BZ: Set this keyword to the solar wind magnetic field bz component used to parametrize
; the bow shock position.
;
; PDYN: Set this keyword to the solar wind dynamic pressure used to parametrize
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
pro overlay_mp, bz=bz, pdyn=pdyn, $
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
	linestyle = 0

if n_elements(linethick) eq 0 then $
	linethick = 1

if n_elements(bz) eq 0 then $
	bz = 0.

if n_elements(pdyn) eq 0 then $
	pdyn = 2.

;F REFERENCES:	"A new functional form to study the solar wind control of the 
;F		magnetopause size and shape", Shue et al., JGR, 102, 1997, p9497.		
;F
;F INPUTS:	theta:	angle between Sun-Earth direction and r 
;F			(r = radial distance to magnetopause at theta)
;F		bz: 	the z-component of the IMF (nT)
;F		p:	solar wind dynamic pressure (nPa)

;function tail_flaring,bz,p
alpha = (0.58-0.010*bz)*(1.+0.010*pdyn)
;end

;function mp_nose,bz,p
if bz ge 0. then begin
	r0 = (11.4+0.013*bz)*(pdyn)^(-1.0/6.6)
endif else begin
	r0 = (11.4+0.14*bz)*(pdyn)^(-1.0/6.6)
endelse
;end

; Now do the  magnetopause. Frist the xy and xz frames. In the Shue et al 
; model the magnetosphere is cylindrically symmetric about the x axis	
if keyword_set(xy) or keyword_set(xz) then begin
	theta = (findgen(351) - 175.)*!dtor
	rad = r0*(2./(1.+cos(theta)))^(alpha)
	xmppos = rad*cos(theta)
	ymppos = rad*sin(theta)
endif
; Now for the yz frame	
if keyword_set(yz) then begin
	theta = !pi/2.
	phi = 2.*!pi*findgen(361)/360.
	rad = r0*(2./(1.+cos(theta)))^(alpha)
	xmppos = rad*cos(phi)
	ymppos = rad*sin(phi)
endif

; Plot the output		
oplot, xmppos, ymppos, $
	color=linecolor, linestyle=linestyle, thick=linethick, $
	noclip=0

; put a little legend on the plot to indicate input parameters
xpos = !x.crange[1] + .06*(!x.crange[1]-!x.crange[0])
ypos = !y.crange[0]
xyouts, xpos, ypos, orientation=90., $
	textoidl('B_z='+string(bz, format='(F03.1)')+'nT, pdyn='+string(pdyn, format='(F03.1)')+'nPa') + $
	' Shue et al., 1997', $
	/data, charsize=.5

end
