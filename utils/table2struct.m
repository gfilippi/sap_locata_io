function S = table2struct(T)
% TABLE2STRUCT  MATLAB-compatible table2struct for Octave
%
%   S = table2struct(T)
%
% Input:
%   T - struct with fields representing columns
%
% Output:
%   S - struct array, one element per row

  if ~isstruct(T)
    error("table2struct: input must be a struct");
  end

  fields = fieldnames(T);

  if isempty(fields)
    S = struct();
    return;
  end

  % Determine number of rows
  first = T.(fields{1});
  nrows = numel(first);

  % Validate column lengths
  for k = 1:numel(fields)
    col = T.(fields{k});
    if numel(col) ~= nrows
      error("table2struct: fields must have the same number of rows");
    end
  end

  % Create struct array
  S = repmat(struct(), nrows, 1);

  for i = 1:nrows
    for k = 1:numel(fields)
      col = T.(fields{k});
      if iscell(col)
        S(i).(fields{k}) = col{i};
      else
        S(i).(fields{k}) = col(i,:);
      end
    end
  end
end
