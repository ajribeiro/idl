;+ 
; NAME: 
; RAD_MAP_READ_RECORD
;
; PURPOSE: 
; This procedure reads one record of data from an opened convection map file. It is essentially CnvMapExternalRead.
; This is used to force external - i.e. fast - record reading instead of doing it in IDL.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RAD_MAP_READ_RECORD, Unit, Lib
;
; INPUTS:
; Unit: The file unit of the open map file.
;
; Lib: The path to the C routine that does the reading (usually from the
; environment variable LIB_CNVMAPIDL).
;
; OPTIONAL OUTPUTS:
; Prm: A named variable that will become a structure holding information about the data.
;
; Stvec: A named variable that will contain a structure holding information about what radars 
; contributed what data to the convection pattern.
;
; Gvec: A named variable that will contain a structure holding information about the actual measured
; velocity vectors.
;
; Mvec: A named variable that will contain a structure holding information about the model vectors
; that went into the fit to constrain the fit.
;
; Coef: A named variable that will contain the coefficients of the harmonic expansion.
;
; Bvec: A named variable that will contain a structure holding information about the boundary of some sort.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on FitExternalRead.
; Written by Lasse Clausen, Nov, 24 2009
;-
function rad_map_read_record, unit, lib, prm, stvec, gvec, mvec, coef, bvec

  stnum=0L
  vcnum=0L
  modnum=0L
  coefnum=0L
  bndnum=0L
  ptr=''

;  if (KEYWORD_SET(lib) eq 0) then lib=getenv('LIB_CNVMAPIDL')
  s=CALL_EXTERNAL(lib,'CnvMapIDLRead', $
                  unit,stnum,vcnum,modnum,coefnum,bndnum,ptr)
  if s eq -1 then return, -1

  prm.stnum   = stnum
  prm.vcnum   = vcnum
  prm.modnum  = modnum
  prm.coefnum = coefnum
  prm.bndnum  = bndnum

	GridMakeStVec, stvec
	GridMakeGVec, gvec
	GridMakeGvec, mvec
	coef = 0.0D
	CnvMapMakeBnd, bvec
	
  stvec=replicate(stvec,stnum)
  if (vcnum ne 0) then gvec=replicate(gvec,vcnum)
  if (modnum ne 0) then mvec=replicate(mvec,modnum)
  if (coefnum ne 0 ) then coef=dblarr(coefnum,4)
  if (bndnum ne 0) then bvec=replicate(bvec,bndnum)

;  if (KEYWORD_SET(lib) eq 0) then lib=getenv('LIB_CNVMAPIDL')
  st=CALL_EXTERNAL(lib,'CnvMapIDLDecode', $
                  ptr,prm,stvec,gvec,mvec,coef,bvec)

  ptr=''
  return, st

end