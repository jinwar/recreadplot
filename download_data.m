clear;

% javaaddpath('IRIS-WS-2.0.6.jar');
load data/fetchdata.mat
load data/phasedb.mat
load data/P_time.mat
setup_parameters

if align_phase~= 'O' && align_phase~= 'P'
	disp('Can not find the align phase! Has to be O or P');
	return
end

event_Otime = datenum(event_info.PreferredTime,'yyyy-mm-dd HH:MM:SS.FFF');
evla = event_info.PreferredLatitude;
evlo = event_info.PreferredLongitude;
event_name = datestr(event_Otime,'yyyymmddHHMM');

if ~exist(event_name,'dir') mkdir(event_name); end

for ista = 1:length(stations_info)
	stnm = stations_info(ista).StationCode;
	network = stations_info(ista).NetworkCode;
	filename = [event_name,'/',network,'_',stnm,'.mat'];
	if exist(filename,'file')
		disp(['Found data file:',filename,', Skip!'])
		continue;
	end
	stla = stations_info(ista).Latitude;
	stlo = stations_info(ista).Longitude;
	dist = distance(stla,stlo,evla,evlo);
	if align_phase == 'O'
		waveform_bgtime = event_Otime;
	else
		travel_time = interp1(p_dist,p_time,dist);
		waveform_bgtime = event_Otime + travel_time/3600/60/24 - min_before/60/24;
	end
	waveform_edtime = waveform_bgtime + min_before/60/24 + min_after/60/24;
	waveform_bgtime_str = datestr(waveform_bgtime,'yyyy-mm-dd HH:MM:SS');
	waveform_edtime_str = datestr(waveform_edtime,'yyyy-mm-dd HH:MM:SS');
	disp(['Downloading station: ',stnm,' From:',waveform_bgtime_str,' To:',waveform_edtime_str]);
	try
		traces = irisFetch.Traces(network,stnm,'*','BH?',waveform_bgtime_str,waveform_edtime_str,'includePZ');
		save(filename,'traces');
	catch e
		e.message;
		continue;
	end
end
