pro m3_ground_truth_apply, event
;
;  PURPOSE:  reads K data csv file made by Peter and multiplies it into an input file
;
;-------------------------------------------------------------------------------------
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
;  read the csv file containing the multipliers
;
csv_file=filepath('M3_KCorrections_1.csv', root_dir=m3_programrootdir(), subdir=['resources', $
           'ground_truth'])
if ~file_test(csv_file) then csv_file=dialog_pickfile(title='CSV File not found, please select:', filter='.csv')
if ~file_test(csv_file) then return
n_csv_lines=file_lines(csv_file)
all_csv_lines=strarr(n_csv_lines)
openr, lun, csv_file, /get_lun
readf, lun, all_csv_lines
free_lun, lun
;
; every other line in the csv file Peter made reads as a blank line for me, so strip off every
; other line
;
line_idx=indgen(n_csv_lines)
good_lines_idx=where(line_idx mod 2 eq 0)
good_csv_lines=all_csv_lines[good_lines_idx]
n_csv_lines=n_elements(good_csv_lines)
;
; read header and count number of columns
;
headers=strsplit(good_csv_lines[0], ',', /extract, /preserve_null)
n_csv_cols=n_elements(headers)
;
; now create an intermediate data array with both wavelengths and polishers but no headers
;
data=dblarr(n_csv_cols, n_csv_lines-1)
for i=1, n_csv_lines-1 do data[*,i-1]=strsplit(good_csv_lines[i], ',',/extract,/preserve_null)
;
;  now create separate wavelength and multipliers arrays
;
csv_wl=data[0,*]
multipliers=data[1:n_csv_cols-1,*]
;
;  strip the wavelength label out of the headers array
;
headers=headers[1:n_csv_cols-1]
;
; get file to apply polishers to, set inheritance to copy map info
;
envi_select, fid=in_fid, dims=dims, pos=pos, title='Select file to apply multiplier to:'
if in_fid[0] eq -1 then return
envi_file_query, in_fid, fname=fname, nb=nb
inherit=envi_set_inheritance(in_fid, dims, pos, /spatial)
;
;  polishers are only for global data
;
if nb gt 85 then message, 'Ground truth corrections are only to be used on global data.'
;
;  ask user which muliplier to use
;
tlb=widget_auto_base(title='M3 Ground Truth')
ws=widget_slist(tlb,list=headers,uvalue='selected',prompt='Pick Multiplier:',/auto)
wo=widget_outfm(tlb,uvalue='outf',/auto)
result=auto_wid_mng(tlb)
if result.accept eq 0 then return
;
;  get output dimensions 
;
ns=dims[2]-dims[1]+1
nl=dims[4]-dims[3]+1
nb=n_elements(pos)
;
;  get selected multiplier, resize it to the size of a BIL tile
;
mult_spectrum=multipliers[result.selected,pos]
mult_bil=rebin(mult_spectrum,ns,nb)
;
;  make sure in-memory processing is safe
;
m_res=magic_mem_check(fid=in_fid,dims=dims, out_dt=4, nb=nb, out_name=result.outf.name,$  
  in_memory=result.outf.in_memory)  
if (m_res.cancel) then return  
in_memory = m_res.in_memory  
out_name = m_res.out_name  
;
;  set up output
;
if in_memory eq 1 then out_cube=fltarr(ns,nl,nb) else openw, out_lun, out_name, /get_lun
;
;  set up tile loop 
;
tile_id=envi_init_tile(in_fid,pos,interleave=1,num_tiles=num_tiles, xs=dims[1], xe=dims[2])
if(in_memory) then ostr = 'Output to Memory' else ostr = 'Output File: ' + out_name  
rstr = ["Input File: " + file_basename(fname), ostr]  
envi_report_init, rstr, title='M3 Ground truth', base=rbase, /interrupt
envi_report_inc, rbase, num_tiles
;
; tile loop
;
for i = 0, num_tiles-1 do begin
  ;
  ;  update progress bar
  ;
  envi_report_stat, rbase, i, num_tiles, cancel=cancel
  if (cancel eq 1) then begin
    envi_report_init, base=rbase, /finish
    if in_memory eq 0 then free_lun, lun 
  endif
  ;
  ;  get a tile and multiply polisher
  ;
  in_tile=double(envi_get_tile(tile_id,i))
  out_tile=float(in_tile*mult_bil)
  ;
  ;  output
  ;
  if in_memory eq 1 then out_cube[*,i,*]=mult_bil else writeu, out_lun, out_tile
endfor  
;
;  close tiles and output
;
envi_tile_done, tile_id
envi_report_init, base=rbase, /finish
if in_memory eq 0 then free_lun, out_lun
;
;  set up header or enter array into avail bands list
;
wl=csv_wl[pos]
bnames='Ground Truth Band ' + strtrim(indgen(nb)+1,2)
if in_memory eq 1 then begin
   envi_enter_data, out_cube, bnames=bnames, wl=wl
 endif else begin
   envi_setup_head, fname=out_name, ns=ns, nl=nl, nb=nb, data_type=4, offset=0, interleave=1, $
     wl=wl,bnames=bnames, inherit=inherit, /write, /open   
endelse     
;
end