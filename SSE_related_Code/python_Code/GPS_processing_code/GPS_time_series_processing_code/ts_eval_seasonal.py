import numpy as np
def ts_eval_seasonal(date, seasonal, component=None):
#function  seasonal_modval = ts_eval_seasonal(date, seasonal, component)
# Evaluate a seasonal model at times given by array date.
# Interpolate model. Input is the struct seasonal with fields
#    bintime    should have values ranging between 0 and 1, with repeated
#             values less than zero and more than 1. For example,
#             [-0.025, 0.025, 0.075, ... , 0.925, 0.975, 1.025]
#    east, north, height  are corresponding bin values
# If component is specified, it should be either 'east', 'north', or 'height'.
#    In that case, seasonal_modval computes that component only.    

    if component is None:
        component = ''

    nbins = len(seasonal['bintime'])
    bin_t = np.concatenate(([seasonal['bintime'][-1] - 1], seasonal['bintime'], [1 + seasonal['bintime'][0]]))
    binsize = seasonal['binsize']

    tdate = date - np.floor(date)# Floor rounding down

    if not component:
        # Figure out which bin interval each point lies in
        #The most efficient way to do it is to loop over the bins and process all
        #points within that bin. The number of bins should be small relative
        #to the number of dates.
        east = np.concatenate(([seasonal['east']['smooth'][-1]], seasonal['east']['smooth'], [seasonal['east']['smooth'][0]]))#np.concatenate
        north = np.concatenate(([seasonal['north']['smooth'][-1]], seasonal['north']['smooth'], [seasonal['north']['smooth'][0]]))
        height = np.concatenate(([seasonal['height']['smooth'][-1]], seasonal['height']['smooth'], [seasonal['height']['smooth'][0]]))

        seasonal_modval = np.zeros((len(tdate), 3))

        for i in range(nbins + 1):
            inbin = np.logical_and(tdate > bin_t[i], tdate <= bin_t[i + 1])
            indices = np.where(inbin)[0]
            dt = (tdate[indices] - bin_t[i])
            seasonal_modval[indices] = np.column_stack((east[i] + (east[i + 1] - east[i]) * (dt / binsize),
                                                         north[i] + (north[i + 1] - north[i]) * (dt / binsize),
                                                         height[i] + (height[i + 1] - height[i]) * (dt / binsize)))

    else:
        val = np.concatenate(([seasonal[component]['smooth'][-1]], seasonal[component]['smooth'], [seasonal[component]['smooth'][0]]))
        seasonal_modval = np.zeros(len(tdate))

        for i in range(nbins + 1):
            inbin = np.logical_and(tdate > bin_t[i], tdate <= bin_t[i + 1])
            indices = np.where(inbin)[0]
            dt = (tdate[indices] - bin_t[i])
            seasonal_modval[indices] = val[i] + (val[i + 1] - val[i]) * (dt / binsize)

    return seasonal_modval
