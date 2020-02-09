function m3_utils_doy2date, doy, year, julian=julian, global=global, target=target
compile_opt strictarr
;
;  PURPOSE:  Given a day-of-year number and a year, returns month day and year
;
;  RETURNS:  standard ascii date/time string (times set to 00:00:00) unless the 
;            JULIAN keyword is set, in which case it returns julian date as a double.
;
;----------------------------------------------------------------------------------------
;
;  check for conflicting keywords
;
t=keyword_set(julian)+keyword_set(global)+keyword_set(target)
if t gt 1 then begin
   print, 'Only one of these three keywords can be set:  julian, global, and target.'
   return, -1
endif
;
;  set up variables
;
dow_list = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
mnames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', $
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
mon_nums = [[1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335], $;reg_year
            [1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336] ] ;leap_year
isleap=(year mod 4) eq 0            
day_indices = mon_nums[*,isleap]
;
;  error handling
;
if doy lt 1 then begin
  print, 'DOY argument must be at least 1.'
  return, -1
endif
;
if doy gt 366 then begin
  print, 'DOY argument is too high.'
  return, -1
endif
;
if doy eq 366 and isleap eq 0 then begin
  print, 'DOY can only be 366 on a leap year.'
  return, -1
endif
;
;  get month and day, convert to julian date
;
imon=value_locate(day_indices, doy)
month=imon+1
day=doy-day_indices[imon]+1
jd=julday(month,day,year)
;
;  handle keywords to return specific formats, in order of priority
;
if keyword_set(global) then begin
  monstr=strtrim(month,2)
  if strlen(monstr) eq 1 then monstr='0'+monstr
  daystr=strtrim(day,2)
  if strlen(daystr) eq 1 then daystr='0'+daystr
  str='M3G' + strtrim(year,2)+monstr+daystr+'T'
  return, str
endif
if keyword_set(target) then begin
  monstr=strtrim(month,2)
  if strlen(monstr) eq 1 then monstr='0'+monstr
  daystr=strtrim(day,2)
  if strlen(daystr) eq 1 then daystr='0'+daystr
  str='M3T' + strtrim(year,2)+monstr+daystr+'T'
  return, str
endif
if keyword_set(julian) then return, jd
;
;  compute day of week assuming March 24, 2002 is a Sunday
;
dow = (jd - julday(3,24,2002)) MOD 7
dow = (dow + 7) MOD 7 
dow_str=dow_list[dow]
;
;  make day a string of right length
;
daystr = strtrim(day,2)
if strlen(daystr) eq 1 then daystr='0'+daystr
;
;  assemble ascii date/time string
;
ascii = dow_str + ' ' + mnames[month-1] + ' ' + daystr + ' '
ascii = ascii + '00:00:00' + ' ' + strtrim(year,2)
return, ascii
;
end

