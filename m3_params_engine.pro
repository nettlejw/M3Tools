pro m3_params_engine, infile, dims, outfile, params_list, r_fid=r_fid
;
;  PURPOSE:  Sets up a loop that calculates a supplied list of parameters.
;
;  INPUTS:  (All of these are required)
;
;     INFILE:  Full path to the input data - should normally be reflectance
;     
;     DIMS:    Standard ENVI dims array for the input data
;
;     OUTFILE:  Full path to where output data should be written
;
;     PARAMS_LIST:  String array containing the parameters to calculate.  Should be in the same
;                   format that the function call needs (ex.  'm3_params_ibd2000')
;
;  OUTPUTS:
;  
;  R_FID:  Fid of output file
;---------------------------------------------------------------------------------------------------------
compile_opt strictarr
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  if (n_elements(report_base) ne 0) then begin
       envi_report_init, base = report_base, /finish
  endif
  return
ENDIF  
;
;  simple input checks
;
if n_elements(infile) eq 0 then message, 'Must supply an input file.'
if n_elements(outfile) eq 0 then message, 'Must supply an output file.'
if n_elements(params_list) eq 0 then message, 'Must supply a list of parameters to calculate.'
if n_elements(dims) eq 0 then message, 'Must supply a DIMS array'
np = n_elements(params_list)
;
;  open input file
;
envi_open_file, infile, r_fid=infid
if infid eq -1 then message, infile + string(9b) + 'is invalid.'
;
;  get input file info
;
envi_file_query, infid, wl=wl, data_type=dt, nb=nb_input
pos = lindgen(nb_input)
descrip = 'M3 parameters cube for ' + file_basename(infile)
;
;  check for number of wavelengths in order to prevent inputting target data for now
;
if (n_elements(pos) ne 85) then $
   message, 'At this time you must select 85-channel GLOBAL data as input to the parameters code.'  
;
;  fail if no wavelength info
;
if (wl[0] eq -1) then message, 'Input file does not have associated wavelength information in its header.'
;
;  handle any subsetting
;
ns = dims[2] - dims[1] + 1
nl = dims[4] - dims[3] + 1
;
;  get ready for loop - open output file and set up report string
;
openw, lun, outfile, /get_lun
report_string = 'Output file: ' + file_basename(outfile)
;
;  Set up tiling, using BIL interleave (samples, bands, lines)
;
tile_id = envi_init_tile(infid, pos, num_tiles = num_tiles,interleave = 1, $
             xs = dims[1], xe=dims[2], ys = dims[3], ye = dims[4])
envi_report_init, report_string, base = report_base, title = 'Processing Parameters...', /interupt
envi_report_inc, report_base, num_tiles
;
;  now loop over tiles
;
for i = 0L, num_tiles -1 do begin
  ;
  ;  status counter
  ;
  envi_report_stat, report_base, i, num_tiles, cancel=cancel
  ;
  ;  handle the cancel button
  ;
  if (cancel) then begin
    envi_report_init, base = report_base, /finish
    free_lun, lun
    return
  endif
  ;
  ;  set up output tile
  ;
  out_tile = fltarr(ns, np) 
  ;
  ;  get an input tile
  ;
  tile_data = envi_get_tile(tile_id, i) ;[ns, nb_input]
  ;
  ;  get zmask
  ;
  zmask=m3_params_get_zmask(tile_data, wl)
  ;
  ;  loop that calls all the selected parameters
  ;
  for j = 0, np - 1 do  out_tile[*,j] = call_function(params_list[j], tile_data, wl, zmask=zmask)
  ;
  ; write the output tile
  ;
  writeu, lun, out_tile
  ;
endfor ;end tile loop
;
;  tile cleanup
;
envi_tile_done, tile_id
envi_report_init, base = report_base, /finish
;
;  set up band names
;
bnames = strarr(np)
for i = 0, np - 1 do bnames[i] = strupcase(strmid(params_list[i] ,10, strlen(params_list[i])-1))
;
;  close output file and set up header
;
free_lun, lun
envi_setup_head, fname=outfile, ns=ns, nl=nl, nb=np, interleave = 1, $
     data_type = 4, offset = 0, bnames = bnames, descrip = descrip, /write
envi_open_file, outfile, r_fid=r_fid
;
end