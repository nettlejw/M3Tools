function m3_get_sample_flip_offset, rdn_fid, flip_code=flip_code
;
;  PURPOSE:  For images with 304 samples that need to be trimmed to 300, this utility function
;            makes sure the trimming is done correctly by returning the appropriate offset to
;            use to subset the number of samples
;
;            case flip_code of 
;              1: print, 'No flipping'
;              2: print, 'Flip samples'
;              3: print, 'Flip lines'
;              4: print, 'Flip lines and samples'
;              else: print, 'flip error'
;            endcase
;----------------------------------------------------------------------------------------------
compile_opt strictarr
on_error, 2  ;return to calling program on error
;
;  make sure we got a fid for the radiance file
;
if n_elements(rdn_fid) eq 0 then message, 'Must supply a radiance FID.'
if rdn_fid le 0 then message, 'Radiance FID is invalid.'
;
; get the flip code
;
op_offset=-1
flip_code=envi_get_header_value(rdn_fid, 'Flip', /fix)
flip_code=flip_code[0] ;in case the header returns an array somehow
;
; if we didn't have a valid flip code then we'll use the dates of the file name
;
if flip_code lt 1 or flip_code gt 4 then begin
  ;
  ;  get the m3 name, fail if it's not m3-style
  ;
  envi_file_query, rdn_fid, fname=fname
  bn=strmid(file_basename(fname),0,18)
  if stregex(bn, '^M3(G|T)200', /boolean) eq 1 then begin
    ;
    ;  convert name to julian date
    ;
    year=double(strmid(bn,3,4))
    month=double(strmid(bn,7,2))
    day=double(strmid(bn,9,2))
    hour=double(strmid(bn,12,2))
    minute=double(strmid(bn,14,2))
    second=double(strmid(bn,16,2))
    bn_jul=julday(month,day,year,hour,minute,second)
    ;
    ;  set flip code 
    ;
    op1_jul=julday(11,16,2008,23,59,59.817219d)
    op2_jul=julday(12,18,2008,4,7,59.816462d)
    op3_jul=julday(3,15,2009,14,9,59.814432d)
    op4_jul=julday(6,18,2009,1,59,59.815533d)
    op_dates=[op1_jul, op2_jul, op3_jul, op4_jul]
    flip_code=value_locate(op_dates, bn_jul)+1
    ;
  endif else begin
    envi_error, ['Sample offset cannot be determined', 'because flip code is not in header', $
                 'and file name does not follow M3 convention']
    return, -1
  endelse
  ;
endif
;
;  now figure the offset and return it
;
op_offset= 1 + (flip_code mod 2 eq 0)*2
return, op_offset
;
end