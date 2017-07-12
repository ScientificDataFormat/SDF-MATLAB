# Scientific Data Format for MATLAB / Simulink

SDF for MATLAB is a library to read, write and interpolate multi-dimensional
data in MATLAB and Simulink. The Scientific Data Format is an open file format
based on [HDF5](https://www.hdfgroup.org/hdf5/) to store multi-dimensional data
such as parameters, simulation results or measurements. It supports...

- very large files
- up to 32 dimensions
- hierarchical structure
- units, comments and custom meta-information

For detailed information see the [SDF specification](https://github.com/ScientificDataFormat/SDF).


## Installation

Download and extract the distribution and add the folder (that contains the +SDF
folder) to the MATLAB path:

```
>> addpath 'C:\libs\SDF-MATLAB'
```

## Examples

To get started try the examples:

- [demo.m](examples/demo.m) read and write *.sdf files
- [interp_1d.m](examples/interp_1d.m) interpolate 1-d data
- [interp_2d.m](examples/interp_2d.m) interpolate 1-d data


-----------------------------

&copy; 2017 Dassault Syst&egrave;mes
