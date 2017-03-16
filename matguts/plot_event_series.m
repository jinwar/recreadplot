clear

javaaddpath('IRIS-WS-2.0.6.jar');

lat_range = [3 6];
lon_range = [61 64];
start_time = '2014-02-23';

events_info = irisFetch.Events('boxcoordinates',[lat_range lon_range],'startTime',start_time);

evlas = [events_info.PreferredLatitude];
evlos = [events_info.PreferredLongitude];
mags = [events_info.PreferredMagnitudeValue];

for ie = 1:length(events_info);
	bg_times(ie) = datenum(events_info(ie).PreferredTime,'yyyy-mm-dd HH:MM:SS.FFF');
end
%bg_times = (bg_times - datenum(2000,1,1))/365 + 2000;
bg_times = (bg_times - datenum(2014,2,24))*24;
	
%marker_range = [2000 2015]
marker_range = [22 27];
figure(85)
clf
subplot(1,2,1)
hold on
cmap = colormap('jet');
x = linspace(marker_range(1),marker_range(2),size(cmap,1));
for ie = 1:length(events_info)
	color = interp1(x,cmap,bg_times(ie));
	plot(bg_times(ie),mags(ie),'o','markerfacecolor',color);
end
%xlim([0 15])
xlim(marker_range)
xlabel('Time (year)','fontsize',20)
ylabel('Magnitude','fontsize',20)

subplot(1,2,2)
ax = worldmap(lat_range,lon_range);
setm(ax,'fontsize',20)
for ie = 1:length(events_info)
	color = interp1(x,cmap,bg_times(ie));
	plotm(evlas(ie),evlos(ie),'ko','markersize',round(mags(ie)*4),'markerfacecolor',color);
end

