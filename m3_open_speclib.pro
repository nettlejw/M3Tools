pro m3_open_speclib, event
compile_opt strictarr
;
;  lets you open a spectral library from the m3tools spectral library directory
;
;----------------------------------------------------------------------------------------------------
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
;load the preference object - always use jnettles as author and m3tools as application
;
prefs = obj_new('m3_prefs')
speclibpref = prefs->get('speclibdir')
;
;  set the path to look in based on whether or not preference is set
;
if file_test(speclibpref, /directory) then path=speclibpref $
  else path = filepath('', root=m3_programrootdir(), subdir = ['resources', 'spectral_libraries'])
;
;  let user choose libraries to open
;  
files = dialog_pickfile(title = 'Select Spectral Libraries', path=path, /multiple_files, /must_exist)
if files[0] eq '' then return
;
;  now open them
;
nfiles = n_elements(files)
for i = 0, nfiles - 1 do begin
  envi_open_file, files[i], r_fid=fid, /no_realize
  if fid ne -1 then spectra_view, fid else Message, files[i] + ' could not be opened.'
endfor
;
;  clean up preferences
;
obj_destroy, prefs
;
end