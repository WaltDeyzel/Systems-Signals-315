function x = gensig(params,t)

% GENSIG    Generate signals for signal manipulator
%  
%       This generates periodic time signals from parameters.
%       The following signals are supported:
%         - cosine wave [1 T0 A t0]
%         - rectangular pulse train [2 T0 A t0 tau]
%         - triangular pulse train [3 T0 A t0 tau]
%         - half-rectified cosine wave [4 T0 A t0]
%         - full-rectified cosine wave [5 T0 A t0]
%       The signal names are returned when gensig is called without
%       inputs.
%
%                    x = gensig(params,t)
%
%       Inputs: params - signal parameters [sig T0 A t0 tau]
%               t      - vector of time instants where signal is evaluated     
%

% Return list of supported signals if not enough inputs
if (nargin < 2)
  x = {'Cosine wave', ...
       'Rectangular pulse train', ...
       'Triangular pulse train', ...
       'Half-rectified cosine wave', ...
       'Full-rectified cosine wave'};
  return;
end;

% Default parameter values
if (length(params) < 1)  sig = 1; else  sig = params(1); end;
if (length(params) < 2)  T0 = 1;  else  T0 = params(2);  end;
if (length(params) < 3)  A = 1;   else  A = params(3);   end;
if (length(params) < 4)  t0 = 0;  else  t0 = params(4);  end;
if (length(params) < 5)  tau = 0; else  tau = params(5); end;

% Now handle each signal type separately
x = zeros(size(t));

% Cosine wave
if (sig == 1)
  if (T0 <= 0)
    x = repmat(NaN,size(t));
  else    
    x = A*cos(2*pi*(t - t0)/T0);
  end;
  
% Rectangular pulse train
elseif (sig == 2)
  if (tau >= T0)            % shortcut possible here
    x = repmat(A,size(t));
  else
    tshift = t - t0;
    roundulus = tshift - T0.*round(tshift./T0);
    ups = find( abs(roundulus) < tau/2 );  
    x(ups) = repmat(A,size(ups));
  end;
  
% Triangular pulse train
elseif (sig == 3)
  if (T0 <= 0)
    x = repmat(inf,size(t));
  else    
    firstpeak = floor((t0 - t(1) + tau)/T0);
    peaks = t0-firstpeak*T0:T0:t(end)+tau;
    for n=1:length(peaks)
      upslope = find((t > peaks(n)-tau) & (t <= peaks(n)));
      x(upslope) = x(upslope) + A*(t(upslope)-peaks(n)+tau)/tau;
      downslope = find((t > peaks(n)) & (t < peaks(n)+tau));
      x(downslope) = x(downslope) + A*(peaks(n)+tau-t(downslope))/tau;
    end;
  end;
  
% Half-rectified cosine wave
elseif (sig == 4)
  if (T0 <= 0)
    x = repmat(NaN,size(t));
  else    
    x = A*cos(2*pi*(t - t0)/T0);
    x(find(x <= 0.0)) = 0.0;
  end;

% Full-rectified cosine wave
elseif (sig == 5)
  if (T0 <= 0)
    x = repmat(NaN,size(t));
  else    
    x = A*abs(cos(2*pi*(t - t0)/T0));
  end;
    
end;
