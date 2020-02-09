function m3_params_get_zmask, tile, wl, threshold
compile_opt strictarr, hidden
;
;  PURPOSE:  all-purpose mask-creation tool for tiles of m3 data.  This function
;            is intended to create masks for spectra with NaN values, all-zero spectra, etc.
;            and possibly later for bad detector elements as well.
;------------------------------------------------------------------------------------------------            
;
;  Simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return, -1
ENDIF
;
;  use default threshold if not passed in
;
if n_elements(threshold) eq 0 then threshold=0.005
;
;  get size of tile
;
s=size(tile, /dimensions)
ns=s[0]
nb=s[1]
;
;  look for all-zero spectra
;
zmask_start = intarr(ns)
for j = 0, ns - 1 do begin
  spectrum = reform(tile[j,*])
  ;
  ;  mask it if 2/3 of the spectrum is zero
  ;
  bad = where(spectrum lt threshold, count)
  if float(count) ge float(nb)*2.0/3.0  then zmask_start[j] = 1
  ;
  ;  now mask out NaN spectra
  ;
  bad=where(~finite(spectrum), count)
  if float(count) ge float(nb)*2.0/3.0  then zmask_start[j] = 1
endfor
zbad = where(zmask_start eq 1, zcount)
if zcount gt 0 then zmask = zbad else zmask=-1
;
return, zmask
;
end