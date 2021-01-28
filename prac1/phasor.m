function phasor(action,data)
%
%PHASOR     View rotating phasor version of Fourier approximation to signal
%  
%       Show rotating phasors and Fourier approximated signal. It operates fully through
%       global data structures (so far). Based on software by Nabeel Azar from JHU.
%       For more info and funky applets, see www.jhu.edu/~signals.
%
%                     phasor(action,data)
%

% Data not used yet
if (nargin<2)   data = []; end;
% Default action is to initialize the whole thing
if (nargin<1)   action = 'Initialize'; end;

% Naughty global variables
global PARAM_DATA;
global SIGNAL_DATA;
global SPECTRUM_DATA;
global PHASOR_DATA;

PHASOR_WINDOW_HANDLE = findobj('Tag','PHASOR');

% This provides an accuracy vs speed trade-off: the higher, the slower, but the nicer
%SPEEDFACTOR = 30;
SPEEDFACTOR = 100;

% The MATLAB 6+ modern version...
%releasenumber = version('-release');
% The Student-version-friendly version...
verstr = version;
relnumind = findstr(verstr,'(R');
releasenumber = str2num(verstr(relnumind+2:relnumind+3));
% Disable nice feature if Matlab not modern enough
nodoublebuffer = (releasenumber < 12);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INITIALIZE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (strcmp(action,'Initialize'))

%*********************************************************

%This part will setup the phasors

%-----------------------------------------------------------

% Retrieve parameters
  T0 = PARAM_DATA(2);
  orig_flag = PARAM_DATA(7);
  double_flag = (PARAM_DATA(8) == 2);
% Retrieve spectrum and signal data
% Only keep visible phasors
  longmag = max(SPECTRUM_DATA(2,:));
  magthere = find(SPECTRUM_DATA(2,:) > longmag/2000);  
  FreqArray = SPECTRUM_DATA(1,magthere);
  MagArray = SPECTRUM_DATA(2,magthere);
  PhaseArray = SPECTRUM_DATA(3,magthere);
  numphasors = length(magthere);
  MagScale = sum(MagArray);

% Please don't continue if there's nothing there
  if (numphasors == 0)
    PHASOR_DATA = [];
    return; 
  end;
% Double-sided spectrum needs clockwise phasors too
  if (double_flag)
  % First pick out troublesome DC component  
    zindex = find(FreqArray == 0);
    DCFreq = zeros(1,length(zindex));
    DCMag = MagArray(zindex);
    DCPhase = PhaseArray(zindex);
    nzindex = find(FreqArray ~= 0);    
    FreqArray = FreqArray(nzindex);
    MagArray = MagArray(nzindex);
    PhaseArray = PhaseArray(nzindex);
    numphasors = length(nzindex);
  % Now add negative frequency phasors right next to their counterparts (0.5*mag, -phase)    
    interleave = [FreqArray; -FreqArray];
    FreqArray = interleave(1:2*numphasors);
    FreqArray = [DCFreq FreqArray(:)'];
    interleave = 0.5*[MagArray; MagArray];
    MagArray = interleave(1:2*numphasors);
    MagArray = [DCMag MagArray(:)'];
    interleave = [PhaseArray; -PhaseArray];
    PhaseArray = interleave(1:2*numphasors);
    PhaseArray = [DCPhase PhaseArray(:)'];
    numphasors = length(FreqArray);
  end;
  
% Turn phasor angles through 90 degrees for pretty display purposes
  PhaseArray = PhaseArray + pi/2;  

% Only use t >= 0 data, so that initial phase is more visible
  tthere = find(SIGNAL_DATA(1,:) >= 0);
  t = SIGNAL_DATA(1,tthere);
  tlimit = [0 t(length(t))];
  xlimit = [-MagScale-.2 MagScale+.2];

%*********************************************************

%This part will setup the axes

%-----------------------------------------------------------

% Get ready to draw
  %disp(PHASOR_WINDOW_HANDLE);
  figure(PHASOR_WINDOW_HANDLE);
  set(gcf,'Color',[0 0 0]);
  clf;

% First do the phasor axes
  hrot = axes('Units','normalized','Position',[0 0 .47 1],'DrawMode','fast');
  axis([xlimit xlimit]);
% Square axis is critical to get correspondence between phasor and time signal y-axes
  axis square;
  axis off;
  text(-0.05,xlimit(2)-0.05,'Re','Color',[.5 .5 .5]);
  text(xlimit(1)+0.02,0,'Im','Color',[.5 .5 .5]);
  zoom on;
% Add the axis lines
  line([-MagScale MagScale],[0 0],'Color',[.5 .5 .5]);
  line([0 0],[-MagScale MagScale],'Color',[.5 .5 .5]);
  title('Rotating phasor sum','Color',[.5 .5 .5]);

% Time signal axes
  hsig = axes('Units','normalized','Position',[.5 0 .47 1]);
  axis([tlimit xlimit]);
% Also square - see above
  axis square;
  axis off;
  text(tlimit(2)+0.05,0,'t','Color',[.5 .5 .5]);
  text(-0.05,xlimit(2)-0.05,'Re','Color',[.5 .5 .5]);
  zoom on;
% Add axis lines
  line(tlimit,[0 0],'Color',[.5 .5 .5]);
  line([0 0],[-MagScale MagScale],'Color',[.5 .5 .5]);
  title('Projection onto real axis = approximated signal','Color',[.5 .5 .5]);
  
%*********************************************************
%This part will do the drawing
%-----------------------------------------------------------

% Compute Cartesian coordinates of phasors
  [xstep,ystep] = pol2cart(PhaseArray, MagArray);
% Add phasors together
  xx = cumsum([0 xstep]);
  yy = cumsum([0 ystep]);
% Split phasors alternately into two broken lines (red + green)
  xr = [xx(1:2:end-1); xx(2:2:end)]; 
  xr = [xr; NaN*ones(1,size(xr,2))];
  xg = [xx(2:2:end-1); xx(3:2:end)]; 
  xg = [xg; NaN*ones(1,size(xg,2))];
  yr = [yy(1:2:end-1); yy(2:2:end)]; 
  yr = [yr; NaN*ones(1,size(yr,2))];
  yg = [yy(2:2:end-1); yy(3:2:end)]; 
  yg = [yg; NaN*ones(1,size(yg,2))];
% Tip of phasor sum
  xtip = xx(end);
  ytip = yy(end);

% Allocate lines so long - will only change their internals from here on
  axes(hrot);
  %hrotline = line(xtip,ytip,'Color','b','LineWidth',2);
  hrotline = animatedline(xtip,ytip,'Color','b','LineWidth',2);
  axes(hsig);
  %hsigline = line(0,ytip,'Color','b','LineWidth',2);
  hsigline = animatedline(0,ytip,'Color','b','LineWidth',2);
  %if nodoublebuffer,
  %  set([hrotline hsigline],'EraseMode','none');
  %end;
      
% Get ready to display phasors in startup position
  axes(hrot);
% Draw phasors
  %phasorlines = zeros(1,2);
  phasorlines1 = animatedline(xr(:),yr(:),'Color','r','LineWidth',2);
  if (numphasors > 1) 
    phasorlines2 = animatedline(xg(:),yg(:),'Color','g','LineWidth',2);
  else
    phasorlines2 = animatedline(NaN,NaN,'Color','g','LineWidth',2);
  end;
% DoubleBuffer requires EraseMode 'normal'  
  %if nodoublebuffer,
  %  set(phasorlines,'EraseMode','xor');
  %end;

% Display phasors NOW
  drawnow;

% Display original signal if required
  if (orig_flag)
    x = SIGNAL_DATA(2,tthere);
    axes(hsig);
    line(t,x,'Color','r');
%    hold on;
  end;  

% Collect data for next phase  
  PHASOR_DATA = [FreqArray; MagArray; PhaseArray];  
  fud = struct('hrot', hrot, 'hsig', hsig, 'tlimit', tlimit(2), 'phasorlines1', phasorlines1, 'phasorlines2',phasorlines2, 'hrotline', hrotline, 'hsigline', hsigline);
  set(PHASOR_WINDOW_HANDLE,'UserData',fud);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW SPECTRUM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif (strcmp(action,'Activate'))
% Check if all is well
  if(isempty(PHASOR_DATA)) disp(['no data']); return; end;
% Retrieve data    
  fud = get(PHASOR_WINDOW_HANDLE,'UserData');
  hrot = fud.hrot;
  hsig = fud.hsig;
  tlimit = fud.tlimit;
  phasorlines1 = fud.phasorlines1;
  phasorlines2 = fud.phasorlines2;
  hrotline = fud.hrotline;
  hsigline = fud.hsigline;
  FreqArray = PHASOR_DATA(1,:);
  MagArray = PHASOR_DATA(2,:);
  PhaseArray = PHASOR_DATA(3,:);
  numphasors = size(PHASOR_DATA,2);
 
%**********************************

% The time sampling rate determines the quality and speed of the picture
  Sample = (numphasors/SPEEDFACTOR)/(10*max(FreqArray));

% Time instants that will be drawn
  %instants = linspace(0,tlimit,Sample); % 
  instants = 0:Sample:tlimit;
  

%**********************************
% Main loop, doing each time step
  for n = 1:length(instants),

% Effects of rotating phasor here in time-dependent phase
    [xstep,ystep] = pol2cart(2*pi*FreqArray*instants(n) + PhaseArray, MagArray);

% Add phasors together
    xx = cumsum([0 xstep]);
    yy = cumsum([0 ystep]);
% Split phasors alternately into two broken lines (red + green)
    xr = [xx(1:2:end-1); xx(2:2:end)]; 
    xr = [xr; NaN*ones(1,size(xr,2))];
    xg = [xx(2:2:end-1); xx(3:2:end)]; 
    xg = [xg; NaN*ones(1,size(xg,2))];
    yr = [yy(1:2:end-1); yy(2:2:end)]; 
    yr = [yr; NaN*ones(1,size(yr,2))];
    yg = [yy(2:2:end-1); yy(3:2:end)]; 
    yg = [yg; NaN*ones(1,size(yg,2))];
% Find tip of resultant phasor
    xtip = xx(end);
    ytip = yy(end);

% Make sure figure isn't cleared out underneath animation
    if(~ishandle(hrot)) return; end; 

% Update complex trajectory
    addpoints(hrotline,xtip,ytip);
    
% Update real-valued signal
    addpoints(hsigline,instants(n), ytip)

% Update phasor lines
    clearpoints(phasorlines1)
    addpoints(phasorlines1,xr(:),yr(:));
    if (numphasors > 1) 
      clearpoints(phasorlines2)
      addpoints(phasorlines2,xg(:),yg(:));
    end;
    
% Update graphics NOW
    drawnow;

%**********************************************
% Back to for loop
  end;
  
% Save data
  newfud = struct('hrot', hrot, 'hsig', hsig, 'tlimit', tlimit, 'phasorlines1', phasorlines1, 'phasorlines2',phasorlines2, 'hrotline', hrotline, 'hsigline', hsigline);
  set(PHASOR_WINDOW_HANDLE,'UserData',newfud); 
end;
