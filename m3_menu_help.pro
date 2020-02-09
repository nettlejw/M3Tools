pro m3_menu_help, buttonInfo, base_ref, mainposn, subteams
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
mainval = 'Help'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value = mainval, $
  ref_value = base_ref, position = *mainposn, /menu, /separator
  ; 
  posn = 0
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Help on M3 Tools', $
    ref_value=mainval, position=posn, event_pro='m3_help', $
    uvalue='m3tools_main_help'
  ;
  posn = posn + 1
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='About M3 Tools', $
    ref_value=mainval, position=posn, event_pro='m3_help_about', $
    uvalue='not used'
;     
end     