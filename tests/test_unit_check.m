% test the unit checks

[pathstr, ~, ~] = fileparts(which('test_unit_check.m'));
filename = fullfile(pathstr, 'unit_check.sdf');

a = SDF.Dataset();
a.name = 'a';
a.unit = 'A';
a.data = [1 2]';

b = SDF.Dataset();
b.name = 'b';
b.unit = 'B';
b.data = [1 2 3]';

c = SDF.Dataset();
c.name = 'c';
c.unit = 'C';
c.data = [1 2 3; 4 5 6];
c.scales = [a b];

g = SDF.Group();
g.datasets = [a b c];

SDF.save(filename, g)

clear a b c g

% no checks
c = SDF.load(filename, '/c');
assert(strcmp(c.name, 'c'));

% load with unit
c = SDF.load(filename, '/c', 'C');
assert(strcmp(c.name, 'c'));

% load with dimensions
c = SDF.load(filename, '/c', '', {'', ''});
assert(strcmp(c.name, 'c'));

% load with scale units
c = SDF.load(filename, '/c', '', {'A', 'B'});
assert(strcmp(c.name, 'c'));

% load with wrong unit
try SDF.load(filename, '/c', 'X'), catch err, end
assert(strcmp(err.message, 'Dataset /c has the wrong unit. Expected ''X'' but was ''C''.'))

% load with wrong dimensions
try SDF.load(filename, '/c', '', {''}), catch err, end
assert(strcmp(err.message, 'Dataset has the wrong rank. Expected 1 but was 2.'))

% load with wrong scale units
try SDF.load(filename, '/c', '', {'A', 'X'}), catch err, end
assert(strcmp(err.message, 'The scale for dimension 2 has the wrong unit. Expected ''X'' but was ''B''.'))
