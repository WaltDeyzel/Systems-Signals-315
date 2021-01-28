function h = cstmplot(amplitudes,centers,name,xlim)
%
%CSTMPLOT   Plots complex stems
%
%       Plots complex stems as a 2D function of time (frequency), 
%       with 2D projections to illuminate the sketch. The only difference
%       between signal and spectra plots is the axis labels, as specified by
%       the name input.
%
%                        h = cstmplot(amplitudes,centers,name,lim)
%
%       Inputs: amplitudes - vector of complex stem amplitudes
%               centers    - vector of stem positions (default=integers)
%               name       - string containing name of abscissa (default = 't')
%               xlim       - axis limits (default [-f0 (N+1)*f0])
%
%       Output: h          - vector of handles for primary lines
%                            in order [Re-Im-name Re-name Im-name Re-Im]
%

error(nargchk(1,4,nargin));

if (nargin < 2)  centers = 0; end;
if (nargin < 3)  name = 't'; end;

if length(centers) == 1  
  centers = centers + (0:length(amplitudes)-1); 
end;

realamps = real(amplitudes);
realamps(abs(realamps) < 1000*eps) = 0;
imagamps = imag(amplitudes);
imagamps(abs(imagamps) < 1000*eps) = 0;

%spread = max([1 centers(end)-centers(1)]);
spacing = max(centers(2:end) - centers(1:end-1));
if (isempty(spacing))  spacing = 2*centers(1); end;
if (spacing == 0)  spacing = 1; end;
x = centers(1)-spacing;
y = NaN;
z = NaN;
for n = 1:length(centers)
  x = [x centers(n) centers(n) centers(n)];
  y = [y 0 imagamps(n) NaN];
  z = [z 0 realamps(n) NaN];
end;
x = [x centers(end)+spacing];
y = [y 0];
z = [z 0];

border = 0.2;
borderframe = 0.1;
if (nargin < 4)
  xlimits = [min(x) max(x)];
else
  xlimits = xlim;
end;
xrange = diff(xlimits);
if (xrange == 0)  xrange = 1; end;
xlimits = xlimits + border*xrange*[-1 1];
xxlimits = xlimits + borderframe*xrange*[-1 1];
ylimits = [min(y) max(y)];
yrange = diff(ylimits);
if (yrange == 0)  yrange = 1; end;
ylimits = ylimits + border*yrange*[-1 1];
yylimits = ylimits + borderframe*yrange*[-1 1];
zlimits = [min(z) max(z)];
zrange = diff(zlimits);
if (zrange == 0)  zrange = 1; end;
zlimits = zlimits + border*zrange*[-1 1];
zzlimits = zlimits + borderframe*zrange*[-1 1];

projectoffset = 0.8;
xproject = xlimits(1) - 0.3*projectoffset*xrange;
yproject = ylimits(2) + 1.1*projectoffset*yrange;
zproject = zlimits(1) - projectoffset*zrange;

axislw = 1;
plotlw = 2;
axiscol = 'k';
plotcol = 'b';
set(gca,'DefaultLineLineWidth',axislw,'FontSize',10);

% axes
line(xlimits,[0 0],[0 0],'Color',axiscol);
line([0 0],ylimits,[0 0],'Color',axiscol);
line([0 0],[0 0], zlimits,'Color',axiscol);
% arrows
line(xlimits(2)*[0.9 1 0.9],yrange*[-0.05 0 0.05],[0 0 0],'Color',axiscol);
line(xrange*[-0.03 0 0.03],ylimits(2)*[0.85 1 0.85],[0 0 0],'Color',axiscol);
line([0 0 0],yrange*[-0.03 0 0.03],zlimits(2)*[0.85 1 0.85],'Color',axiscol);
% 3D plot
h(1) = line(x,y,z,'LineWidth',plotlw,'Color',plotcol);
h(5) = line(centers,imagamps,realamps);
set(h(5),'LineWidth',plotlw,'Color',plotcol,'Marker','o','MarkerFaceColor',plotcol,'LineStyle','none');

% axes
line(xlimits,yproject*[1 1],[0 0],'Color',axiscol);
line([0 0],yproject*[1 1],zlimits,'Color',axiscol);
% frame
line(xxlimits([1 2 2 1 1]),yproject*ones(1,5),zzlimits([1 1 2 2 1]),'Color',axiscol);
% axis arrows
line(xlimits(2)*[0.9 1 0.9],yproject*[1 1 1],zrange*[-0.05 0 0.05],'Color',axiscol);
line(xrange*[-0.03 0 0.03],yproject*[1 1 1],zlimits(2)*[0.85 1 0.85],'Color',axiscol);
% Re-t plot
h(2) = line(x,yproject*ones(size(x)),z,'LineWidth',plotlw,'Color',plotcol);
h(6) = line(centers,yproject*ones(size(centers)),realamps);
set(h(6),'LineWidth',plotlw,'Color',plotcol,'Marker','o','MarkerFaceColor',plotcol,'LineStyle','none');

%axes
line(xlimits,[0 0],zproject*[1 1],'Color',axiscol);
line([0 0],ylimits,zproject*[1 1],'Color',axiscol);
%frame
line(xxlimits([1 2 2 1 1]),yylimits([1 1 2 2 1]),zproject*ones(1,5),'Color',axiscol);
% axis arrows
line(xlimits(2)*[0.9 1 0.9],yrange*[-0.05 0 0.05],zproject*[1 1 1],'Color',axiscol);
line(xrange*[-0.03 0 0.03],ylimits(2)*[0.85 1 0.85],zproject*[1 1 1],'Color',axiscol);
% Im-t plot
h(3) = line(x,y,zproject*ones(size(x)),'LineWidth',plotlw,'Color',plotcol);
h(7) = line(centers,imagamps,zproject*ones(size(centers)));
set(h(7),'LineWidth',plotlw,'Color',plotcol,'Marker','o','MarkerFaceColor',plotcol,'LineStyle','none');

% axes
line(xproject*[1 1],ylimits,[0 0],'Color',axiscol);
line(xproject*[1 1],[0 0],zlimits,'Color',axiscol);
% frame
line(xproject*ones(1,5),yylimits([1 2 2 1 1]),zzlimits([1 1 2 2 1]),'Color',axiscol);
% axis arrows
line(xproject*[1 1 1],ylimits(2)*[0.9 1 0.9],zrange*[-0.05 0 0.05],'Color',axiscol);
line(xproject*[1 1 1],yrange*[-0.03 0 0.03],zlimits(2)*[0.85 1 0.85],'Color',axiscol);
% Re-Im plot
h(4) = line(xproject*ones(size(x)),y,z,'LineWidth',plotlw,'Color',plotcol);
h(8) = line(xproject*ones(size(centers)),imagamps,realamps);
set(h(8),'LineWidth',plotlw,'Color',plotcol,'Marker','o','MarkerFaceColor',plotcol,'LineStyle','none');

% labels
set(gca,'DefaultTextHorizontalAlignment','center');
set(gca,'DefaultTextVerticalAlignment','bottom');
set(gca,'DefaultTextFontSize',32);
text(0,yproject,zzlimits(2),['Re-' name],'Rotation',-12);
text(0,yylimits(1),zproject,['Im-' name],'Rotation',-12,'VerticalAlignment','top');
text(xproject,0,zzlimits(2),'Re-Im','Rotation',38);

% view
view([29 42]);
axis off;
set(gca,'Projection','perspective');
rotate3d on;
