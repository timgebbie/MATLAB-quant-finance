function [TF, LOC] = ismemstr(A,S)
%ISMEMSTR True for set member when A and S are cell arrays (of strings)
%   with the same number of columns. Returns a vector (TF) containing 1 where the
%   rows of A are also rows of S and 0 otherwise. Also returns an index array
%   LOC containing the highest absolute index in S for each element in A which
%   is a member of S and 0 if there is no such index.
%
%   Example:
%
%    A = cellstr(char(fix(rand(15,32)*(double('Z')-double('A')))+double('A')));
%    B = A([6 3 2]);
%    profile on; [tf, loc] = ismemstr(A, B), profile off;profile report;

% Copyright 2003 OPTI-NUM solutions (Pty) Ltd

% $Revision: 1.1 $ $Date: 2008/07/01 14:49:42 $ $Author: Tim Gebbie $

A = A(:);

if ischar(S),
  S = cellstr(S);
else
  S=S(:);
end;%if

sizeA1 = size(A,1);
LOC= zeros(sizeA1,1);
TF= false(sizeA1,1);
for k = 1:sizeA1
  for m = 1:size(S,1)
    if isequal(S(m,:),A(k,:))
      TF(k) = true;
      LOC(k) = m;
    end;
  end;
end;
