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

%% breq_fast, email request. FAST & in bulk
label = ['recread',event_name];

stas = {stations_info.StationCode}';
nwks = {stations_info.NetworkCode}';

% timing of requested waveforms
travel_time=zeros(length(stations_info),1);
if strcmp(align_phase,'O')
    % no change
elseif strcmp(align_phase,'P')
    stdists = distance(evla,evlo,[stations_info.Latitude],[stations_info.Longitude])';
    travel_time = interp1(p_dist,p_time,stdists); % get time from interpolation of P-time function
else 
    stdists = distance(evla,evlo,[stations_info.Latitude],[stations_info.Longitude])';
    for is = 1:length(stations_info)
        tt = tauptime('deg',stdists(is),'depth',event_info.PreferredDepth,'phases',align_phase);
        if isempty(tt), error('No phase %s at station %s to align on',align_phase,stations_info(is).StationCode); end
        travel_time(is,1) = tt(1).time;
    end
end

waveform_bgtime = event_Otime + travel_time/3600/24 - min_before/60/24;
waveform_edtime = waveform_bgtime + min_before/60/24 + min_after/60/24;


%% breq_fast, email request. FAST & in bulk
label = ['recread',event_name];
email_matlab_setup;
% ========================= DATA REQUESTED HERE ===========================
breq_fast_request(label,'recreader',stas,'BH?',nwks,'*',waveform_bgtime,waveform_edtime,'SEED',[event_name,'_BREQFAST_REQUEST'])

% ======================= DATA PROCESSED FROM HERE ========================
% ============= PROCEED FROM THIS POINT WHEN DATA IS READY ================

tr = breq_fast_process(label,stas,'BH?',nwks,'*',waveform_bgtime);

return

%% irisFetch, station-by-station. SLOW but steady....
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
