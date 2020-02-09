pro m3_utils_open_quickmap, event
;
;  PURPOSE:  Routine to open the ACT Quickmap Webpage
;
;-------------------------------------------------------------------------------------------
compile_opt strictarr
;
;  this is the webpage to load
;
url='http://207.87.28.167/m3_qmap.html'
;
;  use preferred browser - this is platform dependent
;
if !version.os_family eq 'Windows' then spawn, 'start ' + url, /hide, /nowait else begin
  ;
  if (!version.os_name eq 'Mac OS X') then begin
    spawn, 'Open ' + url
    return
  endif
  ; 
  ;  try htmlview on unix
  ;
  spawn, 'htmlview ' + url, exit_status=exit_status
  if exit_status gt 0 then envi_error, ['This routine does not work on your linux/unix version.']
  ;
endelse
;
end