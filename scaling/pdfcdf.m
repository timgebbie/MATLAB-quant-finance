  function [pdf,cdf,x] = pdfcdf(L)
  % PDFCDF Estimate the PDF and CDF distributions from data 
  %
  % [PDF, CDF] = PDFCDF(D) Data D is used to estimate the PDF
  % and CDF using Guassian Kernel Broadening. 
  %
  % See Also : KSDENSITY

  [m,n]=size(L);

  for i=1:n  
    % use gaussian broadening to find the pdf and cdf
    [pdf(:,i),x(:,i)] = ksdensity(L,'width',6,'function','pdf');
    % create the cdf by integrating the pdf
    cdf(:,i) = ksdensity(L,'width',6,'function','cdf');
  end;
  

  