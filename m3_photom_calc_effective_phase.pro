pro m3_photom_calc_effective_phase, obs_file, out_file
;
;  PURPOSE:  Does the band math that creates a new, "effective phase" image.  The value of the
;            pixel is the same as the phase band from the input obs_file, but is marked as 
;            positive or negative according to the pixel is a shadowed or illuminated case.
;
;------------------------------------------------------------------------------------------------
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
; make sure we have the filenames we need
;
if n_elements(obs_file) eq 0 then message, 'Must supply an OBS file as input.'
if n_elements(out_file) eq 0 then message, 'Must supply an output file name.'
;
;  query the obs file
;
envi_open_file, obs_file, r_fid=obs_fid
envi_file_query, obs_fid, ns=ns, nl=nl, nb=nb
if nb ne 10 then message, file_basename(obs_file) + ' does not have 10 bands.  Please use a 10-band OBS file.'
g_pos=4 ;b1
i_pos=1 ;b2
e_pos=3 ;b3
pos=[g_pos,i_pos,e_pos]
dims=[-1,0,ns-1,0,nl-1]
;
;  set up the band math
;
;exp='( ( (b1 le (b2>b3))*(-1.0) + (b1 gt (b2>b3)) )*(b1 gt 0.0) )*double(b1)'
;exp='( ( (b1 gt (b2>b3))*(-1.0) + (b1 le (b2>b3)) )*(b1 gt 0.0) )*double(b1)' ;reversed
exp='double(b1)*(-1.0d)'
fid=[obs_fid, obs_fid,obs_fid]
out_bname='Shadow/Illum Phase Band'
;
;  call the band math function
;
envi_doit, 'math_doit', dims=dims, pos=pos, exp=exp, fid=fid, out_bname=out_bname, $
  out_name=out_file, r_fid=r_fid
;
;  close the files
;
envi_file_mng, id=obs_fid, /remove
envi_file_mng, id=r_fid, /remove  
;
end