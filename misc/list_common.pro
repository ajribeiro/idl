;+ 
; NAME: 
; LIST_COMMON 
; 
; PURPOSE: 
; This procedure lists all variables in a common block. It achieves that by 
; 1) using scope_varname function or for fuller description 2) parsing through 
; the output of help, names='*'
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; LIST_COMMON, Block_name
; 
; INPUTS: 
; Block_name: A string containing the name of the common block.
; 
; KEYWORD PARAMETERS: 
; FULL: Set this keyword to force a fuller description of the variables.
;
; LIST: Set this keyword to list all common blocks.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro list_common, block_name, full=full, list=list

if keyword_set(list) then begin
	; get all variable names on $MAIN$ level
	help, names='*', output=out, level=1
	parsed_blocks = ''
	nparsed_blocks = 0
	nn = n_elements(out)
	; cycle through all variable names, looking 
	; for the opening parantheses which indicate
	; whether a variable belongs to a common block
	; if we find such a paratheses, we know we've
	; found a common block.
	for i=0L, nn-1L do begin
		if (pos=strpos(out[i], '(')) ne -1 then begin
			block_name = strmid(out[i], pos+1, strpos(out[i],')')-pos-1)
			inds = where(parsed_blocks eq block_name)
			if inds[0] eq -1 then begin
				if nparsed_blocks eq 0 then $
					parsed_blocks = block_name $
				else $
					parsed_blocks = [parsed_blocks, block_name]
				nparsed_blocks += 1
				if keyword_set(full) then $
					list_common, block_name $
				else $
					print, '  '+block_name
			endif
		endif
	endfor
	return
endif

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Block_name.'
	return
endif
if size(block_name, /type) ne 7 then begin
	prinfo, 'Block_name. must be of type string.'
	return
endif

_block_name = strupcase(block_name)

; try to include common block
; if it doesn't exist, this produces an error
dd = execute('common '+_block_name, 1, 1)
if dd ne 1 then begin
    prinfo, 'Common block '+_block_name+' does not exist'
    return
endif

print, '+---+'
print, 'Common block '+_block_name+' contains:'
print, '+---+'

; the "easy" solution
if ~keyword_set(full) then begin
    vars = scope_varname(common=_block_name)
    vars = vars[sort(vars)]
    for i=0, n_elements(vars)-1 do $
    	print, vars[i], format='(A20)'
    return
endif

; the "hard" way
; parsing through output using regular expressions
chars = '[a-zA-Z_0-9]'
ext_chars = '[][ a-zA-Z_0-9<>'+"'"+'-,]'
help, names='*', output=out
nn = n_elements(out)

varname_regex   = '('+chars+'+) +'
varcommon_regex = '\('+block_name+'\)'
vardef_regex    = '('+chars+'+) += +(-> +)?('+ext_chars+'+)'

global_regex = '^'+varname_regex+varcommon_regex+' +'+vardef_regex
varnc_regex = '^'+varname_regex+varcommon_regex

got_all = 0
varname_found = 0
for i=0L, nn-1L do begin
	pos = stregex(out[i], global_regex, length=length, /subexpr)
	if pos[0] eq -1 then begin
		pos = stregex(out[i], varnc_regex, length=length, /subexpr)
		if pos[0] eq -1 then begin
			pos = stregex(out[i], '^ +'+vardef_regex, length=length, /subexpr)
			if pos[0] eq -1 then begin
			endif else begin
				vartype = strmid(out[i], pos[1], length[1])
				varvalu = strmid(out[i], pos[3], length[3])
				if varname_found eq 1 then got_all = 1
			endelse
		endif else begin
			varname = strmid(out[i], pos[1], length[1])
			varname_found = 1
		endelse
	endif else begin
		varname = strmid(out[i], pos[1], length[1])
		vartype = strmid(out[i], pos[2], length[2])
		varvalu = strmid(out[i], pos[4], length[4])
		got_all = 1
	endelse
	if got_all eq 1 then begin
		print, varname, vartype, varvalu, format='(A20,3X,A-10,3X,A-30)'
		varname_found = 0
	endif
	got_all = 0
endfor

end
