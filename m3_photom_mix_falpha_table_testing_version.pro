pro m3_photom_mix_falpha_table_testing_version, coeffs, rdn_file, out_file, table_dir
;
;  PURPOSE:  Given a set of coefficients, mixes the three different surface phase
;            function models (highlands, mare, and Apollo 16) and creates a new
;            f(alpha) normalization table based on those coefficients that can be 
;            applied to the data.
;
;----------------------------------------------------------------------------------------
compile_opt strictarr
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
; make sure coefficients are present and sum to unity
;
if n_elements(coeffs) eq 0 then coeffs=[0.5, 0.5, 0.0]
if n_elements(coeffs) ne 3 then message, 'Coefficients must be a 3 element vector.'
if total(coeffs) ne 1.0 then message, 'Coefficients must sum to unity.'
coeffs=double(coeffs)
;
;  look at radiance file to see if input is global or target
;
mode=m3_get_imaging_mode(rdn_file, /long_str)
;
;  pick which table to use
;
all_tables_dir='D:\Work\jeffn\photometry\tables\'
subdirs=file_search(all_tables_dir+'*', /test_directory, count=n_sub)
if n_sub eq 0 then begin
  print, 'No tables were found in ' + all_tables_dir
  return
endif
subdir_names=strarr(n_sub)
for i=0,n_sub-1 do begin
  p=strpos(subdirs[i], '\', /reverse_search)
  subdir_names[i]=strmid(subdirs[i], p+1)
endfor  
base = widget_auto_base(title='Pick table to use')  
ws = widget_slist(base,list=subdir_names, uvalue='sel', /auto)  
result = auto_wid_mng(base)  
if (result.accept eq 0) then return
table_dir=subdirs[result.sel]  
if strmid(table_dir,0,1,/reverse_offset) ne path_sep() then table_dir=table_dir+path_sep()
;table_dir=filepath('',root_dir=m3_programrootdir(), subdir=['resources', 'photometry'])




;
; read in correction factor tables, starting with the highlands table
;

highlands_file=table_dir+'highlands_'+mode+'.sli'
envi_open_file, highlands_file, r_fid=highlands_fid, /no_realize, /no_interactive_query
envi_file_query, highlands_fid, ns=ns, nl=nl, nb=nb, data_type=dt, bnames=bnames, $
                 spec_names=spec_names, file_type=file_type, wl=wl
sli_dims=[-1,0,ns-1,0,nl-1]
highlands_sli=double(reform(envi_get_data(fid=highlands_fid,dims=sli_dims, pos=0)))
envi_file_mng, id=highlands_fid,/remove
;
;  now the mare table
;
mare_file=table_dir+'mare_'+mode+'.sli'
envi_open_file, mare_file, r_fid=mare_fid, /no_realize, /no_interactive_query
mare_sli=double(reform(envi_get_data(fid=mare_fid,dims=sli_dims, pos=0)))
envi_file_mng, id=mare_fid, /remove
;
;  apollo 16 table last
;
ap16_file=table_dir+'ap16_'+mode+'.sli'
envi_open_file, ap16_file, r_fid=ap16_fid, /no_realize, /no_interactive_query
ap16_sli=double(reform(envi_get_data(fid=ap16_fid,dims=sli_dims, pos=0)))
envi_file_mng, id=ap16_fid, /remove
;
;  now mix the table according to the coefficients
;
highlands_mix=highlands_sli*coeffs[0]
mare_mix=mare_sli*coeffs[1]
ap16_mix=ap16_sli*coeffs[2]
out_table=highlands_mix+mare_mix+ap16_mix
;
; write the table out to a spectral library
;
openw, lun, out_file, /get_lun
writeu, lun, out_table
free_lun, lun
envi_setup_head, fname=out_file, ns=ns, nl=nl, nb=nb, data_type=5, offset=0, interleave=0, $
  file_type=file_type, spec_names=spec_names, bnames=bnames, wl=wl, /write
;
end