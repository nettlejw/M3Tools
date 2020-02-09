pro m3_menu_preferences, buttonInfo, base_ref, mainposn, subteams
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
mainval = 'Set Preferences'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value = 'Set Default Directories', ref_value = base_ref, $
  position = *mainposn, event_pro='m3_set_dir_prefs', uvalue='not used', /separator 
  ;
;  posn = posn + 1
;  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Set Menu Extensions', ref_value = mainval, $
;    position = posn, event_pro='m3_join_subteams', uvalue = 'not used'
;     
end     