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
              if strcmp(delimiter, '\t')
                  delimiter = sprintf('\t');
              end
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

  % check for consistency
  for k = 1:numel(fields)
    if numel(T.(fields{k})) ~= nrows
        error('writetable: column "%s" has inconsistent length', fields{k});
    end
  end

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

          % --- Extract scalar value safely ---
          if iscell(col)
              val = col{i};
          elseif isstring(col)
              val = char(col(i));
          else
              val = col(i);
          end

          % --- Print value ---
          if isnumeric(val)
              fprintf(fid, '%g', val);
          elseif islogical(val)
              fprintf(fid, '%d', val);
          elseif ischar(val)
              fprintf(fid, '%s', val);
          else
              fprintf(fid, '%s', mat2str(val));
          end

          % --- Print delimiter BETWEEN columns ---
          if k < numel(fields)
              fprintf(fid, '%s', delimiter);
          end
      end
      fprintf(fid, '\n');
  end

  fclose(fid);