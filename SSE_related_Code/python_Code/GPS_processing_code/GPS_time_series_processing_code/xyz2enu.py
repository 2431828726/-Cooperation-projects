import numpy as np
#[enu, covenu] = xyz2enu(llh, xyz, covxyz)
# Rotate coordinates from XYZ to ENU (East-North-Up).
#  ENU system is defined at lat-long given by llh (degrees).
#  If a single llh is given, all vectors are transformed using that position.
#  If the size of llh is the same as that of xyz, each vector is
#  transformed using the corresponding position.
#  Output vector is always a column vector, regardles of input
#  covariance output argument is optional; if not given, input covariance is ignored

# Function to calculate the transformation matrix
def xyz2enu(llh, xyz, covxyz=None):
    deg2rad = np.pi / 180
#Please make sure to differentiate between the "llh" in "readtime". Here, it is passed from 
#the previous "refllh" and is not the actual "llh" (to avoid confusion, this refers to the
# first column of the "refllh", which is a 3x1 matrix).11h：lon，lat，height
    def calc_transformation(lat1, lon1):
        lat1=llh[0]
        lon1=llh[1]
        slat = np.sin(lat1 * deg2rad)
        clat = np.cos(lat1 * deg2rad)
        slon = np.sin(lon1 * deg2rad)
        clon = np.cos(lon1 * deg2rad)

        t = np.array([[-slon, clon, 0],
                      [-slat*clon, -slat*slon, clat],
                      [clat*clon, clat*slon, slat]], dtype=object)
        return t
 # Transpose the input vector if needed to make sure dimensions match for the matrix multiplication for transformation.
    llh = llh.reshape(-1, 1)#Reshape the dimension of 11h into (rows, 1) instead of (rows,).Revised on November 6, 2023
    xyz = xyz.reshape(-1, 1)#Reshape the dimension of xyz into (rows, 1) instead of (rows,).Revised on November 6, 2023
    if xyz.shape[0] == 1:
        xyz = xyz.T

    nvec = xyz.shape[0] // 3
   
    enu = np.zeros(nvec * 3).reshape((-1, 1))#0 matrix
# Check if covariance matrix is provided
    if covxyz is not None:
        do_covar = True
        covenu = np.zeros((nvec*3, nvec*3))
    else:
        do_covar = False

    nllh = llh.shape[0] // 3
 # Determine which mode of operation to use
    if nllh == nvec:
        rot_at_site = True
    else:
        rot_at_site = False
        if nllh != 1:
            print('Warning: length mismatch of llh and enu; transforming using first llh value.')

        t = calc_transformation(llh[1] * deg2rad, llh[2] * deg2rad)
 # Rotate XYZ vector and covariance to ENU
    for ista in range(nvec):
        k1 = 3 * ista

        if rot_at_site:
            t = calc_transformation(llh[k1 + 1] * deg2rad, llh[k1 + 2] * deg2rad)

        enu[k1:k1+3] = np.dot(t, xyz[k1:k1+3])
#Transform each sub-block of the covariance
        if do_covar:
            for jsta in range(nvec):
                k2 = 3 * jsta
                covenu[k1:k1+3, k2:k2+3] = np.dot(np.dot(t, covxyz[k1:k1+3, k2:k2+3]), t.T)

    if covxyz is not None:        
        return enu, covenu
    else:
        return enu
