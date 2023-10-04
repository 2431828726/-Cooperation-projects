function [venu, vxyz, vcov, tcov] = calc_geodvel(inplate, varargin)
%function [venu, vxyz, vcov, tcov] = calc_geodvel(inplate, varargin)
%    Two variants:
%     [venu, vxyz, vcov, tcov] = calc_geodvel(inplate, lat, long)
%     [venu, vxyz, vcov, tcov] = calc_geodvel(inplate, r)
%
%    Given an input position vector, compute the velocity (ENU) based on
%    GEODVEL (Argus et al., 2010, doi: 10.1111/j.1365-246X.2009.04463.x)
%    A Geocenter correction for use with ITRF2008 updated from that paper is
%    included, based on an email from Donald Argus (2/24/2011).
%
%    The angular velocities of each plate were not presented in the paper,
%    but these values were provided by Donald Argus in Feb. 2011 and come
%    from the same solution.
%
%    Predictiosn from this model may be compared to ITRF2008 velocities
%
%    Inputs are:
%       plate     : string     : name of the plate to be used for this computation
%           use 'no plate' or 'noplate' or 'none' to apply only geocenter
%           correction
%    And coordinates either as:
%       lat, long : column vectors of (lat, long) values 
%       r         : [x;y;z]    : XYZ position, (3 by N) column vector or 3 by N matrix
%                  r must be given in METERS
%
%    Output:
%       venu  : local ENU (3 by N) velocity vector
%       vcov  : (3 by 3N) covariance vector (ENU)
%       tcov  : (3n by 3N) covariance for all stations in XYZ
%   
%     Note: Multiple stations can be given at once.  If this is the case
%           vcov will be a (3 by 3N) matrix of the covariance for each
%           station.
%
%    The distance units of the output velocities will be meters/year.

%%
%  Figure out the inputs

%  First, the plate or plates
%    all plate names are mapped to lowercase

plate = lower(inplate);

predict_plate = 0;
switch (inplate)
    case {'none', 'noplate', 'no plate'}
        nplates = -1;
        predict_plate = 0;
    otherwise
        nplates = -1;
        predict_plate = 1;
end


%  This code might be used to allow a plate to be specified for each site
%if ( iscell(inplate) )
%    plate = lower(inplate);
%else
%    plate = lower(cellstr(inplate));
%end
%nplates = length(inplate);

%  Then the list of site coordinates

nsites = 0;

n = length(varargin);

if ( n == 1 )
    %   coordinates are given as a matrix or vector stored set of XYZs
    %     reshape this into a 3 by nsites matrix (of column vectors)
    
    r      = varargin{1};
    r      = reshape(r(:), 3, []);
    nsites = size(r, 2);
    
elseif ( n == 2 )
    %   coordinates are given by vectors of lat and long values
    %     Convert lat-long to xyz
    
    lat = varargin{1};
    lon = varargin{2};
    
    nlat = length(lat);
    nlon = length(lat);
    if ( nlat == nlon )
        nsites = nlat;
        llh = [ lat(:) , lon(:), zeros(size(lat(:))) ]';
        r = llh2xyz(llh);
    end
    
end

%  If inputs are mis-matched, we need to throw an exception to terminate
%  the execution

if ( nsites == 0 || ( nplates > 1 && nsites ~= nplates ) )
    
    if ( nsites == 0 )
    
        ME = MException('calc_geodvel:no_sites', ...
                        'Site coordinate arguments were not properly specified');
    else
    
        ME = MException('calc_geodvel:site/plate_mismatch', ...
                        'Number of plates must be equal to 1');
%           ME = MException('calc_geodvel:site/plate_mismatch', ...
%                           'Number of plates must be either 1 or equal to the number of sites');
    end
                       
    throw(ME);

end

%%
%   Load up the plate model and identify the plate

[plates, omegas, omegacov, geocenter_xyz, geocenter_cov] = load_argus2005_model;

if ( predict_plate )

    % Check to make sure that the requested plate actually exists in the model

    pmatch = strmatch(plate, plates);
    if ( sum(pmatch) == 0 )

        ME = MException('calc_geodvel:plate_not_found', ...
                            'Plate %s not found', plate);
        throw(ME);

    end

    om = omegas(:,pmatch);
    k = 3*(pmatch-1);
    omcov = omegacov(k+1:k+3,k+1:k+3);

    % Form the transformation matrix rmat

    %rmat = [];
    %
    %for i = 1: nsites
    %        rmat =[rmat; [0, r(3,i), -r(2,i);-r(3,i), 0, r(1,i);r(2,i), -r(1,i), 0] ];
    %end

    rmat = zeros(3*nsites,3);

    for i = 1: nsites
        k = 3*(i-1);
        rmat(k+1:k+3,:) = [0, r(3,i), -r(2,i); -r(3,i), 0, r(1,i); r(2,i), -r(1,i), 0];
    end

    vxyz = rmat*om;

    % calculate covariance

    tcov = rmat*omcov*rmat';

else
    %  We are not predicting a plate
    
    vxyz = zeros(3*nsites,1);
    tcov = zeros(3*nsites);
end

%  Correct for geocenter motion (estimate and covariance)

rmat = zeros(3*nsites,3);
for i = 1: nsites
    k = 3*(i-1);
    rmat(k+1:k+3,:) = eye(3);
end

vxyz = vxyz - rmat*geocenter_xyz;
tcov = tcov + rmat*geocenter_cov*rmat';

% Output velocities and covariance in column vectors

venu = zeros(size(r));
vcov = zeros(3, 3*nsites);
for i = 1:nsites
    k = 3*(i-1);
    [llh] = xyz2llh(r(:,i));
    [venu(:,i) covenu] = xyz2enu(llh, vxyz(3*i-2:3*i), tcov(3*i-2:3*i,3*i-2:3*i));
    vcov(:,k+1:k+3) = covenu;
end


return

%%
% Internal function to load the plate model

function [plates, omegas, omegacov, geocenter_xyz, geocenter_cov] = load_argus2005_model
%  Angular velocities in the tables are in units of radians per million years
%  Convert all units to radians per year

% anta -0.00115899 -0.00152263  0.00328637
% arab  0.00741655  0.00194326  0.00847657
% aust  0.00724980  0.00560919  0.00583401
% eura -0.00053595 -0.00244848  0.00359444
% noam  0.00027649 -0.00337936 -0.00018938
% indi  0.00580027  0.00130548  0.00720402
% nazc -0.00147409 -0.00766879  0.00801227
% nubi  0.00044618 -0.00282666  0.00345576
% pcfc -0.00196175  0.00498483 -0.01060919
% soam -0.00123752 -0.00141244 -0.00064365
% soma -0.00035868 -0.00341258  0.00441288
%           approximated bsaed on MORVEL
% carb -0.0000363  -0.0036865   0.0024434

% Geocenter correction for ITRF2008 and covariance
%  Sigmas on geocenter rounded up to 0.2 mm/yr (from 0.05)

geocenter_xyz = 0.001*[ 0.17; 0.26; -1.04 ];
geocenter_cov = (0.001^2)*[ 0.04 0.0 0.0 ; 0.0 0.04 0.0 ; 0.0 0.0 0.04 ];

% Geocenter correction for ITRF2005 and covariance
%
%geocenter_xyz = 0.001*[ 0.08; 0.27; -1.12 ];
%geocenter_cov = (0.001^2)*[ .056 -.002 -.020 ; -.002 .120 .009 ; -.020 .009 .092 ];

% Plate names

plates = { 'anta', 'arab', 'aust', 'eura', 'noam', 'indi', 'nazc', 'nubi', 'pcfc', 'soam', 'soma', 'carb' };

 %  Angular velocities here are in units of radians per million years

omegas = [ -0.00115899 -0.00152263  0.00328637 ; ...
            0.00741655  0.00194326  0.00847657 ; ...
            0.00724980  0.00560919  0.00583401 ; ...
           -0.00053595 -0.00244848  0.00359444 ; ...
            0.00027649 -0.00337936 -0.00018938 ; ...
            0.00580027  0.00130548  0.00720402 ; ...
           -0.00147409 -0.00766879  0.00801227 ; ...
            0.00044618 -0.00282666  0.00345576 ; ...
           -0.00196175  0.00498483 -0.01060919 ; ...
           -0.00123752 -0.00141244 -0.00064365 ; ...
           -0.00035868 -0.00341258  0.00441288 ; ...
           -0.0038872   0.0136561  -0.0236616  ];
       
       % Last entry is for CARB, approximated from MORVEL

omegas = omegas'/10^6;

%  Covariances are in units of 10^-10 radians^2 per (million years)^2
%          equivalent to 10^-22 (radian/million years)^2


 
omegacov = [ 37. 4. -2. -6. -7. 17. 20. 7. -15. -22. -8. 16. -26. -3. 3. 3. -4. 8. 0. 2. -9. 2. -10. 31. 1. 11. -30. -1. -7. 18. 13. -6. 20. ; ...
      4. 27. -20. 1. -8. 9. 2. 9. 7. 1. -11. 3. -3. -8. -9. 2. -5. 12. -3. 4. -12. 0. -2. 0. 0. 2. -5. -2. 0. -8. 2. 0. 10. ; ...
     -2. -20. 71. 0. -3. 5. 3. 4. 1. -2. -5. 3. -4. -3. -3. 3. 7. 7. -1. 2. -5. 0. -2. 4. 0. 2. -5. -1. -1. -1. 3. 1. 5. ; ...
     -6. 1. 0. 3744. 4494. 2827. 3. 10. 8. 13. -11. -5. -3. -4. -4. 16. -3. 0. -17. 3. -1. -1. -12. -12. -5. 11. 10. -12. -9. -10. 8. -9. -5. ; ...
     -7. -8. -3. 4494. 5543. 3447. -10. -15. -5. -3. 17. -3. 13. 9. 7. -15. 6. -9. 15. -5. 10. 0. 14. -2. 4. -14. 6. 11. 10. 6. -12. 9. -8. ; ...
     17. 9. 5. 2827. 3447. 2224. 11. 8. -5. -13. -10. 11. -14. -6. -4. 0. -4. 12. 1. 3. -13. 1. -5. 19. 1. 5. -21. 0. -2. 5. 6. -1. 18. ; ...
     20. 2. 3. 3. -10. 11. 46. -12. 12. -11. -11. 10. -21. -4. 0. 11. -4. 6. -8. 3. -7. 1. -14. 18. -2. 14. -19. -7. -10. 9. 14. -9. 13. ; ...
     7. 9. 4. 10. -15. 8. -12. 45. -14. 3. -19. 4. -14. -9. -8. 16. -6. 11. -16. 6. -12. 0. -15. 2. -4. 16. -6. -11. -10. -7. 13. -9. 9. ; ...
     -15. 7. 1. 8. -5. -5. 12. -14. 36. 15. -7. -8. 10. -6. -8. 6. 1. 4. -8. 3. -4. -1. 0. -19. -2. -1. 15. -5. 0. -17. -2. 0. -5. ; ...
     -22. 1. -2. 13. -3. -13. -11. 3. 15. 35. 0. 2. 14. -2. -5. 8. 1. -4. -11. 1. 4. -2. -1. -27. -3. 0. 24. -7. -1. -18. -2. -2. -15. ; ...
     -8. -11. -5. -11. 17. -10. -11. -19. -7. 0. 23. -1. 14. 12. 10. -16. 7. -13. 16. -6. 14. 0. 16. -3. 4. -15. 7. 12. 10. 8. -14. 9. -11. ; ...
     16. 3. 3. -5. -3. 11. 10. 4. -8. 2. -1. 28. -13. -2. 1. 0. -1. 6. 2. 1. -6. 1. -4. 17. 1. 4. -17. 1. -2. 9. 5. -1. 12. ; ...
     -26. -3. -4. -3. 13. -14. -21. -14. 10. 14. 14. -13. 34. -7. 11. -12. 6. -8. 10. -4. 10. -1. 17. -24. 3. -18. 24. 8. 13. -11. -17. 11. -17. ; ...
     -3. -8. -3. -4. 9. -6. -4. -9. -6. -2. 12. -2. -7. 57. -34. -7. 3. -9. 7. -4. 9. 0. 6. 0. 1. -5. 4. 5. 3. 7. -5. 3. -7. ; ...
     3. -9. -3. -4. 7. -4. 0. -8. -8. -5. 10. 1. 11. -34. 47. -5. 3. -8. 6. -4. 9. 0. 3. 5. 2. -3. 0. 4. 1. 11. -2. 1. -4. ; ...
     3. 2. 3. 16. -15. 0. 11. 16. 6. 8. -16. 0. -12. -7. -5. 705. 2855. 650. -21. 5. -4. 0. -19. -3. -6. 18. 2. -15. -14. -7. 18. -9. 1. ; ...
     -4. -5. 7. -3. 6. -4. -4. -6. 1. 1. 7. -1. 6. 3. 3. 2855. 12762. 2870. 6. -1. 6. 2. 4. 1. 1. -6. 6. 4. 4. 2. 8. 18. -4. ; ...
     8. 12. 7. 0. -9. 12. 6. 11. 4. -4. -13. 6. -8. -9. -8. 650. 2870. 706. -3. 4. -14. 1. -5. 8. 0. 5. -11. -3. -1. -5. 8. 2. 14. ; ...
     0. -3. -1. -17. 15. 1. -8. -16. -8. -11. 16. 2. 10. 7. 6. -21. 6. -3. 70. 81. 38. 1. 18. 7. 6. -17. -5. 15. 13. 9. -13. 12. 1. ; ...
     2. 4. 2. 3. -5. 3. 3. 6. 3. 1. -6. 1. -4. -4. -4. 5. -1. 4. 81. 378. 129. 0. -4. 0. -1. 4. -2. -3. -3. -3. 4. -2. 3. ; ...
     -9. -12. -5. -1. 10. -13. -7. -12. -4. 4. 14. -6. 10. 9. 9. -4. 6. -14. 38. 129. 95. 0. 6. -7. 0. -6. 12. 3. 2. 4. -6. 2. -15. ; ...
     2. 0. 0. -1. 0. 1. 1. 0. -1. -2. 0. 1. -1. 0. 0. 0. 2. 1. 1. 0. 0. 46. 0. 2. 0. 0. -2. 1. 0. 1. 1. 1. 1. ; ...
     -10. -2. -2. -12. 14. -5. -14. -15. 0. -1. 16. -4. 17. 6. 3. -19. 4. -5. 18. -4. 6. 0. 32. -6. 5. -18. 6. 13. 14. 1. -16. 12. -6. ; ...
     31. 0. 4. -12. -2. 19. 18. 2. -19. -27. -3. 17. -24. 0. 5. -3. 1. 8. 7. 0. -7. 2. -6. 51. 3. 6. -33. 4. -3. 22. 9. -1. 21. ; ...
     1. 0. 0. -5. 4. 1. -2. -4. -2. -3. 4. 1. 3. 1. 2. -6. 1. 0. 6. -1. 0. 0. 5. 3. 30. 3. -5. 4. 4. 2. -4. 4. 1. ; ...
     11. 2. 2. 11. -14. 5. 14. 16. -1. 0. -15. 4. -18. -5. -3. 18. -6. 5. -17. 4. -6. 0. -18. 6. 3. 28. -9. -12. -13. 0. 16. -12. 6. ; ...
     -30. -5. -5. 10. 6. -21. -19. -6. 15. 24. 7. -17. 24. 4. 0. 2. 6. -11. -5. -2. 12. -2. 6. -33. -5. -9. 42. -2. 3. -17. -9. 2. -23. ; ...
     -1. -2. -1. -12. 11. 0. -7. -11. -5. -7. 12. 1. 8. 5. 4. -15. 4. -3. 15. -3. 3. 1. 13. 4. 4. -12. -2. 44. -17. 0. -10. 9. 0. ; ...
     -7. 0. -1. -9. 10. -2. -10. -10. 0. -1. 10. -2. 13. 3. 1. -14. 4. -1. 13. -3. 2. 0. 14. -3. 4. -13. 3. -17. 43. 5. -12. 9. -2. ; ...
     18. -8. -1. -10. 6. 5. 9. -7. -17. -18. 8. 9. -11. 7. 11. -7. 2. -5. 9. -3. 4. 1. 1. 22. 2. 0. -17. 0. 5. 28. 2. 0. 6. ; ...
     13. 2. 3. 8. -12. 6. 14. 13. -2. -2. -14. 5. -17. -5. -2. 18. 8. 8. -13. 4. -6. 1. -16. 9. -4. 16. -9. -10. -12. 2. 250. 242. -47. ; ...
     -6. 0. 1. -9. 9. -1. -9. -9. 0. -2. 9. -1. 11. 3. 1. -9. 18. 2. 12. -2. 2. 1. 12. -1. 4. -12. 2. 9. 9. 0. 242. 325. -66. ; ...
     20. 10. 5. -5. -8. 18. 13. 9. -5. -15. -11. 12. -17. -7. -4. 1. -4. 14. 1. 3. -15. 1. -6. 21. 1. 6. -23. 0. -2. 6. -47. -66. 55. ];

omegacov = omegacov/10^22;

% Approximation for CARB

omegacov(34,34) = 300./10^22;
omegacov(35,35) = 300./10^22;
omegacov(36,36) = 300./10^22;

return