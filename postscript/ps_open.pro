;+ 
; NAME: 
; PS_OPEN 
; 
; PURPOSE: 
; This procedure opens a PostScript file for plotting.
; 
; CATEGORY: 
; PostScript
; 
; CALLING SEQUENCE: 
; PS_OPEN, Filename
; 
; INPUTS: 
; Filename: The full filename (i.e. inlcuding path) of the PostScript
; file to open.
;
; If the path to the output file does not exist, this procedure will look whether the
; environment variable PS_PATH is set to a valid path. If yes, then the output
; file is placed there. If not, then the file is placed in ~/.
;
; If no filename is given, ~/piccy.ps is the default.
;
; KEYWORD PARAMETERS:
; COLOR: Set this keyword to indicate that the PostScript file supports colours.
;
; COLOR: Set this keyword to indicate that the PostScript file supports colors.
;
; BW: Set this keyword to indicate that the PostScript file supports only Black/White.
;
; SILENT: Set this keyword to surpress messages about the opened file.
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
; Written by: Lasse Clausen, 2007.
;-
pro ps_open, filename, color=color, bw=bw, silent=silent, no_init=no_init
	
IF N_PARAMS() EQ 0 THEN $
	filename = getenv('PS_OUTPUT_PATH')+'/piccy.ps'

if file_dirname(filename) eq '.' and ~strmatch(filename, './*') then $
		filename = getenv('PS_OUTPUT_PATH')+'/'+file_basename(filename)
odir = file_dirname(filename)

if ~file_test(odir, /dir) then begin
	if ~keyword_set(silent) then $
		prinfo, 'Output directory does not exist: '+file_dirname(filename), /force
	if ~file_test(getenv('PS_OUTPUT_PATH'), /dir) then $
		filename = '~/'+file_basename(filename) $
	else $
		filename = getenv('PS_OUTPUT_PATH')+'/'+file_basename(filename)
endif

SET_PLOT, 'ps'
if keyword_set(bw) then $
	DEVICE, FILENAME=filename, /HELVETICA, color=0, BITS=8 $
else $
	DEVICE, FILENAME=filename, /HELVETICA, /COLOR, BITS=8

!p.font = -1

ps_set_filename, filename
ps_set_isopen, !true

; set format of postscript file
fmt = get_format(landscape=ls)
if ls then $
	set_format, /landscape $
else $
	set_format, /portrait

; update colors, especially
; background and foreground
if ~keyword_set(no_init) then $
	init_colors

if ~keyword_set(silent) then $
	prinfo, 'Opened ', filename
	
END
