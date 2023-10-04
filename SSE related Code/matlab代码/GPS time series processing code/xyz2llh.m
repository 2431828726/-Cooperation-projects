function llh = xyz2llh(xyz)
%
%     ... Transform from x,y,z to lat,lon,h
%

deg2rad = pi/180;
a = 6378137;
f = 1/298.257223563;
e2 = 2*f - f*f;

[junk num] = size(xyz);

for i = 1:num,
   p = sqrt(xyz(1:2,i)'*xyz(1:2,i));
   r = sqrt(xyz(:,i)'*xyz(:,i));
   lon = atan2(xyz(2,i),xyz(1,i));
%
%     ... First iteration on lat and h
%            - assumes h = 0
%
   lat = atan2(xyz(3,i)/p,(1-e2));
   n = a/sqrt((1 - e2*sin(lat)^2));
   h = p/cos(lat) - n;
%
%        ... Iterate until h converges (should be quick since h << n)
%
   oldh = -1e9;
   iter = 0;
   num = xyz(3,i)/p;
   while ( (abs(h - oldh) > 0.0001) && ( abs(lat) - pi/2) > 0.01)
      iter = iter + 1;
      oldh = h;
      den = 1 - e2*n/(n+h);
      lat = atan2(num,den);
      n = a/sqrt((1 - e2*sin(lat)^2));
      h = p/cos(lat) - n;
   end
%
   llh(1,i) = lat/deg2rad;
   llh(2,i) = lon/deg2rad;
   llh(3,i) = h;
end
