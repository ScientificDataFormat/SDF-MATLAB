% Copyright (c) 2016 Dassault Systemes. All rights reserved.

classdef Group < handle
    
    properties
        name = ''
        comment = ''
        attributes = struct([])
        datasets = SDF.Dataset.empty
        groups = SDF.Group.empty
    end
    
    methods

        function object = find_object(self, object_name)
            
            object = [];
            
            segments = strsplit(object_name, '/');
            
            first = '';
            
            while isempty(first) && ~isempty(segments)
                first = segments{1};
                segments = segments(2:end);
            end
            
            if isempty(first)
                % path is empty
                return
            end
                      
            % search the datasets
            for i = 1:numel(self.datasets)
                dataset = self.datasets(i);
                if strcmp(dataset.name, first)
                    object = dataset;
                    return
                end
            end
            
            % search the groups
            for i = 1:numel(self.groups)
                group = self.groups(i);
                if strcmp(group.name, first)
                    if isempty(segments)
                        object = group;
                    else
                        % continue the search
                        path = strjoin(segments, '/');
                        object = group.find_object(path);
                    end                    
                end
            end
                        
        end
        
   end
    
end
