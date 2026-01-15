function tf = contains(str, pattern, varargin)
% CONTAINS  MATLAB-compatible contains() for Octave
%
%   tf = contains(str, pattern)
%   tf = contains(str, pattern, 'IgnoreCase', true)

  % --- Parse optional arguments
  ignoreCase = false;
  if nargin > 2
    for k = 1:2:numel(varargin)
      if strcmpi(varargin{k}, 'IgnoreCase')
        ignoreCase = varargin{k+1};
      end
    end
  end

  % --- Normalize inputs
  if ischar(str)
    str = {str};
    singleOutput = true;
  else
    singleOutput = false;
  end

  if ischar(pattern)
    pattern = {pattern};
  end

  tf = false(size(str));

  % --- Apply IgnoreCase
  if ignoreCase
    str = lower(str);
    pattern = lower(pattern);
  end

  % --- Matching
  for i = 1:numel(str)
    for j = 1:numel(pattern)
      if ~isempty(strfind(str{i}, pattern{j}))
        tf(i) = true;
        break;
      end
    end
  end

  % --- Restore scalar output
  if singleOutput
    tf = tf(1);
  end
end
