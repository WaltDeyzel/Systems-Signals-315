function fs = genfs(params,N)

% GENFS     Generate Fourier series coefficients
%  
%       This generates Fourier series coefficients from parameters.
%       The following signals are supported:
%         - cosine wave [1 T0 A t0]
%         - rectangular pulse train [2 T0 A t0 tau]
%         - triangular pulse train [3 T0 A t0 tau]
%         - half-rectified cosine wave [4 T0 A t0]
%         - full-rectified cosine wave [5 T0 A t0]
%
%                   fs = genfs(params,N)
%
%       Input:  params - signal parameters [sig T0 A t0 tau]
%               N      - number of coefficients to calculate
%
%       Output: fs     - [freqs; mags; phases] of Fourier coefficients
%

error(nargchk(2,2,nargin));

% Default parameter values
if (length(params) < 1)  sig = 1; else  sig = params(1); end;
if (length(params) < 2)  T0 = 1;  else  T0 = params(2);  end;
if (length(params) < 3)  A = 1;   else  A = params(3);   end;
if (length(params) < 4)  t0 = 0;  else  t0 = params(4);  end;
if (length(params) < 5)  tau = 0; else  tau = params(5); end;

f0 = 1/T0;               % Fundamental frequency = 1/period
fs = zeros(3,N);         % This will contain Fourier series data
X = zeros(1,N);          % N Fourier series coefficients

% Now handle each signal type separately

% Cosine wave
if (sig == 1)
  X(2) = A*exp(-j*2*pi*f0*t0);    % Only one harmonic (n=1)!
  
% Rectangular pulse train
elseif (sig == 2)
  if (tau > 0)
    X(1) = A*f0*tau;       % This is the DC (average) value of the signal
    if (tau < T0)
      for n = 1:N-1,
        X(n+1) = 2*A*f0*tau*(sin(pi*n*f0*tau)/(pi*n*f0*tau))*exp(-j*2*pi*n*f0*t0);
      end;
    end;
  end;
  
% Triangular pulse train
elseif (sig == 3)
  if (tau > 0)
    X(1) = A*f0*tau;       % This is the DC (average) value of the signal
    for n = 1:N-1,
      X(n+1) = 2*A*f0*tau*((sin(pi*n*f0*tau)/(pi*n*f0*tau))^2)*exp(-j*2*pi*n*f0*t0);
    end;
  end;
  
% Half-rectified cosine wave
elseif (sig == 4)
  X(2) = 2*(A/4)*exp(-j*2*pi*f0*t0);
  for n = 0:2:N-1 
    X(n+1) = 2*A/(pi*(1 - n*n))*(j^n)*exp(-j*2*pi*n*f0*t0);
  end;  
  X(1) = X(1)/2;
    
% Full-rectified cosine wave
elseif (sig == 5)
  for n = 0:2:N-1 
    X(n+1) = 4*A/(pi*(1 - n*n))*(j^n)*exp(-j*2*pi*n*f0*t0);
  end;  
  X(1) = X(1)/2;
  
end;

fs(1,:) = (0:N-1)*f0;   % Harmonic frequencies
fs(2,:) = abs(X);       % Magnitude spectrum
fs(3,:) = angle(X);     % Phase spectrum
