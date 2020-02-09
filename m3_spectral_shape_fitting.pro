;+
; NAME:
;	LINEAR_SPECTRAL_UNMIXING
;
; PURPOSE:
;	This function calculates Mean-Square minimization to fit a spectrum
; 	by a linear combination of three endmembers spectra:
;	a mineral spectrum and two spectral slopes
; 	It returns a parameter that is sensitive to the abundance (higher values)
; 	and an associated RMS that is low when the likelihood of presence of a mineral is high
; 	The spectral slopes endmembers are designed to accommodate variations in albedo due to different illuminations
;	and observation geometries, as well as spectral slope of Lunar spectra due to surface maturity
;
; CATEGORY:
;	Spectral shape fitting
;
; CALLING SEQUENCE:
;	Result = LINEAR_SPECTRAL_UNMIXING(Spectrum, Band_shape, Nb)
;
; INPUTS:
;	Spectrum:	Array that contains the spectrum to be analyszed
;	Band_shape:	2-D array that contains one mineral spectral endmember and two spectral slopes
;	Nb:	Number of wavelengths (not the full spectral range of the instrument)
;
; RESTRICTIONS:
;	The results are only indicative of the presence of mafic minerals,
; 	and should be interpreted just like classical spectral parameters.
;	For example, mixtures of several materials are not considered
;
; MODIFICATION HISTORY:
; 	Written by:	Jean-Philippe Combe, December 15, 2008.
;	December 17, 2008	add of the COMPILE_OPT STRICTARR directive to support ENVI RT users
;						arrays have been subscripted with [ ]'s rather than with ( )
;-


function Linear_spectral_unmixing, spectrum, band_shape, nb
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
 return, -1
ENDIF
;
;  Covariance matrix
;
cov = (transpose(band_shape) ## band_shape)/nb
;
;  Covariance vector
;
vec_cov = (spectrum ## band_shape)/nb
;
;  Mixing coefficients
;
mix_coef = invert(cov) ## vec_cov
;
;  Modeled spectrum
;
mix_coef = transpose(mix_coef)
mix_coef_m = mix_coef # replicate(1,nb)
model = band_shape*mix_coef_m
model = total(model,1)
;
;  Root-Mean Square Error
;
RMSE = SQRT(1./nb*TOTAL((spectrum - model)^2))
;
;  Spectral parameter to be returned
;  
;  parameter = mix_coef(0) / rmse
parameter = [mix_coef[0], rmse]
;
;  Negative values are not relevant for mineral detection
;  therefore they are set to zero
if parameter[0] lt 0 then begin
;   parameter = 0
  parameter = [0.,0.]
endif
;
return, parameter
;
end

;+
; NAME:
;	PARAMETER_PREPARATION
;
; PURPOSE:
;	This function calculates the spectral slopes that accommodate partially the effects of Lunar surface maturity
;	When a stable version of the method is adopted, that part should be an input, and this function will be supressed
;
; CATEGORY:
;	Spectral analysis of M3 hyperspectral data
;
; CALLING SEQUENCE:
;	PARAMETER_PREPARATION, Spectrum, Wl, Band_shape, Imineral, Nb
;
; INPUTS:
;	Spectrum:	Array that contains the spectrum to be analyszed
;	Wl:	Array that contains wavelengths of the spectrum (not the full spectral range of the instrument)
;	Band_shape:	Array that contains the mineral spectral endmember
; 	Imineral: Array of selected spectral range
;	Nb:	Number of wavelengths (not the full spectral range of the instrument)
;
; RESTRICTIONS:
;	The variables contained in the M3_mineral_parameters.idl file are designed
;	for the wavelengths of the M3 instrument in global mode only
;
; MODIFICATION HISTORY:
; 	Written by:	Jean-Philippe Combe, December 15, 2008.
;	December 17, 2008	add of the COMPILE_OPT STRICTARR directive to support ENVI RT users
;						arrays have been subscripted with [ ]'s rather than with ( )
;-
function Parameter_preparation, spectrum, wl, band_shape, imineral, nb
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
 return, -1
ENDIF
;
;  subset
;
spectrum_mineral = spectrum[imineral]
;
;  Building the spectral slopes
;  While the method is still under testing, it is more convenient
;  to calculate the spectral slopes in the program
;
max_value = 1
;positive spectral slope
ap = max_value/(max(wl[imineral])-min(wl[imineral]))
bp = 0. - ap*min(wl[imineral])
dp = ap*wl[imineral]+bp
;negative spectral slope
an = -max_value/(max(wl[imineral])-min(wl[imineral]))
bn = max_value - an*min(wl[imineral])
dn = an*wl[imineral]+bn
;
;  All three spectral "endmembers" in the same array
;
band_shapes = transpose([[band_shape], [dp], [dn]])
;
; Calculation of the mineral parameter
;
mineral_p = Linear_spectral_unmixing(spectrum_mineral, band_shapes, nb)
;
return, mineral_p
;
end

;#####################################################################################
;MAIN PROGRAM
;#####################################################################################

; $Id: Spectral_shape_fitting.pro,v 1.0 2008/12/15 16:55:00  $
;
;+
; NAME:
;	SPECTRAL_SHAPE_FITTING
;
; PURPOSE:
;	This procedure reads hyperspectral images and calculates similarity to spectral shapes of minerals.
; 	Those minerals are Olivine, Clinopyroxene and Orthopyroxene so far.
; 	Wavelengths and minerals are set up for data of the Moon Mineral Mapper (M3) instrument in global mode
;
; CATEGORY:
;	Spectral analysis of M3 hyperspectral data
;
; CALLING SEQUENCE:
;	M3_SPECTRAL_SHAPE_FITTING
;
; INPUTS:
;	ENVI menu event structure (currently not used but is required by ENVI)
;
; RESTRICTIONS:
;	The variables contained in the M3_mineral_parameters.idl file are designed
;	for the wavelengths of the M3 instrument in global mode only
;
;
; EXAMPLE:
;	M3_SPECTRAL_SHAPE_FITTING 
;
; MODIFICATION HISTORY:
; 	-Written by:	Jean-Philippe Combe, December 15, 2008.
; 	-December 17, 2008	add of the COMPILE_OPT STRICTARR directive to support ENVI RT users
;						arrays have been subscripted with [ ]'s rather than with ( )
;		-December 22, 2008  added support for ENVI routines, better support of ENVI RT, and some standard
;		        M3 functionality.				
;-
pro m3_spectral_shape_fitting, event
;
;standard compiler directive, forces you to use []'s to denote array subscripts
;
COMPILE_OPT strictarr
;
;simple (standard) error catching mechanism
;
CATCH, error
IF (error NE 0) THEN BEGIN
  catch, /cancel
  ok = m3_error_message()
  return
ENDIF
;
;  Ask for input file, no subsetting allowed
;
ENVI_SELECT, Title='Select Input file', fid=fid_0, /no_spec, /no_dims, /file_only
if fid_0[0] eq -1 then return
;
;  Now ask for output file using ENVI auto managed widget
;
tlb = widget_auto_base(title='Select Output File')  
wo = widget_outf(tlb, uvalue='outf', func='m3_file_test', /auto)  
result = auto_wid_mng(tlb)  
if (result.accept eq 0) then return  
fname_1 = result.outf 
;
;  Restore saved spectral library files
;
restore, filepath('M3_mineral_parameters.idl', root_dir=m3_programrootdir(), $
                subdir=['resources'])
opx0=opxt[iopx0]
cpx0=cpxt[icpx0]
ol0=olt[iol0]
;
;  Gather input file details
;
envi_file_query, fid_0, $
  fname = fname0, $
  file_type = file_type, $
  data_type = data_type, $
  wl = wl, $
  ns = ns, $
  nl = nl, $
  nb = nb
;
;  set up output array & open output file
;  
; parameters_bil = fltarr(ns, 3)
parameters_bil = fltarr(ns, 6)
openw, u1, fname_1, /get_lun
;
;  set up status report widget
;
envi_report_init, ['Moon Mineral Mapper data (global mode)'], title = 'Spectral shape fitting for mafics', base=base_progression_image, /interrupt
envi_report_inc, base_progression_image, nl
;
;  loop over each line, then loop over each spectrum in the line
;
for l = 0L, nl-1L do begin
  ;
  ; get a line 
  ;
  spectra = envi_get_slice(fid = fid_0, line = l)
  ;
  ; now loop over each spectrum in the line
  ;
  for s = 0L, ns-1L do begin
    ; 
    ;  subset to a spectrum
    ;
    spectrum = reform(spectra[s,*])
    ;
    ;  shape fitting
    ;
    params = Parameter_preparation(spectrum, wl, ol0, iol0, nb_ol0)
    parameters_bil[s,0] = params[0]
    parameters_bil[s,3] = params[1]
    params = Parameter_preparation(spectrum, wl, cpx0, icpx0, nb_cpx0)
    parameters_bil[s,1] = params[0]
    parameters_bil[s,4] = params[1]
    params = Parameter_preparation(spectrum, wl, opx0, iopx0, nb_opx0)
    parameters_bil[s,2] = params[0]
    parameters_bil[s,5] = params[1]
    ;
  endfor
  ;
  ;  output to file
  ;
  writeu, u1, parameters_bil
  ;
  ;  Widget for progression bar
  ;
  envi_report_stat, base_progression_image, l, nl, cancel = cancel
  if cancel eq 1 then begin
     base_gestion = widget_auto_base(title='Spectral shape fitting processing interruption')
     list_gestion = ['Continue unfinished processing', 'Cancel processing (no saving)']
     we = widget_pmenu(base_gestion, list=list_gestion, uvalue='menu', /auto, default = 0)
     gestion = auto_wid_mng(base_gestion)
     if (gestion.accept eq 0) then return
     if (gestion.menu gt 0) then begin
       envi_report_init, base=base_progression_image, /finish
       return
     endif
  endif
  ;
endfor
;
;  remove status widget, close output file, and setup header
;
envi_report_init, base=base_progression_image, /finish
free_lun, u1
envi_setup_head, fname = fname_1, $
  ns = ns, $
  nl = nl, $
;  nb = 3,$;
  nb = 6,$;
  data_type = 4, $
  file_type = file_type, $
;  bnames=['Olivine', 'Clinopyroxene (High-Ca Pyroxene)', 'Orthopyroxene (Low-Ca Pyroxene)'], $
  bnames=['Olivine', 'Clinopyroxene (High-Ca Pyroxene)', 'Orthopyroxene (Low-Ca Pyroxene)','RMS Olivine', 'RMS Clinopyroxene (High-Ca Pyroxene)', 'RMS Orthopyroxene (Low-Ca Pyroxene)'], $
  interleave = 1, $;
  /write, /open
;
end

