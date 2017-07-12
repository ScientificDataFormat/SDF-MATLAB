% Save and load a signal using SDF

% create a scale
ds_time = SDF.Dataset;
ds_time.name = 'time';
ds_time.comment = 'Time';
ds_time.data = [0:0.5:10]';
ds_time.is_scale = true;
ds_time.display_name = 'Time';
ds_time.unit = 's';

% create a dataset
ds_v = SDF.Dataset;
ds_v.name = 'v';
ds_v.comment = 'Measured voltage';
ds_v.data = sin(ds_time.data);
ds_v.relative_quantity = true;
ds_v.unit = 'V';
ds_v.scales = ds_time;

% creat a group
g = SDF.Group;
g.comment = 'An example SDF file';
g.datasets = [ds_time ds_v];

% save the group
SDF.save('demo.sdf', g)

% re-load the dataset from the file
ds_v = SDF.load('demo.sdf', '/v', 'V', {'s'});

% get the scale from the dataset
ds_time = ds_v.scales(1);

% plot the data
plot(ds_time.data, ds_v.data)
xlabel([ds_time.name ' / ' ds_time.unit])
ylabel([ds_v.name ' / ' ds_v.unit])
