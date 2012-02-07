;+ 
; NAME: 
; SEARCH
; 
; PURPOSE: 
; This function recursively searches for pattern in filenames and inside files.
; Recursively means it searches all subdirectories as well.
; This procedure uses the shell commands "grep" and "find", so if they are not
; installed on your machine or you're running Windows, SEARCH won't work.
; 
; CATEGORY: 
; Input/Output 
; 
; CALLING SEQUENCE: 
; SEARCH, Pattern
; 
; INPUTS: 
; Pattern: A string giving the pattern to search for. Can contain wildcards.
; 
; KEYWORD PARAMETERS:
; DIRECTORY: Set this to a valid directory path to only search files in that directory.
; Default is ./
;
; FILE_EXTENSIONS: Set this to a file extension and only files ending in that 
; extension will be searched. Can be an array of file extensions.
;
; WORD: Set this keyword to only match the pattern if it is a word.
;
; IDL: Set this keyword to use .pro and .go as file extension.
;
; EXAMPLE: 
; Search for that batch file that plots the PostScript 
; file called "easy_stuff.ps"
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
; Go > search, 'easy_plots'
; ./60sBeast/plot_easy_stuff.pro:44:ps_open, '/home/lbnc1/results/20051107/easy_plots.ps'
;
; This takes a LOOOOONG time because ALL files are 
; searched; really, all of them. Speed it up by setting
; the idl keyword
;
; Go > search, 'easy_plots', /idl
; ./60sBeast/plot_easy_stuff.pro:44:ps_open, '/home/lbnc1/results/20051107/easy_plots.ps'
;
; Looking for the string "my mother" in all txt files in
; the birthday directory
;
; Go > search, 'my_mother', d='/home/lbnc1/birthday/', f='txt'
; find: /home/lbnc1/birthday/: No such file or directory
;
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2007
;-
pro search, pattern, directory=directory, file_extensions=file_extensions, $
    word=word, idl=idl, print_cmd=print_cmd

grep_switches = '--ignore-case --with-filename --line-number --colour=always'

if keyword_set(idl) then $
    file_extensions = ['pro','go']

if ~keyword_set(directory) then $
    directory = './'

if ~keyword_set(file_extensions) then $
    file_pattern = '-name "*"' $
else $
    file_pattern = $
;			'\( -not -path "*thmsw*" -and \( -name "*.'+strjoin(file_extensions,'" -o -name "*.')+'" \) \)'
			'\( -name "*.'+strjoin(file_extensions,'" -o -name "*.')+'" \)'

if keyword_set(word) then $
    grep_switches += ' --word_regexp'

find_filename_cmd = 'find '+directory+' -name "*'+pattern+'*"'

find_cmd = 'find '+directory+' '+file_pattern
grep_cmd = ' -exec grep '+grep_switches+' '+pattern+' "{}" \;'
;grep_cmd = ' -print'

full_cmd = find_cmd+grep_cmd

if keyword_set(print_cmd) then begin
    print, find_filename_cmd
    print, full_cmd
endif else begin
    spawn, find_filename_cmd
    spawn, full_cmd
endelse
end
