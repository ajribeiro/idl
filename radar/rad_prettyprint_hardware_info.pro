;+
; NAME: 
; RAD_PRETTYPRINT_HARDWARE_INFO
;
; PURPOSE: 
; This function reads a hdw.dat file and pretty prints the contents.
; 
; CATEGORY: 
; Radar
; 
; CALLING SEQUENCE:
; RAD_PRETTYPRINT_HARDWARE_INFO, Filename
;
; INPUTS:
; Filename: The name of the hardware file to beautify.
;
; KEYWORD PARAMETERS:
; OUTDIR: Set this keyword to a directory into which to write the beautified file.
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
; Written by Lasse Clausen, Dec, 11 2009
;-
pro rad_prettyprint_hardware_info, filename, outdir=outdir

common radarinfo

if ~file_test(filename) then begin
	prinfo, 'Cannot find file: '+filename
	return
endif

if ~file_test(filename, /read) then begin
	prinfo, 'Cannot open file: '+filename
	return
endif

if ~keyword_set(outdir) then $
	outdir = file_dirname(filename)

if ~file_test(outdir, /dir) then begin
	prinfo, 'Output directory does not exist: '+outdir
	return
endif

; open input file
openr, ilun, filename, /get_lun, error=error
if error ne 0 then begin
	prinfo, 'Cannot open input file: '+!error_state.msg
	free_lun, opplun
	return
endif

; choose a Windows newline in order to make the file
; readable even in crappy Notepad
nwl = string(13b)+string(10b)

; string in the first line
first_line = ''

info_text = $
	'#' + nwl + $
	'# Each radar has a distinct set of hardware parameters that are used' + nwl + $
	'# by the radar control software and the analysis software. These' + nwl + $
	'# parameters are read in a distinct order and are assumed to have' + nwl + $
	'# specific units. If either the order of the parameters or their units' + nwl + $
	'# are incorrect, the processing and analysis software will produce' + nwl + $
	'# incorrect answers that may not be easily identified. It is the' + nwl + $
	'# responsibility of the SuperDARN P.I.s to insure that the hdw.dat files' + nwl + $
	'# for their radars are correct and that these files are updated as' + nwl + $
	'# required to accurately represent the physical state of the radar and' + nwl + $
	'# that copies of these files are retained under revision control by Rob' + nwl + $
	'# Barnes. Revision controlled versions of hdw.dat files are destributed' + nwl + $
	'# with SuperDARN radar control software and with analysis software.' + nwl + $
	'#' + nwl + $
	'# The hardware parameters are distributed as a string of values' + nwl + $
	'# delineated by one or more spaces. The following table specifies the' + nwl + $
	'# parameters, their units, and a brief description of their meaning.' + nwl + $
	'#' + nwl + $
	'# 01) Station ID (unique numerical value). Assigned by Rob Barnes.' + nwl + $
	'# 02) Last year that parameter string is valid. (4 digit year).' + nwl + $
	'# 03) Last second of year that parameter string is valid (range 0 to' + nwl + $
	'#     34163999 for non-leap years). The parameter string giving the current' + nwl + $
	'#     configuration is assumed to be valid until the last second of 2999.' + nwl + $
	'# 04) Geographic latitude of radar site (Given in decimal degrees to 3' + nwl + $
	'#     decimal places. Southern hemisphere values are negative)' + nwl + $
	'# 05) Geographic longitude of radar site (Given in decimal degrees to' + nwl + $
	'#     3 decimal places. West longitude values are negative)' + nwl + $
	'# 06) Altitude of the radar site (meters)' + nwl + $
	'# 07) Scanning boresight (Direction of the center beam, measured in' + nwl + $
	'#     degrees relative to geographic north. CCW rotations are negative.)' + nwl + $
	'# 08) Beam separation (Angular separation in degrees between adjacent' + nwl + $
	'#     beams. Normally 3.24 degrees)' + nwl + $
	'# 09) Velocity sign (At the radar level, backscattered signals with' + nwl + $
	'#     frequencies above the transmitted frequency are assigned positive' + nwl + $
	'#     Doppler velocities while backscattered signals with frequencies below' + nwl + $
	'#     the transmitted frequency are assigned negative Doppler velocity. This' + nwl + $
	'#     convention can be reversed by changes in receiver design or in the' + nwl + $
	'#     data samping rate. This parameter is set to +1 or -1 to maintain the' + nwl + $
	'#     convention.)' + nwl + $
	'#' + nwl + $
	'# Some SuperDARN radars have analog receivers whereas others have' + nwl + $
	'# analog front-end receivers followed by digital receivers. Analog' + nwl + $
	'# receivers and analog front-ends can have gain and bandwidth controls' + nwl + $
	'# that are identified here and corrected in the radar control software.' + nwl + $
	'# Digital receiver information is retained and compensated for within' + nwl + $
	'# the digital receiver driver.' + nwl + $
	'#' + nwl + $
	'# 10) Analog Rx attenuator step (dB)' + nwl + $
	'#' + nwl + $
	'# In order to obtain information on the vertical angle of arrival of' + nwl + $
	'# the backscattered signals, the SuperDARN radars include a four antenna' + nwl + $
	'# interferometer array in addition to the 16 antenna main array. This' + nwl + $
	'# second array is typically displaced from the main array along the' + nwl + $
	'# array normal direction and the different path length due to the' + nwl + $
	'# displacement and the different cable lengths between the antenna' + nwl + $
	'# arrays and their phasing matrices introduces a phase shift that is' + nwl + $
	'# dependent on the elevation angle of the returning backscattered' + nwl + $
	'# signal.' + nwl + $
	'#' + nwl + $
	'# 11) Tdiff (Propagation time from interferometer array antenna to' + nwl + $
	'#     phasing matrix input minus propagation time from main array antenna' + nwl + $
	'#     through transmitter to phasing matrix input. Units are decimal' + nwl + $
	'#     microseconds)' + nwl + $
	'# 12) Phase sign (Cabling errors can lead to a 180 degree shift of the' + nwl + $
	'#     interferometry phase measurement. +1 indicates that the sign is' + nwl + $
	'#     correct, -1 indicates that it must be flipped.)' + nwl + $
	'# 13) Interferometer offset  (Displacement of midpoint of' + nwl + $
	'#     interferometer array from midpoint of main array. This is given in' + nwl + $
	'#     meters in Cartesian coordinates. X is along the line of antennas with' + nwl + $
	'#     +X toward higher antenna numbers, Y is along the array normal' + nwl + $
	'#     direction with +Y in the direction of the array normal. Z is the' + nwl + $
	'#     altitude difference, +Z up.)' + nwl + $
	'#' + nwl + $
	'# More analog receiver information' + nwl + $
	'#' + nwl + $
	'# 14) Analog Rx rise time (Time given in microseconds. Time delays of' + nwl + $
	'#     less than ~10 microseconds can be ignored. If narrow-band filters are' + nwl + $
	'#     used in analog receivers or front-ends, the time delays should be' + nwl + $
	'#     specified.)' + nwl + $
	'# 15) Analog attenuation stages (Number of stages. This is used for' + nwl + $
	'#     gain control of an analog receiver or front-end.)' + nwl + $
	'# 16) Maxinum of range gates used (Number of gates. This is used for' + nwl + $
	'#     allocation of array storage.)' + nwl + $
	'# 17) Maximum number of beams to be used at a particular radar site.' + nwl + $
	'#     (Number of beams. It is important to specify the true  maximum. This' + nwl + $
	'#     will assure that a given beam number always points in the same' + nwl + $
	'#     direction. A subset of these beams, e.g. 8-23, can be used for' + nwl + $
	'#     standard 16 beam operation.)' + nwl + $
	'#' + nwl

notes_hdr = $
	'# **********************************************************************' + nwl + $
	'# ==Notes==' + nwl + $
	'#' + nwl

notes_ftr = $
	'#' + nwl + $
	'# **********************************************************************' + nwl

header_text = $
	'#' + nwl + $
	'#  1   2      3        4         5       6      7      8    9   10   11   12  13(1)  13(2)  13(3)  14   15  16 17' + nwl

; string holding notes
notes = ''

; string for actual parameter entries
hdw_entries = ''

; we'll assemble the entire contents of the
; pretty hdw.dat in this string first and then
; print that out with a single PRINTF command
; that way we get around newline issues.
ostr = ''

line = ''
st_id = 0
year = 0
yrsec = 0L
glat = 0.0
glon = 0.0
alt = 0.0
boresite = 0.
bmsep = 0.
vdir = 0.
atten = 0.
tdiff = 0.
phidiff = 0.
i_xpos = 0.
i_ypos = 0.
i_zpos = 0.
rec_rise = 0.0
maxatten = 0
ngates = 0
nbeams = 0
firstentry = !true
while ~eof(ilun) do begin
	readf, ilun, line
	; get rid of leading and trailing whitespaces
	line = strtrim(line, 2)
	; ignare empty lines
	if strlen(line) lt 2 then $
		continue
	; check if current line is a comment
	if strmid(line, 0, 1) eq '#' then begin
		; stuff between the line 
		;==Notes==
		; and 
		; **************
		; should survive the pretty printing, hence read everything 
		; between those to line and add it to the notes variable
		if strpos(line, '==Notes==') ne -1 then begin
			while !true do begin
				readf, ilun, line
				if strpos(line, '**************') gt -1 then begin
					break
				endif
				if strlen(line) gt 3 then begin
					notes += line + nwl
				endif
			endwhile
		endif else $
			; throw all other comments away
			continue
	; if the current line contains an entry, parse it and make it pretty
	endif else begin
		reads, line, st_id, year, yrsec, glat, glon, alt, boresite, bmsep, vdir, atten, $
			tdiff, phidiff, i_xpos, i_ypos, i_zpos, rec_rise, maxatten, ngates, nbeams
		rad = radarGetRadar(network, st_id)
		if size(rad, /type) ne 8 then begin
			prinfo, 'Station ID not found in network structure: '+string(st_id, format='(I3)')
			free_lun, ilun
			free_lun, opplun
			return
		endif
		sradnme = rad.name
		if firstentry then begin
			first_line = '#  Hardware parameters for '+sradnme+' radar.' + nwl
			firstentry = !false
		endif
		sradid  = string(st_id, format='(I3)')
		syear   = string(year, format='(I4)')
		syrsc   = string(yrsec, format='(I8)')
		hdw_entries += '#' + nwl
		hdw_entries += '# UNTIL '+format_juldate(julday(1, 1, year, 0, 0, yrsec)) + nwl
		sglat   = string(glat, format='(F8.3)')
		sglon   = string(glon, format='(F8.3)')
		salt    = string(alt, format='(F7.1)')
		sbores  = string(boresite, format='(F6.1)')
		sbmsep  = string(bmsep, format='(F5.2)')
		svdir   = string(vdir, format='(I2)')
		satten  = string(atten, format='(I4)')
		stdiff  = string(tdiff, format='(F6.3)')
		spdiff  = string(phidiff, format='(I2)')
		sixpos  = string(i_xpos, format='(F6.1)')
		siypos  = string(i_ypos, format='(F6.1)')
		sizpos  = string(i_zpos, format='(F6.1)')
		srecrs  = string(rec_rise, format='(F5.1)')
		smaxa   = string(maxatten, format='(I2)')
		sngates = string(ngates, format='(I3)')
		snbeams = string(nbeams, format='(I2)')
;    1    2      3        4         5       6      7      8    9   10   11   12  13(1)  13(2)  13(3)  14   15  16 17
;  204  2010 15346800 0038.859  0-99.389 00675.1 0-25.0 03.24 01 0010 00.000 01 0000.0 0-80.0 0000.0 000.0 01 110 16
		hdw_entries += '  '+sradid+' '+syear+' '+syrsc+' '+sglat+' '+sglon+' '+salt+$
			' '+sbores+' '+sbmsep+' '+svdir+' '+satten+' '+stdiff+' '+$
			spdiff+' '+sixpos+' '+siypos+' '+sizpos+' '+srecrs+' '+smaxa+' '+$
			sngates+' '+snbeams + nwl
	endelse
endwhile
free_lun, ilun

; open output hdw file
oppfilename = outdir+'/'+file_basename(filename)+'.p'
openw, opplun, oppfilename, /get_lun, error=error
if error ne 0 then begin
	prinfo, 'Cannot open PP output file: '+!error_state.msg
	return
endif
printf, opplun, first_line+info_text+notes_hdr+notes+notes_ftr+header_text+hdw_entries+'# EOF'
free_lun, opplun

file_move, oppfilename, outdir+'/'+file_basename(oppfilename, '.p'), /overwrite

end
