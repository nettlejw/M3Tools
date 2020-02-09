function m3_utils_date2doy, month, day, year
compile_opt strictarr
;
mon_nums = [[1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335], $;reg_year
            [1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336] ] ;leap_year
is_leap=(year mod 4) eq 0            
day_indices = mon_nums[*,is_leap]
;
doy=day_indices[month-1]+day-1
return, doy
;
end