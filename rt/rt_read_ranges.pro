;+ 
; NAME: 
; RT_READ_RANGES
;
; PURPOSE: 
; This procedure reads electron header of rays.dat
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RT_READ_RANGES, unit, numran, gndran, grpran, ranelv
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
; Written by Sebastien de Larquier, Sept. 2010
;-
pro 	rt_read_ranges, unit, numran, gndran, grpran, ranelv
; print,'running rt_read_ranges.pro'
; Procedure to read ground reflection
; Here and rt_read_header: read in a dummy 64 bits at beginning and end 
; of record

; dum = 0L
dum = 0D
numran = 0L

READU, unit, dum, numran, dum
; print, 'numran: ', numran

IF numran GT 0 THEN BEGIN
  gndran = dblarr(numran)
  grpran = dblarr(numran)
  ranelv = dblarr(numran)

  READU, unit, dum, gndran, grpran, ranelv, dum
ENDIF ELSE BEGIN
  gndran = 0D
  grpran = 0D
  ranelv = 0D
ENDELSE

END
