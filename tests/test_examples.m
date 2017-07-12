% run example scripts

% get the example directory
[pathstr, ~, ~] = fileparts(which('test_examples.m'));
[pathstr, ~, ~] = fileparts(pathstr);
pathstr = fullfile(pathstr, 'examples');

% run the example scripts
run(fullfile(pathstr, 'demo.m'))
run(fullfile(pathstr, 'interp_1d.m'))
run(fullfile(pathstr, 'interp_2d.m'))

% close the figures
close all
