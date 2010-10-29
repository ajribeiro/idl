;+ 
; NAME: 
; RAD_GRD_READ_RECORD
;
; PURPOSE: 
; This procedure reads one record of data from an opened grid file. It is essentially GridExternalRead.
; This is used to force external - i.e. fast - record reading instead of doing it in IDL.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; RAD_GRD_READ_RECORD, Unit, Lib
;
; INPUTS:
; Unit: The file unit of the open map file.
;
; Lib: The path to the C routine that does the reading (usually from the
; environment variable LIB_GRIDIDL).
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
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on FitExternalRead.
; Written by Lasse Clausen, Nov, 24 2009
;-
function rad_grd_read_record, unit, lib, prm, stvec, gvec

  stnum=0L
  vcnum=0L
  ptr=''

  GridMakeStVec,stvec
  GridMakeGVec,gvec
	
  s=CALL_EXTERNAL(lib,'GridIDLRead', $
                  unit,stnum,vcnum,ptr)

  if s eq -1 then return, -1
 
  prm.stnum=stnum
  prm.vcnum=vcnum
  stvec=replicate(stvec,stnum)
  if (vcnum ne 0) then gvec=replicate(gvec,vcnum)

  st=CALL_EXTERNAL(lib,'GridIDLDecode', $
                  ptr,prm,stvec,gvec)

  ptr=''
  return, s
end