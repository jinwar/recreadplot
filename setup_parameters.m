
% event parameters
lat_range = [33 34];
lon_range = [-119 -117];
mag_range = [4 10];
start_time = '2014-03-29 00:00:00';
search_time_range = 24; % in hour

% station parameters
%station_network = '_GSN';
%station_network = 'TA';
station_network = '_US-ALL';

% define donwload waveform length
align_phase = 'P';   % O for original time, P for P phase
min_before = 10;   % minutes before the phase
min_after = 60; %  minutes after the phase

% Waveform processing parameters

lowfilter = [200 30];
midfilter = [25 5];
highfilter = [2 0.25];
resample_delta = 0.1;

% Waveform plotting parameters
time_range = [-600 6000];

