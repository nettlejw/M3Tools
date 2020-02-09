pro m3_photom_calc_lommel_seeliger, event, obs_file, out_file, r_fid=r_fid
;
;  PURPOSE:  Given an OBS file, does the band math to output a lommel-seeliger
;            correction factor band.
;
;-----------------------------------------------------------------------------
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
if n_elements(obs_file) eq 0 then message, 'Must supply an OBS file as input.'
if n_elements(out_file) eq 0 then message, 'Must specify an output file name.'
;
;  query the obs file
;
envi_open_file, obs_file, r_fid=obs_fid
envi_file_query, obs_fid, ns=ns, nl=nl, nb=nb
if nb ne 10 then message, file_basename(obs_file) + ' does not have 10 bands.  Please use a 10-band OBS file.'
i_pos=1 ;b1
e_pos=3 ;b2
pos=[i_pos,e_pos]
dims=[-1,0,ns-1,0,nl-1]
;
;  set up the band math
;
exp='cos(b1*!dtor) / ( cos(b1*!dtor) + cos(b2*!dtor) )'
fid=[obs_fid,obs_fid]
out_bname='LS Band'
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
