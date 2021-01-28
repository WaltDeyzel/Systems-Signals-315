function sigmanip(action,data)

%SIGMANIP   Manipulate signals and calculate Fourier series
%  
%       Manipulates signals via GUI interface. At this stage only rectangular  
%       pulse train is allowed.
%
%                 sigmanip(action,data)
%

% Default action is to initialize the whole thing
if (nargin<1)   action = 'Initialize'; end;

% Naughty global variables
global PARAM_DATA;
global SIGNAL_DATA;
global SPECTRUM_DATA;

SIGMANIP_WINDOW_HANDLE = findobj('Tag','SIGMANIP');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INITIALIZE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (strcmp(action,'Initialize'))
% Default time axis 
  t = -3:0.002:3;
% Initial values for signal parameters
  sig = 2;
  nCoefs = 10;
  T0 = 1;
  tau = 0.5;
  t0 = 0;
  A = 1;
% Default positions on sliders/menus (sig/T0/tau/t0/nCoefs)
  sliderinit = [2, sqrt((T0-0.1)/9.9), tau/T0, t0/T0 + 0.5, 10/100];

% Create time signal
  x = gensig([sig T0 A t0 tau],t);
% Setup robust y-axis limits
  xlimit = [min(x) max(x)];
  xrange = xlimit(2) - xlimit(1);
  if (xrange <= 0)  xrange = 1; end;

% Transfer appropriate global data to other figures
%  PARAM_DATA = [nCoefs sig T0 tau t0 A 0 0];
  PARAM_DATA = [sig T0 tau t0 nCoefs A 0 0];
  SIGNAL_DATA = [t; x];          
  SPECTRUM_DATA = genfs(PARAM_DATA([1 2 6 4 3]),PARAM_DATA(5));

% Get ready to draw
  figure(SIGMANIP_WINDOW_HANDLE);
  clf;

% Main axes showing original pulse train - keep the axis limits fixed and no zooming!  
  hsig = axes('Units','normalized','Position',[.1 .6 .85 .3]);
  axis([t(1) t(length(t)) xlimit(1)-0.25*xrange xlimit(2)+0.25*xrange]);
  axis manual;
  line(t,x);
%  title('Time signal - rectangular pulse train');
  xlabel('Time (s)');
  ylabel('Amplitude x(t)');

% Popup menu to select signal
  hsigpm = uicontrol('Units','normalized','Position',[0.39 0.92 0.45 0.08], ...
                     'Style','popupmenu','Tag','sig_PopupMenu', ...
                     'String',gensig,'Value',sliderinit(1), ...
                     'Callback','sigmanip(''ManipulateSignal'', [1, get(gco,''value'')]);');
  set(hsigpm,'UserData',[hsig hsigpm]);
  uicontrol('Units','normalized','Position',[0.16 0.92 0.2 0.07], ...
            'Style','text','Tag','siglabel_StaticText', ...
            'String','Time signal:');
  
% Slider labels  
  uicontrol('Units','normalized','Position',[0.05 0.38 0.2 0.1], ...
            'Style','text','Tag','T0label_StaticText', ...
            'String','Period (T0)');
  uicontrol('Units','normalized','Position',[0.05 0.26 0.2 0.1], ...
            'Style','text','Tag','taulabel_StaticText', ...
            'String','Pulse width (tau)');
  uicontrol('Units','normalized','Position',[0.05 0.14 0.2 0.1], ...
            'Style','text','Tag','t0label_StaticText', ...
            'String','Pulse delay (t0)');
  uicontrol('Units','normalized','Position',[0.05 0.02 0.2 0.1], ...
            'Style','text','Tag','nCoefslabel_StaticText', ...
            'String','Number of harmonics');

% Labels displaying current value of pulse train parameters
  hT0 = uicontrol('Units','normalized','BackgroundColor',[0.7 0.7 0.7], ...
                  'Position',[0.66 0.38 0.1 0.1], ...
                  'Style','text','Tag','T0_StaticText', ...
                  'String',num2str(T0));
  htau = uicontrol('Units','normalized','BackgroundColor',[0.7 0.7 0.7], ...
                   'Position',[0.66 0.26 0.1 0.1], ...
                   'Style','text','Tag','tau_StaticText', ...
                   'String',num2str(tau));
  ht0 = uicontrol('Units','normalized','BackgroundColor',[0.7 0.7 0.7], ...
                  'Position',[0.66 0.14 0.1 0.1], ...
                  'Style','text','Tag','t0_StaticText', ...
                  'String',num2str(t0));
  hnCoefs = uicontrol('Units','normalized','BackgroundColor',[0.7 0.7 0.7], ...
                      'Position',[0.66 0.02 0.1 0.1], ...
                      'Style','text','Tag','nCoefs_StaticText', ...
                      'String',num2str(nCoefs));

% Sliders
  hT0sl = uicontrol('Units','normalized','Position',[0.28 0.38 0.35 0.1], ...
                    'Style','slider','Tag','T0_Slider', ...
                    'UserData',[hsig hT0],'Value',sliderinit(2), ...
                    'Callback',@T0slider); %'sigmanip(''ManipulateSignal'', [2, hT0sl.Value]);');  %get(gco,''value'')
  htausl = uicontrol('Units','normalized','Position',[0.28 0.26 0.35 0.1], ...
                     'Style','slider','Tag','tau_Slider', ...
                     'UserData',[hsig htau],'Value',sliderinit(3), ...
                     'Callback',@tauslider); %'sigmanip(''ManipulateSignal'', [3, get(gco,''value'')]);');
  ht0sl = uicontrol('Units','normalized','Position',[0.28 0.14 0.35 0.1], ...
                    'Style','slider','Tag','t0_Slider', ...
                    'UserData',[hsig ht0],'Value',sliderinit(4), ...
                    'Callback',@t0slider); %'sigmanip(''ManipulateSignal'', [4, get(gco,''value'')]);');
  hnCoefssl = uicontrol('Units','normalized','Position',[0.28 0.02 0.35 0.1], ...
                        'Style','slider','Tag','nCoefs_Slider', ...
                        'UserData',[hsig hnCoefs],'Value',sliderinit(5), ...
                        'Callback',@nCoeffslider); %'sigmanip(''ManipulateSignal'', [5, get(gco,''value'')]);');
                    
% Reset buttons
  hT0rst = uicontrol('Units','normalized','BackgroundColor',[0.7 0.7 0.7], ...
	             'Position',[0.8 0.38 0.15 0.1], ...
                     'String','Reset','Tag','T0_Pushbutton','UserData',hT0sl, ...
                     'Callback',['sigmanip(''ManipulateSignal'', [2,' num2str(sliderinit(2),20) ']);']);
  htaurst = uicontrol('Units','normalized','BackgroundColor',[0.7 0.7 0.7], ...
	              'Position',[0.8 0.26 0.15 0.1], ...
                      'String','Reset','Tag','tau_Pushbutton','UserData',htausl, ...
                      'Callback',['sigmanip(''ManipulateSignal'', [3,' num2str(sliderinit(3),20) ']);']);
  ht0rst = uicontrol('Units','normalized','BackgroundColor',[0.7 0.7 0.7], ...
                     'Position',[0.8 0.14 0.15 0.1], ...
                     'String','Reset','Tag','t0_Pushbutton','UserData',ht0sl, ...
                     'Callback',['sigmanip(''ManipulateSignal'', [4,' num2str(sliderinit(4),20) ']);']);
  hnCoefsrst = uicontrol('Units','normalized','BackgroundColor',[0.7 0.7 0.7], ...
           	         'Position',[0.8 0.02 0.15 0.1], ...
                         'String','Reset','Tag','nCoefs_Pushbutton','UserData',hnCoefssl, ...
                         'Callback',['sigmanip(''ManipulateSignal'', [5,' num2str(sliderinit(5),20) ']);']);

% Transfer user data to figure
  fud = [hsig hsigpm hT0sl  htausl  ht0sl  hnCoefssl; ...
         hsig hsigpm hT0    htau    ht0    hnCoefs];
  set(gcf,'UserData', fud);
% Debugging
%  disp(['original sig data = ']); 
%  disp(num2str(fud));
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MANIPULATE SIGNAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       
elseif (strcmp(action,'ManipulateSignal'))
% Get user data containing uicontrol handles  
  fud = get(SIGMANIP_WINDOW_HANDLE,'UserData');
% Debugging
%  disp(['sig data = ']); 
%disp(fud);

% Redraw means main time signal has to be redrawn (when its parameters change)
  redraw = 1;
% Signal switch don't redraw if same signal selected
  if (data(1) == 1)
    if (PARAM_DATA(data(1)) == data(2))
      redraw = 0;
    else
      PARAM_DATA(data(1)) = data(2);
    end;
% T_0    
  elseif (data(1) == 2)
    PARAM_DATA(data(1)) = 0.1 + 9.9*(data(2)^2);
% tau    
  elseif (data(1) == 3)
    PARAM_DATA(data(1)) = PARAM_DATA(2)*data(2);
% t_0    
  elseif (data(1) == 4)
    PARAM_DATA(data(1)) = PARAM_DATA(2)*(data(2) - 0.5);
% nCoefs don't require redraw
  elseif (data(1) == 5)
    PARAM_DATA(data(1)) = 1+round(100*data(2));
    redraw = 0;
  end;  

  % Update slider and label settings, and save user data again
  if (data(1) > 1)
    set(fud(1,1+data(1)),'Value',data(2));
    set(fud(2,1+data(1)),'String',num2str(PARAM_DATA(data(1))));
  end;
  set(SIGMANIP_WINDOW_HANDLE,'UserData',fud);
  
% Redraw simply changes internal data of line object in axes
  if (redraw)
    hsig = fud(1,1);
    hplot = findobj(hsig,'Type','line');
    t = get(hplot,'XData');
    x = gensig(PARAM_DATA([1 2 6 4 3]),t);
    SIGNAL_DATA(2,:) = x;
    axes(hsig);
    cla;
    if (data(1) == 1)
      % Setup robust y-axis limits
      xlimit = [min(x) max(x)];
      xrange = xlimit(2) - xlimit(1);
      if (xrange <= 0)  xrange = 1; end;
      axis([t(1) t(length(t)) xlimit(1)-0.25*xrange xlimit(2)+0.25*xrange]);
      axis manual;
    end;
    line(t,x);
    drawnow;
  end;

% Time to update the spectrum view  
  SPECTRUM_DATA = genfs(PARAM_DATA([1 2 6 4 3]),PARAM_DATA(5));
  specview('DrawSpectrum');
  
  
end;

function T0slider(hObject, evendata, hi)
    sigmanip('ManipulateSignal',[2, hObject.Value]);

function tauslider(hObject, evendata, hi)
    sigmanip('ManipulateSignal',[3, hObject.Value]);

function t0slider(hObject, evendata, hi)
    sigmanip('ManipulateSignal',[4, hObject.Value]);
    
function nCoeffslider(hObject, evendata, hi)
    sigmanip('ManipulateSignal',[5, hObject.Value]);

