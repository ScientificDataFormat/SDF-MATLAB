function object = read_dsres(filename, object_name)

mat = load(filename);

% get the arrays
file_info = mat.Aclass;

if strcmp(file_info(2,1:3), '1.1') 
    if strcmp(file_info(4,1:8), 'binTrans')
        info = mat.dataInfo;
        desc = mat.description';
        cons = mat.data_1';
        vars = mat.data_2';
        names = mat.name';
    elseif strcmp(file_info(4,1:9), 'binNormal')
        info = mat.dataInfo';
        desc = mat.description;
        cons = mat.data_1;
        vars = mat.data_2;
        names = mat.name;
    else
        error('Format not supported')
    end
elseif strcmp(file_info(2,1:3), '1.0')
    
    names = mat.names;
    vars = mat.data;
    n = size(vars, 2);
    desc = char(zeros(n,1));
    info = [ones(n,1).*2, [1:n]']';

else
    error('Format not supported')
end

% remove the string terminators so strtrim() works correctly
names(names == 0) = ' ';
desc(desc == 0) = ' ';

n = size(info, 2);

root = SDF.Group();

ds_time = SDF.Dataset();
ds_time.name = strtrim(names(1, :));
ds_time.comment = strtrim(desc(1, :));
ds_time.unit = 's';
ds_time.data = vars(:, 1);
ds_time.is_scale = true;

root.datasets(end+1) = ds_time;

for i = 2:n
    
    ds = SDF.Dataset();
    
    d = info(1, i); % variability (constant=1, variable=2)
    x = info(2, i);
    c = abs(x);     % colum
    s = sign(x);    % sign
    
    path = strtrim(names(i, :));
    
    path_elements = strsplit(path, '.');
    
    parent_group = root;
    
    for j = 1:numel(path_elements)-1
        path_element = path_elements{j};
        pg = [];
        
        for k = 1:numel(parent_group.groups)
            if strcmp(parent_group.groups(k).name, path_element)
                pg = parent_group.groups(k);
                break
            end
        end
        
        if isempty(pg)
            pg = SDF.Group();
            pg.name = path_element;
            parent_group.groups(end+1) = pg;
        end
        
        parent_group = pg;
    end
    
    comment = strtrim(desc(i, :));
    last = find(comment == '[', 1, 'last');

    if d == 1
        data = cons(1, c);
    else
        data = vars(:, c);
        ds.scales = ds_time;
    end
    
    unit = '';
    display_unit = '';
    
    if ~isempty(comment) && comment(end) == ']' && last
        type_info = comment(last+1:end-1);
        comment = comment(1:last-1);
        elements = strsplit(type_info, ':#');
        for j = 1:numel(elements)
            element = elements{j};
            if strcmp(element, '(type=Integer)')
                % change type
                data = int32(data);
            elseif strcmp(element, '(type=Boolean)')
                % change type
                data = logical(data);
            elseif ~isempty(element)
                unit = element;
            end
        end
    end
    
    j = find(unit == '|');
    
    if j
        display_unit = unit(j+1:end);
        unit = unit(1:j-1);
    end
    
    if s < 0
        data = -data;
    end
    
    ds.name = path_elements{end};
    ds.comment = strtrim(comment);
    ds.unit = unit;
    ds.display_unit = display_unit;
    ds.data = data;
    
    parent_group.datasets(end+1) = ds;

end

if strcmp(object_name, '/')
    object = root;
else
    object = root.find_object(object_name);
end

end
