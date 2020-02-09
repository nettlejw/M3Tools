;
; Programmatically add M3 menu system
;
; Written, Aug 29 2007, Jeff Nettles, Brown University
;   inspired by CRISM CAT written by Shannon Pelkey
; Modified, Nov 29, 2008, Jeff Nettles, Brown University
;   redesigned to put menu categories in their own routine and add conditional menus.  
;
pro m3tools_define_buttons, buttonInfo ;**************************************************************
compile_opt strictarr, hidden
;
;  PURPOSE:  This is the M3 main menu-creating routine.  
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
   catch, /cancel
   ok = m3_error_message()
   return
ENDIF
;
;  Top Level
;
topval = 'M3 Tools'
mainposn = ptr_new(0)
ENVI_DEFINE_MENU_BUTTON, buttonInfo, Value=topval, ref_value = 'File', /Sibling, position='after', /Menu
;
; Open m3 file utility
;
m3_menu_file, buttonInfo, topval, mainposn
*mainposn = *mainposn + 1
;
; Level 2 (Photometry) Routines
; 
m3_menu_photom, buttonInfo, topval, mainposn
*mainposn = *mainposn + 1
;
; Parameters Routines
; 
m3_menu_parameters, buttonInfo, topval, mainposn
*mainposn = *mainposn + 1
;;
;;  Polishing Routines
;;
;m3_menu_polishing, buttonInfo, topval, mainposn
;*mainposn = *mainposn + 1
;
;  Resampling Routines
;
*mainposn = *mainposn + 1
m3_menu_resampling, buttonInfo, topval, mainposn
;
;  Spectral Analysis Routines
;
*mainposn = *mainposn + 1
m3_menu_analysis, buttonInfo, topval, mainposn
;
;  Mosaic routines
;
*mainposn = *mainposn + 1
m3_menu_mapping, buttonInfo, topval, mainposn
;
;  Local Code added to the M3 Menu
;
*mainposn = *mainposn + 1
m3_menu_personal_code, buttonInfo, topval, mainposn
;
;  Preferences Routines
;
*mainposn = *mainposn + 1
m3_menu_preferences, buttonInfo, topval, mainposn
;
;  Help Menu
;
*mainposn = *mainposn + 1
m3_menu_help, buttonInfo, topval, mainposn
;   
ptr_free, mainposn
;   
end

pro m3tools, event
compile_opt strictarr
 ;placeholder - leave this as is
end

