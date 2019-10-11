function varargout = acorr(varargin);
% ACORR finds the autocorrelation function from time-series data
%
% [AC, M , SD, Pxy, Pxyc, F] = ACORR(X) For autocorrelations AC
% means M, standard deviations SD, power spectrum Pxy, confidence
% intervals for the power spectrum Pxyc and the frequency domain
% in units of the Nyquist frequency 
%
% Uses : SPECTRUM

% Author: Tim Gebbie 31-09-2004

% $Revision: 1.1 $ $Date: 2008/07/01 14:51:18 $ $Author: Tim Gebbie $
% sample factor
sf = 261; % 1 day  = 261/2 , 1 week = 52/2, 1 month = 12/2, 1 year = 1/2 
str ='';

switch nargin
case 1
    y = varargin{1};
    x = y;
case 2
    y = varargin{1};
    x = varargin{2};
    
case 3
    y = varargin{1};
    x = varargin{2};
    if isempty(x), x = y; end;
    sf = varargin{3};
    
case 4
    y = varargin{1};
    x = varargin{2};
    if isempty(x), x = y; end;
    sf = varargin{3};  
    str = varargin{4};
    
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
if (nargout==0 | nargout>1)
    for k=1:m, 
        [PP{k},FF{k}] = spectrum(x(:,k),y(:,k));
        Pxy(k,:)      = transpose(PP{k}(:,3));
        Pxyc(k,:)     = transpose(PP{k}(:,end));  
        F             = FF{k};
    end;
end;
        
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
   title(sprintf('%s %s','Auto-correlation function Cxy',str));
   hold off;
   subplot(2,1,2);
   % rescale the frequency domainto fin hertz 1Fhz = 1/1 year.
   % sampling frequency here is 1 day => Nyquist = 261/2
   plot(sf/2 * F(:),[Pxy(:) Pxy(:)+Pxyc(:) Pxy(:)-Pxyc(:)]);
   grid on;
   xlabel('Frequency FHz (1 FHz = 1/year)');
   ylabel('Power');
   title(sprintf('%s %s','Spectral Density Pxy',str));
   
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
   surf(sf/2 * F,1:m,Pxy');
   set(gca,'XScale','log');
   set(gca,'View', [0 90]);
   shading interp; 
   title('Power spectrum');
   xlabel('Frequency (1 FHz = 1/year)');
   ylabel('Object');
   colorbar;
   
 end
   
case {1},
    varargout{1} = AC;
case {2,3,3,4,5,6},
    varargout{1} = AC;
    varargout{2} = M;
    varargout{3} = SD;
    varargout{4} = Pxy;
    varargout{5} = Pxyc;
    varargout{6} = F;
    
otherwise
    error('incorrect number of output arguments');
end