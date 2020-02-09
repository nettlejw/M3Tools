pro m3_photom_falpha_norm_cube, eff_phase_file, table_file, out_file
;
;  PURPOSE:  Creates a cube of f(alpha) normalization factors based on a lookup of the 
;            effective phase band (which considers shadowed/illuminated phase cases)
;            in a table that gives the normalization factor per wavelength.  Values are
;            interpolated.
;
;----------------------------------------------------------------------------------------------
compile_opt strictarr
;
;  simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  stop
  ;return
ENDIF
;
;  handle inputs
;
if n_elements(eff_phase_file) eq 0 then message, 'must supply a file containing shadow/illum. phase band.'
if n_elements(table_file) eq 0 then message, 'must supply a normalization table spectral library.'
if n_elements(out_file) eq 0 then message, 'must specify an output file.'
;
;  open up input files
;
envi_open_file, eff_phase_file, r_fid=mask_fid, /no_realize, /no_interactive_query
if mask_fid[0] eq -1 then message, 'Could not open '+ eff_phase_file
envi_open_file, table_file, r_fid=table_fid, /no_realize, /no_interactive_query
if table_fid[0] eq -1 then message, 'Could not open '+table_file
;
;  query mask file
;
envi_file_query, mask_fid, ns=mns, nl=mnl
;
; read the sli file into memory
;
envi_file_query, table_fid, ns=tns, nl=tnl, data_type=dt, spec_names=spec_names, wl=wl
tdims=[-1,0,tns-1,0,tnl-1]
table=envi_get_data(fid=table_fid,dims=tdims,pos=0)
help, table
;
; fix spec_names
;
n_phases=n_elements(spec_names)
lut_phases=intarr(n_phases)
for i=0,n_phases-1 do lut_phases[i]=fix((strsplit(spec_names[i],' ',/extract))[0])
;
;  open output file
;
openw, lun, out_file, /get_lun
;
;  loop over lines in shadow/illum mask
;
for i = 0, mnl - 1 do begin
  if (i mod 50 eq 0) then print, i+1,mnl
  ;
  ;  get a line of data (eff_phase = "effective" phase, a name i used to use)
  ;
  eff_phase=envi_get_slice(fid=mask_fid, line=i)
  ;
  ;  make sure there are no -9999 values
  ;
  bad_idx=where(eff_phase lt -99.0d or eff_phase gt 999.0d, bad_count)
  if bad_count gt 0 then eff_phase[bad_idx]=0.0d
  ;
  ;  do the part of the phase angle interpolation that can be done by line
  ;
  indices = value_locate(lut_phases, eff_phase)
  low_vals = lut_phases[indices]
  high_vals  = lut_phases[indices+1]
  norm_factor = (eff_phase - low_vals)/(high_vals - low_vals)  ;this is the interpolation factor
  ;
  low_tile=make_array(mns,85,type=dt)
  high_tile=make_array(mns,85,type=dt)
  for j = 0, mns - 1 do begin
    if eff_phase[j] lt -999.0 then begin
      low_tile[j,*]=replicate(-9999.0,85)
      high_tile[j,*]=replicate(-9999.0,85)
    endif else begin    
      low_tile[j,*] = reform(table[*, indices[j]])
      high_tile[j,*] = reform(table[*,indices[j]+1])
    endelse  
  endfor
  ;
  ;  do the interpolation
  ;
  norm_correction = rebin(norm_factor, mns, 85)
  f_alpha_tile = double((high_tile - low_tile) * norm_correction + low_tile)
  ;
  ; set bad values back to -9999
  ;
  if bad_count gt 0 then f_alpha_tile[bad_idx]= 0.0d
  ;
  ; write to disk
  ;
  writeu, lun, f_alpha_tile
  ;
endfor
;
; close file, set up header
;
free_lun, lun
bnames = 'F(alpha) Norm Band ' + strtrim(lindgen(85)+1,2)
envi_setup_head, fname=out_file, ns=mns, nl=mnl, nb=85, data_type=5, offset=0, interleave=1, $
  wl=wl, bnames=bnames, /write
;
;  close inputs
;  
envi_file_mng, id=mask_fid, /remove
envi_file_mng, id=table_fid, /remove  
;
end