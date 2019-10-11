function y= fftcf2density(cf,a,N)
% Y = FFTCF2DENSITY(CF,A,N) Compute RN density from characteristic function
b = a/N; 
u = ((0:N-1)-N/2) * b; % create grid
h2 = ((-1) .^ (0:N-1)) .* cf(u); % discrete points of char. func.
% execute the FFT
g = fft(h2); % inverse(cf) -> density function
% compute the real component to get the probability distribution
y = real(((-1).^(0:N-1)).*g) * (b / (2 * pi)));