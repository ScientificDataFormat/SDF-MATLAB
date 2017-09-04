/* Copyright (c) 2017 Dassault Systemes. All rights reserved. */

#define S_FUNCTION_NAME sfun_ndtable
#define S_FUNCTION_LEVEL 2

#include <yvals.h>
#if (_MSC_VER >= 1600)
#define __STDC_UTF_16__
#endif

extern "C" {
#include "simstruc.h"
}

#include "NDTable.h"


enum Parameter {

	interpMethodParam,
	extrapMethodParam,
	dataParam,
	numberOfParams

};


inline NDTable_InterpMethod_t interpMethod(SimStruct *S) { 
	int v = static_cast<int>(mxGetScalar(ssGetSFcnParam(S, interpMethodParam)));
	return static_cast<NDTable_InterpMethod_t>(v);
}


inline NDTable_ExtrapMethod_t extrapMethod(SimStruct *S) { 
	int v = static_cast<int>(mxGetScalar(ssGetSFcnParam(S, extrapMethodParam)));
	return static_cast<NDTable_ExtrapMethod_t>(v);
}


inline void _getDims(SimStruct *S, int *dims) { 
	
	real_T *data = static_cast<real_T *>(mxGetData(ssGetSFcnParam(S, dataParam)));

	int ndims = data[0];

	for (int i = 0;  i < ndims; i++) {
		dims[i] = data[i + 1];
	}

}


#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
static void mdlCheckParameters(SimStruct *S) {

	//ssPrintf("\nmdlCheckParameters()\n");

	if (!mxIsNumeric(ssGetSFcnParam(S, interpMethodParam)) || mxGetNumberOfElements(ssGetSFcnParam(S, interpMethodParam)) != 1) {
		ssSetErrorStatus(S, "Parameter 1 (interpolation method) must be a scalar");
        return;
    }

	switch (interpMethod(S)) {
		case NDTABLE_INTERP_HOLD:
		case NDTABLE_INTERP_NEAREST:
		case NDTABLE_INTERP_LINEAR:
		case NDTABLE_INTERP_AKIMA:
		case NDTABLE_INTERP_FRITSCH_BUTLAND:
		case NDTABLE_INTERP_STEFFEN:
			break;
		default:
			ssSetErrorStatus(S, "Parameter 1 (interpolation method) must be one of 1 (= hold),  2 (= nearest), 3 (= linear), 4 (= Akima), 5 (= Fritsch-Butland) or 6 (= Steffen)");
			return;
	}
		
	if (!mxIsNumeric(ssGetSFcnParam(S, extrapMethodParam)) || mxGetNumberOfElements(ssGetSFcnParam(S, extrapMethodParam)) != 1) {
		ssSetErrorStatus(S, "Parameter 2 (extrapolation method) must be a scalar");
        return;
    }

	switch (extrapMethod(S)) {
		case NDTABLE_EXTRAP_HOLD:
		case NDTABLE_EXTRAP_LINEAR:
		case NDTABLE_EXTRAP_NONE:
			break;
		default:
			ssSetErrorStatus(S, "Parameter 2 (extrapolation method) must be one of 1 (= hold),  2 (= linear) or 3 (= no extrapolation)");
			return;
	}

	int rank, i, size, dims[32];
	const double *scales[32];
	NDTable_h table = NULL;

	if (!mxIsNumeric(ssGetSFcnParam(S, dataParam))) {
		ssSetErrorStatus(S, "Parameter 3 (data) must be numeric");
		return;
	}

	size = mxGetNumberOfElements(ssGetSFcnParam(S, dataParam));

	if (size < 2) {
		ssSetErrorStatus(S, "The number of elements in parameter 3 (data) must be >= 2");
		return;
	}

	const real_T *data = (real_T *)mxGetData(ssGetSFcnParam(S, dataParam));

	rank = *data++;

	// check the rank
	if (rank < 0 || rank > 32) {
		ssSetErrorStatus(S, "The first element in data must be in the range [0;32]");
		return;
	}

	// check the size
	if (size < 1 + rank) {
		ssSetErrorStatus(S, "Parameter 3 (data) has not enough elements for the given number of dimensions");
		return;
	}

	// check the dimensions
	for (i = 0; i < rank; i++) {
		dims[i] = *data++;

		if (dims[i] < 1) {
			ssSetErrorStatus(S, "The size of the dimensions must be >= 1");
			return;
		}
	}

	// check the number of elements
	int numel = 1;
	
	for (i = 0; i < rank; i++) {
		numel *= dims[i]; // data
	}

	for (i = 0; i < rank; i++) {
		numel += dims[i]; // scales
	}

	numel += rank; // dims
	numel++; // ndims

	if (size != numel) {
		ssSetErrorStatus(S, "Parameter 3 (data) has the wrong number of elements for the given dimensions. Expected %d but was %d.", numel, size);
		return;
	}

}
#endif /* MDL_CHECK_PARAMETERS */


static void mdlInitializeSizes(SimStruct *S) {

	//ssPrintf("\nmdlInitializeSizes()\n");

	size_t			i			= 0;	
	int				ndims		= -1;
	//
	ssSetNumSFcnParams(S, numberOfParams);

	#if defined(MATLAB_MEX_FILE)
	if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
		mdlCheckParameters(S);
		if (ssGetErrorStatus(S) != NULL) {
			return;
		}
	} else {
		return; // parameter mismatch will be reported by Simulink
	}
#endif

	ssSetNumPWork(S, 1);

	ndims = ((real_T *)(mxGetData(ssGetSFcnParam(S, dataParam))))[0];

	if (!ssSetNumInputPorts(S, ndims)) return;
	for(i = 0; i < (size_t)ndims; i++) {
		ssSetInputPortWidth(S, i, 1);
		ssSetInputPortDirectFeedThrough(S, i, 1);
	}

	if (!ssSetNumOutputPorts(S,1)) return;
	ssSetOutputPortWidth(S, 0, 1);

	ssSetNumSampleTimes(S, 1);

	/* Take care when specifying exception free code - see sfuntmpl.doc */
	ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}

static void mdlInitializeSampleTimes(SimStruct *S) {
	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
	ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
#if defined(MDL_START) 
 static void mdlStart(SimStruct *S) {

	int ndims = 0;
	int dims[32] = { 0 };
	const double *scales[32] = { 0 };

	real_T *data = (real_T *)mxGetData(ssGetSFcnParam(S, dataParam));

	int idx = 0;

	ndims = data[idx++];

	for (int i = 0; i < ndims; i++) {
		dims[i] = data[idx++];
	}

	for (int i = 0; i < ndims; i++) {
		scales[i] = &data[idx];
		idx += dims[i];
	}

	NDTable_h table = NDTable_create_table(ndims, dims, &data[idx], scales);

	if (!table) {
		ssSetErrorStatus(S, NDTable_get_error_message());
		return;
	}
	
	ssGetPWork(S)[0] = table;
}
#endif /*  MDL_START */


static void mdlOutputs(SimStruct *S, int_T tid) {
	double params[32] = { 0 };
	int i;
	InputRealPtrsType u = nullptr;
	NDTable_h table = static_cast<NDTable_h>(ssGetPWork(S)[0]);

	for(i = 0; i < table->ndims; i++) {
		u = ssGetInputPortRealSignalPtrs(S, i);
		params[i] = *u[0];
	}

	real_T *y = ssGetOutputPortRealSignal(S, 0);

	if (NDTable_evaluate(table, table->ndims, params, interpMethod(S), extrapMethod(S), y) != 0) {
		ssSetErrorStatus(S, NDTable_get_error_message());
	}

}


static void mdlTerminate(SimStruct *S) {

	NDTable_free_table((NDTable_h)ssGetPWork(S)[0]);

}


#ifdef MATLAB_MEX_FILE /* Is this file being compiled as a MEX-file? */
#include "simulink.c" /* MEX-file interface mechanism */
#else
#include "cg_sfun.h" /* Code generation registration function */
#endif
