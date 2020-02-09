pro m3_utils_search_from_basename, event
;
;  searches for files using the basename of an input file
;
;--------------------------------------------------------------------------
compile_opt strictarr
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
;  get input file
;
envi_select, fid=fid, title='Select file to use for search:', /no_spec, /no_dims, /file_only
if fid eq -1 then return
;
;  get input filename, make sure it's an m3 basename
;
envi_file_query, fid, fname=fname
bn=strmid(file_basename(fname),0,18)
if stregex(bn, '^M3(G|T)200', /boolean) eq 0 then begin
  envi_error, 'The file you selected appears to not have an M3-style name.'
  return
endif
;
;  do the search
;
m3_file_search_tool, 0, bn
;
end