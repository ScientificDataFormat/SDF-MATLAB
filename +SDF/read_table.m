function data = read_table(filename, dataset)

disp(['loading ' filename ' ' dataset])

ds = SDF.load(filename, dataset);

data = ds.rank;

for i = 1:ds.rank
    data = [data numel(ds.scales(i).data)];
end

for i = 1:ds.rank
    data = [data ds.scales(i).data(:)'];
end

values = ds.data;

% convert from column-major (FORTRAN) to row-major (C) order
order = fliplr(1:ndims(values));
values = permute(values, order);

data = [data values(:)'];

end
