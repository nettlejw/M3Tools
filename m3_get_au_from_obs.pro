pro m3_get_au_from_obs, distb, sd
;
;  standard compiler directive, forces you to use []'s to denote array subscripts
;
COMPILE_OPT strictarr, hidden
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  print, 'caught'
  catch, /cancel
  sd = -1
  return
ENDIF
;
extract = strsplit(distb, '-', /extract) ;should be a 3 elem array   
if ~array_equal(extract, '') then begin
 if n_elements(extract) eq 3 then begin
   sd = double(file_basename(extract[2], ')'))  ;trick to remove trailing ')' character
 endif
endif   
if sd eq 0.0d then sd = -1

end