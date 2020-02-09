pro m3_set_dir_prefs, event
compile_opt strictarr, hidden
 ; 
 ;this routine allows the user to set preferences that are stored between ENVI sessions.  It uses
 ;a renamed version of Mike Galloy's mg_prefs object (used by permission).
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
 ;  load the preference object - always use jnettles as author and m3tools as application
 ;
 prefs = obj_new('m3_prefs')
 current_data_dir=prefs->get('workingdir')
 current_speclib_dir=prefs->get('speclibdir')
 current_archive_dir=prefs->get('archivedir')
 ;
 ;  build widget (auto managed for now)
 ;
 tlb = widget_auto_base(title = 'Set M3 Preferences')
 wo1 = widget_outf(tlb, uvalue='m3work',/directory,prompt = 'Select default M3 working directory', $
              default = current_data_dir,  /auto)
 wo2 = widget_outf(tlb, uvalue='m3archive',/directory,prompt = 'Select M3 archive directory', $
              default = current_archive_dir,  /auto)
 wo3 = widget_outf(tlb, uvalue='m3speclib',/directory, prompt  = 'Select M3 spectral library directory', $
              default = current_speclib_dir, /auto)
 result = auto_wid_mng(tlb)
 if (result.accept eq 0) then return
 ;
 ;  Write the preferences
 ;
 m3work=result.m3work
 m3archive=result.m3archive
 m3speclib=result.m3speclib
 if m3work ne '<undefined>' and strmid(m3work,0,1,/reverse_offset) ne path_sep() then $
   m3work=m3work+path_sep()
 if m3archive ne '<undefined>' and strmid(m3archive,0,1,/reverse_offset) ne path_sep() then $
   m3archive=m3archive+path_sep()
 if m3speclib ne '<undefined>' and strmid(m3speclib,0,1,/reverse_offset) ne path_sep() then $
   m3speclib=m3speclib+path_sep()
 prefs->set, 'workingdir', m3work
 prefs->set, 'archivedir', m3archive
 prefs->set, 'speclibdir', m3speclib
 ;
 ;  cleanup
 ;
 obj_destroy, prefs
 ;
end