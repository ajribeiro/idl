;+ 
; NAME: 
; RT_WRITE_INPUT
;
; PURPOSE: 
; This procedure generates input file for raytracing code
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_WRITE_INPUT
;
; INPUTS:
; RADAR: the radar code for which you want to run the raytracing
;
; KEYWORD PARAMETERS:
;
; COMMON BLOCKS:
; RADARINFO
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
; Written by Sebastien de Larquier, Sept. 2010
;	Last modified 17-09-2010
;-
PRO	rt_write_input, lat, lon, azim, date, hour, freq=freq, elev=elev, nhop=nhop, $
		outdir=outdir, filename=filename, silent=silent

common radarinfo

parse_date, date, year, month, day

if ~keyword_set(outdir) then $
  outdir = '/tmp/'

if ~file_test(outdir, /dir) then begin
  prinfo, 'Output directory does not exist: '+outdir
  return
endif

if ~keyword_set(filename) then $
  filename = 'Input_RT.inp'

davit_lib = getenv("DAVIT_LIB")
; davit_lib = ''
; Read base input file
openr, unit, davit_lib+'/vt/fort/rtmpi/Inputs_tpl.inp', /get_lun

; Skip first 2 lines
bla = ''
readf, unit, bla, format='(A)'
readf, unit, bla, format='(A)'

; Then go on until end of file
fmt 	= '(I3,F17.2)'
tdata 	= {ID:0S, VAL:0.0}
data 	= REPLICATE(tdata,20)
j = 0
status = FSTAT(unit)
POINT_LUN, -unit, pos 
WHILE (~EOF(unit) AND pos lt status.size - 2) DO BEGIN
	readf, unit, tdata, format=fmt
	data[j] = tdata
	j++
	POINT_LUN, -unit, pos 
ENDWHILE

free_lun, unit

; Set new radar position
data[where(data.ID eq 1)].VAL = lat
data[where(data.ID eq 2)].VAL = lon
data[where(data.ID eq 3)].VAL = azim[0]
data[where(data.ID eq 4)].VAL = azim[1]
data[where(data.ID eq 5)].VAL = azim[2]

; Set elevation limits
if ~keyword_set(elev) then $
	elev = [5., 55., .1]
data[where(data.ID eq 6)].VAL = elev[0]
data[where(data.ID eq 7)].VAL = elev[1]
data[where(data.ID eq 8)].VAL = elev[2]

; Set frequency
if ~keyword_set(freq) then $
	freq = 11.
data[where(data.ID eq 9)].VAL = freq

; Set number of hops
if ~keyword_set(nhop) then $
	nhop = 1
data[where(data.ID eq 10)].VAL = nhop

; Set date and time
data[where(data.ID eq 11)].VAL = year
data[where(data.ID eq 12)].VAL = month*100L + day
data[where(data.ID eq 13)].VAL = hour[0]
data[where(data.ID eq 14)].VAL = hour[1]
data[where(data.ID eq 15)].VAL = hour[2]
  
; Write input file
openw, unit, outdir+filename, /get_lun

; Skip first 2 lines
printf, unit, bla
printf, unit, bla
; Write input to file
FOR i=0,j-1 DO BEGIN
	tdata = data[i]
	if tdata.ID eq 10 or $
		 tdata.ID eq 11 or $
		 tdata.ID eq 12 then $
				ifmt = '(I3,I17)' $
	else $
		ifmt = fmt
	printf, unit, tdata, format=ifmt
ENDFOR

free_lun, unit

END