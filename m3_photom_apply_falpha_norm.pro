pro m3_photom_apply_falpha_norm, falpha_file, norm_file, out_file, table_dir, r_fid=r_fid
;
;  PURPOSE:  Divides the f(alpha) normalization factor (in norm_file) out of the cube of 
;            f(alpha) curves (in falpha_file).  Output is BIL interleave.
;
;----------------------------------------------------------------------------------------------
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
;  error check inputs
;
if n_elements(falpha_file) eq 0 then message, 'must supply a cube of f(alpha) values.'
if n_elements(norm_file) eq 0 then message, 'must supply a cube of f(alpha) normalization curves.'
if n_elements(out_file) eq 0 then message, 'must specify an output file.'
;
; open input files
;
envi_open_file, falpha_file, r_fid=f_fid, /no_realize, /no_interactive_query
if f_fid[0] eq -1 then message, 'could not open '+falpha_file
envi_open_file, norm_file, r_fid=n_fid, /no_realize, /no_interactive_query
if n_fid[0] eq -1 then message, 'could not open '+norm_file
;
;  query files
;
envi_file_query, f_fid, ns=ns, nl=nl, nb=nb, wl=wl, data_type=dt, xstart=xstart, ystart=ystart
pos=indgen(nb)
inherit=envi_set_inheritance(f_fid, [-1,0,ns-1,0,nl-1], pos, /spatial)
envi_file_query, n_fid, ns=n_ns, nl=n_nl, nb=n_nb, wl=n_wl, data_type=n_dt
;if (n_ns ne ns) or (n_nl ne nl) or (n_nb ne nb) or (n_elements(n_wl) ne n_elements(wl)) or (n_dt ne dt) then $
;  message, 'The two input files do not have matching dimensions.'
;
;  the lommel seeliger part of the correction still needs to be normalized to 
;  i=30, e=0.  Do that here, at the very end so that you can look at individual files
;  (f(alpha) cubes, LS bands, etc. without them containing LS(30,0).
;
ls_norm=m3_photom_ls(30,0)
;
;  I/F is defined as having i=0, but we're correcting to the case where i=30, so we 
;  need to divide out cos(30) of I/F now.
;
cos30=cos(30.0d*!dpi/180)
;
;  set up tiles
;
t_id=envi_init_tile(f_fid, pos, interleave=1, num_tiles=num_tiles)
n_id=envi_init_tile(n_fid, pos, interleave=1, num_tiles=num_tiles2)
if (num_tiles2 ne num_tiles) then message, 'Tile sizes are different.'
;
; open output file
;
openw, lun, out_file, /get_lun
;
;  set up progress bar
;
rstr=['Last step:  F(alpha) normalization', 'Output to: ' + file_basename(out_file)]
envi_report_init, rstr, title='M3 Photometric Correction', base=rbase
envi_report_inc, rbase, num_tiles
;
; tile loop
;
for i = 0, num_tiles-1 do begin
  ;
  ;  update progress bar
  ;
  envi_report_stat, rbase, i, num_tiles
  ;
  ;  get tiles from both cubes
  ;
  t_tile=envi_get_tile(t_id, i)
  n_tile=envi_get_tile(n_id, i)
  ;
  ;  normalize alpha by multiplying by f(30)/f(alpha)
  ;
  out_tile=t_tile*n_tile
  ;
  ;  normalize i and e - multiply by LS(30,0) only (LS(i,e) divided out upstream)
  ;
  out_tile=out_tile*ls_norm
  ;
  ;  correct I/F to i=30
  ;
  out_tile=out_tile/cos30
  ;
  ;  write to output file
  ;
  if i eq 0 then out_dt=size(out_tile, /type)
  writeu, lun, out_tile
  ;
endfor
;
;  close tiles, output file, and progress bar
;
free_lun, lun
envi_tile_done, t_id
envi_tile_done, n_id
envi_report_init, base=rbase, /finish
;
;  put the name of the raw correction factor table in the header if found
;  (this is a *.dat file that is not actually used.  what is used in the correction are the 
;   .sli files in the same directory as the .dat file.  these are just the .dat file reformatted
;   as spectral libraries.  So the .dat file doesn't really have to be there, but if it is, this 
;   puts the name of it in the envi header)
;
descrip='M3 Photometrically Corrected Reflectance (Level 2 Version B)'
if n_elements(table_dir) eq 1 then begin
  ;dat_dir=filepath('', root_dir=m3_programrootdir(), subdir=['resources', 'photometry'])
  dat_dir=table_dir
  if strmid(dat_dir,0,1,/reverse_offset) ne path_sep() then dat_dir=dat_dir+path_sep()
  dat_file=file_search(dat_dir+'*.dat', count=n_dat)
  if n_dat eq 1 then descrip=[descrip, dat_file]
endif  
;
; set up envi header
;
bnames='M3 REFL BAND '+strtrim(pos+1,2)
envi_setup_head, fname=out_file, ns=ns, nl=nl, nb=nb, offset=0, interleave=1, $
  data_type=out_dt, inherit=inherit, descrip=descrip, wl=wl, xstart=xstart, $
  ystart=ystart, bnames=bnames, /write
envi_open_file, out_file, r_fid=r_fid
;
; add reflectance version and solar spectrum version to envi header
;
envi_assign_header_value, fid=r_fid, keyword='m3_reflectance_version', value='B'
;envi_assign_header_value, fid=r_fid, keyword='m3_solar_spectrum_used', value=ss_name

;
;  close input files
;
envi_file_mng, id=f_fid, /remove
envi_file_mng, id=n_fid, /remove  
;
end