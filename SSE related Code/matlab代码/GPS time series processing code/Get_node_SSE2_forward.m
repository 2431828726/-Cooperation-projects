%
% This script is mainly designed for generating the command line nng, nvg.
% for second SSE, 2009.85-2011.81
%
%  Shanshan Li, 4/24/2018
%
% in the routine:
% nodfile = '~/2014_2015/research/New_velocity_model_time_period/velocity_model/SouthernAlaska_2011.81-2014.87_small/TDEFNODE_research/TDEFNODE_research1/bspn12_1_15_13/';

% awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' bspn.nod > bspn_calculatedNodeSSE2.gmt
% format: 
% Fault name, fault number, node x index, node z index, hangingwall block,
% footwall bock, node longitude, node latitutde, node depth, node phi.

nodfile = 'bspn_calculatedNodeSSE2.gmt';

scanstring   = '%s %s %f %f %s %s %f %f %f %f';

gpsfid = fopen(nodfile);

if ( gpsfid == -1 )
    error( strcat('Could not read file ', nodfile) );
end

%       read the data. Textscan will leave zeros in any fields that are
%       blank, so we don't have to worry about whether the correlations are
%       there or not.

E = textscan(gpsfid, scanstring, 'CommentStyle', '#');
fclose(gpsfid);

nodex = E{3};
nodez = E{4};

fixwall = E{6};
mvwall = E{5};

nodephi = E{10};

lengthx = length(nodex(:));
lengthz = length(nodez(:));

% dx = 3;
% dw = 2;

file1 = 'nodeindex424181.in';   % for directly copying after the command nng:

p = 1;
write_sample = ( ~isempty(file1) );

if  ( write_sample )
    fid = fopen(file1, 'w');
    
    for z = 1:14   % along downdip
 
        for x = 1:42   % along strike
            %if(x<=33)
                
                fprintf(fid, '%d ',p);
                p = p+1;
          
        end
        fprintf(fid,'\n');
        
    end
    
end

fclose(fid);

file1 = 'nodephi424181.in';   % for directly copying after the command nvg:

p = 1;
write_sample = ( ~isempty(file1) );

if  ( write_sample )
    fid = fopen(file1, 'w');

    for z = 1:14   % along downdip
            for x = 1:42   % along strike

                fprintf(fid, '%2.3f ',nodephi(p));
                p = p+1;
            end
            fprintf(fid,'\n');
    end

end
fclose(fid);
