## Program for the record reading waveform plot
Written by Ge Jin, ge.jin@ldeo.columbia.edu, jinwar@gmail.com

### Instruction: 

* Edit setup_parameters.m to setup parameters.
	- Change event parameters to search the earthquake.
	- Change station parameters to define the network and epicenter distance range to be downloaded
	- define the download window
	- define filters
	- define the original (unzoomed) window to be plotted
* run fetch_event.m, click on the event you want to download, and confirm and type 'y'. The station map will be plotted in this step. It will save "fetchdata.mat" for event and station informations.
* run download_data.m. rerun it if anything goes wrong in the process of downloading. It will skip the already downloaded stations. 
* run prepare_data.m. This script will do the instrument response removal, horizontal component rotation, and the filters defined in the parameter file. If you change the filter setting, you need to rerun this step to make it effective. It will save a data file named: "YYYYMMDDhhmm.mat"
* run prepare_synthetics.m. (OPTIONAL) This script uses instaseis to generate synthetics, creating an identical stucture to prepare_data. If you change the filter setting, you need to rerun this step to make it effective. It will save a data file named: "YYYYMMDDhhmm_synth.mat"
* run plot_recread.m and play with it.

Command list can be found in command_list.txt

TIP: You must restart your matlab if you plug or unplug a monitor to your computer.

Enjoy!

Jingle

### Notes from record reading code during record reading Hackathon on 3/16/17:

In order to plot radiation patterns, download the Quick CMT solution in the 'ndk' file format from:
http://www.globalcmt.org/CMTfiles.html
Name the file CMTSOLUTION and put it in the directory from which you are running the scripts.
(Updated by Celia, 3/16/17)

To calculate synthetics for plotting with data, need to update the python3 and instaseis database paths in prepare_synthetics.m
Use 'j' to toggle synthetic traces.
(Updated by Josh, 3/16/17)

