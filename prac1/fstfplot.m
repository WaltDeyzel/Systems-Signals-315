function h = fstfplot(tx,fs,flim)
%
% FSTFPLOT  Fourier series time-frequency representation
%
%           h = fstfplot(tx,fs,flim)
%
%       Inputs: tx    - time information      [time; signal]
%               fs    - frequency information [freqs; mags; phases]
%               flim  - frequency axis limits (default [-f0 (N+1)*f0])
%
%       Output: h  - line handles
%

error(nargchk(2,3,nargin));

% Split up information for convenience
T = size(tx,2);
t = tx(1,:);
x = zeros(1,T);
if (size(tx,1) == 1)
  x = t;
  t = 0:T-1;
else
  x = tx(2,:);  
end;
N = size(fs,2);
freq = fs(1,:);
mags = fs(2,:);
phases = fs(3,:);
f0 = freq(2) - freq(1);   % assumption!
if (nargin < 3)  flim = [freq(1)-f0 (N+1)*f0]; end;
  
%nonzerofreq = find(freq ~= 0);
%delays(nonzerofreq) = -fs(3,nonzerofreq)./fs(1,nonzerofreq);
%delays(find(freq == 0)) = 0;

% Build up basis functions on same time axis
cosines = repmat(mags',1,T).*cos(repmat(2*pi*freq',1,T).*repmat(t,N,1) + repmat(phases',1,T));
% Add signal projection point
%freq = [freq N*freq(2)];

% Setup border
border = 0.15;
%borderframe = 0.1;
tlimits = [min(t) max(t)];
trange = diff(tlimits);
if (trange == 0)  trange = 1; end;
tlimits = tlimits + border*trange*[-1 1];
%ttlimits = tlimits + borderframe*trange*[-1 1];
flimits = [min(freq) max(freq)];
frange = diff(flimits);
if (frange == 0)  frange = 1; end;
flimits = flimits + border*frange*[-1 1];
%fflimits = flimits + borderframe*frange*[-1 1];
%zlimits = [min(min([cosines; x])) max(max([cosines; x]))];
zlimits = [min(x) max(x)];
zrange = diff(zlimits);
if (zrange == 0)  zrange = 1; end;
zlimits = zlimits + border*zrange*[-1 1];
%zzlimits = zlimits + borderframe*zrange*[-1 1];

axislw = 1;
plotlw = 2;
set(gcf,'Renderer','zbuffer');
set(gca,'DefaultLineLineWidth',axislw,'FontSize',10,'YDir','reverse');
%axis([tlimits flimits zlimits]);
%axis manual;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
zlabel('Amplitude');
title('Time-frequency phasor representation');

for n=1:N
  % basis functions
  hb = line(t,repmat(freq(n),1,T),cosines(n,:),'LineWidth',axislw);
  % magnitude spectrum
  hs = line([t(1) t(1)],[freq(n) freq(n)],[0 mags(n)],'Color','k','LineWidth',plotlw);
  line(t(1),freq(n),mags(n),'Color','k','Marker','o','LineWidth',plotlw);
  % phase spectrum
%  line([t(end)+delays(n) t(end)],[freq(n) freq(n)],[0 0],'Color','k','LineWidth',plotlw);
end;
% time signals
hx  = line(t,repmat(flim(1),1,T),x           ,'Color','g','LineWidth',plotlw);
hxa = line(t,repmat(flim(2),1,T),sum(cosines),'Color','r','LineWidth',plotlw);
% axes
line([t(1) t(1)]    ,[flim(1)+f0/2 flim(2)-f0/2],[0 0],'Color','k','LineWidth',axislw);
line([t(1) t(end)]  ,flim([2 2])                  ,[0 0],'Color','k','LineWidth',axislw);
line([t(end) t(end)],[flim(1)+f0/2 flim(2)-f0/2],[0 0],'Color','k','LineWidth',axislw);
line([t(1) t(end)]  ,flim([1 1])                  ,[0 0],'Color','k','LineWidth',axislw);

view([-45 60]);
rotate3d on;

h = [hx hxa hs hb];
