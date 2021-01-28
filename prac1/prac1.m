%
% Systems & Signals 315
%
% Practical 1
%
% Ludwig Schwardt
%
% 22 February 2000
%
%
% This GUI demo examines the relationship between time signals (specifically the
% rectangular pulse train) and the Fourier series / harmonic phasors.
%

close all;
screensize = get(0,'ScreenSize');

%sigmanipsize = [1, (350/600)*screensize(4)-51, (370/800)*screensize(3), (250/600)*screensize(4)];
sigmanipsize = [1, (350/600)*screensize(4)-37, (370/800)*screensize(3), (250/600)*screensize(4)];
%global SIGMANIP_WINDOW_HANDLE;
hsig = figure(1);
set(hsig,'Position',sigmanipsize,'Tag','SIGMANIP');

specviewsize = [2+sigmanipsize(3), 20, screensize(3)-sigmanipsize(3)-2, screensize(4)-55];
%specviewsize = [2+sigmanipsize(3), -12, screensize(3)-sigmanipsize(3)-2, screensize(4)-55];
%global SPECVIEW_WINDOW_HANDLE;
hspec = figure(2);
set(hspec,'Position',specviewsize,'Tag','SPECVIEW');

phasorsize = [1, -24, (370/800)*screensize(3), (285/600)*screensize(4)-5];
%global PHASOR_WINDOW_HANDLE;
hphasor = figure(3);
set(hphasor,'Color',[0 0 0],'Position',phasorsize,'Tag','PHASOR');

% The MATLAB 6+ modern version...
%releasenumber = version('-release');
% The Student-version-friendly version...
verstr = version;
relnumind = findstr(verstr,'(R');
releasenumber = str2num(verstr(relnumind+2:relnumind+3));
% Enable nice feature if modern enough
if releasenumber >= 12,
  set(hphasor,'DoubleBuffer','on');
end;

sigmanip;
specview;
