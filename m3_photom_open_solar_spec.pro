pro m3_photom_open_solar_spec, event
;
;  Opens m3 solar spectrum, either in global, target, or full res mode, 
;  as specified by the input uvalue
;
;
;  standard compiler directive, forces you to use []'s to denote array subscripts
;
COMPILE_OPT strictarr
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
;  locate the directory where all the solar spectrum files should be kept
;
basedir = filepath('', root_dir=m3_programrootdir(), subdirectory = ['resources', 'level2'])
basename = 'solar_spectrum_'
;
;  get the uvalue so that we know which resolution is called for
;
widget_control, event.id, get_uvalue=res
;
;  build full path to spectral library file
;
sli = basedir + basename + res + '.sli'
;
;  open sli file and display library widget
;
envi_open_file, sli, r_fid=fid, /no_realize
spectra_view, fid
;
end