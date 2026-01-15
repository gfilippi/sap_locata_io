function T = struct2table(S)
% STRUCT2TABLE  MATLAB-compatible struct2table for Octave
%
%   T = struct2table(S)
%
% Input:
%   S - struct array (1×N)
%
% Output:
%   T - struct with column vectors as fields (emulating table)

  if ~isstruct(S)
    error("struct2table: input must be a struct array");
  end

  if isempty(S)
    T = struct();
    return;
  end

  fields = fieldnames(S);
  nrows = numel(S);

  for k = 1:numel(fields)
    f = fields{k};
    col = cell(nrows,1);

    % Extract field values into a cell
    for i = 1:nrows
      col{i} = S(i).(f);
    end

    % If numeric or logical and all values are scalar, convert to vector
    if all(cellfun(@(x) isnumeric(x) && isscalar(x), col))
      T.(f) = cell2mat(col);
    else
      T.(f) = col;  % keep as cell array for strings / arrays
    end
  end
end
