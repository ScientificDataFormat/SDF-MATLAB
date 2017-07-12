% Test the SDF roundtrip (write & read SDF object tree)

[pathstr, ~, ~] = fileparts(which('test_hdf5.m'));

filename = fullfile(pathstr, 'roundtrip.sdf');

% create a scale
ds_time = SDF.Dataset;
ds_time.name = 'Time';
ds_time.comment = 'A scale';
ds_time.data = [1:0.1:10]';
ds_time.unit = 's';
ds_time.is_scale = true;

% create a dataset
ds_sine = SDF.Dataset;
ds_sine.name = 'sine';
ds_sine.comment = 'A 1-d dataset w/ attached scale';
ds_sine.data = sin(ds_time.data);
ds_sine.unit = 's';
ds_sine.scales = ds_time;

% create a sub-group
g_sub = SDF.Group;
g_sub.name = 'sub';
g_sub.comment = 'A sub-group';

% create the root group
g = SDF.Group;
g.comment = 'A test file';
g.datasets = [ds_time, ds_sine];
g.groups = g_sub;

% create a 2-d datase
ds_2d = SDF.Dataset();
ds_2d.name = 'two_d';
ds_2d.data = [1 2 3; 4 5 6];
g_sub.datasets = ds_2d;

% save the file
SDF.save(filename, g)

clear g ds_time ds_sine g_sub ds_2d

% load the file
g = SDF.load(filename);

% ckeck the root group
assert(strcmp(g.comment, 'A test file'));

% check /Time
ds_time = g.find_object('/Time');
assert(strcmp(ds_time.name, 'Time'));
assert(strcmp(ds_time.comment, 'A scale'));
assert(all(ds_time.data == [1:0.1:10]'));
assert(strcmp(ds_time.unit, 's'));
assert(ds_time.is_scale);

% check /sine
ds_sine = g.find_object('/sine');
assert(strcmp(ds_sine.name, 'sine'));
assert(strcmp(ds_sine.comment, 'A 1-d dataset w/ attached scale'));
assert(all(ds_sine.data == sin([1:0.1:10]')));
assert(strcmp(ds_sine.unit, 's'));
assert(ds_sine.scales == ds_time)

% check /sub
g_sub = g.find_object('/sub');
assert(isa(g_sub, 'SDF.Group'));
assert(strcmp(g_sub.name, 'sub'));
assert(strcmp(g_sub.comment, 'A sub-group'));

% check /sub/two_d
ds_2d = g.find_object('/sub/two_d');
assert(all(all(ds_2d.data == [1 2 3; 4 5 6])))

