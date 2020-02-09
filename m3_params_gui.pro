pro m3_params_gui, group, infile, dims, outfile, params_list, type=type, $
     prompt=prompt, in_fid=in_fid, no_channel_check=no_channel_check
;
;  PURPOSE:  Calls widgets to get info to use in calculating parameters to pass
;            to the parameters engine
;
;  Special Keywords:
;
;    NO_CHANNEL_CHECK:  By default, the program checks to make sure that the input data is 85 channel
;                       global data.  Setting this keyword bypasses that check, but use at your own risk.
;
;----------------------------------------------------------------------------------------------------------
;
;  standard compiler directive, forces you to use []'s to denote array subscripts
;
COMPILE_OPT strictarr
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
;  Get input file, allow spatial but not spectral subsetting
;
if n_elements(prompt) eq 0 then title='Select input file' else title=prompt
envi_select, fid = in_fid, dims=dims, title=title, /no_spec, file_type=type
if (in_fid[0] eq -1) then return
;
;  get image info, check for wavelength arrays
;
envi_file_query, in_fid, fname=infile, wl=wl, nb=nb
;
;  check for number of wavelengths in order to prevent inputting target data for now
;
if ~keyword_set(no_channel_check) then if (nb ne 85) then $
   message, 'At this time you must select 85-channel GLOBAL data as input to the parameters code.'
;
;  fail if no wavelength info
;
if (wl[0] eq -1) then message, 'Input file does not have associated wavelength information in its header.'
;;
;;  build list of parameter files given the group to choose from
;;
;start_dir = filepath('', root_dir=m3_programrootdir(), subdir = ['parameters'])
;if strmid(start_dir,0,1,/reverse_offset) ne path_sep() then start_dir = start_dir + path_sep()
;case group of 
; 'All':begin
;        pf1 = file_search(start_dir + 'pipeline'+path_sep()+'m3_params_*.pro')
;        pf2 = file_search(start_dir + 'supplemental'+path_sep()+'m3_params_*.pro')
;        param_files=[pf1,pf2]
;       end
; '3um':begin
;        param_files = file_search(start_dir + '3um_absorber'+path_sep()+'m3_params_*.pro')
;       end
; 'Pipeline':begin
;             param_files = file_search(start_dir + 'pipeline'+path_sep()+'m3_params_*.pro')
;             tlb = widget_auto_base(title = 'M3 Spectral Summary Parameters')
;               def=m3_params_get_badval()
;               wp = widget_param(tlb, dt=4,field=3,uvalue='badval', undefined=1e-34, $
;                                 default=def,prompt='Background Value:', /auto)
;               wf = widget_outf(tlb, uvalue='outf', func='m3_file_test', /auto_manage)
;               result = auto_wid_mng(tlb)
;               if (result.accept eq 0) then return
;             outfile=result.outf
;             params_list = file_basename(param_files, '.pro')
;             if result.badval ne 1e-34 then void=m3_params_get_badval(result.badval)
;             m3_params_engine, infile, dims, outfile, params_list
;             return  
;            end
;  else:  Message, 'Error Finding the Parameters Directory.'
;endcase           
;;
;;  make sure we found some parameters
;;
;np = n_elements(param_files)
;if (np eq 0) OR (np eq 1 and param_files[0] eq '') then message, 'Error finding parameters.'
;
;  prepare parameter files names for user selection and hand off to parameters engine
;
case group of 
  '3um': params_list = m3_params_get_params_list(/water)
  'All':params_list = m3_params_get_params_list()
  'photometry':params_list = m3_params_get_params_list(/photometry)
  else: params_list = m3_params_get_params_list()
endcase 


params_list = m3_params_get_params_list()
np=n_elements(params_list)
display_list = strarr(np)
for i = 0, np-1 do display_list[i] = strmid(params_list[i],10, strlen(params_list[i])-1)
display_list=strupcase(display_list)
;
;  Set up auto-managed widget to handle output file and select parameters
;
ysize = 450
tlb = widget_auto_base(title = 'M3 Spectral Summary Parameters')
wm = widget_multi(tlb, list = display_list, uvalue='params_selected', ysize = ysize, /auto_manage)
def=m3_params_get_badval()
wp = widget_param(tlb, dt=4,field=3,uvalue='badval', undefined=1e-34,default=def,$
                  prompt='Background Value:', /auto)
wf = widget_outf(tlb, uvalue='outf', func='m3_file_test', /auto_manage)
result = auto_wid_mng(tlb)
if (result.accept eq 0) then return
outfile=result.outf
badval=result.badval
if badval ne 1e-34 then begin
  if badval ne -1 then void=m3_params_get_badval(badval) else $
   ok=dialog_message('Bad value of -1 not supported.  Using default instead.')
endif
;
;  only process the parameters that the user selected
;
selected = where(result.params_selected eq 1, count)
if count eq 0 then message, 'No parameters were selected.'
params_list = params_list[selected]
;
end