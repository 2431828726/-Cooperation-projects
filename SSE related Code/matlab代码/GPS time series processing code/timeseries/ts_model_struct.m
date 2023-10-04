function ts_struct = ts_model_struct()

    hyperbolic_tangents =  struct(  'amplitude', [], ...% ignored on input by model estimation,  
                                    'ap_value', [], ... % a priori value for model estimate
                                    'ap_sigma', [], ... % a priori sigma for model estimate
                                    'times', [], ...    % at which times (w/ respect to t_epoch) are such functions to be estimated
                                    'tau', [] ...       % which relaxation time should be used for the function estimated at time(i)?
                                 );

    exponentials        =  struct(  'amplitude', [], ...% ignored on input by model estimation,  
                                    'ap_value', [], ... % a priori value for model estimate
                                    'ap_sigma', [], ... % a priori sigma for model estimate
                                    'times', [], ...    % at which times (w/ respect to t_epoch) are such functions to be estimated
                                    'tau', []    ...    % which relaxation time should be used for the function estimated at time(i)?
                                 );

    logarithmics        =  struct(  'amplitude', [], ...% ignored on input by model estimation,  
                                    'ap_value', [], ... % a priori value for model estimate
                                    'ap_sigma', [], ... % a priori sigma for model estimate
                                    'times', [], ...    % at which times (w/ respect to t_epoch) are such functions to be estimated
                                    'tau', []    ...    % which relaxation time should be used for the function estimated at time(i)?
                                 );

    displacements       =  struct(  'amplitude', [], ...% ignored on input by model estimation,  
                                    'times', []  ...    % at which times (w/ respect to t_epoch) are such functions to be estimated
                                 );

    periodics           =  struct(  'amplitude', [] );  % ignored on input by model estimation,  
    

    % tells what parameters are to be estimated
    estimates   = struct( 'periodics', periodics, ...                     % periodic terms
                          'displacements', displacements, ...             % displacement terms
                          'logarithmics', logarithmics, ...               % logarithmic terms
                          'exponentials', exponentials, ...               % exponential terms
                          'hyperbolic_tangents', hyperbolic_tangents);    % hyperbolic tangent terms
                         
    % additional parameters needed for either estimation of params or model calculation 
    parameters  = struct( 't_epoch', [] );                               % epoch time (reference for all time values and t0 for linear model)

    % the estimated model and its statistics
    model       = struct( 'parlist', [], ...                              % list of (estimated) parameter names
                          'parval', [], ...                               % vector of (estimated) parameter values
                          'parcov', [], ...                               % (estimated) parameter covariance matrix
                          'residuals', [], ...                            % residuals fit vs. data
                          'chi2',   []);                                  % chi squared

    
    %now put it all together into the ts_struct
    ts_struct = struct( 'estimate', estimates, ...
                        'parameters', parameters, ...
                        'model', model);
end

%OLD STUFF:
%             obj.n     = struct( 'nper', 0, 'ndisp', 0, 'nlogs', 0, 'nexp', 0, 'ntanhs', 0);
%             obj.t     = struct( 'td', [], 'tl', [], 'te', [], 'tth', []);
%             obj.tau   = struct( 'ltau', [], 'etau', [], 'thtau', []);
%             obj.model = struct( 'periodics', [], ...            %periodic terms
%                                 'displacements', [], ...        %displacement terms
%                                 'logarithmics', [], ...         %logarithmic terms
%                                 'exponentials', [], ...         %exponential terms
%                                 'hyperbolic_tangents', [], ...  %hyperbolic tangent terms
%                                 'np', [], ...
%                                 't_ep', []', ...        % average time of the data series
%                                 'n', n, ...
%                                 't', t, ...
%                                 'tau', tau, ...
%                                 'parlist', [], ...
%                                 'parval', [], ...
%                                 'parcov', []);


