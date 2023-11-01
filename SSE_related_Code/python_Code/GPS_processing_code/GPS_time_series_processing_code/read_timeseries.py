import numpy as np
from llh2xyz import llh2xyz
from xyz2enu import xyz2enu
from newtime import new_timeseries# This is not necessary, as we have already defined the corresponding fields for our timeseries below.
# For any parameters that have not been explicitly set, we will use the values defined below.
def read_timeseries(file, sigtol=None, refvel=None, refllh=None):
    if sigtol is None:
        sigtol = np.array([100, 100, 200])
    if refvel is None:
        refvel = np.array([0, 0, 0])
    if refllh is None:
        refllh = []
    if refllh and refllh.shape[1] == 3:
        refllh = refllh.T# Transpose it if the number of columns is 3
#Optional arguments:
# sigtol  3x1 array with MAXIMUM tolerance for ENU sigmas, in mm
#            defaults to [100; 100; 200] mm
# refvel  3x1 array with reference velocity (in ENU) to subtract from east
#         north up values, in meters per year.
#            defaults to [0; 0; 0]
# refllh  3x1 array with reference llh value. If specified, the function
#            will use this as reference for east-north-up values instead of
#            the first value on the file.
#            defaults to []
#
# The timeseries struct has the following elements:
#    timeseries.time        N by 1 vector of dates (decimal year)
#    timeseries.sitename    1-4 character string with site name
#    timeseries.comment     Comment(s), string or cell array
#    timeseries.refllh      Reference lat-long-height (3 by 1)
#   timeseries.refxyz      Reference XYZ (3 by 1)
#    timeseries.llh         series of Lat-long-height values
#    timeseries.east        series of east values
#    timeseries.esig        series of east sigmas
#    timeseries.north       series of east values
#    timeseries.nsig        series of east sigmas
#    timeseries.height      series of east values
#    timeseries.hsig        series of east sigmas
#    timeseries.enu         array-stored enu values (3 by N)
#    timeseries.enucov      array of cells, each with 3x3 covariance
#    timeseries.outlier     array of outlier flags, 0=ok, 1=outlier
#    timeseries.x123axes    3x3 column vectors of coordinate axes x1,x2,x3
#    timeseries.x123names   cell array of names for coordinate axes x1,x2,x3
#    timeseries.x123        array-stored (x1,x2,x3) values (3 by N)
#   timeseries.x123cov     array of cells, each with 3x3 covariance
    timeseries = {'time': None, 'sitename': None, 'llh': None, 'refllh': None,
                 'refxyz': None, 'enu': None, 'east': None, 'north': None,
                 'height': None, 'esig': None, 'nsig': None, 'hsig': None,
                 'enucov': None}

    with open(file, 'r') as fid:
        data = [line.split() for line in fid]

    if not data:
        print('Error opening file', file)
    else:
# Place all time series data into the 'data' variable, extract the first column as the time column, and pass the 'data' to 'C'.
        data = np.array(data, dtype=object)
        time = data[:, 0].astype(float)
        c = data[:, :]
# Check if 'sigma' exceeds the specified range.       
        idx = np.where((c[:, 6].astype(float) < sigtol[0]) &
                       (c[:, 7].astype(float) < sigtol[1]) &
                       (c[:, 8].astype(float) < sigtol[2]))[0]
#if idx ＞0
        if len(idx) > 0:
            timeseries['time'] = time[idx]
            ndates = len(timeseries['time'])#data len
            t_init = timeseries['time'][0]#init time
            timeseries['sitename'] = c[0, 0]#site name
# Create a zero matrix of size 3*nadates.
            llh = np.zeros((3, ndates))
            # Obtain the corresponding longitude, latitude, and height data.
            llh[0, :] = c[idx, 4].astype(float)
            llh[1, :] = c[idx, 3].astype(float)
            llh[2, :] = c[idx, 5].astype(float)
            timeseries['llh'] = llh #llh（lon，lat，height）
            # 'llh' contains all longitude, latitude, and height data, while 'refllh' contains the first column of longitude, latitude, and height data.
            if len(refllh) == 3:
                timeseries['refllh'] = refllh
            else:
                timeseries['refllh'] = timeseries['llh'][:, :1]
# You need to enter the 'llh2xyz' function.ENU——XYZ
            timeseries['refxyz'] = llh2xyz(timeseries['refllh'])#已经验证与matlab对应的参数值是一样的
            xyzdiff = (llh2xyz(timeseries['llh']) - np.tile(timeseries['refxyz'], (1, ndates))).reshape(-1, 1, order='F')

            enu_result = xyz2enu(timeseries['refllh'], xyzdiff)
            timeseries['enu'] = enu_result.reshape(3, -1, order='F')# You need to enter the 'xyz2enu' function.
            timeseries['east'] = timeseries['enu'][0, :] - (timeseries['time'] - t_init) * refvel[0]
            timeseries['north'] = timeseries['enu'][1, :] - (timeseries['time'] - t_init) * refvel[1]
            timeseries['height'] = timeseries['enu'][2, :] - (timeseries['time'] - t_init) * refvel[2]
            #timeseries sigma
            timeseries['esig'] = c[idx, 6].astype(float) / 1000
            timeseries['nsig'] = c[idx, 7].astype(float) / 1000
            timeseries['hsig'] = c[idx, 8].astype(float) / 1000
            corr_en = c[idx, 9].astype(float)
            corr_ev = c[idx, 10].astype(float)
            corr_nv = c[idx, 11].astype(float)
            # array of cells, each with 3x3 covariance
            enucov = []
            for i in range(ndates):
                cov = np.zeros((3, 3))
                cov[0, 0] = timeseries['esig'][i] ** 2
                cov[1, 1] = timeseries['nsig'][i] ** 2
                cov[2, 2] = timeseries['hsig'][i] ** 2
                cov[0, 1] = corr_en[i] * timeseries['esig'][i] * timeseries['nsig'][i]
                cov[1, 0] = cov[0, 1]
                cov[0, 2] = corr_ev[i] * timeseries['esig'][i] * timeseries['hsig'][i]
                cov[2, 0] = cov[0, 2]
                cov[1, 2] = corr_nv[i] * timeseries['nsig'][i] * timeseries['hsig'][i]
                cov[2, 1] = cov[1, 2]
                enucov.append(cov)
            timeseries['enucov'] = enucov

    return timeseries








