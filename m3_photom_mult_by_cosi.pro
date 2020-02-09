pro m3_photom_mult_by_cosi, event, infile, obs_file, outfile, to_topo=to_topo, r_fid=r_fid
;
;  PURPOSE: Convert ARFL Back to I/F so it can be used with existing photometry code
;
;           Because ARFL=(I/F)/cos(i), this routine just does ARFL*cos(i) = I/F
;
;  TO_TOPO Keyword:  Set this to use the "Facet Cos(i)" band in the obs file rather than 
;                    the "To-sun Zenith" band.
;
;------------------------------------------------------------------------------------------
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
;  check for inputs
;
if n_elements(infile) eq 0 then message, 'Must supply an input file.'
if n_elements(obs_file) eq 0 then message, 'Must supply an OBS file.'
if n_elements(outfile) eq 0 then message, 'Must supply an output file.'
;
;  open and query input file
;
envi_open_file, infile, r_fid=fid, /no_realize, /no_interactive_query
if fid eq -1 then begin
  envi_error, 'input file did not open.'
  return
endif
envi_file_query, fid, ns=ns, nl=nl, nb=nb, data_type=dt, wl=wl, bnames=bnames, $
  xstart=xstart, ystart=ystart
map_info=envi_get_map_info(fid=fid)
envi_file_mng, id=fid, /remove
;
;  open all three files and assoc to input and obs files
;
openr, inlun, infile, /get_lun
in_bil=assoc(inlun, make_array(ns,nb, type=dt))
openr, obslun, obs_file, /get_lun
obs_bil=assoc(obslun, fltarr(ns,10))
openw, outlun, outfile, /get_lun
;
;  loop over each line, do the multiplication and write to output file
;
for i=0,nl-1 do begin
  ;
  in_tile=in_bil[i]
  obs_tile=obs_bil[i]
  ;
  ;  get cosi, rebin it to the size of a tile
  ;
  if keyword_set(to_topo) then cosi_line=obs_tile[*,9] else cosi_line=cos(obs_tile[*,1]*!dtor)
  cosi_tile=rebin(cosi_line, ns, nb)
  ;
  ;  do the multiplication
  ;
  out_tile=in_tile*cosi_tile
  ;
  ;  write to output file
  ;
  writeu, outlun, out_tile
  ;
endfor
;
;  close all the files
;
free_lun, inlun, obslun, outlun
;
;  set up output file envi header
;
envi_setup_head, fname=outfile, ns=ns, nl=nl, nb=nb, data_type=dt, interleave=1, offset=0, $
  wl=wl, bnames=bnames, xstart=xstart, ystart=ystart, map_info=map_info, /write
if arg_present(r_fid) then envi_open_file, outfile, r_fid=r_fid
;
end

  