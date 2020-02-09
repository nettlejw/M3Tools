pro m3_figure_and_apply_flip_and_subset_gui, event
;
;  Asks user for input and output files and feeds them to Joe's code
;
;-----------------------------------------------------------------------------------
compile_opt strictarr
;
;  error handling
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF
;
;  ask for input file
;
envi_select, fid=fid, title='Select Input File:', /file_only, /no_spec, /no_dims
if fid eq -1 then return
envi_file_query, fid, fname=ifile
;
;  ask for output file
;
tlb=widget_auto_base(title='M3 L0 Subset')
wo=widget_outf(tlb, uvalue='outf', func='m3_file_test', /auto)
result=auto_wid_mng(tlb)
if result.accept eq 0 then return
ofile=result.outf
;
;  hand off to the code that does the actual flipping/subsetting
;
m3_figure_and_apply_flip_and_subset,ifile,ofile
envi_open_file, ifile  ;put ifile back in avail bands list
envi_open_file, ofile
;
end