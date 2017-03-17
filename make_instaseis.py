# Outputs event .mat file for processing in MatLab
#
# !! Must update path the to instaseis database (instaseisDB) !!
#
# Instaseis installation instructions: 
#                            http://www.instaseis.net/
#
# Premade instaseis databases:
#                            http://ds.iris.edu/ds/products/syngine/
#
#


import obspy as obs
import scipy.io as spio
import os
from scipy.io import savemat
import numpy as np
import instaseis



## OPEN INSTASEIS DATABASE ##
f = open("instaseisDB_path.txt","r")
instaseisDB = f.read()
db = instaseis.open_db(instaseisDB)
print(db)

##############################################
## CALCULATE SYNTHETICS AND OUTPUT MAT FILE ##
##############################################

## SETUP FOLDER PATHS
f = open("event_name.txt","r")
evnum = f.read()
synthDir = "/Users/russell/Lamont/record_reading/HACKATHON_2017/recreadplot/" + evnum + "_synth/"

## READ EVENT INFORMATION FROM GCMT ##
cat = obs.read_events("https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/NEW_QUICK/E" + evnum + "A.ndk")

## MAKE SYNTHETICS DIRECTORY ##
if not os.path.exists(synthDir):
    os.makedirs(synthDir)
    
## LOOP THROUGH STATIONS ##
datadir = "./" + evnum + "/"
fils = os.listdir(datadir) 
for fil in fils:
    print(fil)
    
    ## Get station information
    mat = spio.loadmat(datadir + fil, squeeze_me=True)
    latitude = mat['traces'][0]['latitude']
    longitude = mat['traces'][0]['longitude']
    network = mat['traces'][0]['network']
    station = mat['traces'][0]['station']
    elevation = mat['traces'][0]['elevation']
    
    # CALCULATE SYNTHETICS
    rec = instaseis.Receiver(latitude=latitude, longitude=longitude, network=network, station=station)
#     tr = db.get_seismograms(source=cat, receiver=rec, components=["Z","R","T"], kind='velocity')
    tr = db.get_seismograms(source=cat, receiver=rec, components=["Z","R","T"], kind='displacement')

    mat_synth = mat
    channels = ["BHZ","BHR","BHT"]
    for icomp in np.arange(0,3):
        channel = channels[icomp]
        sampleCount = len(tr[icomp].data)
        sampleRate = 1./db.info.dt

        mat_synth['traces'][icomp]['channel'] = channel
        mat_synth['traces'][icomp]['sampleCount'] = sampleCount
        mat_synth['traces'][icomp]['sampleRate'] = sampleRate
        mat_synth['traces'][icomp]['data'] = tr[icomp].data


    outmat = synthDir + fil
    savemat(outmat,mat_synth)
