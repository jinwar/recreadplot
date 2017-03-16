clear;

% javaaddpath('IRIS-WS-2.0.6.jar');

setup_parameters;

end_time = datenum(start_time,'yyyy-mm-dd HH:MM:SS') + search_time_range/24;
end_time = datestr(end_time,'yyyy-mm-dd HH:MM:SS');

events_info = irisFetch.Events('boxcoordinates',[lat_range lon_range],...
		'startTime',start_time,'endTime',end_time,...
		'MinimumMagnitude',mag_range(1),'maximumMagnitude',mag_range(2));

figure(18)
clf
set(gcf,'color','w');
ax = worldmap(lat_range,lon_range);
evlas = [events_info.PreferredLatitude];
evlos = [events_info.PreferredLongitude];
mags = [events_info.PreferredMagnitudeValue];
for ie = 1:length(events_info)
	bg_times(ie) = datenum(events_info(ie).PreferredTime,'yyyy-mm-dd HH:MM:SS.FFF');
end
for ie = 1:length(events_info)
	plotm(evlas(ie),evlos(ie),'ko','markersize',round(mags(ie)*4));
end
[~,first_eventid] = min(bg_times);
[~,biggest_eventid] = max(mags);
plotm(evlas(first_eventid),evlos(first_eventid),'bo','markersize',round(mags(first_eventid)*4));
plotm(evlas(biggest_eventid),evlos(biggest_eventid),'ro','markersize',round(mags(biggest_eventid)*4));
[mlat,mlon] = inputm(1);
dists = distance(mlat,mlon,evlas,evlos);
[~,eventid] = min(dists);
plotm(evlas(eventid),evlos(eventid),'ko','markersize',round(mags(eventid)*4),'markerfacecolor','g');

disp(['Event: ',events_info(eventid).PreferredTime,' Mag: ', num2str(mags(eventid))]);

com = input('Is this the right event? y/n','s');
if com == 'n'
	return;
end

event_info = events_info(eventid);

% getting station information
%
disp(['Fetching the station information']);
disp(['Station Network Required: ', station_network]);

stations_info = irisFetch.Stations('channel',station_network,'*','*','BHZ','startTime',start_time,'endTime',end_time,'radialcoordinates',[evlas(eventid),evlos(eventid), max_epi_dist,min_epi_dist]);
stlas = [stations_info.Latitude];
stlos = [stations_info.Longitude];
disp('Save event and stations information into fetchdata.mat');

figure(19)
clf
worldmap world
coast = load('coast');
plotm(coast.lat,coast.long,'k');
plotm(stlas,stlos,'bv');
plotm(evlas(eventid),evlos(eventid),'rp','markersize',20,'markerfacecolor','r')
drawnow


save('data/fetchdata.mat','stations_info','event_info');

