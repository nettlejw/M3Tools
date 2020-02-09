function m3_photom_ls, i, e
;
;  PURPOSE:  calculates the lommel-seeliger scattering function value for a given i and e.
;
;------------------------------------------------------------------------------------------------
compile_opt strictarr
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return,-1
ENDIF
;
; error check inputs
;
if n_elements(i) gt 0 then i = double(i) else message, 'must supply incidence angles.'
if n_elements(e) gt 0 then e = double(e) else message, 'must supply emission angles.'
;
; convert to radians, take cosines
;
cos_i=cos(i*!dpi/180.0d)
cos_e=cos(e*!dpi/180.0d)
;
; calculate ls
;
ls=cos_i/(cos_i+cos_e)
return, ls
;
end