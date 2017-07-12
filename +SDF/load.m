%SDF.LOAD Load a dataset from an SDF file
%
%   g = SDF.load(FILENAME) loads the whole file and returns an SDF.Group
%
%   obj = SDF.load(FILENAME, OBJECT_NAME) loads an object from an SDF file
%   and returns an SDF.Group or SDF.Dataset
%
%   ds = SDF.load(FILENAME, DATASET_NAME, UNIT) loads a dataset, asserts 
%   the unit and returns an SDF.Dataset
%
%   ds = SDF.load(FILENAME, DATASET_NAME, UNIT, SCALE_UNITS) loads a 
%   dataset, asserts the unit, dimensions, scale units and returns an SDF.Dataset
%
%   Example:
%     
%       ds = SDF.load('data.sdf', '/signals/v')              % load the dataset 'v' in group 'singals
%       ds = SDF.load('data.sdf', '/signals/v', 'V')         % assert the unit 'V'
%       ds = SDF.load('data.sdf', '/signals/v', 'V', {'s'})  % assert the unit 's' of the scale for dimension 1
%       ds = SDF.load('data.sdf', '/signals/v', '', {''})    % assert that /v is a 1-d dataset

function object = load(filename, varargin)

    % check if the file exists
    assert(exist(filename, 'file') == 2, ['The file ''' filename ''' does not exist'])

    [~, ~, ext] = fileparts(filename);
    
    object_name = '/';
    
    if numel(varargin) >= 1
        object_name = varargin{1};
    end

    if strcmp(ext, '.sdf')
        object = read_hdf5(filename, object_name);
    elseif strcmp(ext, '.mat')
        object = read_dsres(filename, object_name);
    else
        error('Unknown file format')
    end
    
    if numel(varargin) >= 2
        % check the unit
        assert(isa(object, 'SDF.Dataset'), ['Unit was provided but ' object_name ' is not a dataset.'])
        unit = varargin{2};
        if ~isempty(unit)
            assert(strcmp(object.unit, unit), ['Dataset ' object_name ' has the wrong unit. Expected ''' unit ''' but was ''' object.unit '''.'])
        end
    end
    
    if numel(varargin) >= 3
        
        % check the rank
        scale_units = varargin{3};
        rank = numel(scale_units);
        assert(object.rank == rank, ['Dataset has the wrong rank. Expected ' num2str(rank) ' but was ' num2str(object.rank) '.'])
        
        % check the scale units
        for i = 1:numel(scale_units)
            scale_unit = scale_units{i};
            if ~isempty(scale_unit)
                scale = object.scales(i);
                assert(strcmp(scale.unit, scale_unit), ['The scale for dimension ' num2str(i) ' has the wrong unit. Expected ''' scale_unit ''' but was ''' scale.unit '''.'])
            end 
        end
        
    end
