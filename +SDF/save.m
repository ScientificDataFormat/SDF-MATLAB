% Copyright (c) 2016 Dassault Systemes. All rights reserved.

%#ok<*AGROW>

function save(filename, root)

% delete the file
if exist(filename, 'file') == 2
    delete(filename)
end

% create a new file
file_id = H5F.create (filename, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');

datasets = write_group(file_id, root);

% set the scales
for i = 1:numel(datasets)
    ds = datasets{i}{1};
    ds_name = datasets{i}{2};
    
    for j = 1:numel(ds.scales)
        scale = ds.scales(j);
        
        % find the name of the scale
        for k = 1:numel(datasets)
            s = datasets{k}{1};
            if scale == s
                scale_name = datasets{k}{2};        
                break
            end
        end
        
        % attache the scale
        ds_id = H5D.open(file_id, ds_name, 'H5P_DEFAULT');
        scale_id = H5D.open(file_id, scale_name, 'H5P_DEFAULT');
        H5DS.attach_scale(ds_id, scale_id, j-1);
        H5D.close(ds_id);
        H5D.close(scale_id);
    end
    
end

H5F.close (file_id);

end

function datasets = write_group(loc_id, g)

    % write the comment
    if ~isempty(g.comment)
        write_attribute(loc_id, 'COMMENT', g.comment);
    end
    
    % write the attributes
    if ~isempty(g.attributes)
        fields = fieldnames(g.attributes);
        for i = 1:numel(fields)
            write_attribute(file_id, fields{i}, g.attributes.(fields{i}));
        end
    end

    datasets = {};
    
    % write the sub-groups
    for i = 1:numel(g.groups)
        subgroup = g.groups(i);
        subgroup_id = H5G.create(loc_id, subgroup.name, 0);
        datasets = horzcat(datasets, write_group(subgroup_id, subgroup));
    end
        
    % then the datasets
    for i = 1:numel(g.datasets)
        ds = g.datasets(i);
        ds_id = write_dataset(loc_id, ds);       
        name = H5I.get_name(ds_id);   
        datasets{end+1} = {ds, name};
        H5D.close (ds_id);
    end
end

function ds_id = write_dataset(file_id, ds)
    
    dims = size(ds.data);
    
    if numel(dims) == 2
        if numel(ds.data) == 1
            dims = [];
        elseif dims(2) == 1
            dims = dims(1);
        end
    end
    
    % MATLAB automatically removes the last dimension
    % if it has extent one. Re-add the dummy dimension if
    % a scale is attached
    if numel(dims) < numel(ds.scales)
        dims = [dims 1];
    end
    
    space_id = H5S.create_simple (numel(dims), dims, []);
    
    % convert the elements in matrix A from row to column major format
    data = permute(ds.data, fliplr(1:ndims(ds.data)));    
    
    if isinteger(data)
        h5_type = 'H5T_NATIVE_INT';
    elseif islogical(data)
        h5_type = 'H5T_NATIVE_INT';
        data = int32(data);
    else
        h5_type = 'H5T_NATIVE_DOUBLE'; 
    end      
    
    ds_id = H5D.create (file_id, ds.name, h5_type, space_id, 'H5P_DEFAULT');
    
    H5D.write (ds_id, h5_type, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data);
    
    if ds.is_scale
        H5DS.set_scale(ds_id, ds.display_name);            
    end
    
    if ~isempty(ds.comment)
        write_attribute(ds_id, 'COMMENT', ds.comment);
    end
    
    if ds.relative_quantity
        write_attribute(ds_id, 'RELATIVE_QUANTITY', 'TRUE');
    end
    
    if ~isempty(ds.unit)
        write_attribute(ds_id, 'UNIT', ds.unit);
    end
    
    if ~isempty(ds.display_unit) && strcmp(ds.display_unit, ds.unit) ~= 1
        write_attribute(ds_id, 'DISPLAY_UNIT', ds.display_unit);
    end
    
    H5S.close (space_id);
end

function write_attribute(obj_id, name, value)
    if ischar(value)

        % encode as UTF-8
        value = char(unicode2native(value, 'UTF-8'));
                
        len = numel(value);    

        type_id = H5T.copy('H5T_FORTRAN_S1');
        H5T.set_size(type_id, len);

        space_id = H5S.create('H5S_SCALAR');
        attr_id = H5A.create(obj_id, name, type_id, space_id, 'H5P_DEFAULT');
        H5S.close(space_id);
        
        H5A.write(attr_id, type_id, value);

        H5A.close(attr_id);
    end
end
