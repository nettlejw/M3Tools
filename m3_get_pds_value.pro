pro m3_get_pds_value, pdsf, key, value
  compile_opt strictarr
  ;
  ;  Reads a pds label file looking for the value in 'key' and returning 'value' 
  ;
  ;  The input file that the program expects is the *_RDN.IMG file. 
  ;
  
  if n_elements(pdsf) eq 0 then message, 'Must supply an PDS file to search.'
  if n_elements(key) eq 0 then message, 'Must supply a key to search for'
;  ;
;  ;  construct the name of the PDS label file to read
;  ;
;  pdsf = file_dirname(infile) + path_sep() + file_basename(infile, '.IMG') + '.LBL'
  ;
  ;  count the lines in the file, open it, read the file into a string array
  ;
  nl = file_lines(pdsf)
  lines = strarr(nl)
  openr, lun, pdsf, /get_lun
  readf, lun, lines
  free_lun, lun
  ;
  ;  loop through the lines looking for the key
  ;
  for i = 0, nl - 1 do begin
    splits = strtrim(strsplit(lines[i], '=', /preserve_null, /extract),2)
    if n_elements(splits) ne 2 then continue  ;skip lines that weren't key/value pairs
    if splits[0] eq key then value = double(strtrim((strsplit(splits[1], '<', /extract))[0],2))
  endfor
  ;
  ;  return -1 if nothing was found
  ;
  if n_elements(value) eq 0 then value = -1.0d
  ;
end
  