pro m3_menu_polishing, buttonInfo, base_ref, mainposn
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
mainval = 'Spectral Polishing'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value = mainval, $
  ref_value = base_ref, position = *mainposn, event_pro='m3_ground_truth_apply', $
  uvalue='not used', /separator
  
  
    
end