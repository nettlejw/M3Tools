pro m3_run_params_on_sli, event
compile_opt strictarr
;
; code that lets you run a set of M3 parameters on a spectral library
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
;  borrow the regular parameters gui to get all the input
;
m3_params_gui, 'All', infile, dims, outfile, params_list, type=envi_file_type('ENVI Spectral Library'), $
  prompt='Select input SPECTRAL LIBRARY', in_fid=slifid, /no_channel_check
if slifid[0] eq -1 then return  
;
; get wl info & number of parameters
;
envi_file_query, slifid, wl=wl, spec_names=spec_names
np=n_elements(params_list)
;
;  read in the spectral library & transpose it to make it a BIL tile
;
sli = transpose(envi_get_data(fid=slifid, dims=dims, pos=0))
s=size(sli,/dimensions)
;
;  open the output file
;
openw, lun, outfile, /get_lun, width = 1000  ;long width just in case there's lots of params
;
;  set up header line
;
tab = string(9b)
display_list=strarr(np)
for i = 0,np - 1 do display_list[i] = strmid(params_list[i],10,strlen(params_list[i])-1)
header = ['Spectrum', strupcase(display_list) ] + tab
printf, lun, header
;
;  calculate zmask for sli tile
;
zmask=m3_params_get_zmask(sli, wl)
;
;  call parameters in a loop
;
out_tile = fltarr(s[0], np)
for j = 0, np - 1 do begin
  out_tile[*,j] = call_function(params_list[j], sli, wl, zmask=zmask)
endfor
;
; now transpose output back for reporting purposes and convert to string
;
pstring = strtrim(transpose(out_tile), 2)
;
;  construct output, write to file and close the file
;
for z = 0, s[0] - 1 do printf, lun, [spec_names[z], pstring[*,z]] + tab
free_lun, lun
;
end