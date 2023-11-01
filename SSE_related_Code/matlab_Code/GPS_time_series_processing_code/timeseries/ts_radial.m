function radialser = ts_radial(inser, llhref)
%function radialser = ts_radial(inser, llhref)
% Rotates a timeseries from (east, north, up) to (radial, transverse, up)
% based on the position of the site relative to the point llhref (3 vector
% with lat, long, height). The radial vector points outward from llhref to
% the site, and the transverse component defines the second axis of a
% right-handed coordinate system with up as the third axis.

% Convert the two lat-long-height values to earth-centered XYZ

xyzref  = llh2xyz(llhref);
xyzsite = llh2xyz(inser.refllh);

dxyz  = xyzsite - xyzref;
denu  = xyz2enu(llhref, dxyz);

% Compute unit vectors

horiz    = [denu(1) ; denu(2) ; 0];
radial   = horiz/norm( horiz,2 );
vertical = [0; 0; 1];
transv   = cross(vertical, radial);

x123axes  = [radial, transv, vertical];
x123names = {'Radial'; 'Transverse'; 'Up'};

radialser = ts_rotate(inser, x123axes, x123names);