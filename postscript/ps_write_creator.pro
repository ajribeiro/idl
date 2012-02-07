;+ 
; NAME: 
; PS_WRITE_CREATOR
; 
; PURPOSE: 
; This procedure writes a small comment into the header of a PostScript file.
; This enables the user to identify the program name that created that
; particular PostScript.
;
; It will also add the PostScript comment %%Orientation, because IDL does not 
; routinely add it.
;
; Basically, the contents of the call stack
; is written into the file. That works because PostScript files are
; ASCII files.
;
; This routine writes the comment by reading the original PostScript file
; line by line, adding the comment at the right place. This can take long
; (a couple of seconds) if your PostScript file is several MB big.
;
; The comment might look like this:
; %CreatorScript: At PS_WRITE_CREATOR   36 /home/lbnc1/idl_lib/graphics/ps_write_creator.pro
; %CreatorScript: PS_CLOSE2           3 /home/lbnc1/idl_lib/graphics/ps_close2.pro
; %CreatorScript: PLOT_ACE2         340 /home/lbnc1/idl_lib/graphics/plot_ace2.pro
; %CreatorScript: $MAIN$             11 /home/lbnc1/idl/tim.pro
;
; The above comment tells me that the comment (and hence the plot) was 
; created by PLOT_ACE2 which was called by $MAIN$, located in tim.pro.
; 
; CATEGORY: 
; PostScript
; 
; CALLING SEQUENCE: 
; PS_WRITE_CREATOR, Filename
;
; INPUTS:
; Filename: The full filename (including path) of the PostScript file into
; which the header will be inserted.
;
; KEYWORD PARAMETERS:
; FORCE_PAPER_SIZE: Set this keyword to Letter or A4 depending on what paper size
; you want to force. Use this carefully! If DocumentPaperSizes is set to A4 and 
; someone in the US, where Letter is standard, tries to print
; this document, this will not work! The printer will ask for 
; A4 paper before printing. The only use is when your postscript
; renderer on your computer ignores output outside the BoundingBox
; and you want to make sure that you can see it.
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
pro ps_write_creator, filename, force_paper_size=force_paper_size

if n_params() ne 1 then $
	fname = ps_get_filename() $
else $
	fname = filename

supported_paper_sizes = ['A4', 'Letter']

if keyword_set(force_paper_size) then begin
	tmp = where(supported_paper_sizes eq force_paper_size)
	if tmp[0] eq -1 then $
		prinfo, 'FORCE_PAPER_SIZE set but ignored.' $
	else $
		spapersize = '%%DocumentPaperSizes: '+strtrim(force_paper_size,2)
endif

; find caller function/routine
help, /traceback, output=hout
creator = strtrim(strmid(hout,4),2)

; do some testing
; nothing of the following should go wrong
if ps_get_isopen() then begin
	prinfo, 'Cannot write comment: File is still open.'
	return
end

if ~file_test(fname) then begin
	prinfo, 'Cannot write comment: File does not exist.'
	return
end

; open original file
openr, fin, fname, /get_lun, error=ioerr
if ioerr ne 0 then begin
	prinfo, 'Could not open input file: ', fname
	return
end

; open new file
openw, fout, fname+'.new', /get_lun, error=ioerr
if ioerr ne 0 then begin
	prinfo, 'Could not open output file: ', fname+'.new'
	free_lun, fin
	return
end

info_written = !false
end_comments = !false
line = ''

; search for the follwoing line
; %%Creator: IDL Version 
; after which our line is inserted
while ~eof(fin) do begin
	readf, fin, line

	; if end of comments has been reached, just continue writing the 
	; original stuff
	if end_comments then begin
		printf, fout, line
		continue
	endif

	; the Title line has been found, insert filename
	; this makes looking at the file in Evince viewer easier
	if strmatch(line, '%%Title:*') then begin
		printf, fout, line+': '+file_basename(fname)

	; delete old entries of CreatorScript; the Creator line has been found, insert info
	endif else if strmatch(line, '%%Creator:*') then begin
		printf, fout, line
		for i=0, n_elements(creator)-1 do $
			printf, fout, '%CreatorScript: '+creator[i]
			if n_elements(spapersize) eq 1 then $
				printf, fout, spapersize
			fmt = get_format(landscape=ls, portrait=pt)
			if pt then $
				printf, fout, '%%Orientation: Portrait'
			if ls then $
				printf, fout, '%%Orientation: Landscape'
			info_written = !true

	; delete old entries of CreatorScript
	endif else if strmatch(line, '%CreatorScript:*') then begin
		; do nothing
		continue
	; in case no Creator comments is present, look for 
	; EndComments
	endif else if strmatch(line, '%%EndComments*') then begin
		if ~info_written then begin
			for i=0, n_elements(creator)-1 do $
				printf, fout, '%CreatorScript: '+creator[i]
			if n_elements(spapersize) eq 1 then $
				printf, fout, spapersize
			info_written = !true
		endif
		printf, fout, line
		end_comments = !true

	; print all the other header stuff
	endif else $
		printf, fout, line

endwhile
free_lun, fin
free_lun, fout

; effectively rename old file
file_delete, fname
file_move,  fname+'.new', fname

if not(info_written) then $
	prinfo, 'Info could not be written.'

end
