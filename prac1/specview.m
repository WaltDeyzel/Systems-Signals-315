function specview(action,data)

%SPECVIEW   View spectrum and signal approximation
%  
%       Show spectrum and approximated signal. Give access to phasor phactory.
%
%                 specview(action,data)
%

% Data not used yet
if (nargin<2)   data = []; end;
% Default action is to initialize the whole thing
if (nargin<1)   action = 'Initialize'; end;

% Naughty global variables
global SPECTRUM_DATA;
global SIGNAL_DATA;
global PARAM_DATA;

SPECVIEW_WINDOW_HANDLE = findobj('Tag','SPECVIEW');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INITIALIZE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (strcmp(action,'Initialize'))
% Setup robust limits on spectrum axes
  flimit = 50;
  xlimit = [min(SIGNAL_DATA(2,:)) max(SIGNAL_DATA(2,:))];
  xrange = xlimit(2) - xlimit(1);
  if (xrange <= 0)  xrange = 1; end;
  limits = [SIGNAL_DATA(1,1), SIGNAL_DATA(1,end), xlimit(1)-0.25*xrange, xlimit(2)+0.25*xrange];

% Get ready to draw  
  figure(SPECVIEW_WINDOW_HANDLE);
  clf;

% Reconstructed time signal  
  hrecon = axes('Units','normalized','Position',[.11 .75 .85 .2]);
  axis(limits);
  axis manual;
  title('Fourier approximation to time signal');
  xlabel('Time (s)');              
  ylabel('Amplitude x_a(t)');
  zoom on;
  
% Magnitude spectrum
  hmag = axes('Units','normalized','Position',[.11 .35 .85 .2],'Visible','off');
  set(hmag,'XLimMode','manual','XLim',[0 flimit]);
  title('Magnitude spectrum (|X_n|)');
  ylabel('Magnitude');
  grid on;
  zoom on;
% Phase spectrum  
  hphase = axes('Units','normalized','Position',[.11 .08 .85 .2],'Visible','off');
  set(hphase,'XLim',[0 flimit], ... % 'XTickLabelMode','manual', ...
             'YLimMode','manual','YLim',[-180 180], ...
             'YTickMode','manual','YTick',[-180 -90 0 90 180]);
  title('Phase spectrum (\angle X_n)');
  xlabel('Frequency n*f0 (Hz)');
  ylabel('Phase (degrees)');
  grid on;
  zoom on;  
% Expanded spectrum
  htf = axes('Units','normalized','position',[.11 .08 .85 .47],'Visible','off');
  axis([limits(1:2) -1 flimit+1 limits(3:4)]);
  axis manual;
% 3D spectrum
  h3d = axes('Units','normalized','position',[.11 .08 .85 .47],'Visible','off');
  
% Check boxes, popup menus and phasor button
  horig = uicontrol('Units','normalized','Position',[0.05 .62 .28 .05], ...
	            'Style','checkbox','Tag','orig_Checkbox', ...
                    'String','View original signal', ...
                    'Callback','specview(''DrawSpectrum'');');
  hsview = uicontrol('Units','normalized','Position',[0.355 .62 .32 .05], ...
                     'Style','popupmenu','Tag','sview_Popupmenu', ...
                     'String',{'Single-sided spectrum', ...
                               'Double-sided spectrum', ...
                               'Time-frequency view', ...
                               'Complex spectrum view'}, 'Value',1, ...
                     'Callback','specview(''DrawSpectrum'');');
  hphasor = uicontrol('Units','normalized','Position',[0.7 0.62 .25 .05], ...
                      'String','Activate phasor','Tag','phasor_Pushbutton', ...
                      'Callback','phasor(''Activate'');');

% Save user data and update spectrum
  %fud = [hrecon hmag hphase horig hsview flimit htf h3d hphasor];
  fud = struct('hrecon', hrecon','hmag',hmag,'hphase',hphase,'horig',horig,'hsview',hsview,'flimit',flimit,'htf',htf,'h3d',h3d,'hphasor',hphasor);
  set(gcf,'UserData',fud);
% Debugging
%  disp(['original spec data = ']); 
%  disp(num2str(fud));
  
  specview('DrawSpectrum');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW SPECTRUM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif (strcmp(action,'DrawSpectrum'))
% Get uicontrol handles  
  fud = get(SPECVIEW_WINDOW_HANDLE,'UserData');
% Debugging
%  disp(['spec data = ']); 
%  disp(num2str(fud));

% The data arrives through globals  
  data = SPECTRUM_DATA;
  t = SIGNAL_DATA(1,:);
  x = SIGNAL_DATA(2,:);

% Calculate reconstructed signal and determine limits
  xhat = real((data(2,:).*exp(j*data(3,:)))*exp(j*2*pi*data(1,:)'*t));
  xlimit = [min(xhat) max(xhat)];
  xrange = xlimit(2) - xlimit(1);
  if (xrange <= 0)  xrange = 1; end;

% Save checkbox settings    
  PARAM_DATA(7) = get(fud.horig,'Value'); %get(fud(4),'Value')
  PARAM_DATA(8) = get(fud.hsview,'Value'); %get(fud(5),'Value')

% Update reconstructed signal display  
  axes(fud.hrecon); % axes(fud(1));
  cla;
  set(gca,'Ylim',[xlimit(1) - 0.25*xrange, xlimit(2) + 0.25*xrange]);
  line(t,xhat,'Color','b');
% Add original signal
  if (PARAM_DATA(7))
    xlimit = [min([xlimit(1) x]) max([xlimit(2) x])];
    xrange = xlimit(2) - xlimit(1);
    if (xrange <= 0)  xrange = 1; end;
    set(gca,'Ylim',[xlimit(1) - 0.25*xrange, xlimit(2) + 0.25*xrange]);
    hold on;
    line(t,x,'Color','r');
  end;

  if (PARAM_DATA(8) < 3)
    % Hide expanded spectrum
    axes(fud.htf); %axes(fud(7));
    cla;
    set(gca,'Visible','off');
    axes(fud.h3d); %axes(fud(8));
    cla;
    set(gca,'Visible','off');
    
    % Update magnitude spectrum, for both single-sided and double-sided spectra
    axes(fud.hmag); % axes(fud(2));
    cla;
    set(gca,'Visible','on');
    rotate3d off;
    zoom on;
    % Double-sided
    if (PARAM_DATA(8) == 2)
      yrange = max([data(2,find(~data(1,:))) 0.5*data(2,find(data(1,:)))]);
      if (yrange <= 0)  yrange = 1; end;
      set(gca,'XLim',[-fud.flimit fud.flimit],'YLim',[0 yrange]);
      %set(gca,'XLim',[-fud(6) fud(6)],'YLim',[0 yrange]);
      for i = 1:size(data,2)
        nf0 = data(1,i);
        if (nf0 <= fud.flimit) %if (nf0 <= fud(6))
          if (nf0 > 0)
            mag = 0.5*data(2,i);
          else
            mag = data(2,i);        
          end;  
          line([nf0 nf0],[0 mag]);
          line(nf0,mag,'Marker','o');    
          line([-nf0 -nf0],[0 mag]);
          line(-nf0,mag,'Marker','o');
        end;
      end;
    % Single-sided
    else
      yrange = max(data(2,:));
      if (yrange <= 0)  yrange = 1; end;    
      set(gca,'XLim',[0 fud.flimit],'YLim',[0 yrange]);
      for i = 1:size(data,2)
        nf0 = data(1,i);
        if (nf0 <= fud.flimit)
          mag = data(2,i);
          line([nf0 nf0],[0 mag]);
          line(nf0,mag,'Marker','o');
        end;
      end;    
    end;
    
    % Update phase spectrum, for both single-sided and double-sided spectra
    axes(fud.hphase); %axes(fud(3));
    cla;
    set(gca,'Visible','on');
    rotate3d off;
    zoom on;
    % Double-sided    
    if (PARAM_DATA(8) == 2)
      set(gca,'XLim',[-fud.flimit fud.flimit]); %set(gca,'XLim',[-fud(6) fud(6)]);
      for i = 1:size(data,2)
        nf0 = data(1,i);
        if (nf0 <= fud.flimit) %if (nf0 <= fud(6))
        
          phase = 180*data(3,i)/pi;
          line([nf0 nf0],[0 phase]);
          line(nf0,phase,'Marker','o');    
          line([-nf0 -nf0],[0 -phase]);
          line(-nf0,-phase,'Marker','o');
        end;
      end;
    else
      set(gca,'XLim',[0 fud.flimit]); %set(gca,'XLim',[0 fud(6)]);
      for i = 1:size(data,2)
        nf0 = data(1,i);
        if (nf0 <= fud.flimit)
          phase = 180*data(3,i)/pi;
          line([nf0 nf0],[0 phase]);
          line(nf0,phase,'Marker','o');
        end;
      end;    
    end;
    
% Expanded (t-f) spectrum view
  elseif (PARAM_DATA(8) == 3)
    % Hide normal spectrum
    axes(fud.hmag); % axes(fud(2));
    cla;
    set(gca,'Visible','off');
    axes(fud.hphase); % axes(fud(3));
    cla;
    set(gca,'Visible','off');
    axes(fud.h3d); % axes(fud(8));
    cla;
    set(gca,'Visible','off');
    
    % Bring up expanded view
    axes(fud.htf); % axes(fud(7));
    cla;
    set(gca,'Visible','on','ZLim',[xlimit(1) - 0.25*xrange, xlimit(2) + 0.25*xrange]);
    finview = find(SPECTRUM_DATA(1,:) < fud.flimit); %finview = find(SPECTRUM_DATA(1,:) < fud(6));
    fstfplot(SIGNAL_DATA,SPECTRUM_DATA(:,finview),[-1 fud.flimit+1]); % fstfplot(SIGNAL_DATA,SPECTRUM_DATA(:,finview),[-1 fud(6)+1]);
    zoom off;
    rotate3d on;
    
% 3D (Re-Im-f) spectrum view
  else
    % Hide normal spectrum
    axes(fud.hmag);%axes(fud(2));
    cla;
    set(gca,'Visible','off');
    axes(fud.hphase);%axes(fud(3));
    cla;
    set(gca,'Visible','off');
    axes(fud.htf);%axes(fud(7));
    cla;
    set(gca,'Visible','off');
    
    % Bring up expanded view
    axes(fud.h3d); % axes(fud(8));
    cla;
    set(gca,'Visible','on');   
    finview = find(SPECTRUM_DATA(1,:) < fud.flimit/2);% finview = find(SPECTRUM_DATA(1,:) < fud(6)/2);
    posf = finview;
    negf = finview(end:-1:2);
    cstmplot([SPECTRUM_DATA(2,negf) 2*SPECTRUM_DATA(2,1) SPECTRUM_DATA(2,posf(2:end))].*exp( ...
             j*[-SPECTRUM_DATA(3,negf) SPECTRUM_DATA(3,posf)]), ...
             [-SPECTRUM_DATA(1,negf) SPECTRUM_DATA(1,posf)],'f',[-fud.flimit/2 fud.flimit/2]);
    zoom off;
    rotate3d on;
  end;
  
% Force graphics update  
  drawnow;
  phasor('Initialize');

end;
