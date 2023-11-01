import numpy as np
# Transform from lat, lon, h to x, y, z
def llh2xyz(llh):
    deg2rad = np.pi / 180
    a = 6378137
    f = 1/298.257223563
    e2 = 2*f - f*f
# Obtain the length of the '11h' column.
    num = llh.shape[1]
    xyz = np.zeros((3, num))

    for i in range(num):
        clat = np.cos(llh[0, i] * deg2rad)
        slat = np.sin(llh[0, i] * deg2rad)
        clon = np.cos(llh[1, i] * deg2rad)
        slon = np.sin(llh[1, i] * deg2rad)

        n = a / np.sqrt(1 - e2 * slat**2)

        xyz[0, i] = (n + llh[2, i]) * clat * clon
        xyz[1, i] = (n + llh[2, i]) * clat * slon
        xyz[2, i] = (n * (1 - e2) + llh[2, i]) * slat

    return xyz
