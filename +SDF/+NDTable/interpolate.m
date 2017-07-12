function y = interpolate(points, data, scales, varargin)

assert(mod(numel(varargin), 2) == 0, 'Wrong number of arguments')

interp_method = 2;
extrap_method = 2;

for i = 1:2:numel(varargin)
    
    name = varargin{i};
    value = varargin{i + 1};
    
    if strcmpi(name, 'InterpMethod')
        
        if strcmpi(value, 'Hold')
            interp_method = 1;
        elseif strcmpi(value, 'Nearest')
            interp_method = 2;
        elseif strcmpi(value, 'Linear')
            interp_method = 3;
        elseif strcmpi(value, 'Akima')
            interp_method = 4;
        elseif strcmpi(value, 'FritschButland')
            interp_method = 5;
        elseif strcmpi(value, 'Steffen')
            interp_method = 6;
        else
            error('InterpMethod must be one of Hold, Nearest, Linear, Akima, FritschButland or Steffen')
        end
        
    elseif strcmpi(name, 'ExtrapMethod')
        
        if strcmpi(value, 'Hold')
            extrap_method = 1;
        elseif strcmpi(value, 'Linear')
            extrap_method = 2;
        elseif strcmpi(value, 'None')
            extrap_method = 3;
        else
            error('ExtrapMethod must be one of Hold, Linear or None')
        end
        
    else
        
        error(['Unknown key: ' name])
        
    end
    
    
end

% convert from column-major (FORTRAN) to row-major (C) order
order = fliplr(1:ndims(data));
data = permute(data, order);

y = mex_ndtable(fliplr(points)', data, scales, interp_method, extrap_method);

end
