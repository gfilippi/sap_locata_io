function T = readtable(filename, delimiter)
% READTABLE_OCTAVE  MATLAB readtable replacement for Octave
% Returns a struct instead of a table.

  if nargin < 2
    delimiter = "\t";
  end

  fid = fopen(filename, "r");
  if fid < 0
    error("Cannot open file: %s", filename);
  end

  header = fgetl(fid);

  if isempty(delimiter)
    if ~isempty(strfind(header, ","))
      delimiter = ",";
    elseif ~isempty(strfind(header, ";"))
      delimiter = ";";
    elseif ~isempty(strfind(header, "\t"))
      delimiter = "\t";
    else
      error("Delimiter could not be detected.");
    end
  end

  names = strsplit(strtrim(header), delimiter);
  names = matlab.lang.makeValidName(names);

  fmt = repmat("%s", 1, numel(names));
  data = textscan(fid, fmt, "Delimiter", delimiter);

  fclose(fid);

  for k = 1:numel(names)
    col = data{k};
    num = str2double(col);

    if all(~isnan(num))
      T.(names{k}) = num;
    else
      T.(names{k}) = col;
    end
  end
end
