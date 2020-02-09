pro m3_resample_sli, event, infile=infile, gfile=gfile, tfile=tfile, no_open=no_open
   ;
   ;routine to resample spectral library files to m3 wavelengths
   ;
   ;standard compiler directive, forces you to use []'s to denote array subscripts
   ;
   COMPILE_OPT strictarr
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
   ; get input file
   ;
   if n_elements(infile) eq 0 then begin
       envi_select, title = 'Please select input spectral library', fid=fid, /no_dims, pos=pos
       if fid eq -1 then return
     endif else begin
       envi_open_file, infile, r_fid=fid
       envi_file_query, fid, nb=nb
       pos = lindgen(nb)
       if fid eq -1 then return
   endelse
   ;
   ; gather file info.  This call looks a little funny b/c a spectral library is really a single band
   ; image in terms of how it's stored on disk.  Spectra are stored in rows, so the number of columns
   ; is the number of bands in the spectra, etc.
   ;
   envi_file_query, fid, ns=nb, nl=nspec, data_type=dt, wl=wl, wavelength_unit=wu, $
     file_type=file_type, fname=fname, spec_names=spec_names, bnames=bnames
   dims = [-1, 0, nb -1, 0, nspec - 1]
   ;
   ;  if max(wl) lt 10, assume wl are in um and change to nm
   ;
   if max(wl) lt 10 then wl=wl*1000
   ;
   ;  Throw an error if input file is not a spectral library (as reflected in the header)
   ;
   if (file_type ne envi_file_type('ENVI Spectral Library')) then $
      Message, 'Input file must be of type ENVI Spectral Library'
   

   if ((n_elements(tfile) + n_elements(gfile)) ne 2) then begin
     ;set up output widget
     ;
     tlb = widget_auto_base(title = 'M3 Spectral Resampling')
     if n_elements(tfile) eq 0 then begin
       tof = widget_outf(tlb, prompt = 'Select Output file for target-resampled library', $
               func = 'm3_file_test', uvalue = 'tfile', /auto)
     endif       
     if n_elements(gfile) eq 0 then begin
       gof = widget_outf(tlb, prompt = 'Select Output file for global-resampled library', $
               func = 'm3_file_test', uvalue = 'gfile', /auto)
     endif         
     result = auto_wid_mng(tlb)
     if (result.accept eq 0) then return
     if n_elements(tfile) eq 0 then tfile=result.tfile
     if n_elements(gfile) eq 0 then gfile=result.gfile
   endif  
   ;
   ;  Read in M3's wavelength info - NOTE: Using global_mapping as returned by m3_read_wl_info
   ;  will still give you 86 channels - the first global channel is removed later in this program.
   ;
   m3_read_wl_info, twl=twl, tfwhm=tfwhm, global_mapping=global_mapping, check=gwl_check
   help, twl, tfwhm, global_mapping
   ;   
   ;
   ;*********** TARGET ***********************************************
   ;
   ; call the ENVI 'Doit' using units of nm (out_wavelength_units = 1)
   ;
   ENVI_DOIT, 'ENVI_SPECTRAL_RESAMPLING_DOIT', fid=fid, dims=dims, pos=pos, out_name=tfile, $
      out_fwhm=tfwhm, out_wl=twl, out_wavelength_units=1, r_fid=t_fid     
   ;
   ;*********** GLOBAL ***********************************************
   ;
    ;
    ;  read in the target spectral library to memory
    ;
    envi_file_query, t_fid, ns=ns_t, nl=nl_t, nb=nb_t
    t_dims = [-1,0,ns_t-1,0,nl_t-1]
    tsli = reform(envi_get_data(fid=t_fid, dims=t_dims, pos=0))
    help, tsli
    ;
    ngwl = n_elements(uniq(global_mapping, sort(global_mapping)))
    gsli = fltarr(ngwl,nl_t) 
    gwl = fltarr(ngwl)
    ;
    for j = 0, ngwl - 1 do begin
      ;
      idx = where(global_mapping eq j+1, count)
      if count le 0 then message, 'iteration ' + strtrim(j,2) + ' did not find a global_mapping.'
      ;
      ;  get the data for this global wavelength
      ;
      mini_tile = tsli[idx,*]
      help, mini_tile
      if nl_t eq 1 then gsli[j,*]=total(mini_tile)/count $
        else gsli[j,*]= transpose(total(mini_tile,1)/count)
      ;
      ;  create the gwl array
      ;
      gwl[j] = total(twl[idx])/count
      ;
    endfor
    ;
    ; remove the first global channel from sli and wl array
    ;
    gsli = gsli[1:n_elements(gwl)-1,*]
    gwl  = gwl[1:n_elements(gwl)-1]
    ngwl = n_elements(gwl)
    ;
    ;  make sure gwl matches what is expected
    ;
    threshold=0.01
    diffs=abs(gwl-gwl_check)
    errpos=where(diffs gt threshold, count)
    if count gt 0 then message, 'Calculated wavelengths do not match those expected.'
    ;
    ;  write global sli to disk and write header
    ;
    openw, lun, gfile, /get_lun
    writeu, lun, gsli
    free_lun, lun
    envi_setup_head, fname=gfile, ns=ngwl, nl=nl_t, nb=1, offset=0, data_type=4, spec_names = spec_names, $
       wl=gwl, wavelength_units = 1, interleave=0,file_type = envi_file_type('ENVI Spectral Library'), $
       bnames=bnames, /write, open=~keyword_set(no_open)
    if keyword_set(no_open) then envi_file_mng, id=t_fid, /remove    
    envi_file_mng, id=fid, /remove
    ;
end