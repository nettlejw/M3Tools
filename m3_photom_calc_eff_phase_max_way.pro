pro m3_photom_calc_eff_phase_max_way, event
;
;  calculates the phase angle that should be looked up in the 
;  phase angle correction table made by Bonnie/Mike.
;
;  This routine reads in the phase angle (g) band from the OBS file
;  backplane cube.  It then reads the to-sun zenith (i) and the
;  to-m3 zenith (e) backplanes and does the following:
;
;  if i > e then g is made negative (image closer to terminator)
;  
;  if i < e then g remains positive  (image closer to limb)
;
; --------------------------------------------------------------
;
;  ask for input file, allow spatial subset but no spectral subset
;
envi_select, title='Select OBS File', fid=fid, dims=dims, /no_spec, /file_only
if fid eq -1 then return
;
;  get OBS band names and figure which band indices to use
;
envi_file_query, fid, bnames=bnames
i_pos = where(bnames eq 'To-Sun Zenith (deg)', count)  ;should be 1
if count eq 0 then message, 'Could not find To-Sun Zenith band'
e_pos = where(bnames eq 'To-M3 Zenith (deg)', count)   ;should be 3
if count eq 0 then message, 'Could not find To-M3 Zenith band'
g_pos = where(bnames eq 'Phase (deg)', count)           ;should be 4
if count eq 0 then message, 'Could not find Phase band'
pos=[g_pos, i_pos, e_pos] ;b1, b2, b3
;
;  get output file name, no output to memory for now
;
tlb = widget_auto_base(title = 'M3 Level 2')
ofw = widget_outf(tlb, uvalue='outf', func='m3_file_test', /auto)
result = auto_wid_mng(tlb)
if result.accept eq 0 then return
outfile = result.outf
;
; set up the band math expression
;
exp = '((b1 gt (b2>b3))+1b)*(b1 ne 0)'
;
;  do the band math
;
envi_doit, 'math_doit', fid=[fid,fid,fid], pos=pos, dims=dims, $  
    exp=exp, out_name=outfile, r_fid=r_fid, out_bname='Effective Phase (deg)'
;
end 

