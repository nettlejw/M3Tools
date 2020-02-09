function m3_params_get_params_list, $
		pipeline=pipeline, $
		removed=removed, $
		supplemental=supplemental, $
		water=water, $
		work=work
;
pipeline_params=['m3_params_2um_ratio', $
		'm3_params_bd1050', $
		'm3_params_bd1250', $
		'm3_params_bd1um_ratio', $
		'm3_params_bd2um_ratio', $
		'm3_params_bd3000', $
		'm3_params_bd620', $
		'm3_params_bd950', $
		'm3_params_ibd1000', $
		'm3_params_ibd2000', $
		'm3_params_r1580', $
		'm3_params_r750', $
		'm3_params_r950_750', $
		'm3_params_thermal_ratio', $
		'm3_params_uvvis', $
		'm3_params_visnir', $
		'm3_params_visuv']
;
removed_params=['m3_params_1um_fwhm', $
		'm3_params_1um_min', $
		'm3_params_1um_sym']
;
supplemental_params=['m3_params_1um_slope', $
		'm3_params_2um_slope', $
		'm3_params_650band', $
		'm3_params_bd1900', $
		'm3_params_bd2300', $
		'm3_params_crism_hcpindex', $
		'm3_params_crism_lcpindex', $
		'm3_params_crism_olindex', $
		'm3_params_curvature', $
		'm3_params_fe_est', $
		'm3_params_fe_est_mare', $
		'm3_params_hbd2700', $
		'm3_params_hbd2850', $
		'm3_params_hlnd_isfeo', $
		'm3_params_lucey_omat', $
		'm3_params_mare_omat', $
		'm3_params_nbd1400', $
		'm3_params_nbd1480', $
		'm3_params_nbd2300', $
		'm3_params_olindex', $
		'm3_params_r2780', $
		'm3_params_r540', $
		'm3_params_r750_950', $
		'm3_params_show_zmask', $
		'm3_params_thermal_slope', $
		'm3_params_tilt', $
		'm3_params_vis_slope', $
		'm3_params_visuv_modified']
;
water_params=['m3_params_3ua_albedo', $
		'm3_params_3ua_albedo_tmask', $
		'm3_params_3ua_ibd3000', $
		'm3_params_3ua_mask', $
		'm3_params_3ua_max', $
		'm3_params_3ua_min', $
		'm3_params_3ua_projtherm', $
		'm3_params_3ua_rcbd', $
		'm3_params_3ua_rcbd_gt0']
;
work_params=['m3_params_lscc_maturity']
;
if keyword_set(pipeline) then return, pipeline_params
if keyword_set(removed) then return, removed_params
if keyword_set(supplemental) then return, supplemental_params
if keyword_set(water) then return, water_params
if keyword_set(work) then return, work_params
;
return, [pipeline_params, supplemental_params]
;
end
