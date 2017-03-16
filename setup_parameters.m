
% event parameters
lat_range = [-25 -22];
lon_range = [-179 -177];
mag_range = [6.6 7.2];
start_time = '2017-02-24 0:00:00';
search_time_range = 72; % in hour

% station parameters
%station_network = '_GSN';
%station_network = 'TA';
%station_network = '*';
station_network = '_US-ALL,_GSN,TA';
min_epi_dist = 0;
max_epi_dist = 180;

% define donwload waveform length
align_phase = 'P';   % O for original time, P for P phase
min_before = 10;   % minutes before the phase
min_after = 110; %  minutes after the phase

% Waveform processing parameters

lowfilter = [200 30];
midfilter = [25 5];
highfilter = [5 2];
resample_delta = 0.1;

% Waveform plotting parameters
time_range = [-600 6000];

