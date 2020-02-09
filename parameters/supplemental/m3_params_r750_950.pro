function m3_params_r750_950, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
;
nums = [749, 949]
if keyword_set(return_nums) then return, nums
i749 = m3_wl_lookup(wl, nums[0])
i949 = m3_wl_lookup(wl, nums[1])
;
R749 = float(tile[*,i749])
R949 = float(tile[*,i949])
if zmask[0] ne -1 then R949[zmask]=1.0
;
out=R749/R949
if zmask[0] ne -1 then out[zmask]=m3_params_get_badval()
return, out
;
end
