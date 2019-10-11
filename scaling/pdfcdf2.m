  function [pdf,cdf,x] = pdfcdf2(L),
  % PDFCDF2 Estimate the PDF and CDF distributions from data
  %
  % [PDF, CDF] = PDFCDF2(D) Data D is used to estimate the PDF
  % and CDF using Guassian Broadening. 
  %
  % See Also : BROADENING, CUMINTEGRATE

  [m,n]=size(L);

  for i=1:n  
    % use gaussian broadening to find the pdf and cdf
    [pdf(:,i),x(:,i)]=broadening(L(:,i),6);
    % create the cdf by integrating the pdf
    cdf(:,i) = cumintegrate(pdf(:,i),x(:,i));
  end;
  

  