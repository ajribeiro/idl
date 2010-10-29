;+ 
; NAME: 
; RT_READ_RANGES
;
; PURPOSE: 
; This procedure reads rays.dat
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_READ_RANGES, unit, radpos, thtpos, phipos, grppth, gndflag
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORDS:
;
; COMMON BLOCKS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-
pro rt_read_rays, unit, radpos, thtpos, phipos, grppth, gndflag
; print,'running rt_read_rays.pro'
; Procedure to read in the locus of one ray
; Here and rt_read_header: read in a dummy 64 bits at beginning and end 
; of record, as F77_UNFORMATTED is incompatible between 64 bit 
; fortran and 32 bit idl.  may go away in next idl version

; dum = 0L
dum = 0D
raynum = 0L

READU, unit, dum, raynum, dum
; print, 'raynum: ', raynum

radpos = dblarr(raynum)
thtpos = dblarr(raynum)
phipos = dblarr(raynum)
grppth = dblarr(raynum)
gndflag = intarr(raynum)

READU, unit, dum, radpos, thtpos, phipos, grppth, gndflag, dum

END
