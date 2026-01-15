function y = wrapToPi(x)
% WRAPTOPI  Wrap angle in radians to interval (-pi, pi]
%
%   y = wrapToPi(x)
%
% MATLAB-compatible implementation.

  y = mod(x + pi, 2*pi) - pi;

  % Handle boundary case to match MATLAB exactly
  idx = (y == -pi) & (x > 0);
  y(idx) = pi;
end
