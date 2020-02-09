pro m3_filedb_report_event, event
compile_opt strictarr
;
;  PURPOSE:  Event handler for the "About" window.
;
;---------------------------------------------------------------------------------------------------
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF
;
widget_control, event.id, get_value=ButtonValue
if ButtonValue eq 'OK' then widget_control, event.top, /destroy
end

pro m3_filedb_report, event
compile_opt strictarr
;
; PURPOSE:  Query the file db csv file, return info about selected strip
;
;--------------------------------------------------------------------------------------------------
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF
;
;  make sure csv file can be found or fail
;
csv_file=filepath('m3_files_db.csv', root_dir=m3_programrootdir(), subdir=['resources'])
if ~file_test(csv_file) then begin
  envi_error, 'The m3 file db csv file could not be found.'
  return
endif
;
;  get strip and strip name
;
envi_select, fid=fid, title='Select Strip:', /no_spec, /no_dims, /file_only
if fid[0] eq -1 then return
envi_file_query, fid, fname=fname
bn=strmid(file_basename(fname),0,18)
;
;  load csv file
;
nl=file_lines(csv_file)
all_lines=strarr(nl)
openr, lun, csv_file, /get_lun
readf, lun, all_lines
free_lun, lun
;
;  parse csv
;
header=strsplit(all_lines[0], ',', /extract)
nc=n_elements(header)
csv_data=strarr(nc,nl)
for i=1,nl-1 do csv_data[*,i]=strsplit(all_lines[i], ',', /extract, /preserve_null)
hdr_col=where(header eq 'Basename', count)
if count ne 1 then begin
  envi_error, 'Header column could not be found in csv file.'
  return
endif
;
; look up selected basename
;
row_idx=where(csv_data[hdr_col,*] eq bn, count)
if count ne 1 then begin
  envi_error, 'Selected file not found in database.'
  return
endif
db_info=csv_data[*,row_idx]
;
;  set up output text
;
cr=string(13b)
out_text=strarr(nc+3)+cr
for i=0,nc-1 do begin 
  line=header[i]+'='+db_info[i]+cr
  out_text[i+1]=line
endfor 
out_text=strjoin(out_text) 
;
;  construct widget to display it
;
envi_center,xoff,yoff
tlb=widget_base(title='M3Tools',column=1, /base_align_center,xoffset=xoff, yoffset=yoff)
wl=widget_label(tlb,value=out_text, xsize=250, ysize=250,/align_center, /frame)
slb=widget_base(tlb,row=1,xsize=50)
ok=widget_button(slb,value='OK', xsize=45)
widget_control, tlb, /realize
;
; register event handler
;
xmanager, 'm3_filedb_report', tlb
end