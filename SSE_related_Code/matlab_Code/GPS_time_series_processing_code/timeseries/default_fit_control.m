function fit_control = default_fit_control
%function fit_control = default_fit_control

colored = struct( 'time_unit', [], 'sig_white', [], 'sig_flicker', [], 'sig_rwalk', [] );
noisemodel = struct( 'varscale', [], 'horz_addsig_time', [], 'vert_addsig_time', [], 'colored', colored );
                      
fit_control = struct( 'outprefix', [], 'pdir', [], 'sdir', [], 'stype', [], ...
                      'outdir', [], 'plate', [], 't1_default', [], 't2_default', [], ...
                      'min_Tspan', [], 'sigtol', [], 'noisemodel', noisemodel, ...
                      'batch', [], 'sitefile', [], 'auto_outlier_rejection', [], ...
                      'station_specific_models', [], 'comment', [] );

return

