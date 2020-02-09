pro m3_file_search_tool, event, search_arg
;
; PURPOSE:  allows user to search for M3 files using wildcards and a recursive search 
;           through their archive directory, so they don't need to know which op a 
;           file is in to find it.
;
;----------------------------------------------------------------------------------------
compile_opt strictarr
;
;  fail if no default directory is set
;
prefs=obj_new('m3_prefs')
archive_dir=prefs->get('archivedir')
obj_destroy, prefs
if ~file_test(archive_dir, /directory) then begin
  msg='Your archive directory is either not set or set to a non-existant directory.  Please fix.'
  ok=dialog_message(msg)
  return
endif
if strmid(archive_dir,0,1,/reverse_offset) ne path_sep() then archive_dir=archive_dir+path_sep()
;
;  set up search string based on whether or not an input argument is present
;
if n_elements(search_arg) gt 0  and size(search_arg, /type) eq 7 then begin
    search_arg=search_arg[0]
    search_str=search_arg+'*'
  endif else begin
    ;
    ;  set up widget to get search strings
    ;
    list = ['Choose Available', 'ARFL','RDN', 'PARAMS', 'OBS', 'LOC']
    tlb=widget_auto_base(title='M3 File Search Tool')
    ws = widget_string(tlb, prompt='Enter search string:', uvalue='str', /auto)
    wm = widget_menu(tlb, list=list, prompt='File types to return:', uvalue='menu', $
            default_ptr=0,rows=2,/exclusive, /frame, /auto)  
    result = auto_wid_mng(tlb)  
    if (result.accept eq 0) then return
    file_type=result.menu  
    ;
    ;  build search string
    ;
    if file_type eq 0 then begin
      if strmid(result.str,0,4, /reverse_offset) eq '.IMG' then search_str=result.str else $
      search_str=result.str+'*.IMG'
    endif else search_str=result.str+'*_V??_'+list[file_type]+'.IMG'
    ;
endelse   
search_report='search string:  '+search_str
dir_report='search dir (recursive):   '+archive_dir     
;
;  do the search
;
found_files=file_search(archive_dir, search_str, count=nf)
;
; subset if >25 files found, and warn user
;
;if nf gt 25 then begin
;  ok=dialog_message('Found '+strtrim(nf,2)+' files.  Truncating results to 1st 25 files.')
;  found_files=found_files[0:24]
;endif  
;
; fail if no files found
;
if nf eq 0 then begin
  msg=['No files were found meeting your criteria.', search_report, dir_report]
  envi_error, msg
  return
endif
;
;  filter out hdr files
;
ff_copy=strlowcase(found_files)
keep=where(stregex(ff_copy,'.hdr$',/boolean) eq 0, count)
if count eq 0 then begin
  envi_error, 'Only header files were found.'
  return
endif
found_files=found_files[keep]
;
;  filter out lbl files
;
ff_copy=strlowcase(found_files)
keep=where(stregex(ff_copy,'.lbl$',/boolean) eq 0, count)
if count eq 0 then begin
  envi_error, 'Only pds labels were found.'
  return
endif
found_files=found_files[keep]
;
;  filter out lbl files
;
ff_copy=strlowcase(found_files)
keep=where(stregex(ff_copy,'.tab$',/boolean) eq 0, count)
if count eq 0 then begin
  envi_error, 'Only TIM files were found.'
  return
endif
found_files=found_files[keep]
;
;  open if only one found
;
if nf eq 1 then begin
  envi_open_file, found_files
  return
endif
;
;  else construct new widget to ask which files to open.
;
bn=file_basename(found_files)
tlb = widget_auto_base(title='Select Files to Open')  
wm = widget_multi(tlb, list=bn, uvalue='selected', ysize=550,/auto)  
result = auto_wid_mng(tlb)  
if (result.accept eq 0) then return  
;
;  open selected files
;
to_open=where(result.selected eq 1, nf)
final_list=found_files[to_open]
envi_open_file, final_list
;
end