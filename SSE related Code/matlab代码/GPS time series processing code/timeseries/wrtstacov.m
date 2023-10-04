function ok = wrtstacov(file, cdate, nsta, staname, xyz, cov);

fid = fopen(file, 'w');
n = nsta*3;

% Write the header line

string = sprintf('%5d PARAMETERS ON %7s.', n, cdate);
ok = fprintf(fid, '%s\n', string);

% Write station names and a priori XYZs

for i = 1:nsta
   k = 3*(i-1);
   string = sprintf('%5d  %4s STA X        %22.15E  +- %22.15E', ...
                    k+1, staname(i,:), xyz(1,i), sqrt(cov(k+1,k+1)));
   ok = fprintf(fid, '%s\n', string);

   string = sprintf('%5d  %4s STA Y        %22.15E  +- %22.15E', ...
                    k+2, staname(i,:), xyz(2,i), sqrt(cov(k+2,k+2)));
   ok = fprintf(fid, '%s\n', string);

   string = sprintf('%5d  %4s STA Z        %22.15E  +- %22.15E', ...
                    k+3, staname(i,:), xyz(3,i), sqrt(cov(k+3,k+3)));
   ok = fprintf(fid, '%s\n', string);
end

% Write the correlations

corr = cov2corr(cov);

for i = 2:n,
   for j = 1:i-1
      string = sprintf('%5d %5d  %22.15E', i, j, corr(i,j));
      ok = fprintf(fid, '%s\n', string);
   end
end

fclose(fid);
