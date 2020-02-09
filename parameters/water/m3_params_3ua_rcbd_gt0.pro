function m3_params_3ua_rcbd_gt0, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
;
; just threshold to positive band depths
;
if keyword_set(return_nums) then return, m3_params_3ua_rcbd(tile, wl, /return_nums)
;
;  get the band depth tile
;
rcbd = m3_params_3ua_rcbd(tile, wl)
;
;  now threshold
;
keep = where(rcbd gt 0.0, count)
rcbd_gt0 = rcbd * 0.0
if count gt 0 then rcbd_gt0[keep] = rcbd[keep]
;
return, rcbd_gt0
;
end
