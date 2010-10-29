;- FUNCTION CALC_POSITIONS
;-
;- Calculates the normal coordinates of plots on a page, depending on the 
;- number of plots per page.
;-
;- Returns an array of size [4, nrows, ncols].
;-
;- n_rows: Number of rows per page
;- n_cols: Number of columns per page
;- xgap: The size of the gap between columns
;- ygap: The size of the gap between rows
;- gap: The size of the gap between plots. If set, xgap and ygap will be set 
;-      to the value of gap
;- row_gap_after: Array of indeces giving the panel number after which to 
;-                put a gap in each row
;- col_gap_after: Array of indeces giving the panel number after which to 
;-                put a gap in each column
;- xoff: offset from the left side of the page where to start plotting
;- xlen: total length of plotting area in x direction, including gaps
;- yoff: offset from the TOP side of the page where to start plotting
;- ylen: total length of plotting area in y direction, including gaps
;-
function calc_positions, n_rows, n_cols, $
	xgap=xgap, ygap=ygap, gap=gap, $
	row_gaps_after=row_gaps_after, col_gaps_after=col_gaps_after, $
	xoff=xoff, xlen=xlen, yoff=yoff, ylen=ylen, $
	go=go, BAR=BAR, HSQUARE=HSQUARE, NO_CENTRE=NO_CENTRE, $
	NO_TITLE=NO_TITLE, SQUARE=SQUARE, WIDE_Y=WIDE_Y

if n_params() ne 2 then n_cols = 1.

if ~keyword_set(xoff) then xoff = 0.15
if ~keyword_set(xlen) then xlen = 0.8
if ~keyword_set(yoff) then yoff = 0.93
if ~keyword_set(ylen) then ylen = 0.80
if ~keyword_set(gap) then gap = 0.0 else gap = float(gap)
if ~keyword_set(xgap) then xgap = gap else xgap = float(xgap)
if ~keyword_set(ygap) then ygap = gap else ygap = float(ygap)
if ~keyword_set(row_gaps_after) then row_gaps_after = -2
if ~keyword_set(col_gaps_after) then col_gaps_after = -2

nrows = float(n_rows)
ncols = float(n_cols)

if keyword_set(go) then begin
	pold = !p.position
	poss = make_array(4, nrows, ncols, /float)
	for r=0, nrows-1 do begin
		for c=0, ncols-1 do begin
			define_panel, nrows, ncols, r, c, $
				BAR=BAR, HSQUARE=HSQUARE, NO_CENTRE=NO_CENTRE, $
				NO_TITLE=NO_TITLE, SQUARE=SQUARE, WIDE_Y=WIDE_Y
			poss[*, r, c] = !p.position
		endfor
	endfor
	!p.position = pold
	return, poss
endif

;- set the indeces where to put gaps
;- depending on whether gap, xgap or ygap is set
if row_gaps_after[0] eq -2 and col_gaps_after[0] eq -2 then begin
	if gap ne 0.0 then begin
		if nrows gt 1. then $
			row_gaps_after = findgen(nrows-1)+1
		if ncols gt 1. then $
			col_gaps_after = findgen(ncols-1)+1
	endif
	if xgap ne 0.0 then begin
		if ncols gt 1. then $
			col_gaps_after = findgen(ncols-1)+1
	endif
	if ygap ne 0.0 then begin
		if nrows gt 1. then $
			row_gaps_after = findgen(nrows-1)+1
	endif
endif

;- subtract gap width in y direction from total length
if row_gaps_after[0] eq -2 then $
	row_totgap = 0. $
else $
	row_totgap = float(n_elements(row_gaps_after))*ygap
ylen -= row_totgap

;- subtract gap width in x direction from total length
if col_gaps_after[0] eq -2 then $
	col_totgap = 0. $
else $
	col_totgap = float(n_elements(col_gaps_after))*xgap
xlen -= col_totgap

;- array holding result
poss = make_array(4, nrows, ncols, /float)

;- counter for gap position
row_no_gap = 0.

;- cycle through rows
for r=0, nrows-1 do begin

	col_no_gap = 0.

	if row_no_gap lt n_elements(row_gaps_after) then $
		if r eq row_gaps_after[row_no_gap] then $
			row_no_gap += 1.

	pos_bottom = yoff - ylen*(r+1.)/nrows - row_no_gap*ygap
	pos_top    = yoff - ylen*(r+0.)/nrows - row_no_gap*ygap

	for c=0,ncols-1 do begin

		if col_no_gap lt n_elements(col_gaps_after) then $
			if c eq col_gaps_after[col_no_gap] then $
				col_no_gap += 1.

		pos_left  = xoff + xlen*(c+0.)/ncols + col_no_gap*xgap
		pos_right = xoff + xlen*(c+1.)/ncols + col_no_gap*xgap

		if ncols gt 1 then $
			poss[*,r,c] = [pos_left, pos_bottom, pos_right, pos_top] $
		else $
			poss[*,r] = [pos_left, pos_bottom, pos_right, pos_top]
	endfor

endfor

return, poss

end
