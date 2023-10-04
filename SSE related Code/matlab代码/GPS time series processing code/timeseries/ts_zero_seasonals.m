function outmodel = ts_zero_seasonals(inmodel)
%function outmodel = ts_zero_seasonals(inmodel)
% Sets the seasonal terms of a model to zero


outmodel = inmodel;

for i = 1:length(inmodel.periodics)
    
    j  = ts_parindex(inmodel.parlist, 'e', 'sin', inmodel.periodics(i));
    if ( j ~= 0 )
        outmodel.parval(j) = 0;
    end
    j  = ts_parindex(inmodel.parlist, 'e', 'cos', inmodel.periodics(i));
    if ( j ~= 0 )
        outmodel.parval(j) = 0;
    end
    
    j  = ts_parindex(inmodel.parlist, 'n', 'sin', inmodel.periodics(i));
    if ( j ~= 0 )
        outmodel.parval(j) = 0;
    end
    j  = ts_parindex(inmodel.parlist, 'n', 'cos', inmodel.periodics(i));
    if ( j ~= 0 )
        outmodel.parval(j) = 0;
    end
    
    j  = ts_parindex(inmodel.parlist, 'u', 'sin', inmodel.periodics(i));
    if ( j ~= 0 )
        outmodel.parval(j) = 0;
    end
    j  = ts_parindex(inmodel.parlist, 'u', 'cos', inmodel.periodics(i));
    if ( j ~= 0 )
        outmodel.parval(j) = 0;
    end
end

return