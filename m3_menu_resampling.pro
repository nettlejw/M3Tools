pro m3_menu_resampling, buttonInfo, base_ref, mainposn, subteams
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
;Spectral Libary Resample
;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Resample Spec. Library (.sli) to M3', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_resample_sli', $
  uvalue='not used', /separator
;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Resample Target Cube to Global', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_cube_spectral_resample', $
  uvalue='not used'
;     
end     