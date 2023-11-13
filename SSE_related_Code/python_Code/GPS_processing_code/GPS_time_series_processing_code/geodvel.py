import numpy as np
import pandas as pd
from llh2xyz import llh2xyz
from xyz2enu import xyz2enu
from xyz2llh import xyz2llh
def calc_geodvel(inplate, *varargin):
    plate = inplate.lower()# Get the lowercase of NOAM
    predict_plate = 0
    
    # Check if 'plate' is in the list, assign different values to nplates and predict_plate
    if plate in ['none', 'noplate', 'no plate']:
        nplates = -1
        predict_plate = 0
    else:
        nplates = -1
        predict_plate = 1

    nsites = 0
    # Determine the length of the 'varargin' variable. If it is 1, calculate 'r' and 'nsites'.
    # If it is 2, calculate 'lat' and 'lon'. If 'lon' is equal in length to 'lat', then assign values to 'llh' and 'r'
    n = len(varargin)

    if n == 1:
        r = np.array(varargin[0])
        r = np.reshape(r, (3, -1))
        nsites = r.shape[1]

    elif n == 2:
        lat = np.array(varargin[0])
        lon = np.array(varargin[1])

        if len(lat) == len(lon):
            nsites = len(lat)
            
            llh = np.column_stack((lat, lon, np.zeros(len(lat))))
            r = llh2xyz(llh)
    #If nsites equals 0 or if nplates and nsites are not equal:
    #If nsites == 0, an exception will be raised with the message 'Site coordinate arguments were not properly specified',
    # indicating that site coordinate arguments were not correctly specified.
    #If (nplates > 1 and nsites != nplates) is true, an exception will be raised with the message 'Number of plates must 
    #be equal to 1', indicating that the number of plates must be equal to 1."
    if nsites == 0 or (nplates > 1 and nsites != nplates):
        if nsites == 0:
            raise Exception('Site coordinate arguments were not properly specified')
        else:
            raise Exception('Number of plates must be equal to 1')
    #Call load_argus2005_model and return the values of plates, omegas, omegacov, geocenter_xyz, and geocenter_cov
    plates, omegas, omegacov, geocenter_xyz, geocenter_cov = load_argus2005_model()

    if predict_plate:
        # Determine the index of 'plate' (noma) in 'plates', which is 4 in this case. Therefore, 'pamatch' is set to 4.
        pmatch = plates.index(plate)
        if pmatch == -1:
            raise Exception(f'Plate {plate} not found')
       # om: All rows of the pmatch column
       # omcov: Rows from k to k+3, columns from k to k+3
        om = omegas[:, pmatch]
        k = 3 * pmatch
        omcov = omegacov[k:k+3, k:k+3]
        # Create a 3xnsites array filled with zeros
        rmat = np.zeros((3*nsites, 3))
        # Assign specific values to 'rmat' at specific positions.
        for i in range(nsites):
            k = 3 * i
            rmat[k:k+3, :] = [[0, r[2,i], -r[1,i]], [-r[2,i], 0, r[0,i]], [r[1,i], -r[0,i], 0]]
        #Perform element-wise matrix multiplication to obtain 'vxyz' and 'tcov'
        vxyz = np.dot(rmat, om)
        tcov = np.dot(np.dot(rmat, omcov), rmat.T)

    else:
        vxyz = np.zeros(3*nsites)
        tcov = np.zeros((3*nsites, 3*nsites))

    rmat = np.zeros((3*nsites, 3))

    for i in range(nsites):
        k = 3 * i
        rmat[k:k+3, :] = np.eye(3)#Set the submatrix of rmat from row k to row k+3 and all columns to a 3x3 identity matrix

    vxyz = vxyz - np.dot(rmat, geocenter_xyz)
    tcov = tcov + np.dot(np.dot(rmat, geocenter_cov), rmat.T)

    #venu: Create a zero array of the same size as 'r'.
    #vcov: Create a zero array of size (3, 3*nsites).
    venu = np.zeros_like(r)
    vcov = np.zeros((3, 3*nsites))
    
    for i in range(nsites):
        k = 3 * i
        llh = xyz2llh(r[:, i])
        #xyz2enu returns enu (a 3x1 array) and covenu (a 3x3 array) which are assigned to venu and covenu respectively.
        venu[:, :], covenu = xyz2enu(llh, vxyz[3*i:3*i+3], tcov[3*i:3*i+3, 3*i:3*i+3])
        vcov[:, k:k+3] = covenu
    # Return venu and vcov needed by the main function. We don't care about the second return value, so I define it as 0.
    return venu,  0,  vcov

#Define the function 'load_argus2005_model' and return values to plates, omegas, 
#omegacov, geocenter_xyz, and geocenter_cov.
def load_argus2005_model():
    geocenter_xyz = 0.001 * np.array([0.17, 0.26, -1.04])
    geocenter_cov = (0.001**2) * np.array([[0.04, 0.0, 0.0],
                                          [0.0, 0.04, 0.0],
                                          [0.0, 0.0, 0.04]])
    plates = ['anta', 'arab', 'aust', 'eura', 'noam', 'indi', 'nazc', 'nubi', 'pcfc', 'soam', 'soma', 'carb']
    
    omegas = np.array([[-0.00115899, -0.00152263, 0.00328637],
                      [0.00741655, 0.00194326, 0.00847657],
                      [0.00724980, 0.00560919, 0.00583401],
                      [-0.00053595, -0.00244848, 0.00359444],
                      [0.00027649, -0.00337936, -0.00018938],
                      [0.00580027, 0.00130548, 0.00720402],
                      [-0.00147409, -0.00766879, 0.00801227],
                      [0.00044618, -0.00282666, 0.00345576],
                      [-0.00196175, 0.00498483, -0.01060919],
                      [-0.00123752, -0.00141244, -0.00064365],
                      [-0.00035868, -0.00341258, 0.00441288],
                      [-0.0038872, 0.0136561, -0.0236616]])

    omegas = omegas.T / 10**6
    # Read Excel file, extract the omegacov data from Matlab and save it in a local xls file for importing into Python.
    # Last entry is for CARB, approximated from MORVEL
    file_path = r'E:\研究生阶段文件\series time code\omegacov.xls'
    data = pd.read_excel(file_path, header=None)
    # Convert the data into a NumPy array.
    omegacov = np.array(data, dtype=np.float64) 
   
    omegacov = omegacov / (10**22)
   

   # Extend the size of the array to 36x36 (because the omegas data was imported from an xls file and is originally a 
   #33x33 array; if not expanded, the following code will raise an error).
    omegacov = np.pad(omegacov, ((0, 3), (0, 3)), mode='constant', constant_values=0)
   # Approximation for CARB
    omegacov[33, 33] = 300. / 10**22
    omegacov[34, 34] = 300. / 10**22
    omegacov[35, 35] = 300. / 10**22
    # Return the variables plates, omegas, omegacov, geocenter_xyz, and geocenter_cov.
    return plates, omegas, omegacov, geocenter_xyz, geocenter_cov

   
