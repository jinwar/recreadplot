## Program for the record reading waveform plot
Written by Ge Jin, ge.jin@ldeo.columbia.edu, jinwar@gmail.com

### Instruction: 

* Edit setup_parameters.m to setup parameters.
** Change event parameters to search the earthquake.
** Change station parameters to define the network to be downloaded
** define the download window
** define filters
** define the original (unzoomed) window to be plotted
* run fetch_event.m, click on the event you want to download, and confirm and type 'y'. The station map will be plotted in this step. It will save "fetchdata.mat" for event and station informations.
* run download_data.m. rerun it if anything goes wrong in the process of downloading. It will skip the already downloaded stations. 
* run prepare_data.m. This script will do the instrument response removal, horizontal component rotation, and the filters defined in the parameter file. If you change the filter setting, you need to rerun this step to make it effective. It will save a data file named: "YYYYMMDDhhmm.mat"
* run plot_recread.m and play with it.

Command list can be found in command_list.txt

TIP: You must restart your matlab if you plug or unplug a monitor to your computer.

Enjoy!

Jingle
