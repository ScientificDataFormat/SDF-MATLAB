% Test the loading of the different dsres formats 

[pathstr, ~, ~] = fileparts(which('test_dsres.m'));

dsres_files = {
    'DoublePendulum_Dymola-7.4.mat', ...
    'DoublePendulum_Dymola-2012.mat', ...
    'DoublePendulum_Dymola-2012-SaveAs.mat', ...
    'DoublePendulum_Dymola-2012-SaveAsPlotted.mat', ...
    };

for filename = dsres_files
    
    filename = filename{1};
    
    plotted = strcmp(filename(end-10:end-4), 'Plotted');
    
    f = fullfile(pathstr, filename);
    
    disp(f)
    
    g = SDF.load(f);
    
    assert(isa(g, 'SDF.Group'))
    
    assert(numel(g.datasets) == 1)
    
    if ~plotted
        assert(numel(g.groups) == 6)
    end
    
    ds_time = g.find_object('/Time');
    assert(all(size(ds_time.data) == [502, 1]))
    if ~plotted
        assert(strcmp(ds_time.comment, 'Time in [s]'))
        assert(strcmp(ds_time.unit, 's'))
    end

    ds_w = g.find_object('/revolute2/w');
    assert(all(size(ds_w.data) == [502, 1]))
    assert(ds_w.scales == ds_time)
    if ~plotted
        assert(strcmp(ds_w.comment, 'First derivative of angle phi (relative angular velocity)'))
        assert(strcmp(ds_w.unit, 'rad/s'))
    end
    
end
