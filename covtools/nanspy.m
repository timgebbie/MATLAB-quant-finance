function nanspy(A)
% nanspy plots an image of NaN's.

% $ Author Tim Gebbie

colormap([1 1 1;1 0 0]);
image(isnan(A)*256);

