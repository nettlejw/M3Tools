pro m3_photom_full_correction_from_thermrem_engine, event, params=params, rdn_file=rdn_file, obs_file=obs_file, $
                                      coeffs=coeffs, out_root=out_root, delete_factors=delete_factors, $
                                      delete_intermediates=delete_intermediates
;
;  PURPOSE:  wrapper routine for the m3 photometry correction, calls the individual routines that 
;            make up the correction
;            
;----------------------------------------------------------------------------------------------
compile_opt strictarr
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF
;
; if a params struct was passed in, use it to fill up the input keywords 
;
if n_elements(params) gt 0 then begin
  therm_file=params.rdn_file  ;structure tag named wrong but it contains therm-removed file
  obs_file=params.obs_file
  coeffs=params.coeffs
  out_root=params.out_root
  delete_factors=params.delete_factors
  delete_intermediates=params.delete_intermediates
endif
;
;  handle input keywords
;
if n_elements(iof_file) eq 0 then message, 'Must supply a Thermally-corrected cube.'
if n_elements(obs_file) eq 0 then message, 'Must supply an OBS file.'
if n_elements(out_root) eq 0 then message, 'Must supply an output root name.'
if n_elements(coeffs) eq 0 then coeffs=[0.5,0.5,0.0]
;
;  back-calculate I/F from thermally-removed cube, which should be in ARFL
;  for now this will be to-sphere by default
;
iof_file=out_root+'_IoF.IMG'
m3_photom_mult_by_cosi, 0, therm_file, obs_file, iof_file
;
;  create lommel_seeliger band
;
ls_band_file=out_root+'_LS_BAND.IMG'
m3_photom_calc_lommel_seeliger, 0, obs_file, ls_band_file
;
;  divide out the lommel_seeliger band, giving an f(alpha) cube
;
falpha_file=out_root+'_F_ALPHA.IMG'
m3_photom_create_falpha, iof_file, ls_band_file, falpha_file
;
;  calculate shadow/illuminated phase band
;
eff_phase_file=out_root+'_EFFECTIVE_PHASE.IMG'
m3_photom_calc_effective_phase, obs_file, eff_phase_file
;
;  open f(alpha) normalization tables, mix them according to coefficients specified by user
;  *ALSO:  multiply by 2.155 in this step also.
;
custom_table_file=out_root+'_F_ALHA_NORM_TABLE.SLI'
m3_photom_mix_falpha_table_testing_version, coeffs,iof_file, custom_table_file, table_dir
;
; look up shadow/illuminated phase band in correction look up table(s), 
; create a cube of f(alpha) normalization factors
;
;eff_phase_file='G:\Photometry\op1b_sc_shadow_illum_phase_flipped_subset.img'
norm_file=out_root+'_F_ALPHA_NORM_FACTORS.IMG'
;custom_table_file='G:\Photometry\table\highlands_global.sli'
m3_photom_falpha_norm_cube, eff_phase_file, custom_table_file, norm_file
;
;  divide out the normalization factor, giving final output
;
out_file=out_root+'_PRFL.IMG'
;norm_file='G:\Photometry\op1b_corrected_subset_attemp2.img'
m3_photom_apply_falpha_norm, falpha_file, norm_file, out_file, table_dir, r_fid=r_fid
;
;  clean up:  delete intermediate files and/or correction factors as dictated by keywords
;
if keyword_set(delete_factors) then begin
  file_delete, ls_band_file
  file_delete, eff_phase_file
  file_delete, custom_table_file
endif
if keyword_set(delete_intermediates) then begin
  file_delete, iof_file
  file_delete, falpha_file
  file_delete, norm_file
endif


;
;  re open input files at the end
;
;envi_open_file, rdn_file, /no_interactive_query
envi_open_file, obs_file, /no_interactive_query
print, 'Finished processing photometric corrections for '+out_root
end