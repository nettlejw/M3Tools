pro m3_menu_parameters, buttonInfo, base_ref, mainposn, subteams
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
;  get subteam preferences
;
;subteams = m3_get_subteams()
;param_team = subteams.parameters
;
;  set up a branch coming off the main M3 Tools menu for the main parameters calculation routines
;
;ParamCalcVal = 'Calculate Parameters...'
;ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value=ParamCalcVal, $
;  ref_value=base_ref, position=*mainposn, /menu, /separator
;  ;
;  posn = 0
;  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Duplicate Pipeline', $
;    ref_value=ParamCalcVal, position=posn, event_pro='m3_params_cube_wrapper', uvalue='Pipeline'
;  ;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Calculate Parameters', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_params_cube_wrapper', uvalue='All', /separator
;
;*mainposn = *mainposn + 1
;ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='3um Parameters', $
;  ref_value=base_ref, position=posn, event_pro='m3_params_cube_wrapper', uvalue='3um'   
;  
;  Parameters Color Composites
;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Display Parameters Color Composite', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_params_display_color_composite', $
  uvalue='not used'
;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Define a Color Composite', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_params_define_color_composite', $
  uvalue='not used'  
;
;  Parameters Documentation
;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Parameters Documentation', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_help', uvalue='params_table_110308'
;
;  Stuff for the Parameters Subgroup
;

;if (param_team eq 1) then begin
;  ;
;  ;  Parameter Testing Stuff
;  ;
;  *mainposn = *mainposn + 1
;  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Display Parameters Text Report of Wavelengths used', $
;    ref_value=ParamCalcVal, position=*mainposn, event_pro='m3_parameters_text_table', $
;    uvalue='All', /separator
;  ;
;  *mainposn = *mainposn + 1
;  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Display Parameters iTools Report of Wavelengths used (slow)', $
;    ref_value=ParamCalcVal, position=*mainposn, event_pro='m3_parameters_itools_table', $
;    uvalue='All'
;endif    
;
;     
end     