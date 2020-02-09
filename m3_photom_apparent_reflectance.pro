pro m3_photom_apparent_reflectance, event, infile, obsfile, outfile, r_fid=r_fid, to_topo=to_topo
;
;  Calculates apparent reflectance using the equation:
;  
;  ARFL = (Radiance * pi)/[ (solar_spec/solar_distance_squared) * cos(i) ]
;
;---------------------------------------------------------
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
     envi_select, fid=obs_fid, title='Select OBS File', /no_spec, /no_dims, /file_only
  endelse
endelse
if obs_fid eq -1 then return 
;
;  compare # samples in obs and rdn files, handle case where rdn is 304 samples and 
;  obs is 300.  M3 went to 304 usable samples as of Jan 2010 team meeting.
;
envi_file_query, obs_fid, ns=obs_ns, nl=obs_nl, bnames=obs_bnames
if obs_nl ne nl then message, 'OBS and RDN files have different numbers of lines.'


case ns of 
  300: begin
    ;
    if obs_ns eq 304 then begin
       ;
       ; trim obs to match radiance
       ;
       obs_good_samples=lindgen(ns)+m3_get_sample_flip_offset(rad_fid)
       ;
    endif else if obs_ns ne 300 then begin
      envi_error, 'RDN file has 300 samples but OBS file does not have 300 or 304.'
      return
    endif
    rdn_good_samples=lindgen(ns)
    obs_good_samples=lindgen(ns)  
    ;
  end
  ;   
  304: begin
    ;
    if obs_ns eq 300 then begin
      ;
      ; trim rdn to match obs
      ;
      ns=300
      rdn_good_samples=lindgen(ns)+m3_get_sample_flip_offset(rad_fid)
      obs_good_samples=lindgen(ns)
      ;
    endif else if obs_ns ne 304 then begin
      envi_error, 'RDN file has 304 samples but OBS does not have 300 or 304.'
      return
    endif else begin
      rdn_good_samples=lindgen(ns)
      obs_good_samples=lindgen(ns)
    endelse
    ;
  end
  ;    
  else: begin
    if ns ne obs_ns then begin
      envi_error, 'RDN and OBS files do not have the same #samples and it is not a 300/304 samples issue.'
      return
    endif
    rdn_good_samples=indgen(ns)
    obs_good_samples=indgen(ns)
  end
  ;  
endcase
;
;  get output file if not passed in
;
if n_elements(outfile) eq 0 then begin
  tlb = widget_auto_base(title = 'M3 Level 2')
  list=['Relative to Smooth Sphere (Old Backplanes)', 'Relative to Topography (New Backplanes)']
  wm = widget_menu(tlb, prompt='Calculate ARFL:', uvalue='sel', rows=2, list=list, /exclusiv, /auto)
  ofw = widget_outf(tlb, uvalue='outf', func='m3_file_test', /auto)
  result = auto_wid_mng(tlb)
  if result.accept eq 0 then return
  outfile = result.outf
  to_topo=result.sel
endif else to_topo=0  ;in batch mode will always use to-sphere for now
;
; is the input file global or target?
;
case m3_get_imaging_mode(infile) of
  'T':mode='target'
  'G':mode='global'
   else: message, 'Could not determine if input data is global or target data.'
endcase
;
;  display the status bar here so the user will know something's happening
;
rstr = ['Processing input file: ' + file_basename(infile), 'This may take several minutes...']
envi_report_init, rstr, title="M3 Apparent Reflectance", base=repbase, /interupt
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
;  get the solar distance from the band name of the solar distance band in the OBS file,
;  convert it to double, then square it
;
;pos=where(stregex(obs_bnames, 'To-Sun Path Length', /boolean),count)
;if count eq 0 then message, 'Did not find the To-Sun Path Length band'
pos=5
idx=stregex(obs_bnames[pos], '\(au-(.+)\)', length=len, /subexpr)
solar_distance_squared=double((STRMID(obs_bnames[pos], idx, len))[1])^2  ;square sd here
if solar_distance_squared eq 0 then begin
  msg='Solar distance not found.  Use 1.0 AU?'
  yesno=dialog_message(msg, /question)
  if yesno eq 'Yes' then solar_distance_squared = 1.0d else return
endif
;
;  divide out the solar distance from the solar spectrum tile
;
sd_norm_ss = solar_spectrum/solar_distance_squared
;
;  set the band to get incidence angle from
;
i_pos=([1,9])[to_topo] ;1=to-sun zenith, 9 is cos(i) (0-based)
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
  radiance=radiance[rdn_good_samples,*]
  ;
  ;  get cos(i)
  ;
  i_line = double(envi_get_slice(fid=obs_fid, pos=i_pos, line=i))
  i_line=i_line[obs_good_samples,*]
  cos_i = rebin(i_line,ns,nb)
  if to_topo eq 0 then cos_i = cos(cos_i * !dpi/180)
  ;
  ;  calculate Apparent Reflectance
  ;
  arfl = (radiance * !dpi)/(sd_norm_ss * cos_i)
  ;
  ;  convert to float and write to file
  ;
  writeu, lun, float(arfl)
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
descrip='M3 Apparent Reflectance'
bnames='ARFL Band ' + strtrim(indgen(nb) + 1,2)
envi_setup_head, fname=outfile, ns=ns, nl=nl, nb=nb, offset=0, interleave=1, $
  data_type=4, inherit=inherit, descrip=descrip, wl=wl_ss, xstart=xstart, $
  ystart=ystart, bnames=bnames, /write
envi_open_file, outfile, r_fid=r_fid
;
; add reflectance version and solar spectrum version to envi header
;
envi_assign_header_value, fid=r_fid, keyword='m3_reflectance_version', value='A'
envi_assign_header_value, fid=r_fid, keyword='m3_solar_spectrum_used', value=ss_name
envi_write_file_header, r_fid
;
end