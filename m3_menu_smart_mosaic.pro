pro m3_menu_smart_mosaic, buttonInfo, base_ref, mainposn
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
;
mainval = 'Smart Mosaic'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value = mainval, $
  ref_value = base_ref, position = *mainposn, /menu, /separator
  ; 
  posn = 0
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Build GLT', $
    ref_value=mainval, position=posn, event_pro='m3_smart_mosaic_built_glt', $
    uvalue='not used'
  ;
  posn = posn + 1
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Mosaic from GLT', $
    ref_value=mainval, position=posn, event_pro='m3_smart_mosaic_build_mosaic', $
    uvalue='not used'
  
  
    
end