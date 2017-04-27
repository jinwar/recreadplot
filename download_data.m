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

%% set up arrays for request 

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

filenames = cell(length(stations_info),1);
for is = 1:length(stations_info)
    filenames{is} = [event_name,'/',nwks{is},'_',stas{is},'.mat'];
end


%% breq_fast, email request. FAST & in bulk
if strcmp(req_opt,'breqfast')
    label = ['recread',event_name];
    req_file = [event_name,'/',event_name,'_BREQFAST_REQUEST'];
    email_matlab_setup;
    % ========================= DATA REQUESTED HERE ===========================
    if exist(req_file,'file')==2 % some chicanery to avoid sending two requests
        yn = input('Already requested - request again? (y/n) ','s');
    else
        yn = 'y';
    end
    if strcmp(yn,'y')
        breq_fast_request(label,'recreader',stas,'BH?',nwks,'*',waveform_bgtime,waveform_edtime,'SEED',req_file)
        fprintf('\n ============  REQUEST SENT  ============\n')
        fprintf('Pausing for 10 mins to allow DMC processing.\nUse  CTRL+C to stop\n') 
        pause(600)
    end
    % ======================= DATA PROCESSED FROM HERE ========================
    % ============= PROCEED FROM THIS POINT WHEN DATA IS READY ================
    fprintf('\n ============  DOWNLOADING DATA  ============\n')
    tr = breq_fast_process(label,'recreader',stas,'BH?',nwks,'*',waveform_bgtime);
    
    for is = 1:length(stations_info)
        fprintf('Saving %s data \n',filenames{is})
        traces = tr(is,:);
        traces = traces(~cellfun('isempty',{traces.network})); traces = traces(:);
        save(filenames{is},'traces');
    end
end


%% irisFetch, station-by-station. SLOW but steady....
if strcmp(req_opt,'irisFetch')
    for is = 1:length(stations_info)
        if exist(filenames{is},'file')
            disp(['Found data file:',filenames{is},', Skip!'])
            continue;
        end
        waveform_bgtime_str = datestr(waveform_bgtime(is));
        waveform_edtime_str = datestr(waveform_edtime(is));
        disp(['Downloading station: ',stas{is},' From:',waveform_bgtime_str,' To:',waveform_edtime_str]);
        try
            traces = irisFetch.Traces(nwks{is},stas{is},'*','BH?',waveform_bgtime_str,waveform_edtime_str,'includePZ');
            save(filenames{is},'traces');
        catch e
            e.message;
            continue;
        end
    end
end
