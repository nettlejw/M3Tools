pro m3_photom_calculate_iea, event
;
;  calculates incidence and exitance and pulls phase from new backplanes 
;  (this is a wrapper for the code Joe wrote for us)
;
;-------------------------------------------------------------------------------------------
compile_opt strictarr
;
;  error handling
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF
;
; get input file (must be an OBS file)
;
envi_select, fid=fid, title='Select OBS file:', /no_spec, dims=dims, /file_only
if fid eq -1 then return
envi_file_query, fid, nb=nb
map_info=envi_get_map_info(fid=fid)
if nb ne 10 then begin
  envi_error, 'Input file must be a 10 band OBS file.'
  return
endif
pos=indgen(nb)
;
; output file
;
tlb = widget_auto_base(title = 'M3 Tools')
ofw = widget_outf(tlb, uvalue='outf', func='m3_file_test', /auto)
result = auto_wid_mng(tlb)
if result.accept eq 0 then return
outfile = result.outf
;
; figure image dimensions
;
ns=dims[2]-dims[1]+1
nl=dims[4]-dims[3]+1
;
; set up tiling
;
tile_id=envi_init_tile(fid, pos, num_tiles=num_tiles)
;
;  set up progress bar
;
rstr='Calculating i,e, and phase...'
envi_report_init, rstr, title='M3 Tools', base=progbar, /interrupt
envi_report_inc, progbar, num_tiles
;
;  open output file
;
openw, lun, outfile, /get_lun
;
;  tile loop
;
for i=0,num_tiles-1 do begin
  ;
  ;  update progress bar
  ;
  envi_report_stat, progbar, i, num_tiles, cancel=cancel
  if (cancel eq 1) then begin
    free_lun, lun
    envi_report_init, base=progbar, /finish
  endif
  ;
  ; calculate i,e,phase for each line
  ;
  in_tile=envi_get_tile(tile_id, i)
  out_tile=m3_photom_build_i_e_a_from_obs(in_tile)
  ;
  ;  write output to file
  ;
  writeu, lun, out_tile
  ;
endfor
;
; tile and progress bar cleanup
;
envi_tile_done, tile_id
envi_report_init, base=progbar, /finish    
;
;  close output file, set up header
;
free_lun, lun
envi_setup_head, fname=outfile, ns=ns, nl=nl, nb=3, data_type=5, interleave=1, offset=0, $
  bnames=['Incidence','Exitance','Phase'], map_info=map_info, /write, /open
;
end