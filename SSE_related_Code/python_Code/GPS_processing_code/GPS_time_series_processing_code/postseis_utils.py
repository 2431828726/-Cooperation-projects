def get_postseis(originalfile, postseisallfile, postInOriginfile):
    def read_gps_data(file_path):
        with open(file_path, 'r') as fid:
            data = [line.strip().split() for line in fid if not line.startswith('#')]
            name, lon, lat = [row[0] for row in data], [float(row[1]) for row in data], [float(row[2]) for row in data]
        return name, lon, lat

    def read_postseis_data(file_path):
        with open(file_path, 'r') as fid:
            data = [line.strip().split() for line in fid if not line.startswith('#')]
            name, lon, lat, vele, veln, velu = [row[0] for row in data], [float(row[1]) for row in data], [float(row[2]) for row in data], [float(row[3]) for row in data], [float(row[4]) for row in data], [float(row[5]) for row in data]
        return name, lon, lat, vele, veln, velu

    def write_filtered_data(file_path, nameDN, lonDN, latDN, veleDN, velnDN, veluDN):
        with open(file_path, 'w') as fid:
            for i in range(len(nameDN)):
                fid.write(f'{nameDN[i]:<5s} {lonDN[i]:.5f} {latDN[i]:.5f} {veleDN[i]:.12f} {velnDN[i]:.12f} {veluDN[i]:.12f}\n')

    name, lon, lat = read_gps_data(originalfile)
    nameD, lonD, latD, veleD, velnD, veluD = read_postseis_data(postseisallfile)

    nameDN, lonDN, latDN, veleDN, velnDN, veluDN = [], [], [], [], [], []

    for p in range(len(name)):
        for q in range(len(nameD)):
            if name[p] == nameD[q]:
                nameDN.append(nameD[q])
                lonDN.append(lonD[q])
                latDN.append(latD[q])
                veleDN.append(veleD[q])
                velnDN.append(velnD[q])
                veluDN.append(veluD[q])

    if postInOriginfile:
        write_filtered_data(postInOriginfile, nameDN, lonDN, latDN, veleDN, velnDN, veluDN)

    return nameDN, lonDN, latDN, veleDN, velnDN, veluDN
