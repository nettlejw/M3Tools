pro m3_photom_i_over_f, event, infile, obsfile, outfile, r_fid=r_fid, flag=flag, sd=sd
;
;  Calculates I/F as:
;  
;  I/F = (radiance * pi)/solar_spectrum
;
;  where solar_spectrum is divided by moon-sun distance (in AU) squared.
;
;---------------------------------------------------------
compile_opt strictarr
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  help, ns, nl, nb
  ok = m3_error_message()
  return
ENDIF
;
;  set a flag for failure or success of this routine
;
flag=0
;
;  Get input file
;
if n_elements(infile) eq 1 then begin
   envi_open_file, infile, r_fid=rad_fid
  endif else begin
   envi_select, fid=rad_fid, title='Select Radiance File', /no_spec, /no_dims, /file_only
endelse  
if rad_fid eq -1 then return
envi_file_query, rad_fid, ns=ns, nl=nl, nb=nb, data_type=dt, wl=wl, xstart=xstart, $
  ystart=ystart, fname=infile
rad_pos = lindgen(nb)
inherit=envi_set_inheritance(rad_fid, [-1L,0,ns-1,0,nl-1], /spatial)
;
;  get output file if not passed in
;
if n_elements(outfile) eq 0 then begin
  tlb = widget_auto_base(title = 'M3 Level 2')
  ofw = widget_outf(tlb, uvalue='outf', func='m3_file_test', /auto)
  result = auto_wid_mng(tlb)
  if result.accept eq 0 then return
  outfile = result.outf
endif
;
; is the input file global or target?
;
case m3_get_imaging_mode(infile) of
  'T':mode='target'
  'G':mode='global'
   else: message, 'Could not determine if input data is global or target data.'
endcase
;
;  open the solar spectrum
;
solar_spec_file = filepath(root_dir=m3_programrootdir(), subdir = ['resources', 'level2'], $
    'solar_spectrum_' + mode + '.sli')
envi_open_file, solar_spec_file, r_fid=ss_fid, /no_realize
envi_file_query, ss_fid, ns=ns_ss, nl=nl_ss, nb=nb_ss, wl=wl_ss, spec_names=ss_name
nb=n_elements(wl_ss)
;
;  read the solar spectrum, reform to the size of a BIL tile
;
sli_dims = [-1,0,ns_ss - 1,0,nl_ss - 1]
solar_spectrum = double(rebin(transpose(envi_get_data(fid=ss_fid, dims=sli_dims, pos=0)), ns, nb))
envi_file_mng, id=ss_fid, /remove
;
;  determine solar distance if not passed in
;
if n_elements(sd) eq 0 then begin
  ;
  ;  Try to find the OBS file
  ;
  if n_elements(obsfile) eq 1 then begin
    envi_open_file, obsfile, r_fid=obs_fid
   endif else begin
    indir = file_dirname(infile, /mark_directory)
    complete_basename = file_basename(infile, '.IMG')
    basename = strmid(complete_basename, 0, strpos(complete_basename, "_", /reverse_search) + 1)
    obsfile_test = indir + basename + 'OBS.IMG'
    if file_test(obsfile_test) then begin
      obsfile = obsfile_test
      envi_open_file, obsfile, r_fid=obs_fid 
    endif else begin
      title='Select OBS File (OR CANCEL TO USE 1AU FOR SOLAR DISTANCE)'
      envi_select, fid=obs_fid, title=title, /no_spec, /no_dims, /file_only
    endelse
  endelse   
  if obs_fid eq -1 then solar_distance_squared=1.0d 
  ;
  ;  get the solar distance from the band name of the solar distance band in the OBS file,
  ;  convert it to double, then square it
  ;
  if obs_fid gt 0 then begin
    envi_file_query, obs_fid, bnames=obs_bnames
    pos=5 ;where(stregex(obs_bnames, 'To-Sun Path Length', /boolean),count)
    ;if count eq 0 then message, 'Did not find the To-Sun Path Length band'
    idx=stregex(obs_bnames[pos], '\(au-(.+)\)', length=len, /subexpr)
    solar_distance_squared=double((STRMID(obs_bnames[pos], idx, len))[1])^2  ;square sd here
    if solar_distance_squared eq 0 then begin
      msg='Solar distance not found.  Use 1.0 AU?'
      yesno=dialog_message(msg, /question)
      if yesno eq 'Yes' then solar_distance_squared = 1.0d else return
    endif
  endif
endif else solar_distance_squared=double(sd)  
;
;  divide out the solar distance from the solar spectrum tile
;
sd_norm_ss = solar_spectrum/solar_distance_squared
;
;  set up progress bar
;
rstr = ['Processing input file: ' + file_basename(infile), 'This may take several minutes...']
envi_report_init, rstr, title="M3 I/F", base=repbase, /interupt
;
;  open output file and setup tiling
;
rad_tile=envi_init_tile(rad_fid, rad_pos, num_tiles=num_tiles, interleave=1) ; BIL tiles
envi_report_inc, repbase, num_tiles
openw, lun, outfile, /get_lun
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
  ; get radiance tile
  ;
  radiance = double(envi_get_tile(rad_tile, i))
  ;
  ;  calculate I/F - now with PI!
  ;
  i_over_f = (radiance*!dpi)/sd_norm_ss
  ;
  ;  convert to float and write to file
  ;
  writeu, lun, float(i_over_f)
  ;
endfor
;
;  tiling clean up
;
envi_tile_done, rad_tile
envi_report_init, base=repbase, /finish
;
;  close file, setup envi header
;
free_lun,lun
descrip='M3 I/F Cube'
bnames='I/F Band ' + strtrim(indgen(nb) + 1,2)
envi_setup_head, fname=outfile, ns=ns, nl=nl, nb=nb, offset=0, interleave=1, $
  data_type=4, inherit=inherit, descrip=descrip, wl=wl_ss, xstart=xstart, $
  ystart=ystart, bnames=bnames, /write
envi_open_file, outfile, r_fid=r_fid
;
; add reflectance version and solar spectrum version to envi header
;
envi_assign_header_value, fid=r_fid, keyword='m3_IoverF', value='A'
envi_assign_header_value, fid=r_fid, keyword='m3_solar_spectrum_used', value=ss_name
;
;  close all the files
;
envi_file_mng, id=rad_fid, /remove
envi_file_mng, id=obs_fid, /remove
envi_file_mng, id=r_fid, /remove
;
; set flag to success
;
flag=1
;
end