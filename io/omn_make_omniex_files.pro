;+
; NAME: 
; OMN_MAKE_OMNIEX_FILES
;
; PURPOSE: 
; This procedure reads dailly ONMI data files in HRO format and converts them
; into a omniex file which is used as input to the map potential routines. 
; The file contains the IMF in 
; year month day hour minute second bx by bz
; format.
; The map potential fitting routine (map_addimf in RST) can be instructed
; to read IMF data from a text file. OMNI data is already lagged so that
; we tell map_addimf that the lag of the IMF data is 0, like so
;  map_addimf -if omniexfile.asc -d 0:0 mapfile > mapfile
; The OMNI data should be obtained from
; ftp://nssdcftp.gsfc.nasa.gov/spacecraft_data/omni/high_res_omni/.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; OMN_MAKE_OMNIEX_FILES, Filename
;
; INPUTS:
; Filename: The name of the file containing the daily OMNI data in HRO format.
; Can contain standard wildcards like * and ?.
;
; KEYWORD PARAMETERS:
; OUTDIR: Set this keyword to the directory in which the daily files will be stored.
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
; Written by Lasse Clausen, 8 Jan, 2010
;-
pro omn_make_omniex_files, filename, outdir=outdir

;- The common format for the 1-min and 5-min OMNI data sets is
;- 
;- Year			        I4	      1995 ... 2006
;- Day			        I4	1 ... 365 or 366
;- Hour			        I3	0 ... 23
;- Minute			        I3	0 ... 59 at start of average
;- ID for IMF spacecraft	        I3	See  footnote D below
;- ID for SW Plasma spacecraft	I3	See  footnote D below
;- # of points in IMF averages	I4
;- # of points in Plasma averages	I4
;- Percent interp		        I4	See  footnote A above
;- Timeshift, sec		        I7
;- RMS, Timeshift		        I7
;- RMS, Phase front normal	        F6.2	See Footnotes E, F below
;- Time btwn observations, sec	I7	DBOT1, See  footnote C above
;- Field magnitude average, nT	F8.2
;- Bx, nT (GSE, GSM)		F8.2
;- By, nT (GSE)		        F8.2
;- Bz, nT (GSE)		        F8.2
;- By, nT (GSM)	                F8.2	Determined from post-shift GSE components
;- Bz, nT (GSM)	                F8.2	Determined from post-shift GSE components
;- RMS SD B scalar, nT	        F8.2	
;- RMS SD field vector, nT	        F8.2	See  footnote E below
;- Flow speed, km/s		F8.1
;- Vx Velocity, km/s, GSE	        F8.1
;- Vy Velocity, km/s, GSE	        F8.1
;- Vz Velocity, km/s, GSE	        F8.1
;- Proton Density, n/cc		F7.2
;- Temperature, K		        F9.0
;- Flow pressure, nPa		F6.2	See  footnote G below		
;- Electric field, mV/m		F7.2	See  footnote G below
;- Plasma beta		        F7.2	See  footnote G below
;- Alfven mach number		F6.1	See  footnote G below
;- X(s/c), GSE, Re		        F8.2
;- Y(s/c), GSE, Re		        F8.2
;- Z(s/c), GSE, Re		        F8.2
;- BSN location, Xgse, Re	        F8.2	BSN = bow shock nose
;- BSN location, Ygse, Re	        F8.2
;- BSN location, Zgse, Re 	        F8.2
;- 
;- AE-index, nT                    I6      See World Data Center for Geomagnetism, Kyoto
;- AL-index, nT                    I6      See World Data Center for Geomagnetism, Kyoto
;- AU-index, nT                    I6      See World Data Center for Geomagnetism, Kyoto
;- SYM/D index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- SYM/H index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- ASY/D index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- ASY/H index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- PC(N) index,                    F7.2    See World Data Center for Geomagnetism, Copenhagen

ifiles = file_search(filename, count=cc)
if cc lt 1 then begin
	prinfo, 'No files found: '+filename
	return
endif

fmt = '(2I4,2I3,18X,I7,28X,F8.2,16X,2F8.2)'
year = 0
doy  = 0
hr   = 0
mt   = 0
dt   = 0L
bx   = 0.0
by   = 0.0
bz   = 0.0
ilun = 0
olun_d = 0
olun_i = 0

if ~keyword_set(outdir) then $
	outdir = './'

; test if output dir exists and is writable
if ~file_test(outdir, /dir)then begin
	prinfo, 'OUTDIR does not exist: '+outdir
	return
endif

if ~file_test(outdir, /write)then begin
	prinfo, 'You do not have write permission in OUTDIR: '+outdir
	return
endif

; loop through all files
for i=0, cc-1 do begin

	stem_ofile = file_basename(ifiles[i], '.asc')
;	d_filename = outdir+'/'+stem_ofile+'ex_delay.asc'
	i_filename = outdir+'/'+stem_ofile+'ex_imf.asc'

	; open input file
	openr, ilun, ifiles[i], /get_lun
	; open output delay file
	; openw, olun_d, d_filename, /get_lun
	; open output imf file
	openw, olun_i, i_filename, /get_lun

	; map fitting does not do 
	; sanity checks on read delay times
	; hence be do not print out
	; delay time into the omniex files
	; if the omni data contains
	; 9999

	; loop through file, only reading the year and the
	; day number
	while ~eof(ilun) do begin

		; read data
		readf, ilun, year, doy, hr, mt, dt, bx, by, bz, $
			format=fmt
	
		if dt eq 999999L then $
			continue
	
		; calculate date of de-delayed imf measurements
		jul = julday(1, doy, year, hr, mt)
		caldat, jul, mn, dy, yr, hr, mt, sc
		;ijul = jul - double(dt)/86400.
		;caldat, ijul, imn, idy, iyr, ihr, imt, isc
		;dhr = dt/3600L
		;dmn = (dt - dhr*3600L)/60L
;		dsc = (dt mod 60L)
	
		; print the original time with the delay in one
		;printf, olun_d, $
		;	yr, mn, dy, hr, mt, sc, dhr, dmn, $
		;	format='(I4,5(" ",I02)," ",I2," ",I3)'
	
		; and the time with the IMF in the other file
		printf, olun_i, $
			yr, mn, dy, hr, mt, sc, bx, by, bz, $
			format='(I4,5(" ",I02),3(" ",F8.2))'
	
	endwhile

	; close input and last output file and exit
	;free_lun, olun_d
	free_lun, olun_i
	free_lun, ilun

	; we need to sort the times
	; in the IMF file because 
	; the times need to be in 
	; ascending order for the
	; fitting routines
	; let the shell do all the hard work
	; -n sorts by string numeric value
	; -t give the separator between fields
	;spawn, 'sort -n -t " " '+i_filename+' > '+i_filename+'.tmp'
	;file_move, i_filename+'.tmp', i_filename, /overwrite

endfor

end
