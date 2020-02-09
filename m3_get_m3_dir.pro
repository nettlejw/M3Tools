function m3_get_m3_dir, pathsep=pathsep, subdir=subdir, path_sep=path_sep
  compile_opt strictarr, hidden
  
  path= filepath('', root_dir=m3_programrootdir(), subdir=subdir)
  if keyword_set(pathsep) then path = path + path_sep()
  if keyword_set(path_sep) then path = path + path_sep()
  return, path

end
