function object = read_hdf5(filename, object_name)

f_info = h5info(filename);

% read the root group
[root, scales] = read_group(filename, f_info);

% restore the scales
dataset_names = scales.keys;

for i = 1:numel(dataset_names)
    dataset_name = dataset_names{i};
    dataset = root.find_object(dataset_name);
    scale_names = scales(dataset_name);
    for j = 1:numel(scale_names)
        scale_name = scale_names{j};
        scale = root.find_object(scale_name);
        dataset.scales(j) = scale;
    end
end

if strcmp(object_name, '/')
    object = root;
else
    object = root.find_object(object_name);
end

end


function [g, scales] = read_group(filename, g_info)

    g = SDF.Group();
    path = strsplit(g_info.Name, '/');
    g.name = path{end};

    scales = containers.Map;
    
    for i = 1:numel(g_info.Attributes)
        attr = g_info.Attributes(i);
            
        if ~strcmp(attr.Datatype.Class, 'H5T_STRING')
            continue
        end
            
        if strcmp(attr.Name, 'COMMENT')
            g.comment = attr.Value;
        else
            g.attributes
        end
    end

    
    for i = 1:numel(g_info.Groups)
        child_group_info = g_info.Groups(i);
        [child_group, child_scales] = read_group(filename, child_group_info);
        g.groups(end+1) = child_group;
        % merge the child scales
        child_scale_names = child_scales.keys;
        for j = 1:numel(child_scale_names)
            dataset_name = child_scale_names{j};
            scales(dataset_name) = child_scales(dataset_name);
        end
    end

    for i = 1:numel(g_info.Datasets)
        ds_info = g_info.Datasets(i);
        ds = SDF.Dataset();
        ds.name = ds_info.Name;
        dataset_name = [g_info.Name '/' ds_info.Name];
        ds.data = h5read(filename, [g_info.Name '/' ds_info.Name]);
        
        % convert to column-major format
        if size(ds.data, 2) > 1
            ds.data = permute(ds.data, numel(size(ds.data)):-1:1);
        end
        
        for j = 1:numel(ds_info.Attributes)
            attr = ds_info.Attributes(j);
                        
            if strcmp(attr.Name, 'DIMENSION_LIST')
                scales(dataset_name) = get_scales(filename, dataset_name);
            end
            
            if ~strcmp(attr.Datatype.Class, 'H5T_STRING')
                continue
            end
            
            if strcmp(attr.Name, 'COMMENT')
                ds.comment = attr.Value;
            elseif strcmp(attr.Name, 'UNIT')
                ds.unit = attr.Value;
            elseif strcmp(attr.Name, 'DISPLAY_UNIT')
                ds.display_unit = attr.Value;
            elseif strcmp(attr.Name, 'CLASS') && strcmp(attr.Value, 'DIMENSION_SCALE')
                ds.is_scale = true;
            else
                % skip
            end
        end
        
        g.datasets(end+1) = ds;
    end

end


function scale_names = get_scales(filename, dataset_name)

    file_id = H5F.open(filename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

    ds_id = H5D.open(file_id, dataset_name);
    
    space_id = H5D.get_space(ds_id);
    
    rank = H5S.get_simple_extent_dims(space_id);
    
    scale_names = cell(rank, 1);
    
    for dim = 1:rank
        [~,~,scale_name] = H5DS.iterate_scales(ds_id, dim-1, [], @iterate_scales, filename);
        scale_names{dim} = scale_name;
        %if isempty(ds.scales), ds.scales = s; else ds.scales(dim) = s; end
    end
    
    H5D.close(ds_id);
    
    H5F.close(file_id);
end


function [status, scale_name] = iterate_scales(~, ~, scale_id, ~)
    scale_name = H5I.get_name(scale_id);
    status = 0; % stop after the first scale
end