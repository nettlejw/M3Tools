pro m3_utils_add_datum_and_ellipse, event
;
;  purpose:  adds the appropriate lines for a lunar datum and ellipse to envi's
;            ellipse.txt and datum.txt files
;
;------------------------------------------------------------------------------------------------
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
;  fail if this is envi 4.7 or higher
;
version=float((strsplit(envi_query_version(), ' ', /extract))[0])
if version ge 4.7 then begin
  envi_error, 'Do not use this routine on ENVI 4.7+'
  return
endif
;
; get envi configuration structure
;
cfg=envi_get_configuration_values()
def_map_proj_file=cfg.DEFAULT_MAP_PROJECTION_FILE
;
;
;
if def_map_proj_file eq '' then begin
  ;
  ;  use envi's map_proj directory
  ;
  envi_dir=envi_get_path()
  if strmid(envi_dir, 0, 1, /reverse_offset) ne path_sep() then envi_dir=envi_dir+path_sep()
  map_proj_dir=envi_dir+'map_proj'+path_sep()
  datumf=map_proj_dir+'datum.txt'
  ellipsef=map_proj_dir+'ellipse.txt'
  ;
 endif else begin
  ;
  ;  use directory specified
  ;
  dir=file_dirname(def_map_proj_file, /mark_directory)
  datumf=dir+'datum.txt'
  ellipsef=dir+'ellipse.txt'
  ;
endelse   
;
; make sure files exist
;
if ~file_test(datumf) then begin
  envi_error, 'Datum.txt file could not be found.'
  return
endif
if ~file_test(ellipsef) then begin
  envi_error, 'Ellipse.txt file could not be found.'
  return
endif
;
;  make sure files exist and are writable
;
datum_write=(file_info(datumf)).write
ellipse_write=(file_info(ellipsef)).write
if datum_write+ellipse_write ne 2 then begin
  if datum_write eq 0 then print, datumf+' is not writable.'
  if ellipse_write eq 0 then print, ellipsef+' is not writable.'
  return
endif
;
;  ellipse.txt
;
added=0
ellipse_text='Moon Sphere 1737.4, 1737400.0, 1737400.0'
el=file_lines(ellipsef)
ellipse_lines=strarr(el)
openr, elun, ellipsef, /get_lun
readf, elun, ellipse_lines
free_lun, elun
exists=where(stregex(ellipse_lines, '^'+ellipse_text, /boolean) eq 1, count)
if count gt 0 then begin
  print, 'The correct line already exists in ' + ellipsef
endif else begin
  openw, elun, ellipsef, /get_lun, /append
  printf, elun, ellipse_text
  free_lun, elun
  print, 'Lunar ellipse added to ' + ellipsef
  added=1
endelse  
;
;  datum.txt
;
datum_text='Moon Sphere 1737.4, Moon Sphere 1737.4, 0, 0, 0'
dl=file_lines(datumf)
datum_lines=strarr(dl)
openr, dlun, datumf, /get_lun
readf, dlun, datum_lines
free_lun, dlun
exists=where(stregex(datum_lines, '^'+datum_text, /boolean) eq 1, count)
if count gt 0 then begin
  print, 'The correct line already exists in ' + datumf
 endif else begin
  openw, dlun, datumf, /get_lun, /append
  printf, dlun, datum_text
  free_lun, dlun
  print, 'Lunar datum added to ' + datumf
  added=1
endelse  
;

if added gt 0 then msg=['Datum.txt and Ellipse.txt files updated.',$
                         'Please restart ENVI for changes to take effect.'] $
  else msg=['Your files appear to already have an appropriate datum and ellipse.'] 
ok=dialog_message(msg, /information)
;
end