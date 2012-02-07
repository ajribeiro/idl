;+ 
; NAME: 
; THE_ORB_PLOT
;
; PURPOSE: 
; The procedure plots an overview page of Themis orbit data with a title.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; THE_ORB_PLOT
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
; PROBE: Set this to the probe for which you wish to plot the orbit,
; can be an array.
;
; XRANGE: The xrange of the orbit panel.
;
; YRANGE: The yrange of the orbit panel.
;
; XY: Set this keyword to plot the orbit projected onto the XY plane.
;
; XZ: Set this keyword to plot the orbit projected onto the XZ plane.
;
; YZ: Set this keyword to plot the orbit projected onto the YZ plane.
;
; COORDS: Set this keyword to the coordinate system to use, either "GSE" or "GSM".
;
; BOWSHOCK: Set this keyword to plot a model representation of the bowshock.
;
; MAGNETOPAUSE: Set this keyword to plot a model representation of the magnetopause.
;
; SILENT: Set this keyword to surpress messages.
;
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
;
; MARK_INTERVAL: The time step between time markers along the orbit, 
; in (decimal) hours. To set it to 2 minutes, set MARK_INTERVAL to 2./60.
;
; MARK_CHARSIZE: The charsize used for the orbit markers.
;
; MARK_CHARTHICK: The charthick used for the orbit markers.
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
; Written by Lasse Clausen, Apr, 4 2010
;-
pro the_orb_plot, date=date, time=time, long=long, $
	probe=probe, xrange=xrange, yrange=yrange, bar=bar, $
	xy=xy, xz=xz, yz=yz, coords=coords, $
	bowshock=bowshock, magnetopause=magnetopause, $
	silent=silent, mark_interval=mark_interval, $
	mark_charsize=mark_charsize, mark_charthick=mark_charthick

if ~keyword_set(probe) then $
	probe = ['a','b','c','d','e']

clear_page

the_orb_plot_panel, 1, 1, 0, 0, date=date, time=time, long=long, $
	probe=probe, xrange=xrange, yrange=yrange, bar=bar, $
	xy=xy, xz=xz, yz=yz, coords=coords, $
	silent=silent, mark_interval=mark_interval, $
	mark_charsize=mark_charsize, mark_charthick=mark_charthick, /last, /first

if keyword_set(bowshock) then $
	overlay_bs, xy=xy, xz=xz, yz=yz

if keyword_set(magnetopause) then $
	overlay_mp, xy=xy, xz=xz, yz=yz

sfjul, date, time, sjul, fjul

plot_title, 'Themis Orbit', '', top_right_title=format_juldate(sjul)+'!C'+format_juldate(fjul)

end
