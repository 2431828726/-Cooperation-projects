import numpy as np
# Read the seasonal data structure seasonal from the file filename
def read_seasonal_file(filename):  
    dummy = {'binval': [], 'smooth': []}

    seasonal = {
        'bintime': [],
        'binsize': [],
        'east': dummy.copy(),
        'north': dummy.copy(),
        'height': dummy.copy()
    }

    input_data = np.loadtxt(filename)

    nbins = input_data.shape[0]

    seasonal['binsize'] = input_data[0, 1] - input_data[0, 0]
    seasonal['bintime'] = (input_data[:, 1] + input_data[:, 0]) / 2

    seasonal['east']['smooth'] = input_data[:, 2]
    seasonal['north']['smooth'] = input_data[:, 3]
    seasonal['height']['smooth'] = input_data[:, 4]

    seasonal['east']['binval'] = input_data[:, 2]
    seasonal['north']['binval'] = input_data[:, 3]
    seasonal['height']['binval'] = input_data[:, 4]

    return seasonal
