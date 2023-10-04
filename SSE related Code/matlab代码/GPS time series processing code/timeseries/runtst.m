clear
[VEL,COV,NVEC,LLH] = matrdvel('tstvel.enu')
LATORG = [19.2812]
LONORG = [-155.1215]
XY = stalocxy(NVEC, LLH, LATORG, LONORG)
X = XY(1,:)
Y = XY(2,:)
EVEL = VEL(1,:)
NVEL = VEL(2,:)
UVEL = VEL(3,:)
EVEL(5) = 0
NVEL(5) = 0
UVEL(5) = 0
%
% PLOT VECTORS
figure
quiver(X,Y,EVEL,NVEL)
hold off
