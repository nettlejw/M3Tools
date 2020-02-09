function m3_params_3ua_min, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
;
r1=76
r2=83
if keyword_set(return_nums) then return, fix(wl[[r1,r2]])
;
;  subset the input data
;
sub_tile=tile[*,r1:r2]
sub_wl = wl[r1:r2]
;
;  find the max values
;
ns = (size(tile, /dimensions))[0]
min_tile = fltarr(ns)
multi_mask = intarr(ns)
for i = 0, ns - 1 do begin
  min_val=min(sub_tile[i,*])
  min_posn=where(sub_tile[i,*] eq min_val)
  if n_elements(min_posn) gt 1 then begin
    multi_mask[i] = 1
    min_posn = min_posn[0]
  endif
  min_tile[i]=sub_wl[min_posn]
endfor
;
;  handle masks
;
if n_elements(zmask) gt 0 then min_tile[zmask] = 0.0
tmask = fix(m3_params_3ua_mask(tile, wl))
tbad = where(tmask eq 1, tcount)
if tcount gt 0 then min_tile[tbad]= 0.0
mbad = where(multi_mask eq 1, mcount)
if mcount gt 0 then min_tile[mbad] = 0.0
;
return, min_tile
;
end
