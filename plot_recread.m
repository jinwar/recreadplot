
event = '201303102251';
%load(event)

freq_band = 0; 
comp = 1;
single_norm = 1;
amp = 5;
N_trace = 250;
norm_amp = 1;
isfill = 0;
is_reduce_v = 0;
ref_v = 10;

stlas = [stadata.stla];
stlos = [stadata.stlo];
dists = distance(stlas,stlos,evla,evlo);
dist_range = [min(dists) max(dists)];
time_range = [500 3700];
zoom_level = 1;
hist_time_range(zoom_level,:) = time_range;
hist_dist_range(zoom_level,:) = dist_range;

figure(89)
clf
ax = usamap('conus');
states = shaperead('usastatelo', 'UseGeoCoords', true);
geoshow(ax, states, 'FaceColor', [0.5 0.5 1])
circleRs = floor(dist_range(1)/10)*10:10:ceil(dist_range(2)/10)*10;
for i=1:length(circleRs)
	[lats lons] = scircle1(evla,evlo,circleRs(i));
	geoshow(lats,lons,'color','k');
end
ind = find(dists>dist_range(1) & dists < dist_range(2));
stah = plotm(stlas(ind),stlos(ind),'rv');



while 1
%	figure(89)
%	if exist('stah','var')
%		delete(stah)
%		clear stah
%	end
%	ind = find(dists>dist_range(1) & dists < dist_range(2));
%	stah = plotm(stlas(ind),stlos(ind),'rv');

	figure(99)
	clf
	hold on
	set(gca,'YDir','reverse');
	clear max_amp
	for ista = 1:length(stadata)
		if dists(ista) < dist_range(1) || dists(ista) > dist_range(2)
			max_amp(ista) = NaN;
		end
		timeaxis = stadata(ista).timeaxis;
		if is_reduce_v
			timeaxis = timeaxis - deg2km(dists(ista))./ref_v;
		end
		ind = find(timeaxis > time_range(1) & timeaxis < time_range(2));
		data = choose_data(stadata(ista),comp,freq_band);
		data = data(ind);
		if ~isempty(data)
			max_amp(ista) = max(abs(data));
		else
			max_amp(ista) = NaN;
		end
	end
	norm_amp = nanmean(max_amp);
	for ista = 1:length(stadata)
		if dists(ista) < dist_range(1) || dists(ista) > dist_range(2)
			continue;
		end
		timeaxis = stadata(ista).timeaxis;
		if is_reduce_v
			timeaxis = timeaxis - deg2km(dists(ista))./ref_v;
		end
		ind = find(timeaxis > time_range(1) & timeaxis < time_range(2));
		if isempty(ind)
			continue;
		end
		timeaxis = timeaxis(ind);
		data = choose_data(stadata(ista),comp,freq_band);
		data = data(ind);
		if single_norm
			data = data./max(abs(data));
		else
			data = data./norm_amp;
		end
		trace_amp = amp*diff(dist_range)/N_trace;
		plot(timeaxis,data*trace_amp+dists(ista),'k');
		if isfill
			data(find(data < 0)) = 0;
			area(timeaxis,data*trace_amp+dists(ista),dists(ista),'facecolor','k');
		end
	end
	ylim(dist_range);
	xlim(time_range);
	switch comp
		case 1
			comp_name = 'BHZ';
		case 2
			comp_name = 'BHR';
		case 3
			comp_name = 'BHT';
	end
	switch freq_band
		case 0
			band_name = 'RAW';
		case 1
			band_name = 'LOW';
		case 2
			band_name = 'MID';
		case 3
			band_name = 'HIGH';
	end
	if is_reduce_v
		refvstr = [num2str(ref_v),' km/s'];
	else
		refvstr = 'None';
	end
	title(['Comp: ',comp_name,' Frequency Band: ',band_name, ' Reduce Vel: ',refvstr],'fontsize',15);
	xlabel('Time /s','fontsize',15)
	ylabel('Distance /degree','fontsize',15)

	[x y bot] = ginput(1);
	if bot == 'q'
		break;
	end
	if bot == 'f'
		isfill = ~isfill;
	end
	if bot == 'a'
		[x2 y2 ampstr] = ginput(1);
		temp = ampstr - '0';
		if temp > 0 & temp < 10
			amp = temp;
		end
	end
	if bot == 'v'
		is_reduce_v = ~is_reduce_v;
		if is_reduce_v
			time_range = time_range - deg2km(mean(dist_range))./ref_v;
		else
			time_range = time_range + deg2km(mean(dist_range))./ref_v;
		end
	end
	if bot == 'p'
		[x2 y2] = ginput(1);
		plot([x x2],[y y2],'r');
		if ~is_reduce_v
			ref_v = deg2km(y2 - y)./(x2 - x);
		else
			ref_v = deg2km(y2 - y)./(x2 - x + deg2km(y2-y)/ref_v)
		end
		text(x2,y2,num2str(ref_v),'color','r','fontsize',15);
		[x2 y2] = ginput(1);
	end

	if bot == 'x'  % changing time range
		[x2 y2] = ginput(1);
		if x2 > x
			time_range = [x x2];
		else
			time_range = [x2 x];
		end
		zoom_level = zoom_level + 1;
		hist_time_range(zoom_level,:) = time_range;
		hist_dist_range(zoom_level,:) = dist_range;
	end
	if bot == 'y' % change distance range
		[x2 y2] = ginput(1);
		if y2 > y
			dist_range = [y y2];
		else
			dist_range = [y2 y];
		end
		zoom_level = zoom_level + 1;
		hist_time_range(zoom_level,:) = time_range;
		hist_dist_range(zoom_level,:) = dist_range;
	end
	if bot == 'o' % reset
		if zoom_level > 1
			zoom_level = zoom_level - 1;
		end
		time_range = hist_time_range(zoom_level,:);
		dist_range = hist_dist_range(zoom_level,:);
		isfill = 0;
	end
	if bot == 'r'
		comp = 2;
	end
	if bot == 'z'
		comp = 1;
	end
	if bot == 't'
		comp = 3;
	end
	if bot == 'l'
		freq_band = 1;
	end
	if bot == 'm'
		freq_band = 2;
	end
	if bot == 'h'
		freq_band = 3;
	end
	if bot == '0'
		freq_band = 0;
	end
end

