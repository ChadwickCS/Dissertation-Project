import pandas as pd
import numpy as np
import glob
import sys
import re
from os.path import exists
import os
import shutil

def NAT_KEY(s, _nsre=re.compile('([0-9]+)')):
    return [int(text) if text.isdigit() else text.lower()
            for text in _nsre.split(s)]

if len(sys.argv) < 2:
	print("{} <data folder> <no of atoms>\n".format(sys.argv[0]))
	exit()

path=sys.argv[1]
no_atoms=sys.argv[2]

lat = pd.DataFrame(columns=['x', 'y', 'z', 'x_prime', 'y_prime', 'z_prime'])
data = pd.DataFrame(columns=['volume', 'pressure', 'energy', 'enthalpy'])
names=[]
i=0

for a_name in sorted(glob.glob(path +"/*.lammps"), key=NAT_KEY):
	lat=lat.append(pd.read_csv(a_name, nrows=1, delim_whitespace=True, header=None, names=lat.columns, index_col=None), ignore_index=True)
	data=data.append(pd.read_csv(a_name, nrows=1, delim_whitespace=True, skiprows=1, header=None, names=data.columns, index_col=None), ignore_index=True)
	i+=1
	names.append(a_name)

data['names'] = names 
data = data.set_index('names') 
minimum = data['enthalpy'].idxmin() 
if not (os.path.isdir('./min_'+no_atoms)):
	os.mkdir('./min_'+no_atoms)
for x in glob.glob(os.path.splitext(minimum)[0]+'.*'):
	shutil.copy(x, './min_'+no_atoms)

print("{} files read\n".format(i))
if exists("./data_{}.csv".format(no_atoms)):
	d_mode='a'
	d_header=False
if exists("lattice_{}.csv".format(no_atoms)):
        l_mode='a'
        l_header=False
else:
	d_mode='w'
	d_header=True
	l_mode='w'
	l_header=True

data['filename']=names
data_csv = data.to_csv("data_{}.csv".format(no_atoms), index=False, mode='w', header=d_header)
print("data csv written\n")
lat_csv = lat.to_csv("lattice_{}.csv".format(no_atoms), index=False, mode='w', header=l_header)
print("lattice csv written\n")
print("End.\n")
