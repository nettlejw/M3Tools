function m3_utils_get_version
compile_opt strictarr
;
;  PURPOSE:  Gets the current m3tools version.  Put in a separate function so it's easy to change
;            how versions are tracked without having to change the widget code that displays it.
;
;-----------------------------------------------------------------------------------------------------
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return, -1
ENDIF
;
;  open text file containing the version number
;
vfile=filepath('m3tools_version.txt', root_dir=m3_programrootdir(), subdir=['resources'])
version=''
openr, lun, vfile, /get_lun
readf, lun, version
free_lun, lun
;
;  return the string
;
return, version
;
end