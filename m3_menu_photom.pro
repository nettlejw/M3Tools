pro m3_menu_photom, buttonInfo, base_ref, mainposn
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
;prefs = obj_new('m3_prefs')
;photom_team = prefs->get('photometry_group')
;   
;  Radiance to Reflectance Conversion
;
*mainposn = *mainposn + 1 
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Calculate I/F  (now WITH pi!)', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_photom_i_over_f', $
  uvalue='not used', separator=(*mainposn gt 1)
;
*mainposn = *mainposn + 1 
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Calculate Apparent Reflectance', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_photom_apparent_reflectance', $
  uvalue='not used'
;
*mainposn = *mainposn + 1 
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Photometry Correction', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_photom_full_correction_gui', $
  uvalue='not used'
;
*mainposn = *mainposn + 1 
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Create i,e,phase cube from OBS', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_photom_calculate_iea', $
  uvalue='not used'      
;;
;*mainposn = *mainposn + 1 
;ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Photometry Parameters', $
;  ref_value=base_ref, position=*mainposn, event_pro='m3_photom_params_gui', $
;  uvalue='not used'    
;
*mainposn = *mainposn + 1
oss_val = 'Open Solar Spectrum'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value = oss_val, $
  ref_value='M3 Tools', position=*mainposn, /menu
  ;
  j=0
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='1nm Resolution', $
  ref_value=oss_val, position=j, $
  event_pro='m3_photom_open_solar_spec', uvalue='full_res'
  ;
  j=j+1
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Global', $
  ref_value=oss_val, position=j, $
  event_pro='m3_photom_open_solar_spec', uvalue='global'
  ;
  j=j+1
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Target', $
  ref_value=oss_val, position=j, $
  event_pro='m3_photom_open_solar_spec', uvalue='target'
;     
;obj_destroy, prefs
;
end     