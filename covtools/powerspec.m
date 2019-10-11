function varargout = powerspec(varargin);s
% POWERSPEC finds the autocorrelation function and spectral density from time-series data 
% and plots these functions if no output arguments are called for. 
%
% [AC, M , SD, Pxy, Pxyc, F] = POWERSEC(X) For autocorrelations AC
% means M, standard deviations SD, power spectrum Pxy, confidence
% intervals for the power spectrum Pxyc and the frequency domain
% in units of the Nyquist frequency 
%
% Uses : SPECTRUM

% Author: Tim Gebbie, Diane Wilcox
% Copyright(c) 2004 Tim Gebbie & Diane Wilcox, University of Cape Town.
% 1.1 2008/07/01 14:45:47 Tim Gebbie

switch nargin
case 1
    y = varargin{1};
    x = y;
case 2
    y = varargin{1};
    x = varargin{2};
        
otherwise
    error;
end

[n, m] = size(y);

% z-score the data
y = (y - repmat(nanmean(y),n,1));
x = (x - repmat(nanmean(x),n,1));

% normalization constant
Nc = sum(y .* x);

% find the auto correlation function
for i=1:n-1
  y1 = y(1:(n-i),:);
  y2 = x(i+1:(n),:);  
  % correctly normalized with respect to degrees of freedom
  AC(i,:) = sum(y1 .* y2) ./ Nc;
end

% output variables tranpose to ensure columns are objects and
% rows are the delays
   M  = nanmean(AC');
   SD = sqrt(nanstd(AC').^2);

% compute the power spectrum
try
for k=1:m, 
   [PP{k},FF{k}] = spectrum(x(:,k),y(:,k));
   Pxy(k,:)      = transpose(PP{k}(:,3));
   Pxyc(k,:)     = transpose(PP{k}(:,end));  
   F             = FF{k};
end;
catch 
    PP = [];
    Pxy = [];
    Pxyc = [];
    F = [];
    warning('missing function spectrum');
end
        
switch nargout,
case 0,
    
 if m==1,  
   line1 = 2*SD;
   line2 = -2*SD;
   figure;
   subplot(2,1,1);
   semilogx(1:length(AC),2*SD,'r');
      hold on;
   semilogx(1:length(AC),-2*SD,'r');
   semilogx(1:length(AC),AC);
   grid on;
   ylabel('Correlation');
   xlabel('Time Delay');
   title('Auto-correlation function Cxy');
   hold off;
   subplot(2,1,2);
   % rescale the frequency domainto fin hertz 1Fhz = 1/1 year.
   % sampling frequency here is 1 day => Nyquist = 
   plot(261/2 * F(:),[Pxy(:) Pxy(:)+Pxyc(:) Pxy(:)-Pxyc(:)]);
   grid on;
   xlabel('Frequency FHz (1 FHz = 1/year)');
   ylabel('Power');
   title('Spectral Density Pxy');
   
 else
   subplot(2,1,1);
   surf(AC');
   set(gca,'XScale','log');
   set(gca,'View', [0 90]);
   shading interp; 
   title('Auto-correlation function');
   xlabel('Delay');
   ylabel('Object');
   colorbar;
   subplot(2,1,2);
   surf(261/2 * F,1:m,Pxy');
   set(gca,'XScale','log');
   set(gca,'View', [0 90]);
   shading interp; 
   title('Power spectrum');
   xlabel('Frequency (1 FHz = 1/year)');
   ylabel('Object');
   colorbar;
   
 end
   
case {1,2,3,3,4,5,6},
    varargout{1} = AC;
    varargout{2} = M;
    varargout{3} = SD;
    varargout{4} = Pxy;
    varargout{5} = Pxyc;
    varargout{6} = F;
    
otherwise
    error('incorrect number of output arguments');
end