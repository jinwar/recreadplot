clear;

javaaddpath('IRIS-WS-2.0.6.jar');

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
	plotm(evlas(ie),evlos(ie),'ko','markersize',round(mags(ie)*4),'LineWidth',2);
end
[temp first_eventid] = min(bg_times);
[temp biggest_eventid] = max(mags);
%addlinesstart changed colors
plotm(evlas(first_eventid),evlos(first_eventid),'o','Color',[0.0235    0.4431    0.5804],'markersize',round(mags(first_eventid)*4),'LineWidth',2);
plotm(evlas(biggest_eventid),evlos(biggest_eventid),'o','Color',[0.8118    0.1804    0.1922],'markersize',round(mags(biggest_eventid)*4),'LineWidth',2);
[mlat mlon] = inputm(1);
dists = distance(mlat,mlon,evlas,evlos);
[temp eventid] = min(dists);
plotm(evlas(eventid),evlos(eventid),'ko','markersize',round(mags(eventid)*4),'markerfacecolor',[0.0235    0.5255    0.3294],'LineWidth',2);
%addlinesend
disp(['Event: ',events_info(eventid).PreferredTime,' Mag: ', num2str(mags(eventid))]);

com = input('Is this the right event (y/n) : ','s');
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

%addlinesstart
set(gcf,'color','w');
axesm('MapProjection','miller','MapLatLimit',[-90 90],'MapLonLimit',[-180 180]);
gridm off; framem on; axis off;
hAx=gca;          % retrieve the handle of the axes itself
pAx=get(hAx,'position');  % and the position vector
set(hAx,'position',[0 0 1 1]);
land = shaperead('landareas.shp','UseGeoCoords',true);
geoshow(land,'FaceColor',[0.9    0.9    0.9])
plotm(stlas,stlos,'v','Color',[0.0235    0.4431    0.5804]);
plotm(evlas(eventid),evlos(eventid),'p','Color',[0.8118    0.1804    0.1922],'markersize',20,'markerfacecolor','r')
%addlinesend
drawnow


save fetchdata.mat stations_info event_info

