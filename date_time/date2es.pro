;+
; NAME:
;   date2es
;
; PURPOSE:
;   Function to convert a standard calendar date into ephemeris seconds before
;   or after J2000.  Similar to Ephemeris Time/TDT, but disregards leap seconds
;   introduced in 1972.
;
; CALLING SEQUENCE:
;   es = date2es(month,day,year)
;     OR
;   es = date2es(month,day,year,hour,minute,second)
;
; INPUTS:
;   month, day, year: desired month, day, and year to convert
;      (MM,    DD,  YYYY)
;
;   Note that arrays are permitted, provided they're all the same length
;
; OPTIONAL INPUTS:
;   hour, minute, second: if included, the desired hour, minute, and second
;     of the specified day
;
; OUTPUTS:
;   es: The number of ephemeris seconds with respect to J2000, January 1,
;     2000 12:00:00, stored as a long integer.  An array of times are
;     returned if an array is used as input.
;
;   returns -1 if an error has occurred
;
; EXAMPLE:
;   ; Get the number of ephemeris seconds at 10/15/1987, 14:05:00 UTC
;   es = date2es(10,15,1987,14,05,00)
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
; RESTRICTIONS / NOTES:
;   This routine is a quick replacement for the SPICE library function
;   STR2ET.  Another routine, date2et is available that does take leap
;   seconds into account.
;
;   Note that this routine does not check for out-of-range input errors,
;   so unpredictable results may occur (GIGO).
;
;   Also note that this routine needs to be tested for complete accuracy
;   for use with Ryan Boller's CXFORM package.
;
;       For more info, see page 4 of
;     http://www.sp.ph.ic.ac.uk/~nach/PSG/joyce_venice.pdf
;
; MODIFICATION HISTORY:
;   2003/09/22: Ryan Boller (Ryan.A.Boller@nasa.gov) - Initial version
;   2003/09/25: Ryan Boller - Added array input capability
;   2004/01/16: Ryan Boller - Updated documentation to include differences
;          between ET & ES
;
;-

function date2es, mon, day, year, hr, minute, sec
    ; Check for correct number of input parameters
    if ((n_params() ne 3) and (n_params() ne 6)) then begin
       print, "Incorrect number of parameters.  Usage:"
       print, "     et = date2es(month,day,year)"
       print, "              or"
       print, "     et = date2es(month,day,year,hour,minute,second)"
       return, -1
    endif

    ; Get number of input elements
    nElem = n_elements(year)

    ; Initialize hr/min/sec if none provided
    if (n_elements(hr) lt 1) then begin
       hr =  lonarr(nElem)
       minute = lonarr(nElem)
       sec = lonarr(nElem)
    endif

    ; Check preconditions
    if ((n_elements(mon) ne n_elements(day))  or  $
        (n_elements(mon) ne n_elements(year)) or  $
        (n_elements(mon) ne n_elements(hr))   or  $
        (n_elements(mon) ne n_elements(minute))  or  $
            (n_elements(mon) ne n_elements(sec))) then begin
       print, "Error:  All input arrays must have the same length"
       return, -1
    endif

    ; Allocate arrays
    JD =    dblarr(nElem, /NOZERO)
    secFromJ2000 =     lonarr(nElem, /NOZERO)
    ;DELTA_AT =     lonarr(nElem, /NOZERO)
    ;TAI =      lonarr(nElem, /NOZERO)
    ;TDT =      lonarr(nElem, /NOZERO)

    ; Get Julian Day
;    for i=0, (nElem-1) do begin
;       JD[i] = DOUBLE(Julday(mon[i],day[i],year[i],0,0,0))
       JD = Julday(mon,day,year,0,0,0)
;    endfor

    ; Add in hours and seconds separately, as Julday is imprecise
    JD[*] = JD[*] + hr[*]/24d + minute[*]/1440d + sec[*]/86400d


    ; Calculate # seconds from J2000 relative to given time in UTC
    secFromJ2000[*] = ROUND((JD[*] - 2451545l) * 86400l)


    ; Return a scalar (secFromJ2000[0]) if scalar arguments were provided
    if (n_elements(secFromJ2000) eq 1) then return, secFromJ2000[0]   $
    else return, secFromJ2000

END
