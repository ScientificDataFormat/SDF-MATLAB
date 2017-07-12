% Copyright (c) 2016 Dassault Systemes. All rights reserved.

classdef Dataset < handle
    
    properties
        name = ''
        comment = ''
        attributes = struct([])
        data = []
        display_name = ''
        relative_quantity = false
        unit = ''
        display_unit = ''
        is_scale = false
        scales = SDF.Dataset.empty
    end
    
    properties (Dependent)
        rank
    end
    
    methods

        function self = Dataset()
            self.attributes = struct();
            self.relative_quantity = false;
            self.is_scale = 0;
        end
        
        function value = get.rank(obj)
            s = size(obj.data);
            nd = ndims(obj.data);
            
            if nd > 2
                value = nd;
            elseif s(1) <= 1 && s(2) <= 1
                value = 0;
            elseif s(1) == 1 || s(2) == 1
                value = 1;
            else
                value = nd;
            end
        end
        
    end
    
end
