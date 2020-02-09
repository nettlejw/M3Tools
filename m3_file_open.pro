pro m3_file_open, event
compile_opt strictarr
;
; opens m3 files, starts file selection dialog in default m3 data directory preference, if it exists
;
;----------------------------------------------------------------------------------------------------
;
;  load the preference object
;
prefs = obj_new('m3_prefs')
datapref = prefs->get('workingdir')
;
;  check to make sure the directory exists first
;
if file_test(datapref, /directory) then begin
    files = dialog_pickfile(title="Select files to open", path=datapref, /multiple_files) 
  endif else begin
    files = envi_pickfile(title="Select files to open", /multiple_files)
endelse  
if files[0] eq '' then return
;
;  open the files
;
for i = 0, n_elements(files) - 1 do envi_open_file, files[i]
;
;  clean up preferences
;
obj_destroy, prefs
;
end