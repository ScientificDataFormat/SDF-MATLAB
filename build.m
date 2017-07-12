% clean up
clear all

if exist('test-env', 'dir')
    rmdir test-env
end

% build the S- and mex-functions
system('build_windows')

archive = 'SDF-MATLAB-0.1.0.zip';

% create the archive
zip(archive, {
    '+SDF/+NDTable/*.m', ...
    '+SDF/*.m', ...
    '+SDF/private/*.m', ...
    'examples/*.m', ...
    'NDTable.slx', ...
    'mex_ndtable.mexw*', ...
    'sfun_ndtable.mexw*', ...
    'README.md', ...
    'LICENSE', ...
});

% extract the distribution file
unzip(archive, 'test-env')

% run the tests
cd tests
addpath ../test-env
runtests

cd ..
