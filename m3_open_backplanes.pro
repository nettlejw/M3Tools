pro m3_open_backplanes, event
compile_opt strictarr
;
;  opens LOC and OBS files for a given Radiance or Reflectance file
;
envi_select, fid=fid, /file_only, /no_dims, /no_spec
if fid eq -1 then return
;
envi_file_query, fid, fname=infile
;
dir = file_dirname(infile)
if strmid(dir, 0, 1, /reverse_offset) ne path_sep() then dir = dir + path_sep()
;
fullbase = file_basename(infile)
pos = strpos(fullbase, '_', /reverse_search)
base= strmid(fullbase,0,pos) + '_'
;
ext = ['LOC', 'OBS']
for i = 0, n_elements(ext) - 1 do begin
  name = dir + base + ext[i] + '.IMG'
  if file_test(name) then envi_open_file, name
endfor  
;
end