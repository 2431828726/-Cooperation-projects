function timeseries = read_timeseries(file, sigtol, refvel, refllh)%function timeseries = read_timeseries(file, sigtol, refvel)% read_timeseries reads a file in the .pfiles format, and returns a struct% containing the time series information. If the refvel argument is% present, that velocity (in meters per year) is subtracted from the east,% north and height timeseries values (but not from other values).%%Optional arguments:% sigtol  3x1 array with MAXIMUM tolerance for ENU sigmas, in mm%            defaults to [100; 100; 200] mm% refvel  3x1 array with reference velocity (in ENU) to subtract from east%         north up values, in meters per year.%            defaults to [0; 0; 0]% refllh  3x1 array with reference llh value. If specified, the function%            will use this as reference for east-north-up values instead of%            the first value on the file.%            defaults to []%% The timeseries struct has the following elements:%    timeseries.time        N by 1 vector of dates (decimal year)%    timeseries.sitename    1-4 character string with site name%    timeseries.comment     Comment(s), string or cell array%    timeseries.refllh      Reference lat-long-height (3 by 1)%    timeseries.refxyz      Reference XYZ (3 by 1)%    timeseries.llh         series of Lat-long-height values%    timeseries.east        series of east values%    timeseries.esig        series of east sigmas%    timeseries.north       series of east values%    timeseries.nsig        series of east sigmas%    timeseries.height      series of east values%    timeseries.hsig        series of east sigmas%    timeseries.enu         array-stored enu values (3 by N)%    timeseries.enucov      array of cells, each with 3x3 covariance%    timeseries.outlier     array of outlier flags, 0=ok, 1=outlier%    timeseries.x123axes    3x3 column vectors of coordinate axes x1,x2,x3%    timeseries.x123names   cell array of names for coordinate axes x1,x2,x3%    timeseries.x123        array-stored (x1,x2,x3) values (3 by N)%    timeseries.x123cov     array of cells, each with 3x3 covariance%MODIFICATION HISTORY% First working version April 2007 by Jeff Freymueller% Modified 9/20/07 by JF: Add error check after fopen call to avoid crash% Modified 9/22/08 by JF: Add optional refllh argumentif ( nargin == 1 )    sigtol = [100; 100; 200];    refvel = [0; 0; 0];end    if ( nargin < 3 )    refvel = [0; 0; 0];end    if ( nargin < 4 )    refllh = [];endif ( size(refllh,2) == 3 )    refllh = refllh';end    timeseries = new_timeseries;fid = fopen(file, 'r');if (fid  == -1 )    disp(strcat('Error opening file ', file));else    c = textscan(fid, '%f %s %s %f %f %f %f %f %f %f %f %f %s');    fclose(fid);    idx = find( (c{7}<sigtol(1) & c{8}<sigtol(2) & c{9}<sigtol(3)) );        if ( ~isempty(idx) )        timeseries.time = c{1}(idx);        ndates = length(timeseries.time);        t_init = timeseries.time(1);        timeseries.sitename = c{2}(1);        timeseries.llh = zeros(3,ndates);        timeseries.llh(1,:) = c{5}(idx)';        timeseries.llh(2,:) = c{4}(idx)';        timeseries.llh(3,:) = c{6}(idx)';        if ( length(refllh) == 3 )            timeseries.refllh  = refllh;        else            timeseries.refllh  = timeseries.llh(:,1);        end        timeseries.refxyz = llh2xyz(timeseries.refllh);        xyzdiff = reshape(llh2xyz(timeseries.llh) - repmat(timeseries.refxyz, 1, ndates), ndates*3,1);        timeseries.enu = reshape(xyz2enu(timeseries.refllh, xyzdiff), 3, ndates);        timeseries.east = timeseries.enu(1,:)' - (timeseries.time - t_init)*refvel(1);        timeseries.north = timeseries.enu(2,:)' - (timeseries.time - t_init)*refvel(2);        timeseries.height = timeseries.enu(3,:)' - (timeseries.time - t_init)*refvel(3);        timeseries.esig   = c{7}(idx)/1000;        timeseries.nsig   = c{8}(idx)/1000;        timeseries.hsig   = c{9}(idx)/1000;        corr_en = c{10}(idx);        corr_ev = c{11}(idx);        corr_nv = c{12}(idx);        timeseries.enucov = cell(ndates, 1);        for i = 1:ndates,            timeseries.enucov{i} = zeros(3,3);            timeseries.enucov{i}(1,1) = timeseries.esig(i)^2;            timeseries.enucov{i}(2,2) = timeseries.nsig(i)^2;            timeseries.enucov{i}(3,3) = timeseries.hsig(i)^2;            timeseries.enucov{i}(1,2) = corr_en(i)*timeseries.esig(i)*timeseries.nsig(i);            timeseries.enucov{i}(2,1) = timeseries.enucov{i}(1,2);            timeseries.enucov{i}(1,3) = corr_ev(i)*timeseries.esig(i)*timeseries.hsig(i);            timeseries.enucov{i}(3,1) = timeseries.enucov{i}(1,3);            timeseries.enucov{i}(2,3) = corr_nv(i)*timeseries.nsig(i)*timeseries.hsig(i);            timeseries.enucov{i}(3,2) = timeseries.enucov{i}(2,3);        end    endend