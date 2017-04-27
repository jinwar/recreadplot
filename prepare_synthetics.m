% Modified by Josh Russell: 3/16/17
%
% Generates synthetics using instaseis and builds .mat structure
%
% 
% Need to have python3 and Instaseis installed:
% http://www.instaseis.net/
% 
% Calls on make_instaseis.py to generate synthetic seismograms for each
% station.
%
% (Don't forget to change the python and instaseis database path variables!)
% 

clear

% SET PYTHON & INSTASEIS PATHS
python_path = '/Users/russell/anaconda/bin/python3';
instaseisDB_path = '/Volumes/instaseis/PREMiso';

%%
load data/fetchdata.mat
setup_parameters
event_Otime = datenum(event_info.PreferredTime,'yyyy-mm-dd HH:MM:SS.FFF');
evla = event_info.PreferredLatitude;
evlo = event_info.PreferredLongitude;
evdp = event_info.PreferredDepth;
event_name = [datestr(event_Otime,'yyyymmddHHMM'),'_synth'];

%% Generate Synthetics
% write event number to textfile
fid = fopen('event_name.txt','w');
fprintf(fid,'%s',datestr(event_Otime,'yyyymmddHHMM'));
fclose(fid);

% write instaseis database path to textfile
fid = fopen('instaseisDB_path.txt','w');
fprintf(fid,'%s',instaseisDB_path);
fclose(fid);

% Run python script
log = system([python_path,' make_instaseis.py']);

system('rm event_name.txt instaseisDB_path.txt');


%%
sta_mat_files = dir([event_name,'/*.mat']);

for ista = 1:length(sta_mat_files)
	sta = load(fullfile(event_name,sta_mat_files(ista).name));
	ind = find(ismember({sta.traces(1:3).channel},{'BHZ'}));
	bhz = sta.traces(ind);
	ind = find(ismember({sta.traces(1:3).channel},{'BHR'}));
	bhr = sta.traces(ind);
	ind = find(ismember({sta.traces(1:3).channel},{'BHT'}));
	bht = sta.traces(ind);
	stla = bhz.latitude;
	stlo = bhz.longitude;

    % define time axes
    b = (bhz.startTime - event_Otime)*24*3600;
	delta = 1./bhz.sampleRate;
    timeaxis = [0:length(bhz.data)-1]*delta;
    dataZ = bhz.data;
    dataR = bhr.data;
    dataT = bht.data;
    
    % estimate the SNR of the data
    stdist = distance(stla,stlo,evla,evlo);
    
	% build up structure
	stadata_synth(ista).stla = stla;
	stadata_synth(ista).stlo = stlo;    
	stadata_synth(ista).stnm = bhz.station;
	stadata_synth(ista).timeaxis = timeaxis;
	stadata_synth(ista).odataZ = dataZ;
	stadata_synth(ista).odataR = dataR;
	stadata_synth(ista).odataT = dataT;
    stadata_synth(ista).dist = distance(stla,stlo,evla,evlo);
    
end


% apply filter
W = 2*delta./lowfilter;
if W < 1
    islow = 1;
    [lowb lowa] = butter(2,W);
else
    islow = 0;
end
W = 2*delta./midfilter;
if W < 1
    ismid = 1;
    [midb mida] = butter(2,W);
else
    ismid = 0;
end
W = 2*delta./highfilter;
if W < 1
    ishigh = 1;
    [highb higha] = butter(2,W);
else
    ishigh = 0;
end
for ista = 1:length(stadata_synth)
    if islow
        stadata_synth(ista).low_dataZ = filtfilt(lowb,lowa,stadata_synth(ista).odataZ);
        stadata_synth(ista).low_dataR = filtfilt(lowb,lowa,stadata_synth(ista).odataR);
        stadata_synth(ista).low_dataT = filtfilt(lowb,lowa,stadata_synth(ista).odataT);
    else
        stadata_synth(ista).low_dataZ = nan(size(stadata_synth(ista).odataZ));
        stadata_synth(ista).low_dataR = nan(size(stadata_synth(ista).odataR));
        stadata_synth(ista).low_dataT = nan(size(stadata_synth(ista).odataT));
    end
    if ismid
        stadata_synth(ista).mid_dataZ = filtfilt(midb,mida,stadata_synth(ista).odataZ);
        stadata_synth(ista).mid_dataR = filtfilt(midb,mida,stadata_synth(ista).odataR);
        stadata_synth(ista).mid_dataT = filtfilt(midb,mida,stadata_synth(ista).odataT);
    else
        stadata_synth(ista).mid_dataZ = nan(size(stadata_synth(ista).odataZ));
        stadata_synth(ista).mid_dataR = nan(size(stadata_synth(ista).odataR));
        stadata_synth(ista).mid_dataT = nan(size(stadata_synth(ista).odataT));
    end
    if ishigh
        stadata_synth(ista).high_dataZ = filtfilt(highb,higha,stadata_synth(ista).odataZ);
        stadata_synth(ista).high_dataR = filtfilt(highb,higha,stadata_synth(ista).odataR);
        stadata_synth(ista).high_dataT = filtfilt(highb,higha,stadata_synth(ista).odataT);
    else
        stadata_synth(ista).high_dataZ = nan(size(stadata_synth(ista).odataZ));
        stadata_synth(ista).high_dataR = nan(size(stadata_synth(ista).odataR));
        stadata_synth(ista).high_dataT = nan(size(stadata_synth(ista).odataT));
    end
end
save(event_name,'stadata_synth','-v7.3');
