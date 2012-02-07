;+
; NAME: 
; ASI_READ
;
; PURPOSE: 
; This procedure reads data from All-Sky-Imagers of the Themis chain.
; It calls the TDAS function THM_LOAD_ASI and puts the results in the 
; common block ASI_DATA_BLK.
; 
; CATEGORY: 
; All-Sky Imager
; 
; CALLING SEQUENCE:  
; Result = ASI_READ(Site)
;
; INPUTS:
; Date: A scalar or 2-element vector giving the time range to read, 
; in YYYYMMDD or MMMYYYY format.
;
; Site: The 4-letter abreviation of the site name.
;
; KEYWORD PARAMETERS:
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; CDF_DATA: Keyword for the THM_LOAD_ASI routine, see TDAS documentation for details.
;
; CURSOR: Keyword for the THM_LOAD_ASI routine, see TDAS documentation for details.
;
; DATATYPE: Keyword for the THM_LOAD_ASI routine, see TDAS documentation for details.
;
; FILES: Keyword for the THM_LOAD_ASI routine, see TDAS documentation for details.
;
; GET_SUPPORT_DATA: Keyword for the THM_LOAD_ASI routine, see TDAS documentation for details.
;
; LEVEL: Keyword for the THM_LOAD_ASI routine, see TDAS documentation for details.
;
; NO_DOWNLOAD: Keyword for the THM_LOAD_ASI routine, see TDAS documentation for details.
;
; PROGOBJ: Keyword for the THM_LOAD_ASI routine, see TDAS documentation for details.
;
; TRANGE: Keyword for the THM_LOAD_ASI routine, see TDAS documentation for details.
;
; VALID_NAMES: Keyword for the THM_LOAD_ASI routine, see TDAS documentation for details.
;
; VERBOSE: Keyword for the THM_LOAD_ASI routine, see TDAS documentation for details.
;
; EXAMPLE:
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
; Written by Lasse Clausen, Dec, 4 2009
;-
pro asi_read, date, site, time=time, long=long, $
	CDF_DATA=CDF_DATA, CURSOR=CURSOR, DATATYPE=DATATYPE, $
	FILES=FILES, GET_SUPPORT_DATA=GET_SUPPORT_DATA, $
	LEVEL=LEVEL, NO_DOWNLOAD=NO_DOWNLOAD, PROGOBJ=PROGOBJ, $
	TRANGE=TRANGE, VALID_NAMES=VALID_NAMES, VERBOSE=VERBOSE

common asi_data_blk

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
asi_info.nrecs = 0L

if n_params() ne 2 then begin
	prinfo, 'Must give date and site.'
	return
endif

if asi_check_loaded(date, site, time=time, long=long) then $
	return

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long

if ~keyword_set(trange) then $
	trange = ([sjul, fjul] - julday(1,1,1970,0))*86400.d

if ~keyword_set(datatype) then $
	datatype = 'asf'

thm_load_asi, site=site, trange=trange, datatype=datatype, $
	CURSOR=CURSOR, $
	FILES=FILES, GET_SUPPORT_DATA=GET_SUPPORT_DATA, $
	LEVEL=LEVEL, NO_DOWNLOAD=NO_DOWNLOAD, PROGOBJ=PROGOBJ, $
	VALID_NAMES=VALID_NAMES, VERBOSE=VERBOSE

thm_load_asi_cal, site, calstr, trange=trange

get_data, 'thg_'+datatype+'_'+site, asf_time, asf
dim = size(asf, /dim)
if dim[0] eq 0 then begin
	prinfo, 'No data loaded.'
	return
endif

tpnames = tnames('thg_'+datatype+'*')
store_data, tpnames, /delete

asi_data = { $
	juls: asf_time/86400.d + julday(1,1,1970,0), $
	images: asf $
}

asi_info.sjul = asi_data.juls[0]
asi_info.fjul = asi_data.juls[dim[0]-1L]
asi_info.site = site
asi_info.glat = asi_get_stat_pos(site, coords='geog', lon=glon)
asi_info.glon = glon
asi_info.mlat = asi_get_stat_pos(site, coords='magn', lon=mlon)
asi_info.mlon = mlon
asi_info.l_value = get_l_value([asi_info.mlat,asi_info.mlon,1.],coords='magn')
asi_info.width = dim[1]
asi_info.height = dim[2]
if ptr_valid(asi_info.cal_struc) then $
	ptr_free, asi_info.cal_struc
asi_info.cal_struc = ptr_new(calstr)
asi_info.datatype = datatype
asi_info.nrecs = dim[0]

end
