import numpy as np

def xyz2llh(xyz):
    """
    Convert (x, y, z) coordinates to longitude, latitude, and height
    
    Args:
        xyz (np.ndarray): Input array of (x, y, z) coordinates, with each column representing a point.
        
    Returns:
        llh (np.ndarray): Output array of longitude, latitude, and height, with each column representing a point.
    """
    deg2rad = np.pi/180
    a = 6378137
    f = 1/298.257223563
    e2 = 2*f - f*f
    
    num = xyz.shape[1]
    llh = np.zeros((3, num))
    
    for i in range(num):
        p = np.sqrt(np.sum(xyz[0:2, i]**2))
        r = np.sqrt(np.sum(xyz[:, i]**2))
        lon = np.arctan2(xyz[1, i], xyz[0, i])
        
        lat = np.arctan2(xyz[2, i]/p, (1-e2))
        n = a/np.sqrt((1 - e2*np.sin(lat)**2))
        h = p/np.cos(lat) - n
        
        oldh = -1e9
        iter_count = 0
        num = xyz[2, i]/p
        
        while ( (np.abs(h - oldh) > 0.0001) and ( np.abs(lat) - np.pi/2) > 0.01):
            iter_count += 1
            oldh = h
            den = 1 - e2*n/(n+h)
            lat = np.arctan2(num, den)
            n = a/np.sqrt((1 - e2*np.sin(lat)**2))
            h = p/np.cos(lat) - n
        
        llh[0, i] = lat/deg2rad
        llh[1, i] = lon/deg2rad
        llh[2, i] = h
    
    return llh
