function m3_params_3ua_rcbd, tile, wl, return_nums=return_nums, zmask=zmask
;
;  PURPOSE:  Implements Roger's formulation of a 3um band depth that he uses for 3um 
;            absorber maps
;----------------------------------------------------------------------------------------
compile_opt strictarr
;
rci = [75,76,77]
rbi = [82,83]
if keyword_set(return_nums) then return, wl[[rci,rbk]]
;
rb = total(tile[*,rbi],2)/n_elements(rbi)
rc = total(tile[*,rci],2)/n_elements(rci)
;
; check for zero averages in denominator
; 
bad = where(rc lt 0.0005, count)
if count gt 0 then rc[bad] = 1.0
;
;  get thermal mask
;
tmask = fix(m3_params_3ua_mask(tile, wl))
tbad = where(tmask eq 1, tcount)
if tcount gt 0 then rc[tbad] = 1.0
;
ratio = rb/rc
out= 1.0-ratio
;
if count gt 0 then out[bad] = 0.0
if tcount gt 0 then out[tbad] = 0.0
if n_elements(zmask) gt 0 then out[zmask] = 0.0
;
return, out
;
end
