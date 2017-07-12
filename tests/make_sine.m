function make_sine

ds_x = SDF.Dataset;
ds_x.name = 'x';
ds_x.data = [0 : pi*0.4 : 2*pi]';

ds_y = SDF.Dataset;
ds_y.name = 'y';
ds_y.data = sin(ds_x.data);
ds_y.scales = ds_x;

g = SDF.Group;
g.datasets = [ds_x ds_y];

SDF.save('sine.sdf', g)

end
