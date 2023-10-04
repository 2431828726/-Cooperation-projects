function  out = wtsmooth(in,weight,win,overlap);

%  OUT = SMOOTH(IN,WEIGHT,WIN,OVERLAP)
%
%  Function to smooth data by moving average window of "win" number of
%  samples window, with "overlap" number of samples of overlap.
%  Each point is weighted by WEIGHT

%  Written by Guy Tytgat; 31 May, 1997

%  Assign default values to arguments not given
if nargin == 2
  win = 100;
  overlap = 0;
elseif nargin == 3
  overlap = 0;
elseif nargin < 2
  error = 'ERROR: This function requires at least two arguments';
  disp(error)
  return
end

%  Calculate how many windows we will need
npts = length(in);
nwin = fix((npts - overlap) / (win - overlap));

%  Take the mean of data within the window and assign it to "out"
for i = 1:nwin
  x1 = (i-1) * (win - overlap) + 1;
  x2 = (i * win) - ((i-1) * overlap);
  out(i) = sum(in(x1:x2).*weight(x1:x2))/sum(weight(x1:x2));
%  disp(['i = ',num2str(i),', mean = ',num2str(out(i))])
end
