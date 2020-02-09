pro m3_menu_analysis, buttonInfo, base_ref, mainposn, subteams
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
mainval = 'Spectral Analysis'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value=mainval, ref_value = base_ref, $
  position = *mainposn,/menu, /separator
  ;
  posn = 0
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Modified Gaussian Model (MGM)', $
    ref_value=mainval, position=posn, event_pro='m3_menu_undefined', $
    uvalue='not used'
  ;
  posn = posn + 1
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Spectral Shape Fitting', $
    ref_value=mainval, position=posn, event_pro='m3_spectral_shape_fitting', $
    uvalue='not used'
;     
end     