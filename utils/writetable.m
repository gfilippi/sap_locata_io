function writetable(T, filename, varargin)
% WRITETABLE_OCTAVE  MATLAB-compatible writetable for Octave
%
%   writetable(T, filename)
%   writetable(T, filename, 'Delimiter', ',')
%
% Input:
%   T - struct with column vectors (emulating table)
%   filename - string, path to CSV file
%   Name-Value pairs:
%       'Delimiter' - ',' (default), or '\t', ';', etc.

  % --- Parse optional arguments ---
  delimiter = ',';
  for k = 1:2:length(varargin)
      switch lower(varargin{k})
          case 'delimiter'
              delimiter = varargin{k+1};
          otherwise
              error('Unknown parameter %s', varargin{k});
      end
  end

  if ~isstruct(T)
      error('writetable_octave: input must be a struct');
  end

  fields = fieldnames(T);
  if isempty(fields)
      warning('writetable_octave: empty struct, nothing to write');
      return;
  end

  % Determine number of rows
  firstField = T.(fields{1});
  nrows = numel(firstField);

  % Open file for writing
  fid = fopen(filename, 'w');
  if fid < 0
      error('Cannot open file: %s', filename);
  end

  % Write header
  fprintf(fid, '%s', fields{1});
  for k = 2:numel(fields)
      fprintf(fid, '%s%s', delimiter, fields{k});
  end
  fprintf(fid, '\n');

  % Write data row by row
  for i = 1:nrows
      for k = 1:numel(fields)
          col = T.(fields{k});
          val = col(i);

          if iscell(col)
              % Strings or mixed data
              val = col{i};
          end

          if isnumeric(val)
              fprintf(fid, '%g', val);
          elseif islogical(val)
              fprintf(fid, '%d', val);
          elseif ischar(val) || isstring(val)
              fprintf(fid, '%s', val);
          else
              % fallback: convert to string
              fprintf(fid, '%s', mat2str(val));
          end

          if k ~= numel(fields)
              fprintf(fid, '%s', delimiter);
          end
      end
      fprintf(fid, '\n');
  end

  fclose(fid);
end
