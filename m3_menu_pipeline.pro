pro m3_menu_pipeline, buttonInfo, base_ref, mainposn, subteams
;
;  PURPOSE:  sets up a menu item for Brown's pipeline processing.  
;
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
;  set up a branch coming off the main M3 Tools menu
;
mainval = 'Pipeline Processing'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value=mainval, $
  ref_value = base_ref, position=*mainposn, /Menu, /separator   
  ;
  posn = 0
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value = 'Test', $
    ref_value = mainval, position = posn, event_pro = 'm3_menu_undefined', $
    uvalue = 'not used'
  ;  
end    