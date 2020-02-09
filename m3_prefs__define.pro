function m3_prefs::_constructFilename, prefname
 compile_opt strictarr
 return, filepath(idl_validname(prefname, /convert_all) + '.sav', root=self.configdir)  
end

function m3_prefs::get, prefname
  compile_opt strictarr
  filename = self->_constructFilename(prefname)
  if (~file_test(filename)) then return, -1L
  restore, filename=filename
  return, prefvalue
end

pro m3_prefs::set_default_local_code_dir
  compile_opt strictarr
  lcodedir=self.configdir + 'local_code' + path_sep()
  if ~file_test(lcodedir,/directory) then file_mkdir, lcodedir
  self->set, 'local_code_dir', lcodedir
end

pro m3_prefs::set_color_composite_dir
  compile_opt strictarr
  ccompdir=self.configdir + 'color_composites' + path_sep()
  if ~file_test(ccompdir,/directory) then file_mkdir, ccompdir
  self->set, 'color_composite_dir', ccompdir
end


pro m3_prefs::set, prefname, prefvalue
  compile_opt strictarr
  filename=self->_constructFilename(prefname)
  save, prefvalue, filename=filename
end

pro m3_prefs::add_local_code_dir_to_path
  compile_opt strictarr
  lcodedir=self->get('local_code_dir')
  ;
  ;  only add to path if there are code files in the directory
  ;
  pro_files=file_search(lcodedir, '*.pro', count=n_pro)
  sav_files=file_search(lcodedir, '*.sav', count=n_sav)
  tot=n_pro + n_sav
  if long(tot) eq 0L then return
  ;
  ; add to path
  old_path=!path
  new_path = lcodedir + path_sep(/search_path) + old_path
  pref_set, 'IDL_PATH', new_path, /commit
  ;
end

pro m3_prefs::cleanup
  compile_opt strictarr
end

pro m3_prefs::prefs_dump
  ; lists current value of all preferences that can be set
  compile_opt strictarr
  ;
  start_dir=self.configdir
  if strmid(start_dir,0,1,/reverse_offset) ne path_sep() then start_dir=start_dir + path_sep()
  sav_files=file_search(start_dir + '*.sav', count=n_sav)
  if n_sav eq 0 then begin
    print, 'No preferences found.'
    return
  endif
  ;
  pref_names=file_basename(sav_files, '.sav')
  for i = 0, n_sav - 1 do begin
    print, pref_names[i]+'='+strtrim(self->get(pref_names[i]),2)
  endfor  
end

function m3_prefs::get_menu_extensions_list, extension_names=extension_names
  compile_opt strictarr
  configdir=self.configdir
  sav_files=file_search(configdir + '*menu_ext.sav', count=n_sav)
  extension_names=file_basename(sav_files,'.sav')
  list=bytarr(n_sav)
  for i = 0, n_sav -1 do list[i]=self->get(extension_names[i])
  return, list
end

pro m3_prefs::set_defaults
  compile_opt strictarr
  print, 'Setting up default preferences...'
  self->set_default_local_code_dir
  self->set_color_composite_dir
  self->set, 'workingdir', '<undefined>'
  self->set, 'archivedir', '<undefined>'
  self->set, 'speclibdir', '<undefined>' 
  self->set, 'dataflow_menu_ext',0
  self->set, 'photometry_menu_ext',0
  self->set, 'parameters_menu_ext',0
  self->set, 'is_def_set',1
  self->set, 'version', m3_utils_get_version()
  print, 'Default preferences set.'
end

pro m3_prefs::set_configdir
  compile_opt strictarr
  version=m3_utils_get_version()
  application = 'M3Tools'+'_v'+version
  author = 'M3'
  auth_descrip = 'Moon Mineralogy Mapper'
  app_descrip = 'Analysis tools and utilities for working with M3 data'
  read_me_text = 'Not used'
  ;                           
  appdir = app_user_dir(author, auth_descrip, application, app_descrip, read_me_text, 1)
  ;                      
  self.configdir = filepath('', subdir='prefs', root=appdir)                        
  if (~file_test(self.configdir)) then file_mkdir, self.configdir
end  


pro m3_prefs::open_configdir
  self->open_dir, self.configdir
end


pro m3_prefs::open_dir, dir
compile_opt strictarr
  if !version.os_family ne 'Windows' then begin
    print, 'Directories can only be opened for you on windows.'
    print, 'The directory you should cd to is ' + self.configdir
  endif else begin
    if file_test(dir,/directory) then spawn, 'explorer ' + dir, /noshell $
      else print, dir + ' was not found.'
  endelse
end

function m3_prefs::init
  compile_opt strictarr
  on_error, 2
  ;                     
  ;  set configdir
  ;
  self->set_configdir
  ;
  ;  set defaults if necessary
  ;
  def_set = self->get('is_def_set')
  if (def_set lt 1) then self->set_defaults
  return, 1
end

pro m3_prefs__define
  compile_opt strictarr
  define = { m3_prefs, configdir: '' }  
end
