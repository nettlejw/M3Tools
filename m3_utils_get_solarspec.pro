function m3_utils_get_solarspec, wl=wl, global=global, target=target, fullres=fullres
;
;  PURPOSE:  A utility function to that returns the m3 solar spectrum.
;
;  KEYWORDS:
;
;      wl:   set this to a named variable to receive the wavelength values (in nm) that 
;            accompany the solar curve
;
;   global:  Set this to output the solar curve at global resolution.  This is the default.
;
;   target:  Set this to output the solar curve at target resolution.  Ignored if global keyword 
;            is set.  Supercedes the fullres keyword.
;
;   fullres: Set this to output the solar curve at 1nm resolution.  Ignored if either the global
;            or target keyword is set.
;
;------------------------------------------------------------------------------------------------
;
compile_opt strictarr, hidden
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return, -1
ENDIF
;
;  handle keywords
;
if keyword_set(fullres) then mode = 'full_res'
if keyword_set(target) then mode = 'target'
if keyword_set(global) then mode = 'global'
if n_elements(mode) eq 0 then mode = 'global'
;
;  open the solar spectrum
;
solar_spec_file = filepath(root_dir=m3_programrootdir(), subdir = ['resources', 'level2'], $
    'solar_spectrum_' + mode + '.sli')
envi_open_file, solar_spec_file, r_fid=ss_fid, /no_realize
envi_file_query, ss_fid, ns=ns_ss, nl=nl_ss, nb=nb_ss, wl=wl, spec_names=ss_name
nb=n_elements(wl)
;
;  read the solar spectrum
;
sli_dims = [-1,0,ns_ss - 1,0,nl_ss - 1]
solar_spectrum = reform(envi_get_data(fid=ss_fid, dims=sli_dims, pos=0))
envi_file_mng, id=ss_fid, /remove
;
return, solar_spectrum
end