pro m3_personal_code_open, event
;
;  opens personal code folder.  
;  
;  -----------------------------------------------------------------------------------------------
;
;  standard compiler directive, forces you to use []'s to denote array subscripts
;
COMPILE_OPT strictarr
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
;  get personal code dir
;
m3_prefs=obj_new('m3_prefs')
pcodedir=m3_prefs->get('local_code_dir')
;
;  handle opening the directory on a per OS basis
;
case !Version.OS_FAMILY of
 'MacOS':   begin
            cmd = 'open ' + pcodedir
            spawn, cmd
          end
 'Windows': begin
             cmd = 'explorer ' + pcodedir
             spawn, cmd, /noshell
            end
 'unix':begin
         if !Version.OS eq 'Mac OS X' then begin
           cmd = 'open ' + pcodedir
           spawn, cmd
         endif else begin
           msg = 'On this OS the directory cannot be automatically opened.  Copy your code into '
           msg = msg + pcodedir + ' and your code should appear on the menu after restarting ENVI.'
           ok=dialog_message(msg, /information)
         endelse   
       end         
  else:     begin
              msg = 'On this OS the directory cannot be automatically opened.  Copy your code into '
              msg = msg + pcodedir + ' and your code should appear on the menu after restarting ENVI.'
              ok=dialog_message(msg, /information)
           end   
endcase
;
;  clean up objects
;
obj_destroy, m3_prefs
;
end