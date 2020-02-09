pro m3_utils_open_files_db, event
;
;  PURPOSE:  opens the files database csv file in whatever program the 
;            user has registered to handle csv files
;
;--------------------------------------------------------
compile_opt strictarr
;
;  get the csv file
;
csvf=filepath('krad_files_db.csv', root_dir=m3_programrootdir(), subdir=['resources'])
if ~file_test(csvf) then begin
  print, 'CSV file not found.'
  return
endif
;
;  build the right command to execute
;
if !version.os_family eq 'Windows' then cmd='start 'else begin
  if !version.os eq 'MacOS' then cmd='open ' else begin
    print, 'You have to open this file yourself on unix/linux.'
    print, 'The full path is '+csvf
    return
  endelse
endelse
;
; launch the file
;
exec=cmd+csvf
spawn, exec, /nowait
;
end