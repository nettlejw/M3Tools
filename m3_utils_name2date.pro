function name2date_dow, month, day, year
;
;  assumes March 24, 2002, is a Sunday
;
dowstr = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
dow = (julday(month,day,year) - julday(3,24,2002)) MOD 7
dow = (dow + 7) MOD 7 
;
return, dowstr[dow]
;
end

function m3_utils_name2date, basename, julian=julian, return_array=return_array, $
                             month=month, day=day, year=year, $
                             hour=hour, minutes=minutes, seconds=seconds
;
;  PURPOSE:  Utility function that takes an m3 basename as input and returns the date and time
;            information on the date of observation.  Array input is supported.  Input
;            can be either just the M3 basename or a full filename. 
;
;  RETURN VALUES:
; 
;    By default (if no other keywords are set), the function returns a standard ASCII 
;    date/time string (ex: "Sat Nov 22 23:29:06 2008").  Return value is modified by 
;    these keywords:
;
;    JULIAN          Set this keyword to return julian dates (in double type) corresponding to the input.
;
;    RETURN_ARRAY    Set this keyword to return an integer array with dimensions [6,n] where n = number
;                    of elements of input.  This is an array you can search with things like WHERE().
;                    Columns are month, day, year, hour, minutes, seconds in that order.
;    
;    OTHER KEYWORDS:  set month, day, year, hour, minutes, seconds keywords to named variables to 
;                     return those arrays individually.
;-----------------------------------------------------------------------------------
;
;  test name array
;
;basename = replicate('M3G20081122T232906',25)
;
;  program-wide variables
;
nf = n_elements(basename)
tab = string(9b)
mnames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', $
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
;
;  extract the date and time portions of the string
;
yrstr = strmid(basename,3,4)
monstr = strmid(basename,7,2)
daystr = strmid(basename,9,2)
hourstr = strmid(basename,12,2)
minstr = strmid(basename,14,2)
secstr = strmid(basename,16,2)
;
;  convert to doubles
;
month = double(monstr)
day = double(daystr)
year = double(yrstr)
hour = double(hourstr)
minutes = double(minstr)
seconds = double(secstr)
;
;  if array keyword is set, return a data array that can be searched (ie, with where())
;
if keyword_set(return_array) then begin
  dates = intarr(6,nf)
  dates[0,*]=month
  dates[1,*]=day
  dates[2,*]=year
  dates[3,*]=hour
  dates[4,*]=minutes
  dates[5,*]=seconds
  return, dates
endif
;  return julian date if that keyword is set
;
if keyword_set(julian) then begin
  jd = julday(month,day,year, hour, minutes,seconds)
  return, jd
endif
;
;  calculate day of week
;
dow = name2date_dow(month, day, year)
;
;  can now convert individual arrays to integers to return them
;
month=fix(month)
day=fix(day)
year=fix(year)
hour = fix(hour)
minutes=fix(minutes)
seconds=fix(seconds)
;
;  assemble standard ASCII date/time string
;
ascii = dow + ' ' + mnames[month-1] + ' ' + daystr + ' '
ascii = ascii + hourstr + ':' + minstr + ':' + secstr + ' ' + yrstr
return, ascii
;
end