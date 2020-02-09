function m3_utils_get_m3basenames, indir, count=count, all=all, recurse=recurse
;
;  returns a list of basenames (ex, M3G20081124T032151) for a given input directory
;  note this looks for .HDR files, and prints the unique entries only (so basenames 
;  for RDN, LOC, and OBS files, etc. aren't double printed)
;
;  ALL keyword - set this to return all basenames, not just the unique list
;  RECURSE keyword - set this for a recursive search (!)
;
;--------------------------------------------------------------------------------------------------
compile_opt strictarr
;
;  test files
;
;files = replicate('M3G20090213T022112',25) + '_V00_RDN.IMG'
;
;  handle the ALL keyword
;
if keyword_set(all) then begin
 ;assume "indir" is really a list of files
 m3_basenames = strmid(indir,0,18)
 return, m3_basenames
endif
;
;  handle normal input
;
if n_elements(indir) eq 0 then indir = dialog_pickfile(title='Select Starting Directory', /directory)
if strmid(indir,0,1,/reverse_offset) ne path_sep() then indir = indir + path_sep()
count=0
;
;  get a list of all files in the directory
;
if keyword_set(recurse) then all_files=file_search(indir, '*', count=n_allf) $
  else all_files = file_search(indir + '*', count=n_allf)
if n_allf eq 0 then return, ''  ;no files found
all_files = file_basename(all_files) ;remove paths 
;
;  find just the files long enough to contain a basename 
;
keep = where(strlen(all_files) ge 18, n_files)
if n_files le 0 then return, ''  ;still no files to process
files = all_files[keep]
;
;  extract substring the length of a basename
;
basenames = strmid(files,0,18)
;
;  check each file to make sure it fits the pattern a basename should follow
;  note that IDL's regular expression engine doesn't support the \d notation or
;  we could make this better by making sure all the characters represented as dots
;  now are numbers.  
;
pattern = 'M3(T|G)........T......'
keep = where(stregex(basenames, pattern, /boolean), n_keep)
if n_keep le 0 then return, ''
basenames=basenames[keep]
;
;  at this point we're as sure as we can be that we have a list of good M3 basenames,
;  so trim down to unique entries, and return them
;
idx = uniq(basenames, sort(basenames))
m3_basenames = basenames[idx]
count=n_elements(m3_basenames)
return, m3_basenames
;
end
;**************************************************************************************************
;  ORIGINAL VERSION OF THIS CODE IS BELOW

;
;ext = '.hdr'
;indir = dialog_pickfile(title='Select Starting Directory', /directory) 
;lastchar = strmid(indir,0,1, /reverse_offset)
;if lastchar ne path_sep() then indir = indir + path_sep()
;;
;hdr_files=file_search(indir+'*'+ext, count=n_files)
;if n_files eq 0 then message, 'No files found.'
;;
;regular_basenames = file_basename(hdr_files, ext)
;underscore = strpos(regular_basenames, '_')
;m3_basenames = reform((strmid(regular_basenames, 0, underscore))[0,*])
;idx = uniq(m3_basenames, sort(m3_basenames))
;m3_basenames = m3_basenames[idx]
;n_hdr = n_elements(m3_basenames)
;;
;if n_elements(outfile) gt 0 then openw, lun, outfile, /get_lun
;;
;for i = 0, n_hdr - 1 do begin
;  if n_elements(outfile) gt 0 then printf, lun, m3_basenames[i] else print, m3_basenames[i]
;endfor
;;  
;if n_elements(outfile) gt 0 then free_lun, lun
;;