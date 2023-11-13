#The specific steps for processing the time series of (CGPS, SGPS) are as follows：
#（1）Remove the post-seismic effects of the 1964 earthquake{2023.10.22-10.31}
#（2）Convert the reference frame from ITRF to NOAM {2023.10.31-2023.11.6}
#（3）Integrate data and add a separator of 9999.0 to each station's time series{2023.10.31-}
#（4）Repeat the steps for processing the time series of CGPS. See details below
import numpy as np
import os
import copy
import pdb  # Adding the pdb library to debug the code due to the Spyder version issue
from postseis_utils import get_postseis
from read_timeseries import read_timeseries
from geodvel import calc_geodvel
from read_seasonal_file import read_seasonal_file
from ts_eval_seasonal import ts_eval_seasonal
section = 5  # It's actually not necessary and can be omitted
if section == 5:
    CampaignSites = 'campaign_paper.txt'  # Site information: site name, longitude, latitude
    ContinuousSites = 'continuous_paper.txt'
    postseis = 'sites_all_name_lat_lon_Up.vec'  # Information about all sites affected by the 1964 earthquake, including site name, longitude, latitude, and three components
    Camp_postOrg = 'campaign_paper_post_org.txt'  # Deformation information for corresponding sites obtained using get_postseis, including site name, longitude, latitude, and three components
    Cont_postOrg = 'continuous_paper_post_org.txt'
    nameCamp, lonCamp, latCamp, veleCamp, velnCamp, veluCamp = get_postseis(CampaignSites, postseis, Camp_postOrg)
    nameCont, lonCont, latCont, veleCont, velnCont, veluCont = get_postseis(ContinuousSites, postseis, Cont_postOrg)
    pdir = 'E:/研究生阶段文件/series time code/Alaska4.0_timeseries-manualAdd'  # Get the latest time series file 4.0 downloaded from the local folder
    sdir = 'E:/研究生阶段文件/series time code/seasonal/'  # Get the seasonal file in the local folder，step3
    stype = 'as'
    stationfile = 'allsites_alaska_ssl_v1.0.vec'  # Get all site information: lon, lat, Ve, Vn, Se, Sn, Rho, Site
    # Try to open the file allsites_alaska_ssl_v1.0.vec. If it can be opened, print that the file has been read. If it cannot be opened, print that it cannot be found.
    try:
        with open(stationfile) as fid:
            print(f'{stationfile} file has been read')
    except FileNotFoundError:
        print(f'Cannot find {stationfile}')
    # Load lon, lat, Ve, Vn, Se, Sn, Rho, Site information from the station file and store it
    lon, lat, Ve, Vn, Se, Sn, Rho, Site = np.loadtxt(stationfile, dtype={'names': ('lon', 'lat', 'Ve', 'Vn', 'Se', 'Sn', 'Rho', 'Site'), 'formats': ('f4', 'f4', 'f4', 'f4', 'f4', 'f4', 'f4', 'U10')}, unpack=True)
    numallsites = len(lon)
    # Create a result storage file .ts
    timeseriesfile = 'TSgpsall_seasonal_postremoved_NOAM.ts'
    write_sample = bool(timeseriesfile)
    if write_sample:
        with open(timeseriesfile, 'w') as fid:
            #read campagin sites
            campsitefile = 'campaign_paper.txt'
            campsitename, loncamp, latcamp = np.loadtxt(campsitefile, dtype={'names': ('name', 'lon', 'lat'), 'formats': ('U10', 'f4', 'f4')}, unpack=True)
            numcamp = len(loncamp)
            #loop through the campaign sites that we want
            for i in range(numcamp):
                #generate the header line (Note: For site names with less than four characters, use dashes to fill)
                count = 0
                for j in range(numallsites):
                    charstationname = len(campsitename[i])
                    if campsitename[i] == Site[j]:
                        count += 1
                        if count == 1:
                            print(Site[j])
                            if charstationname == 3:
                                newsite = '_' + Site[j]
                                fid.write(f'{lon[j]:.2f} {lat[j]:.2f} {Ve[j]:.3f} {Vn[j]:.3f} {Se[j]:.3f} {Sn[j]:.3f} {Rho[j]:.3f} {newsite}\n')
                            elif charstationname == 2:
                                newsite = '__' + Site[j]
                                fid.write(f'{lon[j]:.2f} {lat[j]:.2f} {Ve[j]:.3f} {Vn[j]:.3f} {Se[j]:.3f} {Sn[j]:.3f} {Rho[j]:.3f} {newsite}\n')
                            else:
                                fid.write(f'{lon[j]:.2f} {lat[j]:.2f} {Ve[j]:.3f} {Vn[j]:.3f} {Se[j]:.3f} {Sn[j]:.3f} {Rho[j]:.3f} {Site[j]}\n')
                numpostcamp = len(lonCamp)
# Up to this point, you should have obtained data for the first site. To verify the feasibility of the preceding code, 
#you can check the .ts file to see if the site has been written according to our requirements (e.g., for site 1000, it should include lon, lat, ...).
                for q in range(numpostcamp):
                    if nameCamp[q] == campsitename[i]:
                        postve = veleCamp[q]
                        postvn = velnCamp[q]
                        postvu = veluCamp[q]
                staname = campsitename[i]
                datafile = f"{pdir}/{staname}.pfiles"   
               # format in datafile is mm.
                sigtol = np.array([12, 12, 25])
                dat1 = read_timeseries(datafile, sigtol)
                # format for data in dat1 is meter, so we need to convert back to mm
                numpos = len(dat1['east'])
                dat2 = dat1.copy()
                dat2_NOAM = copy.deepcopy(dat2)  # 使用深层拷贝 
                for p in range(numpos):  # loop for all the points for each station
# step1:remove the postseismic signal(read_timeseries,get_postseis,xyz2enu,llh2xyz)，We have verified the accuracy by comparing it with the results obtained from Matlab.
                    dat2['time'][p] = dat1['time'][p]

                    dat2['east'][p] = dat1['east'][p] * 1000 - postve * (dat1['time'][p] - dat1['time'][0])  # mm
                    dat2['east'][p] = dat2['east'][p] / 1000  # meter
                    dat2['esig'][p] = dat1['esig'][p]  # meter

                    dat2['north'][p] = dat1['north'][p] * 1000 - postvn * (dat1['time'][p] - dat1['time'][0])  # mm
                    dat2['north'][p] = dat2['north'][p] / 1000  # meter
                    dat2['nsig'][p] = dat1['nsig'][p]  # meter

                    dat2['height'][p] = dat1['height'][p] * 1000 - postvu * (dat1['time'][p] - dat1['time'][0])  # mm
                    dat2['height'][p] = dat2['height'][p] / 1000  # meter
                    dat2['hsig'][p] = dat1['hsig'][p]  # meter
#step2:Convert the reference frame from ITRF to NOAM(calc_geodvel,xyz2llh(xyz-EUH),read_timeseries,)
#We need to use calc_geodvel to obtain the values of vrel_plate and vRPcov
                    vrel_plate, _, vRPcov = calc_geodvel('NOAM', dat2['refxyz'])
                    dat2_NOAM['east'][p] = dat2['east'][p] - vrel_plate[0] * (dat1['time'][p] - dat1['time'][0])  # meter，
                    #We fixed this portion of the code on 2023.11.12. What we need is the component from data2, not data2_NOAW.
                    dat2_NOAM['esig'][p] = np.sqrt(dat2['esig'][p]**2 + vRPcov[0, 0] * ((dat1['time'][p] - dat1['time'][0]) ** 2))  # meter, due to error propagation law
                    dat2_NOAM['north'][p] = dat2['north'][p] - vrel_plate[1] * (dat1['time'][p] - dat1['time'][0])  # meter
                    dat2_NOAM['nsig'][p] = np.sqrt(dat2['nsig'][p]**2 + vRPcov[1, 1] * ((dat1['time'][p] - dat1['time'][0]) ** 2))  # meter, due to error propagation law
                    dat2_NOAM['height'][p] = dat2['height'][p] - vrel_plate[2] * (dat1['time'][p] - dat1['time'][0])  # meter
                    dat2_NOAM['hsig'][p] = np.sqrt(dat2['hsig'][p]**2 + vRPcov[2, 2] * ((dat1['time'][p] - dat1['time'][0]) ** 2))  # meter, due to error propagation law
#step3： remove the seasonal signal，We need to call the function ts_eval_seasonal and read_seasonal_file to obtain the value of seasonal_modval
#Read and subtract the seasonal model in the .season file if it exists
#We do this at this step because the covariance needs to be the same as for the regular model
                if os.path.exists(f"{sdir}{staname}_{stype}.seasonal"):
                  print("Removing seasonal from observed time series")
                  #seasonal：bintim，binsize，east，north，height
                  seasonal = read_seasonal_file(f"{sdir}{staname}_{stype}.seasonal")
                  seasonal_modval = ts_eval_seasonal(dat2_NOAM['time'], seasonal)

                # subtract seasonal modval from data
                  dat2_season_removed = dat2_NOAM.copy()
                  dat2_season_removed['east']   = dat2_NOAM['east']   - seasonal_modval[:,0]
                  dat2_season_removed['north']  = dat2_NOAM['north']  - seasonal_modval[:,1]
                  dat2_season_removed['height'] = dat2_NOAM['height'] - seasonal_modval[:,2]
                  dat2_season_removed['enu']    = dat2_NOAM['enu']    - seasonal_modval.T
                else:
                   dat2_season_removed = None

                dat3 = dat2_season_removed  # now still meters
                    # Final lines for time series data in the input file
                numpos2 = len(dat3['east'])

                for q in range(numpos2):
                    fid.write(f'{dat3["time"][q]:4.4f} {dat3["east"][q]*1000:3.4f} {dat3["esig"][q]*1000:3.4f} '
                              f'{dat3["north"][q]*1000:3.4f} {dat3["nsig"][q]*1000:3.4f} {dat3["height"][q]*1000:3.4f} '
                               f'{dat3["hsig"][q]*1000:3.4f}\n')
                    # Format is mm now.

                endsign = 9999.0
                fid.write(f'{endsign:4.1f}\n')

# End of dealing with campaign sites




             
# read continuous sites
            consitefile = 'continuous_paper.txt'
    
            consitename, loncon, latcon = np.loadtxt(consitefile, dtype={'names': ('name', 'lon', 'lat'), 'formats': ('U10', 'f4', 'f4')}, unpack=True)
            numcon = len(loncon)
            #loop through the campaign sites that we want
            for i in range(numcon):
                #generate the header line (Note: For site names with less than four characters, use dashes to fill)
                count = 0
                for j in range(numallsites):
                    charstationname = len(consitename[i])
                    if consitename[i] == Site[j]:
                        count += 1
                        if count == 1:
                            print(Site[j])
                            if charstationname == 3:
                                newsite = '_' + Site[j]
                                fid.write(f'{lon[j]:.2f} {lat[j]:.2f} {Ve[j]:.3f} {Vn[j]:.3f} {Se[j]:.3f} {Sn[j]:.3f} {Rho[j]:.3f} {newsite}\n')
                            elif charstationname == 2:
                                newsite = '__' + Site[j]
                                fid.write(f'{lon[j]:.2f} {lat[j]:.2f} {Ve[j]:.3f} {Vn[j]:.3f} {Se[j]:.3f} {Sn[j]:.3f} {Rho[j]:.3f} {newsite}\n')
                            else:
                                fid.write(f'{lon[j]:.2f} {lat[j]:.2f} {Ve[j]:.3f} {Vn[j]:.3f} {Se[j]:.3f} {Sn[j]:.3f} {Rho[j]:.3f} {Site[j]}\n')
                numpostcon = len(loncon)
# Up to this point, you should have obtained data for the first site. To verify the feasibility of the preceding code, 
#you can check the .ts file to see if the site has been written according to our requirements (e.g., for site 1000, it should include lon, lat, ...).
                for q in range(numpostcon):
                    if nameCont[q] == consitename[i]:
                        postve = veleCont[q]
                        postvn = velnCont[q]
                        postvu = veluCont[q]
                staname = consitename[i]
                datafile = f"{pdir}/{staname}.pfiles"   
               # format in datafile is mm.
                sigtol = np.array([12, 12, 25])
                dat1 = read_timeseries(datafile, sigtol)
                # format for data in dat1 is meter, so we need to convert back to mm
                numpos = len(dat1['east'])
                dat2 = dat1.copy()
                dat2_NOAM = copy.deepcopy(dat2)  # 使用深层拷贝 
                for p in range(numpos):  # loop for all the points for each station
# step1:remove the postseismic signal(read_timeseries,get_postseis,xyz2enu,llh2xyz)，We have verified the accuracy by comparing it with the results obtained from Matlab.
                    dat2['time'][p] = dat1['time'][p]

                    dat2['east'][p] = dat1['east'][p] * 1000 - postve * (dat1['time'][p] - dat1['time'][0])  # mm
                    dat2['east'][p] = dat2['east'][p] / 1000  # meter
                    dat2['esig'][p] = dat1['esig'][p]  # meter

                    dat2['north'][p] = dat1['north'][p] * 1000 - postvn * (dat1['time'][p] - dat1['time'][0])  # mm
                    dat2['north'][p] = dat2['north'][p] / 1000  # meter
                    dat2['nsig'][p] = dat1['nsig'][p]  # meter

                    dat2['height'][p] = dat1['height'][p] * 1000 - postvu * (dat1['time'][p] - dat1['time'][0])  # mm
                    dat2['height'][p] = dat2['height'][p] / 1000  # meter
                    dat2['hsig'][p] = dat1['hsig'][p]  # meter
#step2:Convert the reference frame from ITRF to NOAM(calc_geodvel,xyz2llh(xyz-EUH),read_timeseries,)
#We need to use calc_geodvel to obtain the values of vrel_plate and vRPcov
                    vrel_plate, _, vRPcov = calc_geodvel('NOAM', dat2['refxyz'])
                    dat2_NOAM['east'][p] = dat2['east'][p] - vrel_plate[0] * (dat1['time'][p] - dat1['time'][0])  # meter，
                    #We fixed this portion of the code on 2023.11.12. What we need is the component from data2, not data2_NOAW.
                    dat2_NOAM['esig'][p] = np.sqrt(dat2['esig'][p]**2 + vRPcov[0, 0] * ((dat1['time'][p] - dat1['time'][0]) ** 2))  # meter, due to error propagation law
                    dat2_NOAM['north'][p] = dat2['north'][p] - vrel_plate[1] * (dat1['time'][p] - dat1['time'][0])  # meter
                    dat2_NOAM['nsig'][p] = np.sqrt(dat2['nsig'][p]**2 + vRPcov[1, 1] * ((dat1['time'][p] - dat1['time'][0]) ** 2))  # meter, due to error propagation law
                    dat2_NOAM['height'][p] = dat2['height'][p] - vrel_plate[2] * (dat1['time'][p] - dat1['time'][0])  # meter
                    dat2_NOAM['hsig'][p] = np.sqrt(dat2['hsig'][p]**2 + vRPcov[2, 2] * ((dat1['time'][p] - dat1['time'][0]) ** 2))  # meter, due to error propagation law
#step3： remove the seasonal signal，We need to call the function ts_eval_seasonal and read_seasonal_file to obtain the value of seasonal_modval
#Read and subtract the seasonal model in the .season file if it exists
#We do this at this step because the covariance needs to be the same as for the regular model
                if os.path.exists(f"{sdir}{staname}_{stype}.seasonal"):
                  print("Removing seasonal from observed time series")
                  #seasonal：bintim，binsize，east，north，height
                  seasonal = read_seasonal_file(f"{sdir}{staname}_{stype}.seasonal")
                  seasonal_modval = ts_eval_seasonal(dat2_NOAM['time'], seasonal)

                # subtract seasonal modval from data
                  dat2_season_removed = dat2_NOAM.copy()
                  dat2_season_removed['east']   = dat2_NOAM['east']   - seasonal_modval[:,0]
                  dat2_season_removed['north']  = dat2_NOAM['north']  - seasonal_modval[:,1]
                  dat2_season_removed['height'] = dat2_NOAM['height'] - seasonal_modval[:,2]
                  dat2_season_removed['enu']    = dat2_NOAM['enu']    - seasonal_modval.T
                else:
                   dat2_season_removed = None

                dat3 = dat2_season_removed  # now still meters
                    # Final lines for time series data in the input file
                numpos2 = len(dat3['east'])

                for q in range(numpos2):
                    fid.write(f'{dat3["time"][q]:4.4f} {dat3["east"][q]*1000:3.4f} {dat3["esig"][q]*1000:3.4f} '
                              f'{dat3["north"][q]*1000:3.4f} {dat3["nsig"][q]*1000:3.4f} {dat3["height"][q]*1000:3.4f} '
                               f'{dat3["hsig"][q]*1000:3.4f}\n')
                    # Format is mm now.

                endsign = 9999.0
                fid.write(f'{endsign:4.1f}\n')
