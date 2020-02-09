function m3_params_3ua_max, tile, wl, return_nums=return_nums, zmask=zmask
compile_opt strictarr
;
r1 = 75
r2 = 81
;
if keyword_set(return_nums) then return, fix(wl[[r1,r2]])
;
;  subset the tile 
;
sub_tile = tile[*,r1:r2]
sub_wl = wl[r1:r2]
;
;  find the max values
;
ns = (size(tile, /dimensions))[0]
max_tile = fltarr(ns)
multi_mask = intarr(ns)
for i = 0, ns - 1 do begin
  max_val=max(sub_tile[i,*])
  max_posn=where(sub_tile[i,*] eq max_val)
  if n_elements(max_posn) gt 1 then begin
    max_posn = max_posn[0]
    multi_mask[i] = 1
  endif
  max_tile[i]=sub_wl[max_posn]
endfor
;
;  handle masks
;
if n_elements(zmask) gt 0 then max_tile[zmask]=0.0
tmask = fix(m3_params_3ua_mask(tile, wl))
tbad = where(tmask eq 1, tcount)
if tcount gt 0 then max_tile[tbad]=0.0
mbad = where(multi_mask eq 1, mcount)
if mcount gt 0 then max_tile[mbad]=0.0
;
return, max_tile
;
end
