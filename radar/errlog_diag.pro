;+
; NAME:
; ERRLOG_DIAG
;
; PURPOSE:
; This function reads and errlog file from a radar and plots frquency, noise, and nave information
;
; CATEGORY:
; Radar
;
; CALLING SEQUENCE:
; Result = ERRLOG_DIAG,date,rad,[RANGE=[fmin,fmax]],[NBINS=nbins]
;
; INPUTS:
; date: a string specifying the date to get information for in the format 'yyyymmdd'
;	rad: a string specifying the 3-letter radar abreviation, eg 'fhe'
;
; KEYWORD PARAMETERS:
; RANGE: Set this keyword to the min and max frequencies (in KHz) to plot on the histogram
;					in vector form, eg [10000,15000]
;
; NBINS: Set this keyword to the number of bins to use in the histogram
;
; COMMON BLOCKS:
;
; EXAMPLE:
; Result = ERRLOG_DIAG,'20110426','fhw',range=[10000,15000],nbins=100
;
; OUTPUT:
; Result = ~/errlog.ps
;
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY:
; Based on Steve Milan's GO.
; Written by Lasse Clausen, Nov, 24 2009
;-


pro errlog_diag,date,rad,range=range,nbins=nbins

  set_plot,'PS',/copy
  device,/landscape,filename='~/errlog.ps',/COLOR,BITS_PER_PIXEL=8

  ;unzip the errlog file
  spawn,'bunzip2 -c -k /sd-data/2011/errlog/'+rad+'/errlog.'+rad+'.'+date+'.bz2 > ~/errlog.'+rad+'.'+date

	;read the restricted frequencies
  restricted = dblarr(10,2)
  num = 0
  openr,rest,"/sd-data/resfreq/restricted_freq.dat",/get_lun
  while(eof(rest) eq 0) do begin
    readf,rest,lo,hi
    restricted(num,0) = lo
    restricted(num,1) = hi
    num = num+1
  endwhile
  close,rest
  free_lun,rest

	;open the errlog file
  openr,errlog,'~/errlog.'+rad+'.'+date,/get_lun
  freqs = dblarr(40000)
  noises = dblarr(40000)
  nave = dblarr(40000)
  numb = 0L
  s = 'temp'
  ;read the errlog file
  while(eof(errlog) eq 0) do begin
    readf,errlog,s
    if(strpos(s,'Transmitting on:') ne -1) then begin
      freqs(numb) = strtrim(strmid(s,strpos(s,'on:')+4,5),2)
      noises(numb) = strtrim(strmid(s,strpos(s,'=')+1,strpos(s,')')-strpos(s,'=')-1),2)
    endif
    if(strpos(s,'sequences:') ne -1) then begin
      nave(numb) = strtrim(strmid(s,strpos(s,'sequences:')+11,2),2)
      numb = numb + 1
    endif
  endwhile
  close,errlog
  free_lun,errlog

  freqs = reform(freqs(0:numb-1))
  noises = reform(noises(0:numb-1))
  nave = reform(nave(0:numb-1))

  
	;plot the histogram of frequencies and restricted frequencies
  if(keyword_set(range) eq 0) then $
    range = [(fix(min(freqs)/1000.))*1000.,(fix(max(freqs)/1000.) + 1)*1000.]

  if(keyword_set(nbins) eq 0) then $
    nbins = 50.

  hist = histogram(freqs,nbins=nbins,max=range(1),min=range(0))

  binsize = (range(1)-range(0))/nbins

  plot,findgen(nbins),hist,xrange=range,yrange=[0,max(hist)+50],ystyle=1,$
        xstyle=1,/nodata,title=date+' '+rad+'  Frequency Distribution',$
        xtitle='frequency (kHz)',ytitle='number',charthick=3.,thick=3.,$
        xticklen=-.01,yticklen=-.01



  for i=0,num-1 do begin
    if(restricted(i,1) lt range(0)) then continue
    if(restricted(i,0) gt range(1)) then continue

    if(restricted(i,0) lt range(0)) then x0 = range(0) $
    else x0 = restricted(i,0)

    if(restricted(i,1) gt range(1)) then x1 = range(1) $
    else x1 = restricted(i,1)

    polyfill,[x0,x1,x1,x0],[0,0,max(hist)+50,max(hist)+50],thick=3.,/line_fill,spacing=0.1,orientation=45
  endfor

  for i=0,nbins-1 do begin
    polyfill,[i*binsize+range(0),(i+1.)*binsize+range(0),(i+1.)*binsize+range(0),i*binsize+range(0)],$
              [0,0,hist(i),hist(i)],thick=3.
  endfor

	;plot the noise levels
  plot,findgen(numb),noises,xrange=[0,numb],yrange=[0,max(noises)+50],ystyle=1,$
        xstyle=1,title=date+' '+rad+'  Noise Levels',$
        xtitle='integration period',ytitle='Noise level',charthick=3.,thick=3.,$
        xticklen=-.01,yticklen=-.01

	;plot the number of averages
  plot,findgen(numb),nave,xrange=[0,numb],yrange=[0,max(nave)+50],ystyle=1,$
        xstyle=1,title=date+' '+rad+'  Number of averages',$
        xtitle='integration period',ytitle='Nave',charthick=3.,thick=3.,$
        xticklen=-.01,yticklen=-.01

  device,/close

  spawn,'rm ~/errlog.'+rad+'.'+date

end