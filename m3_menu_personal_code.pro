pro m3_menu_personal_code, buttonInfo, base_ref, mainposn, subteams
compile_opt strictarr, hidden
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
;  set up a branch coming off the main M3 Tools menu for the routines that are found
;
MainVal = 'Run Personal Code...'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value=MainVal, $
  ref_value=base_ref, position=*mainposn, /menu, /separator
;
;  Get personal code directory
;
m3_prefs=obj_new('m3_prefs')
pcodedir=m3_prefs->get('local_code_dir')
m3_prefs->add_local_code_dir_to_path
;
;  get list of pro and sav files in that directory
;
pro_files = file_search(pcodedir + '*.pro', count = n_pro_files)
sav_files = file_search(pcodedir + '*.sav', count = n_sav_files)
;
;  now fill in the fly-out menu with pro files found
; 
if n_pro_files gt 0 then begin
  for i=0, n_pro_files - 1 do begin
    thispro = file_basename(pro_files[i], '.pro')
    parts = strsplit(thispro, '_', /extract)
    for j = 0, n_elements(parts) - 1 do begin
      first = strmid(parts[j],0,1)
      rest = strmid(parts[j],1,strlen(parts[j]))
      parts[j] = strupcase(first) + rest
    endfor
    name = strjoin(parts, ' ')
    ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value=name, $
      ref_value=MainVal, position=i, event_pro=thispro, uvalue='not used'
  endfor
endif
;
;  now add sav files
;
if n_sav_files gt 0 then begin
  for i=0, n_sav_files - 1 do begin
    thissav = file_basename(sav_files[i], '.sav')
    parts = strsplit(thissav, '_', /extract)
    for j = 0, n_elements(parts) - 1 do begin
      first = strmid(parts[j],0,1)
      rest = strmid(parts[j],1,strlen(parts[j]))
      parts[j] = strupcase(first) + rest
    endfor
    name = strjoin(parts, ' ')
    ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value=name, $
      ref_value=MainVal, position=i, event_pro=thissav, uvalue='not used'
  endfor
endif

;
;  open folder button
;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Open Personal Code Folder', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_personal_code_open', $
  uvalue='not used'
;
;  clean up objects
;
obj_destroy, m3_prefs
;
end