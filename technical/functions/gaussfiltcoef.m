function b=gaussfiltcoef(SR,fco)
%GAUSSFILTCOEF  Return coefficients of Gaussian lowpass filter.
% SR=sampling rate, fco=cutoff (-3dB) freq, both in Hz. 
% Coeffs for FIR filter of length L (L always odd) are computed.
% This symmetric FIR filter of length L=2N+1 has delay N/SR seconds.
% Examples of use
%    Compute Gaussian filter frequency response for SR=1000, fco=50 Hz:
%    freqz(gaussfiltcoef(1000,50),1,256,1000);
%    Filter signal X sampled at 5kHz with Gaussian filter with fco=500:
%    y=filter(gaussfiltcoef(5000,500),1,X);
% SR, fco are not sanity-checked.  WCR 2006-10-11.

b=0;
a=3.011*fco;
N=ceil(0.398*SR/fco);   %filter half-width, excluding midpoint
%Width N corresponds to at least +-3 sigma which captures at least 99.75%
%of area under Normal density function. sigma=1/(a*sqrt(2pi)).
L=2*N+1;                %full length of FIR filter
for k=-N:N
    b(k+N+1)=3.011*(fco/SR)*exp(-pi*(a*k/SR)^2);
end;
%b(k) coeffs computed above will add to almost exactly unity, but not 
%quite exact due to finite sampling and truncation at +- 3 sigma.  
%Next line adjusts to make coeffs b(k) sum to exactly unity.
b=b/sum(b);