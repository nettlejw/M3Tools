pro m3_utils_304_to_300_samples, event, infile, outfile, r_fid=r_fid
;
; PURPOSE:  Temporary utility that trims 304 to 300 samples based on flip code and/or file
;           date
;
;----------------------------------------------------------------------------------------------
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
;  get input file, query it
;
if n_elements(infile) eq 0 then begin
  envi_select, fid=fid, /file_only, title='Pick file to trim:', /no_spec, /no_dims
  batch=0
endif else begin
  envi_open_file, infile, r_fid=fid, /no_realize, /no_interactive_query
  batch=1
endelse
if fid eq -1 then return
envi_file_query, fid, ns=ns, nl=nl, nb=nb, wl=wl, bnames=bnames, data_type=dt, $
  descrip=descrip, xstart=xstart,ystart=ystart, fname=fname
dims=[-1,0,ns-1,0,nl-1]
pos=lindgen(nb)
map_info=envi_get_map_info(fid=fid)
;
; fail if not 304 samples
;
if ns ne 304 then begin
  ok=dialog_message('The input image has '+strtrim(ns,2)+' samples, not 304.', /error)
  return
endif
;
;  get output file
;
if n_elements(outfile) eq 0 then begin
  tlb = widget_auto_base(title = 'M3 Tools')
  ofw = widget_outf(tlb, uvalue='outf', func='m3_file_test', /auto)
  result = auto_wid_mng(tlb)
  if result.accept eq 0 then return
  outfile = result.outf
endif
;
;  get the sample offset to use in trimming
;
op_offset=m3_get_sample_flip_offset(fid, flip_code=flip_code)
xstart=xstart+op_offset
keep=indgen(300)+op_offset
;
; open output file
;
openw, lun, outfile, /get_lun
;
;  set up progress bar
;
rstr=strarr(5,4)
rstr[0,0]='Mode 1: descending forwards'
rstr[1,0]='no sample flip'
rstr[2,0]='no line flop'
rstr[3,0]='1 global sample offset narrow to wide'
rstr[4,0]='start 2008 NOV 16 23:59:59.817219'
;
rstr[0,1]='Mode 2: descending backwards'
rstr[1,1]='yes sample flip'
rstr[2,1]='no line flop'
rstr[3,1]='3 global sample offset narrow to wide'
rstr[4,1]='start 2008 DEC 18 04:07:59.816462'
;
rstr[0,2]='Mode 3: ascending backwards'
rstr[1,2]='no sample flip'
rstr[2,2]='yes line flop'
rstr[3,2]='1 global sample offset narrow to wide'
rstr[4,2]='start 2009 MAR 15 14:09:59.814432'
;
rstr[0,3]='Mode 4: ascending forwards'
rstr[1,3]='yes sample flip'
rstr[2,3]='yes line flop'
rstr[3,3]='3 global sample offset narrow to wide'
rstr[4,3]='start 2009 JUN 18 01:59:59.815533'
;
rstr=[file_basename(fname), rstr[*,flip_code-1]]
envi_report_init, rstr, title="M3 Tools", base=repbase, /interupt
;
;  init tiles
;
tile_id=envi_init_tile(fid, pos, num_tiles=num_tiles, interleave=1) ; BIL tiles
envi_report_inc, repbase, num_tiles
;
;  tile loop
;
for i = 0L, num_tiles-1 do begin
  envi_report_stat, repbase, i, num_tiles, cancel = cancel
  if cancel then begin
    envi_report_init, base=repbase, /finish
    return
  endif
  ;
  ; subset tile and write it back out
  ;
  tile = envi_get_tile(tile_id, i)
  out = tile[keep,*]
  writeu, lun, out
  ;
endfor
;
;  tiling clean up
;
envi_tile_done, tile_id
envi_report_init, base=repbase, /finish
;
;  close file, setup envi header
;
free_lun,lun
envi_setup_head, fname=outfile, ns=300, nl=nl, nb=nb, offset=0, interleave=1, $
  data_type=dt, map_info=map_info, descrip=descrip, wl=wl, xstart=xstart, $
  ystart=ystart, bnames=bnames, /write
if batch eq 0 then envi_open_file, outfile, r_fid=r_fid else envi_file_mng, id=fid,/remove  
;
end