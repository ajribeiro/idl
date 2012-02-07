pro FitMakeFitData,fit

  MAX_RANGE=300

  fit={FitData, $
         revision: {rlstr, major: 0L, minor: 0L}, $ 
         noise: {nfstr, sky: 0.0, lag0: 0.0, vel: 0.0}, $
         pwr0: fltarr(MAX_RANGE), $
         nlag: intarr(MAX_RANGE), $
         qflg: bytarr(MAX_RANGE), $
         gflg: bytarr(MAX_RANGE), $
         p_l:  fltarr(MAX_RANGE), $ 
         p_l_e: fltarr(MAX_RANGE), $
         p_s: fltarr(MAX_RANGE), $
         p_s_e: fltarr(MAX_RANGE), $
         v: fltarr(MAX_RANGE), $
         v_e: fltarr(MAX_RANGE), $
         w_l: fltarr(MAX_RANGE), $
         w_l_e: fltarr(MAX_RANGE), $
         w_s: fltarr(MAX_RANGE), $
         w_s_e: fltarr(MAX_RANGE), $
         sd_l: fltarr(MAX_RANGE), $
         sd_s: fltarr(MAX_RANGE), $
         sd_phi: fltarr(MAX_RANGE), $
         x_qflg: bytarr(MAX_RANGE), $
         x_gflg: bytarr(MAX_RANGE), $
         x_p_l: fltarr(MAX_RANGE), $
         x_p_l_e: fltarr(MAX_RANGE), $
         x_p_s: fltarr(MAX_RANGE), $
         x_p_s_e: fltarr(MAX_RANGE), $
         x_v: fltarr(MAX_RANGE), $
         x_v_e: fltarr(MAX_RANGE), $
         x_w_l: fltarr(MAX_RANGE), $
         x_w_l_e: fltarr(MAX_RANGE), $
         x_w_s: fltarr(MAX_RANGE), $
         x_w_s_e: fltarr(MAX_RANGE), $
         phi0: fltarr(MAX_RANGE), $
         phi0_e: fltarr(MAX_RANGE), $
         elv: fltarr(MAX_RANGE), $
         elv_low: fltarr(MAX_RANGE), $
         elv_high: fltarr(MAX_RANGE), $
         x_sd_l: fltarr(MAX_RANGE), $
         x_sd_s: fltarr(MAX_RANGE), $
         x_sd_phi: fltarr(MAX_RANGE) $

      }

end