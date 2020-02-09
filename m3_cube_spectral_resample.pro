pro m3_cube_spectral_resample, infile, outfile
  ;
  ;PURPOSE:  This routine takes an input image cube that is at target spectral
  ;        	 resolution and resamples it down to global spectral resolution.
  ;          A channel averaging approach is used, which mimics the way the spacecraft
  ;          itself creates global resolution data.
  ;
  ;          This routine is intended to be called by the spectral parameters tiling routine,
  ;          and as such has to arguments, infile and outfile.  The routine can, of course,
  ;          be used for other purposes than the spectral parameters code.
  ;
  ;ARGUMENTS:
  ;
  ;          infile = string containing full path to an input file to be used.
  ;
  ;          outfile = string designating output file name (full path)
  ;
  ;          r_fid = output file ID, used to pass to spectral parameters routine
  ;
  ;MODIFICATION HISTORY
  ;          Written, 9/4/2008, Jeffrey Nettles, Brown University
  ;*****************************************************************************
  ;
;  indir = 'C:\Documents and Settings\jeffn\My Documents\M3 Docs\Example Data\20080602\L1B\'
;  infile = indir + 'M3T20080607T112000_V01_RDN.IMG'
;  outfile = indir + 'M3T20080607T112000_V01_RDN_RESAMPLED.IMG'
  ;
  ;  validate input and output arguments
  ;
  if n_elements(infile) eq 0 then $
       infile = dialog_pickfile(title = 'Select file to be resampled')
  if n_elements(outfile) eq 0 then $
       outfile = dialog_pickfile(title = 'Select output file name')
  ;
  ;  open input file and query the file
  ;
  envi_open_file, infile, r_fid = infid
  envi_file_query, infid, ns=ns, nl=nl, nb=nb, wl = inwl
  pos = indgen(nb)
  ;
  ;  read in m3 wavelength info
  ;
  m3_read_wl_info, twl=twl, fwhm=fwhm, global_mapping=global_mapping
  ;
  ;  1/21/10 - current target data does not have first four or very last original target channel
  ;
  twl=twl[4:258]
  fwhm=fwhm[4:258]
  global_mapping=global_mapping[4:258]
  ;
  ;  now proceed as before
  ;
  ngwl = n_elements(uniq(global_mapping, sort(global_mapping)))
  global_mapping = global_mapping - 1 ;convert channel nums to indices
  ntwl = n_elements(twl)
  gwl = fltarr(ngwl)
  ;
  ;  set up output file
  ;
  openw, lun, outfile, /get_lun
  report_string = 'Output file: ' + file_basename(outfile)
  ;
  ;  Set up tiling, using BIL interleave (samples, bands, lines)
  ;
  tile_id = envi_init_tile(infid, pos, num_tiles = num_tiles,interleave = 1)
  envi_report_init, report_string, base = report_base, title = 'Resampling input file...', /interupt
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
    out_tile = fltarr(ns, ngwl)
    ;
    ;  get an input tile
    ;
    tile_data = envi_get_tile(tile_id, i) ;[ns, twl]
    ;
    ;  loop over global wavelengths and interpolate
    ;
    for j = 0, ngwl - 1 do begin
      ;
      idx = where(global_mapping eq j, count)
      if count le 0 then message, 'iteration ' + strtrim(j,2) + 'did not find a global_mapping.'
      ;
      ;  get the data for this global wavelength
      ;
      mini_tile = tile_data[*,idx]
      out_tile[*,j] = total(mini_tile, 2)/count
      ;
      ;  create the gwl array
      ;
      if i eq 0 then gwl[j] = total(twl[idx])/count
      ;
    endfor
    ;
    ;  write the output tile
    ;
    writeu, lun, out_tile
    ;
  endfor ;end tile loop
  ;
  ; tile cleanup
  ;
  envi_tile_done, tile_id
  envi_report_init, base = report_base, /finish
  ;
  ; close output file and set up header
  ;
  free_lun, lun
  envi_setup_head, fname=outfile, ns=ns, nl=nl, nb=ngwl, interleave = 1, $
       wl = gwl, data_type = 4, offset = 0, descrip = descrip, /write, /open
  ;
end