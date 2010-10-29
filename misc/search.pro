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
