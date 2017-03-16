rrdir = pwd;
addpath([rrdir,'/matguts']);
javaaddpath([rrdir,'/matguts/IRIS-WS-2.0.15.jar']);

% event parameters
lat_range = [-27 -26];
lon_range = [-115 -114];
mag_range = [5 7];
start_time = '2014-09-06 01:00:00';
search_time_range = 10; % in hour

% station parameters
%station_network = '_US-ALL';
%station_network = '_GSN';
%station_network = 'TA';
%station_network = '*';
station_network = '_GSN';
min_epi_dist = 0;
max_epi_dist = 100;

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
time_range = [-600 3000];

