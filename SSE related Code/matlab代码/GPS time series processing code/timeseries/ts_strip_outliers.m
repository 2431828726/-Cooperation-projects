function outseries = ts_strip_outliers(inseries)
%function outseries = ts_strip_outliers(inseries);
%  Removes points from a timeseries if the outlier flags are set.
%

%  Create a new timeseries struct and copy over the fields that do not
%   depend on the number of time records in the timeseries.

outseries = new_timeseries;
outseries.sitename  = inseries.sitename;
outseries.refllh    = inseries.refllh;
outseries.refxyz    = inseries.refxyz;
outseries.comment   = inseries.comment;
outseries.x123axes  = inseries.x123axes;
outseries.x123names = inseries.x123names;

%  Copy all time records if the outlier array is empty, or if no points are
%  marked as outliers

copy_all = isempty(inseries.outlier);
if ( ~copy_all )
    copy_all = ( norm(inseries.outlier) == 0 );
end

% List of fieldnames for those that are stored as simple 1-D vectors, and
%   those stored as cell arrays of matrices.

vec_fields = {'time', 'llh', 'east', 'esig', 'north', 'nsig', 'height', 'hsig', ...
              'outlier', 'x123' };
mat_fields = { 'enucov', 'x123cov' };

%  This code uses dynamic field names: struct.(variable)
%     where variable is a string

if ( copy_all )
    
    for i = 1:length(vec_fields)
        if ( ~isempty( inseries.(vec_fields{i}) ) )
            outseries.(vec_fields{i}) = inseries.(vec_fields{i}); 
        end
    end
    
    outseries.enu = inseries.enu;
      
    for i = 1:length(mat_fields)
        if ( ~isempty( inseries.(mat_fields{i}) ) )
            outseries.(mat_fields{i}) = inseries.(mat_fields{i}); 
        end
    end
  
else
    
    %  Find the points NOT marked as outliers and keep them.

    idx = find( inseries.outlier == 0);
    disp (['Removing ' num2str(length(inseries.time) - length(idx)) ' outliers'])
        
    for i = 1:length(vec_fields)
        if ( ~isempty( inseries.(vec_fields{i}) ) )
            v = inseries.(vec_fields{i});
            outseries.(vec_fields{i}) = v(idx); 
        end
    end
    
    outseries.enu = inseries.enu(:,idx);
      
    for i = 1:length(mat_fields)
        if ( ~isempty( inseries.(mat_fields{i}) ) )
            v = inseries.(mat_fields{i});
            outseries.(mat_fields{i}) = cell(length(idx),1);
            k = 0;
            for j = 1:length(idx)
                k = k + 1;
                outseries.(mat_fields{i}){k} = v{idx(i)}; 
            end
        end
    end
  
end


