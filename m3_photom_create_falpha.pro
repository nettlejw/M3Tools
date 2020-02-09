pro m3_photom_create_falpha, rdn_file, ls_band_file, out_file, r_fid=r_fid
;
;  PURPOSE:  Does the band math that produces an f(alpha) cube given an I/F file
;            and a file containing an image of lommel-seeliger factors
;
;----------------------------------------------------------------------------------------
compile_opt strictarr
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF
;
; handle inputs
;
if n_elements(rdn_file) eq 0 then message, 'Must supply a RDN file.'
if n_elements(ls_band_file) eq 0 then message, 'Must supply an LS file.'
if n_elements(out_file) eq 0 then message, 'Must specify an output file name.'
;
; query RDN file
;
print, 'using: ', rdn_file
envi_open_file, rdn_file, r_fid=rdn_fid
envi_file_query, rdn_fid, ns=ns, nl=nl, nb=nb, wl=wl, data_type=rdn_dt
map_info=envi_get_map_info(fid=rdn_fid)
rdn_pos=indgen(nb)
dims=[-1,0,ns-1,0,nl-1]
envi_file_mng, id=rdn_fid, /remove
;
;  query OBS file
;
envi_open_file, ls_band_file, r_fid=ls_fid
envi_file_query, ls_fid, data_type=ls_dt
envi_file_mng, id=ls_fid, /remove
;
; assoc to the files
;
openr, rdn_lun, rdn_file, /get_lun
rdn_assoc=assoc(rdn_lun, make_array(ns, nb, type=rdn_dt))
openr, ls_lun, ls_band_file, /get_lun
ls_assoc=assoc(ls_lun, make_array(ns, type=ls_dt))
;
; open output file
;
openw, out_lun, out_file, /get_lun
;
; set up progress report
;
rstr=['Dividing out Lommel-Seeliger band','output file: ' + file_basename(out_file)]
envi_report_init, rstr, title='M3 Photometry', base=rbase
envi_report_inc, rbase, nl
;
;  loop over number of lines
;
for i = 0, nl - 1 do begin
  ;
  ;  update progress bar
  ;
  envi_report_stat, rbase, i, nl
  ;
  ;  get a tile/line of input data
  ;
  rdn_tile=double(rdn_assoc[i])
  ls_line=ls_assoc[i]
  ;
  ;  reform the ls line to size of a tile
  ;
  ls_tile=rebin(ls_line, ns, nb)
  ;
  ;  do the division, write to file
  ;
  out_tile=rdn_tile/ls_tile
  writeu, out_lun, out_tile 
  ; 
endfor
;
; get rid of progress bar
;
envi_report_init, base=rbase, /finish
;
;  close files
;
free_lun, rdn_lun
free_lun, ls_lun
free_lun, out_lun
;
; set up output header
;
bnames='F(alpha) Band '+strtrim(rdn_pos+1,2)
envi_setup_head, fname=out_file, ns=ns, nl=nl, nb=nb, data_type=5, interleave=1, offset=0, $
  wl=wl, bnames=bnames, map_info=map_info, /write  
;
end

 