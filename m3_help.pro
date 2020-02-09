pro m3_help, event
compile_opt strictarr
 ;
 ;  handles launching the various M3 help files
 ;
 ;--------------------------------------------------------------------------------------------------
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
 ;  first get the uvalue for the menu button that called the event
 ;
 if n_elements(event) gt 0 then begin
   widget_control, event.id, get_uvalue=uval
 endif else uval='m3tools_main_help'  
 ;
 ;  now figure out path to help file based on which one is being requested
 ;
 ;  first assume the following:
 ;    1) uvalue is equal to the file name of the  helpfile (minus the file extension)
 ;    2) helpfile is a pdf file (with .pdf extension)
 ;    3) helpfile is stored in the help_files directory of the M3 Tools distribution.
 ;
 helpdir = m3_programrootdir() + path_sep() + 'resources' + path_sep() + 'help_files' + path_sep()
 helpfile = helpdir + uval + '.pdf'
 if file_test(helpfile) then begin
    online_help, book=helpfile, /full_path
    return ;qo ahead and quit if we've already found the file
 endif
 ;
 ;  later insert other stuff here to handle different situations if needed.
 ;
 ;
 ;
 ;  if we get this far we didn't find the file, so throw an error.
 ;
 Message, 'The help file you requested was not found.'
 ;
end

