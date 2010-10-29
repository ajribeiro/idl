;+
; NAME: 
; OMN_SPLIT_FILE
;
; PURPOSE: 
; This procedure reads yearly ONMI data files in HRO format and splits them
; into daily files. The OMNI data should be obtained from
; ftp://nssdcftp.gsfc.nasa.gov/spacecraft_data/omni/high_res_omni/ and is
; then used as input to the map potential routines.
; The map potential fitting routine (map_addmodel in RST) can be instructed
; to read IMF data and delays from text files. However, we can't use
; OMNI data as is because the IMF in the OMNI files is already lagged.
; Hence after splitting into daily files we must write the delay times
; in one ascii file and the de-delayed imf into a separate one.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; OMN_SPLIT_FILE, Filename
;
; INPUTS:
; Filename: The name of the file containing the OMNI data in HRO format.
;
; KEYWORD PARAMETERS:
; OUTDIR: Set this keyword to the directory in which the daily files will be stored.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, 8 Jan, 2010
;-
pro omn_split_file, filename, outdir=outdir

if n_params() lt 1 then begin
	prinfo, 'Must give filename.'
	return
endif

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

fmt = '(2I4)'
year = 0
doy  = 0
adoy = 0
line = ''

ilun = 0
olun = 0

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

	; open input file
	openr, ilun, ifiles[i], /get_lun

	; loop through file, only reading the year and the
	; day number
	while ~eof(ilun) do begin
		; get the position in input file
		point_lun, -ilun, pun
		; read year and doy
		readf, ilun, year, doy, format=fmt
	
		; if new day, close old file and open a new one
		if doy ne adoy then begin
			if olun ne 0 then $
				free_lun, olun
			caldat, julday(1, doy, year, 0.), am, ad
			str_year = string(year, format='(I4)')
			ofile = outdir + '/' + $
				format_date(year*10000L+am*100L+ad)+'_omni.asc'
			openw, olun, ofile, /get_lun
		endif
	
		; revert position in file to beginning of line
		point_lun, ilun, pun
		; read (again) and print to output file
		readf, ilun, line
		printf, olun, line
	
		adoy = doy
	endwhile

	; close input and last output file and exit
	free_lun, olun
	free_lun, ilun

endfor

end
