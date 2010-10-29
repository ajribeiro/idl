function conv_struc, in, out, diag, fix_sc=fix_sc, rad_rem=rad_rem, snp=snp, $
                    big=big,no_def=no_def, $
                    r_diag=r_diag, ret_curr_blank=ret_curr_blank

;**************************************************************************************
; conv_struc converts DMSP SSJ/4/5 data from APL file format into a format convenient for tom
;
; written by tom sotirelis 1/2005 with bits hacked from conv_rec
;
; /big:    yields a larger data structure with additional tags ready for boundary analysis
; /no_def: yields a smaller data structure without the differntial energy flux
;
; returns 1 on success and 0 on failure
;*****************************************************************************************

common conv_struc_sav, mode_o, strct0, diag0, init_q

;***************************************************************************************
; Output a blank record if requested, mode must already be set by a previous call
;***************************************************************************************


if keyword_set(init_q) && keyword_set(ret_curr_blank) then begin

    ret_curr_blank   =   strct0
    
    return, 0
    
endif

;******************************************************************************************
; define output structure
;******************************************************************************************


if ~keyword_set(init_q) then begin

    init_q  =   1
    mode_o  =   255B

endif


fix_sc_q    =   keyword_set(fix_sc)
rad_q       =   keyword_set(rad_rem)
snp_q       =   keyword_set(snp)
big_q       =   keyword_set(big)
no_def_q    =   keyword_set(no_def)
r_diag_q    =   keyword_set(r_diag)

if big_q && no_def_q then  no_def_q = 0B

mode        =   no_def_q + 2B * big_q


if (mode ne mode_o) then begin

    z       =   0.0
    z19     =   fltarr(19)
    reset   =   1B
    mode_o  =   mode

endif else  reset = 0B

;***************************************************************************************


if reset && big_q then begin

    reset   =   0B
    diag0   =   {ssj_noise_diag $
                , ci_av:z, cil_av:z, ce_av:z, cel_av:z $
                , ci_min:z, cil_min:z, ce_min:z, cel_min:z $
                , jirr:0, jirrl:0, jerr:0, jerrl:0 $
                , jirr_sm:z, jirrl_sm:z, jerr_sm:z, jerrl_sm:z $
                , bi:z, bil:z, be:z, bel:z $
                , bi_sm:z, bil_sm:z, be_sm:z, bel_sm:z $
                , ce_sc:z, cel_sc:z, ci_sc:z, cil_sc:z $
                , e_sc:z, el_sc:z, i_sc:z, il_sc:z $
                , e_ov:0, el_ov:0, i_ov:0, il_ov:0 $
                }
    strct0  =   {j_type_b $
                , sat:0, year:0, ys:0D, doy:0, sod:0D $
                , glat:z, glon:z, mlat:z, mlon:z, mlt:z $
                , jne:z, jee:z, eav:z, ergs:z $         ; electron fluxes
                , jni:z, jei:z, iav:z, irgs:z $         ; ion fluxes
                , jee3:z, jee5:z, eav5:z $              ; e- flux discarding some channels
                , deflux:z19, diflux:z19 $              ; e-, ion differntial energy flux
                , amlat:z, hemi:0 $                     ; absolute mlat, hemisphere
                , jev:z19, jiv:z19 $                    ; electron, ion energy flux vector
                , eflux:z19, iflux:z19 $                ; electron, ion counts
                , def_unc:z19, dif_unc:z19 $            ; e-, ion diff. E-flux uncorrected
                , sc_ch_fl:0 $                          ; spacecraft charging flag
                , rad_f_e:z,  rad_f_i:z $               ; radiation subtraction fraction 
                , rad_f_el:z, rad_f_il:z $              ; radiation subtr fraction low chans
                , rad_b_e:z,  rad_b_i:z $               ; radiation noise 
                , rad_b_el:z, rad_b_il:z $              ; radiation noise in low J4 channels
                , rad_diag:diag0 $                      ; rad removal diagnostics 
                , fact_ptr:ptr_new() $
               
; The tags above are calcualted here, those below are not

                , ion_pk_en:z, ion_pk_def:z $           ; peak ion def and energy
                , el_pk_en:z, el_pk_def:z $          ; peak el def and energy
                , jel:z, jeh:z, jim:z $              ; partial energy fluxes
                , jih:z, jih_mf:z $                  ; partial energy fluxes
;                                               ; local 1-sec spectra character scores
                , acc_code:-9 $                      ; electron acceleration code
                , acc_co_en:z $                      ;   electron energy just above dropoff
                , acc_rat_for:z,acc_rat_back:z $     ; dropoff ratios
                , leic_code:-9 $                     ; low energy ion cutoff code
                , leic_co_en:z, leic_co_def:z $      ;   cutoff energy
                , leic_drop_rat:z $                  ;   dropoff ratio
                , leic_n:0L $                        ;   counts pre-drop
                , maxw_e_rat:z, maxw_e_ch:z $        ; electron maxwell chisq, ratio
                , maxw_e_n:0, maxw_e_nnz:0 $         ;   number fit, nonzero number fit
                , maxw_eje:z,maxw_ejn:z,maxw_eav:z $ ;   jee,jne,eav
                , maxw_i_rat:z, maxw_i_ch:z $        ; ion maxwell chisq, ratio
                , maxw_i_n:0, maxw_i_nnz:0 $         ;   number fit, nonzero number fit
                , maxw_ije:z,maxw_ijn:z,maxw_iav:z $ ;   jee,jne,eav
                , re:z, rp:z $                       ; eqrward and plwrd correlation coeffs
;                , cps:z, bps:z, void:z $             ; region id scores
;                , ncps:z, nbps:0., mps:z $
;                , cusp:z, mant:z, polr:z $
;                , llbl:z, opll:z $
                }

            
endif


if reset && no_def_q then begin

    reset   =   0B
    strct0  =   {j_type_s $
                , sat:0, year:0, ys:0D, doy:0, sod:0D $
                , glat:z, glon:z, mlat:z, mlon:z, mlt:z $
                , jne:z, jee:z, eav:z, ergs:z $      ; electron fluxes
                , jni:z, jei:z, iav:z, irgs:z $      ; ion fluxes
                , jee3:z, jee5:z, eav5:z $           ; electron flux discarding some channels
                , amlat:z, hemi:0 $                  ; absolute mlat, hemisphere
                , sc_ch_fl:0 $                       ; spacecraft charging flag
                , rad_f_e:z, rad_f_i:z $             ; radiation subtraction fraction
                , rad_f_el:z, rad_f_il:z $           ; rad subtr fraction low chans
                }
                
endif


if reset then begin

    strct0  =   {j_type $
                , sat:0, year:0, ys:0L, doy:0, sod:0L $
                , glat:z, glon:z, mlat:z, mlon:z, mlt:z $
                , jne:z, jee:z, eav:z, ergs:z $      ; electron fluxes
                , jni:z, jei:z, iav:z, irgs:z $      ; ion fluxes
                , jee3:z, jee5:z, eav5:z $           ; electron flux discarding some channels
                , deflux:z19, diflux:z19 $           ; electron, ion differntial energy flux
                , amlat:z, hemi:0 $                  ; absolute mlat, hemisphere
                , sc_ch_fl:0 $                       ; spacecraft charging flag
                , rad_f_e:z, rad_f_i:z $             ; radiation subtraction fraction 
                , rad_f_el:z, rad_f_il:z $           ; rad subtraction fraction low chans
                }
                
endif

;******************************************************************************************
;    d0  =  {apl_ssj_ty, f:0B, yr:0B, doy:0, ilat:0, ilon:0, eflux:z, iflux:z, sod:0L $
;                      , ver:0, orig_pos_f:0B, f1:0B, norad_err_f:0B, geomag_err_f:0B $
;                  , nlat:0L, nlon:0L, nalt:0L, mlat:0L, mlon:0L, mlt:0L, aacgm_year:0, f2:0L}
;******************************************************************************************


if max(in.geomag_err_f) gt 0 then begin
    w = where(in.geomag_err_f gt 0, nw)
    print,'conv_struc: geomag_err_f', in[0].yr, in[0].doy, nw
    return, 0
endif

if max(in.sat) ne min(in.sat) then begin
 print,'conv_struc: max(in.sat) ne min(in.sat)', in[0].yr, in[0].doy, max(in.sat), min(in.sat)
    return, 0
endif


num   =  n_elements(in)

if num le 0 then return, 0

out   =  replicate(strct0, num)
  
;******************************************************************************************
; position and time
;*************************************************


sat   =  fix(in[0].sat)
yr    =  fix(in[0].yr)
doy   =  fix(in[0].doy)
sod   =  double(in.sod) ;+ 0.001*in.frac_sec
ys    =  sod + ((doy-1)*86400L)

if yr lt 80 then  year = yr + 2000  else  year = yr + 1900
  

out.sat   =  sat
out.year  =  year
out.ys    =  ys
out.doy   =  doy
out.sod   =  sod


w  =  where(in.norad_err_f, nw, com=wc, ncom=nc)

if nc gt 0 then begin

    out[wc].glat  =  in[wc].nlat/10000.0
    out[wc].glon  =  in[wc].nlon/10000.0
    
endif 

if nw gt 0 then begin

    out[w].glat  =  in[w].ilat/10.0
    out[w].glon  =  in[w].ilon/10.0
    
endif


out.mlat  =  in.mlat/10000.0
out.mlon  =  in.mlon/10000.0
out.mlt   =  in.mlt/100000.0

out.amlat  =  abs(out.mlat)
out.hemi   =  out.mlat/out.amlat

;*******************************************************************************************
; Get calibration factors
;******************************************************************************************


tom_facts, sat, year, facts, fact_ptr

if big_q then out.fact_ptr    =   fact_ptr

;************************************************************************************
; rescale
;************************************************************************************


reflux    =  float(in.eflux > 0)
w         =  where(reflux gt 32000.0, nw)

if nw gt 0 then  reflux[w] = 32000.0 + (reflux[w] - 32000.0) * 100.0
    
riflux   =  float(in.iflux > 0)
w        =  where(riflux gt 32000.0, nw)

if nw gt 0 then  riflux[w] = 32000.0 + (riflux[w] - 32000.0) * 100.0

;***************************************************************************************
; eliminate non-channel in J5 data
;***************************************************************************************


if sat ge 16 then begin

    reflux = [reflux[0:8, *], reflux[10:19, *]]
    riflux = [riflux[0:8, *], riflux[10:19, *]]

endif

;*****************************************************************************************
; ameliorate spacecraft charging effects
;*****************************************************************************************


if fix_sc_q then begin

    aiflux = fix_sc_ch(riflux, facts, nw, w)
    
    if nw gt 1 then  out[w].sc_ch_fl = 1
    
endif else  aiflux = riflux

;****************************************************************************************
; radiation amelioration
;****************************************************************************************

if rad_q then begin

    if r_diag_q then  diag = diag0
    
 ;   rem_ssj_noise, aiflux, iflux, reflux, eflux, ys, out.amlat, sat, snp=snp $
    rem_ssj_noise, aiflux, iflux, reflux, eflux, ys, out.amlat, sat $
                  , bi, bil, be, bel, ci_av, cil_av, ce_av, cel_av $
                 , diag, diag_q=r_diag_q
                 
endif else begin

    iflux   =   aiflux
    eflux   =   reflux
    
endelse


if rad_q then begin                                ; Rad diagnostics

    out.rad_f_e     =  be/(ce_av > 1.0)
    out.rad_f_i     =  bi/(ci_av > 1.0)
    
    if sat le 15 then begin
        out.rad_f_el    =   bel/( cel_av > 1.0)
        out.rad_f_il    =   bil/( cil_av > 1.0)
    endif
    
    if big_q then begin
    
        out.rad_b_e     =  be
        out.rad_b_i     =  bi
        if sat le 15 then begin
            out.rad_b_el    =  bel
            out.rad_b_il    =  bil
        endif
        
    endif
endif


;******************************************************************************************
; Make J4 data into 19 channels by discarding redundant channel
;******************************************************************************************


if sat le 15 then begin
    
    reflux          =  [reflux[0:8, *], reflux[10:19, *]]
    eflux           =  [ eflux[0:8, *],  eflux[10:19, *]]
    
    riflux          =  [riflux[0:9, *], riflux[11:19, *]]
    iflux           =  [ iflux[0:9, *],  iflux[11:19, *]]
    
endif

;******************************************************************************************
; Number and energy fluxes
; jn in #/cm^2/s/sr
; je in ev/cm^2/s/sr
;******************************************************************************************


fjne5       =  facts.jne
fjee5       =  facts.jee
fjee3       =  facts.jee
fjne5[0:7]  =  0.
fjee5[0:7]  =  0.
fjee3[0:2]  =  0.

out.jne  =  reform( facts.jne#eflux )
out.jee  =  reform( facts.jee#eflux )
out.eav  =  out.jee/(out.jne > 10000.)
out.jee3 =  reform( fjee3#eflux )
out.jee5 =  reform( fjee5#eflux )
out.eav5 =  ( out.jee5 / reform( fjne5#eflux > 10000.) ) > out.eav
out.ergs =  out.jee * !pi * 1.602e-12

out.jni  = reform( facts.jni#iflux )
out.jei  = reform( facts.jei#iflux )
out.iav  = out.jei/(out.jni > 500)
out.irgs = out.jei * !pi * 1.602e-12

;*************************************************
; differential energy fluxes in 1/cm^2/s/sr
;*************************************************


if ~no_def_q then for i=0l, num-1L do begin

    out[i].deflux = eflux[*,i]*facts.edef
    out[i].diflux = iflux[*,i]*facts.idef
    
endfor

;*************************************************
; energy flux vector
; jXv in ev/cm^2/s/sr per channel
;*************************************************


if big_q then begin
    
    out.eflux       =  eflux
    out.iflux       =  iflux
    
    for i=0L, num-1L do begin
        
        out[i].jev      =   eflux[*,i]*facts.jee
        out[i].jiv      =   iflux[*,i]*facts.jei
        out[i].def_unc  =   reflux[*,i]*facts.edef
        out[i].dif_unc  =   riflux[*,i]*facts.idef
        
    endfor

    if r_diag_q then  out.rad_diag = diag
    
endif


return, 1

end