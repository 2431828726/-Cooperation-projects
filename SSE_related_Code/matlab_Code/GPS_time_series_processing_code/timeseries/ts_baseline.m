function baseline = ts_baseline(ts1, ts2, refsys)
%function baseline = ts_baseline(ts1, ts2, refsys)
%
%Computes the baseline ts1 minus ts2
% The resulting time series is converted to east-north-up based on refsys:
%    refsys = 1   means use east-north-up defined at site 1
%    refsys = 2   means use east-north-up defined at site 2
% 
% Outliers and alternative axes are ignored at this point.

baseline = [];

[tcom, idxcom1, idxcom2] = find_common_times(ts1.time, ts2.time);

if ( ~isempty(tcom) )
   
    baseline = new_timeseries;
    baseline.time = tcom;
    baseline.sitename = strcat(ts1.sitename, '-',ts2.sitename);
    baseline.comment = ['Baseline ' ts1.sitename ' minus ' ts2.sitename];
    
    if ( refsys == 1 )
        
        baseline.refllh = ts1.refllh;
        baseline.refxyz = ts1.refxyz;
        
    else
        
        baseline.refllh = ts2.refllh;
        baseline.refxyz = ts2.refxyz;
        
    end
    
    % Now we have to convert the east-north-up timeseries back to XYZ so we
    % can difference them (and then convert back).
    % First the estimates:
    
    common = ts1.enu(:,idxcom1);
    xyz1 = enu2xyz( baseline.refllh, common(:), [] );
    common = ts2.enu(:,idxcom2);
    xyz2 = enu2xyz( baseline.refllh, common(:), [] );
    dxyz = xyz1 - xyz2;
    baseline.enu    = reshape( xyz2enu(baseline.refllh, dxyz, []), 3, []);
    baseline.east   = baseline.enu(1,:)';
    baseline.north  = baseline.enu(2,:)';
    baseline.height = baseline.enu(3,:)';
    
    % Now the covariance; we have to go time point by time point
    
    baseline.esig = zeros(size(baseline.east));
    baseline.nsig = baseline.esig;
    baseline.hsig = baseline.esig;
    
    baseline.enucov = cell(length(tcom), 1);
    for i = 1:length(tcom)
        z = zeros(3,1);
        [~, xyz1cov] = enu2xyz( baseline.refllh, z, ts1.enucov{idxcom1(i)} ); 
        [~, xyz2cov] = enu2xyz( baseline.refllh, z, ts2.enucov{idxcom2(i)} ); 
        [~, baseline.enucov{i}] = xyz2enu(baseline.refllh, z, xyz1cov + xyz2cov);
        
        baseline.esig(i) = sqrt( baseline.enucov{i}(1,1) );
        baseline.nsig(i) = sqrt( baseline.enucov{i}(2,2) );
        baseline.hsig(i) = sqrt( baseline.enucov{i}(3,3) );
    end
    
end

return