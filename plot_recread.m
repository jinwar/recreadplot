%% scripts to make plots for recreading
% written by Ge Jin, jinwar@gmail.com, ge.jin@ldeo
% 2013-03-29
%
%event = '201303102251';
%load(event)
stlas = [stadata.stla];
stlos = [stadata.stlo];
[dists azi] = distance(evla,evlo,stlas,stlos);

%% Things you may need to change:
% for event from south
ind = find(azi>180);
azi(ind) = azi(ind) - 360;
dist_range = [min(dists) max(dists)];
time_range = [0 4000];

% parameters that not need to be changed.
ori_dist_range = dist_range;
ori_time_range = time_range;
azi_range = [min(azi) max(azi)];
zoom_level = 1;
hist_time_range(zoom_level,:) = time_range;
hist_dist_range(zoom_level,:) = dist_range;
freq_band = 0; 
comp = 1;
single_norm = 1;
amp = 5;
N_trace = 250;
norm_amp = 1;
isfill = 0;
is_reduce_v = 0;
ref_v = 10;
is_dist = 1;
is_cheatsheet = 0;
is_bin = 1;

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

% Gather phase travel-time information
phasenum = 0;
phases = [];
for n=0:9
	command = ['traveltime = [stadata.t',num2str(n),'];'];
	eval(command);
	command = ['name = {stadata.kt',num2str(n),'};'];
	eval(command);
	if nansum(traveltime) > 1
		phasenum = phasenum+1;
		phasedata = [dists(:),traveltime(:)];
		phasedata = sortrows(phasedata,1);
		phases(phasenum).dists = phasedata(:,1);
		phases(phasenum).times = phasedata(:,2);
		for i=1:length(name)
			if sum(char(name(i))==' ') < length(char(name(i)))
				phases(phasenum).name = char(name(i));
				break
			end
		end
	end
end


while 1


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
	norm_amp = nanmedian(max_amp);
	dist_bin = linspace(dist_range(1),dist_range(2),N_trace);
	plot_bin = zeros(size(dist_bin));
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
			if max(abs(data)) > 5
				data(:) = 0;
			end
		end
		if is_dist
			if is_bin
				bin_id = round((dists(ista)-dist_bin(1))./(dist_bin(2)-dist_bin(1)));
				if bin_id == 0
					bin_id = bin_id+1;
				end
				if bin_id > length(plot_bin)
					bin_id = bin_id-1;
				end
				plot_bin(bin_id) = plot_bin(bin_id)+1;
				if plot_bin(bin_id) > 1
					continue;
				end
			end
			trace_amp = amp*diff(dist_range)/N_trace;
			plot(timeaxis,data*trace_amp+dists(ista),'k');
			if isfill
				data(find(data > 0)) = 0;
				area(timeaxis,data*trace_amp+dists(ista),dists(ista),'facecolor','r');
			end
		else
			ind = find(dists>dist_range(1) & dists < dist_range(2));
			azi_range = [min(azi(ind)) max(azi(ind))];
			trace_amp = amp*diff(azi_range)/N_trace;
			plot(timeaxis,data*trace_amp+azi(ista),'k');
			if isfill
				data(find(data > 0)) = 0;
				area(timeaxis,data*trace_amp+azi(ista),azi(ista),'facecolor','r');
			end
		end
	end % end of station loop
	if is_cheatsheet
		for ip = 1:length(phases)
			phasedist = phases(ip).dists;
			phasetime = phases(ip).times;
			ind = find(isnan(phasetime));
			phasetime(ind) = [];
			phasedist(ind) = [];
			if is_reduce_v
				phasetime = phasetime - deg2km(phasedist)./ref_v;
			end
			plot(phasetime,phasedist,'r');
			texty = dist_range(1) + diff(dist_range)*(.3+rand/10-.1);
			textx = interp1(phasedist,phasetime,texty);
			text(textx,texty,phases(ip).name,'color','r','fontsize',20,'linewidth',2);
			texty = dist_range(1) + diff(dist_range)*(.7+rand/10-.1);
			textx = interp1(phasedist,phasetime,texty);
			text(textx,texty,phases(ip).name,'color','r','fontsize',20,'linewidth',2);
		end
	end
	if is_dist
		ylim(dist_range);
	else
		ylim(azi_range);
	end
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
		raypstr = [num2str(1/km2deg(ref_v)), ' s/deg '];
	else
		refvstr = 'None';
		raypstr = 'None';
	end
	title(['Comp: ',comp_name,' Band: ',band_name, ' Vel: ',refvstr, ' rayP: ', raypstr],'fontsize',15);
	xlabel('Time /s','fontsize',15)
	if is_dist
		ylabel('Distance /degree','fontsize',15)
	else
		ylabel('Azimuth /degree','fontsize',15)
	end

	[x y bot] = ginput(1);
	if ~is_dist
		is_dist = 1;
		continue;
	end
	if bot == 'q'
		break;
	end
	if bot == '/'
		figure(89)
		if exist('stah','var')
			delete(stah)
			clear stah
		end
		ind = find(dists>dist_range(1) & dists < dist_range(2));
		stah = plotm(stlas(ind),stlos(ind),'rv');	
	end
	if bot == 'f'
		isfill = ~isfill;
	end
	if bot == 'd'
		is_dist = ~is_dist;
	end
	if bot == 'a'
		[x2 y2 ampstr] = ginput(1);
		temp = ampstr - '0';
		if temp > 0 & temp < 10
			amp = temp;
		end
	end
	if bot == 'i'
		rayp = input('Reduce slowness(s/deg):');
		new_ref_v = deg2km(1/rayp);
		if is_reduce_v
			time_range = time_range + deg2km(mean(dist_range))./ref_v - deg2km(mean(dist_range))./new_ref_v;;
			for izoom = 1:size(hist_time_range,1)
				hist_time_range(izoom,:) = hist_time_range(izoom,:) ...
					+ deg2km(mean(dist_range))./ref_v - deg2km(mean(dist_range))./new_ref_v;
			end
		end
		ref_v = new_ref_v;
	end

	if bot == 'n'
		single_norm = ~single_norm;
	end
	if bot == 'v'
		is_reduce_v = ~is_reduce_v;
		if is_reduce_v
			time_range = time_range - deg2km(mean(dist_range))./ref_v;
			for izoom = 1:size(hist_time_range,1)
				hist_time_range(izoom,:) = hist_time_range(izoom,:) - deg2km(mean(dist_range))./ref_v;
			end
		else
			time_range = time_range + deg2km(mean(dist_range))./ref_v;
			for izoom = 1:size(hist_time_range,1)
				hist_time_range(izoom,:) = hist_time_range(izoom,:) + deg2km(mean(dist_range))./ref_v;
			end
		end
	end
	if bot == 'p'
		[x2 y2] = ginput(1);
		plot([x x2],[y y2],'r');
		if ~is_reduce_v
			new_ref_v = deg2km(y2 - y)./(x2 - x);
		else
			new_ref_v = deg2km(y2 - y)./(x2 - x + deg2km(y2-y)/ref_v)
		end
		if is_reduce_v
			time_range = time_range + deg2km(mean(dist_range))./ref_v - deg2km(mean(dist_range))./new_ref_v;;
			for izoom = 1:size(hist_time_range,1)
				hist_time_range(izoom,:) = hist_time_range(izoom,:) ...
					+ deg2km(mean(dist_range))./ref_v - deg2km(mean(dist_range))./new_ref_v;
			end
		end
		ref_v = new_ref_v;
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
	if bot == 'O' % reset
		zoom_level = 1;
		hist_time_range(zoom_level,:) = ori_time_range;
		hist_dist_range(zoom_level,:) = ori_dist_range;
		time_range = hist_time_range(zoom_level,:);
		dist_range = hist_dist_range(zoom_level,:);
		isfill = 0;
		is_reduce_v = 0;
		single_norm = 1;
		amp = 5;
		ref_v = 10;
		is_dist = 1;
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
	if bot == 'c'
		is_cheatsheet = ~is_cheatsheet;
	end
	if bot == 'b'
		is_bin = ~is_bin;
	end
end

