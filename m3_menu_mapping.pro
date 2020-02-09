pro m3_menu_mapping, buttonInfo, base_ref, mainposn
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
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Project Single Strip', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_map_project_strip', $
  uvalue='not used', /separator 
;
mainval = 'Smart Mosaic'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value = mainval, $
  ref_value = base_ref, position = *mainposn, /menu
  ; 
  posn = 0
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Build GLT', $
    ref_value=mainval, position=posn, event_pro='m3_smart_mosaic_start', $
    uvalue='not used'
  ;
  posn = posn + 1
  ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Mosaic from GLT', $
    ref_value=mainval, position=posn, event_pro='m3_smart_mosaic_build_mosaic', $
    uvalue='not used'
;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Update Ellipse.txt and Datum.txt', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_utils_add_datum_and_ellipse', $
  uvalue='not used'
;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Subset/FLip L0 File', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_figure_and_apply_flip_and_subset_gui', $
  uvalue='not used', /separator        
;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Trim 304 to 300 Samples', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_utils_304_to_300_samples', $
  uvalue='not used', /separator    
;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value='Open ACT Quickmap', $
  ref_value=base_ref, position=*mainposn, event_pro='m3_utils_open_quickmap', $
  uvalue='not used', /separator    
  
    
end