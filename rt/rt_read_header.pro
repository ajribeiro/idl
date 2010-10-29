;+ 
; NAME: 
; RT_READ_HEADER
;
; PURPOSE: 
; This procedure reads header of rays.dat
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_READ_HEADER, unit, freq_beg, freq_stp, elev_beg, elev_stp
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
pro rt_read_header, unit, freq_beg, freq_stp, elev_beg, elev_stp, elev_end
; print,'running rt_read_header.pro'
; Procedure to read in the header of rays.dat
; Here and rt_read_rays: read in a dummy 64 bits at beginning and end 
; of record, as F77_UNFORMATTED is incompatible between 64 bit 
; fortran and 32 bit idl.  may go away in next idl version

; check numbers wrt ground group paths to make sure they're right.  Then compare 
; group and ground ranges as calculated here. 
; Then use to recalculate vladimir interval.  
; work out elev fudge for Ch. B

; dum = 0L
dum = 0D
freq_beg = 0.D
freq_end = 0.D
freq_stp = 0.D
azim_beg = 0.D
azim_end = 0.D
azim_stp = 0.D
elev_beg = 0.D
elev_end = 0.D
elev_stp = 0.D

READU, unit, dum, $
	freq_beg, freq_end, freq_stp, $
	azim_beg, azim_end, azim_stp, $
	elev_beg, elev_end, elev_stp, $
	dum

;  print, freq_beg, freq_end, freq_stp, $
; 	azim_beg, azim_end, azim_stp, $
; 	elev_beg, elev_end, elev_stp
END
