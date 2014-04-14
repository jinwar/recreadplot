clear

load fetchdata.mat
setup_parameters

event_Otime = datenum(event_info.PreferredTime,'yyyy-mm-dd HH:MM:SS.FFF');
evla = event_info.PreferredLatitude;
evlo = event_info.PreferredLongitude;
evdp = event_info.PreferredDepth;
event_name = datestr(event_Otime,'yyyymmddHHMM');

sta_mat_files = dir([event_name,'/*.mat']);

for ista = 1:length(sta_mat_files)
	sta = load(fullfile(event_name,sta_mat_files(ista).name));
	ind = find(ismember({sta.traces.channel},{'BHZ'}));
	if isempty(ind)
		delete(fullfile(event_name,sta_mat_files(ista).name));
		continue;
	end
	ind = find(ismember({sta.traces.channel},{'BHN','BH1'}));
	if isempty(ind)
		delete(fullfile(event_name,sta_mat_files(ista).name));
		continue;
	end
	ind = find(ismember({sta.traces.channel},{'BHE','BH2'}));
	if isempty(ind)
		delete(fullfile(event_name,sta_mat_files(ista).name));
		continue;
	end
end

sta_mat_files = dir([event_name,'/*.mat']);

for ista = 1:length(sta_mat_files)
	sta = load(fullfile(event_name,sta_mat_files(ista).name));
	ind = find(ismember({sta.traces.channel},{'BHZ'}));
	bhz = sta.traces(ind);
	ind = find(ismember({sta.traces.channel},{'BHN','BH1'}));
	bhn = sta.traces(ind);
	ind = find(ismember({sta.traces.channel},{'BHE','BH2'}));
	bhe = sta.traces(ind);
	stla = bhz.latitude;
	stlo = bhz.longitude;
	% remove instrument response
	bhz = rm_resp(bhz); 
	bhe = rm_resp(bhe);
	bhn = rm_resp(bhn);
	% resample waveform to ensure same data length
	b = (bhz.startTime - event_Otime)*24*3600;
	delta = 1./bhz.sampleRate;
	old_timeaxis = b:delta:b + delta*(bhz.sampleCount-1);
	new_timeaxis = old_timeaxis(1):resample_delta:old_timeaxis(end);
	dataZ = interp1(old_timeaxis,bhz.data_cor,new_timeaxis);
	b = (bhn.startTime - event_Otime)*24*3600;
	delta = 1./bhn.sampleRate;
	old_timeaxis = b:delta:b + delta*(bhn.sampleCount-1);
	dataN = interp1(old_timeaxis,bhn.data_cor,new_timeaxis);
	b = (bhe.startTime - event_Otime)*24*3600;
	delta = 1./bhe.sampleRate;
	old_timeaxis = b:delta:b + delta*(bhe.sampleCount-1);
	dataE = interp1(old_timeaxis,bhe.data_cor,new_timeaxis);
	% rotate
	baz = azimuth(stla,stlo,evla,evlo);
	R_az = baz+180;
	T_az = R_az+90;
	dataR = dataN*cosd(R_az-bhn.azimuth)+dataE*cosd(R_az-bhe.azimuth);
	dataT = dataN*cosd(T_az-bhn.azimuth)+dataE*cosd(T_az-bhe.azimuth);
	% build up structure
	stadata(ista).stla = stla;
	stadata(ista).stlo = stlo;
	stadata(ista).stnm = bhz.station;
	stadata(ista).timeaxis = new_timeaxis;
	stadata(ista).odataZ = dataZ;
	stadata(ista).odataR = dataR;
	stadata(ista).odataT = dataT;
end


% apply filter
delta = resample_delta;
W = 2*delta./lowfilter;
[lowb lowa] = butter(2,W);
W = 2*delta./midfilter;
[midb mida] = butter(2,W);
W = 2*delta./highfilter;
[highb higha] = butter(2,W);
for ista = 1:length(stadata)
	stadata(ista).low_dataZ = filtfilt(lowb,lowa,stadata(ista).odataZ);
	stadata(ista).low_dataR = filtfilt(lowb,lowa,stadata(ista).odataR);
	stadata(ista).low_dataT = filtfilt(lowb,lowa,stadata(ista).odataT);
	stadata(ista).mid_dataZ = filtfilt(midb,mida,stadata(ista).odataZ);
	stadata(ista).mid_dataR = filtfilt(midb,mida,stadata(ista).odataR);
	stadata(ista).mid_dataT = filtfilt(midb,mida,stadata(ista).odataT);
	stadata(ista).high_dataZ = filtfilt(highb,higha,stadata(ista).odataZ);
	stadata(ista).high_dataR = filtfilt(highb,higha,stadata(ista).odataR);
	stadata(ista).high_dataT = filtfilt(highb,higha,stadata(ista).odataT);
end

save(event_name,'stadata','evla','evlo','evdp');
