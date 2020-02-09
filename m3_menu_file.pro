pro m3_menu_file, buttonInfo, base_ref, mainposn, subteams
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
;mainval = 'Open...'
;ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value=mainval, $
;  ref_value = base_ref, position=*mainposn, /Menu 
;  ;
;  posn = 0
*mainposn = *mainposn + 1 
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value = 'Open M3 file(s)', $
    ref_value = base_ref, position = *mainposn, event_pro = 'm3_file_open', $
    uvalue = 'not used'
  ;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value = 'M3 File Search Tool', $
    ref_value = base_ref, position = *mainposn, event_pro = 'm3_file_search_tool', $
    uvalue = 'not used'    
  ;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value = 'Search using Input File', $
    ref_value = base_ref, position = *mainposn, event_pro = 'm3_utils_search_from_basename', $
    uvalue = 'not used'
  ;
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value = 'Open M3 Spec. Library', $
    ref_value = base_ref, position = *mainposn, event_pro = 'm3_open_speclib', $
    uvalue = 'not used'

*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value= 'Display Albedo Quicklook', $
   ref_value = base_ref, position = *mainposn, event_pro = 'm3_utils_disp_albedo', $
   uvalue = 'not used', /separator  
    
*mainposn = *mainposn + 1
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value= 'Display Thermal Quicklook', $
   ref_value = base_ref, position = *mainposn, event_pro = 'm3_utils_disp_band84', $
   uvalue = 'not used'  
   
;*mainposn = *mainposn + 1
;ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value= 'Get info on a strip', $
;   ref_value = base_ref, position = *mainposn, event_pro = 'm3_filedb_report', $
;   uvalue = 'not used', /separator  
;
;*mainposn = *mainposn + 1
;ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value= 'Open File Info CSV', $
;   ref_value = base_ref, position = *mainposn, event_pro = 'm3_utils_open_files_db', $
;   uvalue = 'not used', /separator     
;
;*mainposn = *mainposn + 1
;ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value= 'Open ACT Quickmap', $
;   ref_value = base_ref, position = *mainposn, event_pro = 'm3_utils_open_quickmap', $
;   uvalue = 'not used'     
      
;     
end     