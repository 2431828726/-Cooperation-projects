%
%
% Shanshan Li 9/23/2014
% modified 12/3/2014
% update 4/22/2016, return one file which has extra three columns
% "vele,veln,velu", for sites affected by 1964 post, they will not be zero,
% for sites not affected by 1964 post, they will be zero.
%   
% Function for Compare ORiginal velocity model and postseismic velocity
% model, find out postseismic velocities for same sites in both models.
% THEN pick out the postseismic velocity for sites by using grdtrack
%
%
% % terminal commands have two parts:
% 1.awk '{print $2,$3}' SAK1-postseis-NOAM_1.horzvec | grdtrack -GSuito_east_15m.grd | grdtrack -GSuito_north_15m.grd | grdtrack -GSuito_vert_15m.grd | sed 's/\t/ /g' > SAK1-postseis-effect-NOAM_1.horzvec
% 2. paste SAK1-postseis-NOAM_1.horzvec SAK1-postseis-effect-NOAM_1.horzvec | awk '{print $1,$2,$3,$10,$11,$12}' > SAK1-postseis-NOAM_1_n.horzvec
%

function [nameDN,lonDN,latDN,veleDN,velnDN,veluDN] = Get_postseis(originalfile,postseisallfile,postInOriginfile)


%% Read velocity from Original_Velocity_Model
scanstring   = '%s %f %f';

gpsfid = fopen(originalfile);
if ( gpsfid == -1 )
    error( strcat('Could not read file ', originalfile) );
end

%       read the data. Textscan will leave zeros in any fields that are
%       blank, so we don't have to worry about whether the correlations are
%       there or not.

C = textscan(gpsfid, scanstring, 'CommentStyle', '#');
fclose(gpsfid);

%  Now assign the values to the variables to be returned
name = C{1};
lon  = C{2};
lat  = C{3};
nsta = length( lat(:) );


%% Read Velocities from Postseis Velocity model including all sites
scanstring   = '%s %f %f %f %f %f';

gpsfid = fopen(postseisallfile);
if ( gpsfid == -1 )
    error( strcat('Could not read file ', postseisallfile) );
end

%       read the data. Textscan will leave zeros in any fields that are
%       blank, so we don't have to worry about whether the correlations are
%       there or not.

D = textscan(gpsfid, scanstring, 'CommentStyle', '#');
fclose(gpsfid);

% The correlations are optional, so fill them in with zeros if the values
% are missing (returned as NaN).

% for i = 1:7
%     idxD = find( isnan(D{i}) );
%     D{i}(idxD) = 0;
% end

%  Now assign the values to the variables to be returned
nameD = D{1};
lonD  = D{2};
latD  = D{3};
veleD = D{4};
velnD = D{5};
veluD = D{6};
nstaD = length(latD(:));


%% pick out the same sites comparing two above velocity files and then list in new file
nameDN = name;
lonDN = lon;
latDN = lat;
veleDN = zeros(1,nsta);
velnDN = zeros(1,nsta);
veluDN = zeros(1,nsta);


for p = 1:nsta
    for q = 1:nstaD
       
        check_point = isequal(name{p},nameD{q});
        
        if(check_point == 1)
            nameDN{p} = nameD{q};
            lonDN(p) = lonD(q);
            latDN(p) = latD(q);
            veleDN(p) = veleD(q);
            velnDN(p) = velnD(q);
            veluDN(p) = veluD(q);
        end
        
    end
end


%% Write the filtered sites information above into the new velocity files
write_tfn = ( ~isempty(postInOriginfile) );

if ( write_tfn )
    fid = fopen(postInOriginfile, 'w');
    if ( fid == -1 )
        error( strcat('Could not read file ', postInOriginfile) );
    end
    for i = 1:nsta
        fprintf(fid, '%5s %4.5f %4.5f %3.12f %3.12f %3.12f\n',...
            nameDN{i},lonDN(i),latDN(i),veleDN(i),velnDN(i),veluDN(i));
    end
    fclose(fid);
end






















return