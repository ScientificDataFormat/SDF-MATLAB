/* Copyright (c) 2017 Dassault Systemes. All rights reserved. */

#include "mex.h"
#include "NDTable.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

	NDTable_InterpMethod_t interp_method;
	NDTable_ExtrapMethod_t extrap_method;

	if (!mxIsCell(prhs[2])) {
		mexErrMsgTxt("Argument 2 must be a Cell array.");
	}

	// check for proper number of arguments
	if (nrhs != 5) {
		mexErrMsgTxt("5 input arguments required.");
	}

	// interp_method
	if (!mxIsDouble(prhs[3]) ||	mxIsComplex(prhs[3]) || mxGetNumberOfElements(prhs[3]) != 1) {
		mexErrMsgTxt("InterpMethod must be a scalar.");
	}

	interp_method = *mxGetPr(prhs[3]);

	// extrap_method
	if (!mxIsDouble(prhs[4]) || mxIsComplex(prhs[4]) || mxGetNumberOfElements(prhs[4]) != 1) {
		mexErrMsgTxt("ExtrapMethod must be a scalar.");
	}

	extrap_method = *mxGetPr(prhs[4]);

	// make sure the second input argument is type double
	if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])) {
		mexErrMsgTxt("Input 2 must be a double array.");
	}

	// get number of dimensions
	int ndims = mxGetNumberOfDimensions(prhs[1]);

	// treat column vectors as 1-D arrays
	if (ndims == 2 && mxGetN(prhs[1]) == 1) {
		ndims = 1;
	}
	
	// check the number of dimensions
	if (nrhs > 32) {
		mexErrMsgTxt("The maximum number of dimensions of data is 32.");
	}
	
	int dims[MAX_NDIMS] = { 0 };

	// check the number of scales
	if (mxGetNumberOfElements(prhs[2]) != ndims) {
		mexErrMsgTxt("The number of scales must match the number of dimensions in data.");
	}

	double *scales[MAX_NDIMS] = { 0 };

	// copy the dimensions
	for (int i = 0; i < ndims; i++) {

		const int j = ndims - 1 - i;
		
		// reverse order
		dims[i] = mxGetDimensions(prhs[1])[j];

		mxArray *pa = mxGetCell(prhs[2], i);

		// check the scale
		if (!mxIsDouble(pa) || mxIsComplex(pa) || mxGetNumberOfElements(pa) != dims[i]) {
			mexErrMsgTxt("Scale does not match dimension");
		}

		scales[i] = mxGetPr(pa);
	}

	if (!mxIsDouble(prhs[0]) ||	mxIsComplex(prhs[0]) || mxGetM(prhs[0]) != ndims) {
		mexErrMsgTxt("Points must be a double matrix where the number of columns matches the number of dimensions in data.");
	}

	// check the number output arguments
	if (nlhs != 1) {
		mexErrMsgTxt("One output required.");
	}

	const int npoints = mxGetN(prhs[0]);

	/* create the output matrix */
	plhs[0] = mxCreateDoubleMatrix(1, npoints, mxREAL);

	/* get a pointer to the real data in the output matrix */
	double *values = mxGetPr(plhs[0]);

	const double *points = mxGetPr(prhs[0]);
	const double *data = mxGetPr(prhs[1]);

	NDTable_h table = NDTable_create_table(ndims, dims, data, scales);

	int status = 0;
	double params[MAX_NDIMS];

	for (int i = 0; i < npoints; i++) {
		// TODO: check status
		status = NDTable_evaluate(table, 1, &points[i * ndims], interp_method, extrap_method, &values[i]);
	}

	NDTable_free_table(table);
}
