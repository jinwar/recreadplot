%% scripts to make plots for recreading
% written by Ge Jin, jinwar@gmail.com, ge.jin@ldeo
% 2013-03-29
%
load phasedb.mat

setup_parameters
N_trace = 100;

if exist('fetchdata.mat','file')
	load fetchdata.mat
	event_Otime = datenum(event_info.PreferredTime,'yyyy-mm-dd HH:MM:SS.FFF');
	event_name = datestr(event_Otime,'yyyymmddHHMM');
end

if ~exist('stadata','var')
	load(event_name);
end

cheatsheetphases = {'P','Pdiff','S','Sdiff','SP',...
					'PP','PPP','SS','SSS',...
					'SSP','PSP',...
					'SKS','SKKS','SKKKS',...
					'ScSScS',...
					'ScS','PcP',...
					'PKIKP','PKKP','PKIKKIKP'...
					'PKP','PKPPKP',...
					'PKIKP'...
	}

if evdp > 50
	cheatsheetphases = [cheatsheetphases, {'pP','pS','sS','sP'}]
end

stlas = [stadata.stla];
stlos = [stadata.stlo];
[dists azi] = distance(evla,evlo,stlas,stlos);

%% Things you may need to change:
% for event from south
if mean(azi) < 90 || mean(azi) > 270
	ind = find(azi>180);
	azi(ind) = azi(ind) - 360;
end
dist_range = [min(dists) max(dists)];

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
norm_amp = 1;
newcheat_max_dist = 3;
newcheat_max_time = 100;
isfill = 0;
is_reduce_v = 0;
ref_v = 10;
is_dist = 1;
is_cheatsheet = 0;
is_newcheatsheet = 0;
is_bin = 1;
is_mark = 0;
amp_diff_tol = 5;
plot_bw = 1; %black and white/color plotting

figure(89)
clf
set(gcf,'color','w');
ax = usamap('conus');
load states.mat
geoshow(ax, states, 'FaceColor', [0.9 0.9 0.9])
ind = find(dists>dist_range(1) & dists < dist_range(2));
stah = plotm(stlas(ind),stlos(ind),'v','MarkerSize',10,'Color',[0.8118    0.1804    0.1922],'MarkerFaceColor',[0.8118    0.1804    0.1922]);
circleRs = floor(dist_range(1)/10)*10:10:(ceil(dist_range(2)/10)*10-10);
for i=1:length(circleRs)
	[lats,lons] = scircle1(evla,evlo,circleRs(i));
	geoshow(lats,lons,'color',[0.0235    0.4431    0.5804]);
	ind = find(lats > 25 & lats < 50 & lons > -125 & lons < -60);
	textm(mean(lats(ind)),mean(lons(ind)),num2str(circleRs(i)),'fontsize',20,'Color',[0.0235    0.4431    0.5804]);
end
circleRs = floor(azi_range(1)/10)*10:10:(ceil(azi_range(2)/10)*10-10);
rnd = [0:5:180];
for i=1:length(circleRs)
	[lats,lons] = reckon(evla,evlo,rnd,circleRs(i));
	geoshow(lats,lons,'color','k');
	ind = find(lats > 25 & lats < 50 & lons > -125 & lons < -60);
	textm(mean(lats(ind)),mean(lons(ind)),num2str(circleRs(i)),'fontsize',20);
end

figure(90)
clf
set(gcf,'color','w');
ax = usamap('alaska');
geoshow(ax, states, 'FaceColor', [0.9 0.9 0.9])
stah1 = plotm(stlas,stlos,'v','MarkerSize',10,'Color',[0.8118    0.1804    0.1922],'MarkerFaceColor',[0.8118    0.1804    0.1922]);
circleRs = floor(dist_range(1)/10)*10:10:ceil(dist_range(2)/10)*10;
for i=1:length(circleRs)
	[lats lons] = scircle1(evla,evlo,circleRs(i));
	geoshow(lats,lons,'color',[0.0235    0.4431    0.5804]);
	ind = find(lats > 50 & lats < 70 & lons > -180 & lons < -130);
	textm(mean(lats(ind)),mean(lons(ind)),num2str(circleRs(i)),'fontsize',20,'color',[0.0235    0.4431    0.5804]);
end
circleRs = floor(azi_range(1)/10)*10:10:ceil(azi_range(2)/10)*10;
rnd = [0:5:180];
for i=1:length(circleRs)
	[lats lons] = reckon(evla,evlo,rnd,circleRs(i));
	geoshow(lats,lons,'color','k');
	ind = find(lats > 50 & lats < 70 & lons > -180 & lons < -130);
	textm(mean(lats(ind)),mean(lons(ind)),num2str(circleRs(i)),'fontsize',20);
end

figure(91)
clf
set(gcf,'color','w');
ax = worldmap([-90 90],[-145 -35]);
land = shaperead('landareas.shp','UseGeoCoords',true);
geoshow(land,'FaceColor',[0.9 0.9 0.9]);
stah2 = plotm(stlas,stlos,'v','MarkerSize',8,'Color',[0.8118    0.1804    0.1922],'MarkerFaceColor',[0.8118    0.1804    0.1922]);
circleRs = floor(dist_range(1)/10)*10:10:ceil(dist_range(2)/10)*10;
for i=1:length(circleRs)
	[lats lons] = scircle1(evla,evlo,circleRs(i));
	geoshow(lats,lons,'color',[0.0235    0.4431    0.5804]);
	ind = find(lats > 50 & lats < 70 & lons > -180 & lons < -130);
	textm(mean(lats(ind)),mean(lons(ind)),num2str(circleRs(i)),'fontsize',20,'color',[0.0235    0.4431    0.5804]);
end
circleRs = floor(azi_range(1)/10)*10:10:ceil(azi_range(2)/10)*10;
rnd = [0:5:180];
for i=1:length(circleRs)
	[lats lons] = reckon(evla,evlo,rnd,circleRs(i));
	geoshow(lats,lons,'color','k');
	ind = find(lats > 50 & lats < 70 & lons > -180 & lons < -130);
	textm(mean(lats(ind)),mean(lons(ind)),num2str(circleRs(i)),'fontsize',20);
end

if exist('CMTSOLUTION','file')
    CMTSOLUTION = './CMTSOLUTION';
    eq = readCMTfile(CMTSOLUTION);  
    figure(92)
    radpplot(eq.np1(1),eq.np1(2),eq.np1(3),1,92,[1 3 1]);
    radpplot(eq.np1(1),eq.np1(2),eq.np1(3),2,92,[1 3 2]);
    radpplot(eq.np1(1),eq.np1(2),eq.np1(3),3,92,[1 3 3]);
end

% Gather phase travel-time information
phasenum = 0;
eventphases = [];
exist_phase_names = [phases.name];

for ip = 1:length(cheatsheetphases)
	phasename = cheatsheetphases(ip);
	if ismember(phasename,exist_phase_names)
		phaseid = find(ismember(exist_phase_names,phasename));
		[evdpdiff depthid] = min(abs(phases(phaseid).evdps - evdp));
		if evdpdiff > 50
			disp(['No phase ',char(phasename),' for this event depth'])
		end
		phasenum = phasenum+1;
		odist = phases(phaseid).event(depthid).dist;
		otime = phases(phaseid).event(depthid).time;
		uni_dist = unique(odist);
		uni_time = uni_dist;
		for id = 1:length(uni_dist)
			uni_time(id) = min(otime(find(odist == uni_dist(id))));
		end

		eventphases(phasenum).dists = uni_dist;
		eventphases(phasenum).times = uni_time;
		eventphases(phasenum).alldists = odist;
		eventphases(phasenum).alltimes = otime;
		eventphases(phasenum).name = char(phases(phaseid).name);
	else
		disp(['Cannot find travel time information in the phase database for ',char(phasename)]);
		disp(['Please use make_phasedb to increase the database']);
	end
end

phasenum_all = 0;
eventphases_all = [];

for ip = 1:length(exist_phase_names)
        phasename = exist_phase_names{ip};
        phaseid = find(ismember(exist_phase_names,phasename));
		[evdpdiff depthid] = min(abs(phases(phaseid).evdps - evdp));
		if evdpdiff > 50
			disp(['No phase ',char(phasename),' for this event depth'])
		end
		phasenum_all = phasenum_all+1;
		odist = phases(phaseid).event(depthid).dist;
		otime = phases(phaseid).event(depthid).time;
		uni_dist = unique(odist);
		uni_time = uni_dist;
		for id = 1:length(uni_dist)
			uni_time(id) = min(otime(find(odist == uni_dist(id))));
		end

		eventphases_all(phasenum_all).dists = uni_dist;
		eventphases_all(phasenum_all).times = uni_time;
		eventphases_all(phasenum_all).alldists = odist;
		eventphases_all(phasenum_all).alltimes = otime;
		eventphases_all(phasenum_all).name = char(phases(phaseid).name);
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
			continue;
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
	ind = find(dists>dist_range(1) & dists < dist_range(2));
%	azi_range = [min(azi(ind)) max(azi(ind))];
	azi_bin = linspace(azi_range(1),azi_range(2),N_trace);
	
	for ista = 1:length(stadata)
		if dists(ista) < dist_range(1) || dists(ista) > dist_range(2)
			continue;
		end
		[azi_isin azi(ista)] = is_in_azirange(azi(ista),azi_range);
		is_in_azi(ista) = azi_isin;
		if ~azi_isin continue; end
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
			if max(abs(data)) > amp_diff_tol
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
			trace_amp = amp*diff(dist_range)/(2*N_trace);
            if (plot_bw==1)
                plot(timeaxis,data*trace_amp+dists(ista),'k');
            else
                plot(timeaxis,data*trace_amp+dists(ista),'Color',...
                    [(azi(ista)+180)/360 0 1-(azi(ista)+180)/360]);
            end
			if isfill
				data(find(data > 0)) = 0;
				area(timeaxis,data*trace_amp+dists(ista),dists(ista),'facecolor','b');
			end
			if is_mark
				plot(markertime,markerdist,'m','linewidth',2);
			end
		else
			if is_bin
				bin_id = round((azi(ista)-azi_bin(1))./(azi_bin(2)-azi_bin(1)));
				if bin_id < 1 || bin_id > length(plot_bin)
					continue;
				end
				plot_bin(bin_id) = plot_bin(bin_id)+1;
				if plot_bin(bin_id) > 1
					continue;
				end
			end
			trace_amp = amp*diff(azi_range)/(2*N_trace);
            if (plot_bw==1)
                plot(timeaxis,data*trace_amp+azi(ista),'k');
            else
                plot(timeaxis,data*trace_amp+azi(ista),'Color',...
                    [dists(ista)/180 0 1-dists(ista)/180]);
            end
			if isfill
				data(find(data > 0)) = 0;
				area(timeaxis,data*trace_amp+azi(ista),azi(ista),'facecolor','b');
			end
		end
	end % end of station loop
	if is_cheatsheet
		for ip = 1:length(eventphases)
			phasedist = eventphases(ip).dists;
			phasetime = eventphases(ip).times;
			ind = find(isnan(phasetime));
			phasetime(ind) = [];
			phasedist(ind) = [];
			if is_reduce_v
				phasetime = phasetime - deg2km(phasedist)./ref_v;
			end
			plot(phasetime,phasedist,'r');
			texty = dist_range(1) + diff(dist_range)*(.3+rand/5-.2);
			textx = interp1(phasedist,phasetime,texty);
			text(textx,texty,eventphases(ip).name,'color','r','fontsize',20,'linewidth',2);
			texty = dist_range(1) + diff(dist_range)*(.7+rand/5);
			textx = interp1(phasedist,phasetime,texty);
			text(textx,texty,eventphases(ip).name,'color','r','fontsize',20,'linewidth',2);
		end
    end
    if is_newcheatsheet
        for ip = 1:length(eventphases_all)
            phasedist = eventphases_all(ip).dists;
            phasetime = eventphases_all(ip).times;
            ind = find(isnan(phasetime));
            phasetime(ind) = [];
            phasedist(ind) = [];
            if is_reduce_v
				phasetime = phasetime - deg2km(phasedist)./ref_v;
            end
            temp1 = abs(phasedist-cheat_loc(2));
            temp2 = abs(phasetime-cheat_loc(1));
            ind1 = find(temp1 <= newcheat_max_dist);
            if (min(temp2(ind1)) <= newcheat_max_time);
                plot(phasetime,phasedist,'b');
                texty = dist_range(1) + diff(dist_range)*(.3+rand/5-.2);
                textx = interp1(phasedist,phasetime,texty);
                text(textx,texty,eventphases_all(ip).name,'color','r','fontsize',20,'linewidth',2);
                texty = dist_range(1) + diff(dist_range)*(.7+rand/5);
                textx = interp1(phasedist,phasetime,texty);
                text(textx,texty,eventphases_all(ip).name,'color','r','fontsize',20,'linewidth',2);
            end
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
	title(['Comp: ',comp_name,' Band: ',band_name, ' Vel: ',refvstr, ' rayP: ', raypstr,' ampnorm: ',num2str(single_norm)],'fontsize',15);
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
		ind = find(dists>dist_range(1) & dists < dist_range(2) & is_in_azi);
		stah = plotm(stlas(ind),stlos(ind),'rv');	
		figure(90)
		if exist('stah','var')
			delete(stah1)
			clear stah1
		end
		stah1 = plotm(stlas(ind),stlos(ind),'rv');	
		figure(91)
		if exist('stah','var')
			delete(stah2)
			clear stah2
		end
		stah2 = plotm(stlas(ind),stlos(ind),'rv');	
	end
	if bot == 's'
		[temp staid] = min(abs(dists-y));
		timeaxis = stadata(staid).timeaxis;
		if is_reduce_v
			timeaxis = timeaxis - deg2km(dists(staid))./ref_v;
		end
		ind = find(timeaxis > time_range(1) & timeaxis < time_range(2));
		if isempty(ind)
			continue;
		end
		timeaxis = timeaxis(ind);
		data = choose_data(stadata(staid),comp,freq_band);
		data = data(ind);
		mk_sound(data,timeaxis(2) - timeaxis(1));
	end
	if bot == 'S'
		figure(89)
		[plat plon] = inputm(1);
		sta_dists = distance(plat,plon,stlas,stlos);
		[temp staid] = min(sta_dists);
		timeaxis = stadata(staid).timeaxis;
		if is_reduce_v
			timeaxis = timeaxis - deg2km(dists(staid))./ref_v;
		end
		ind = find(timeaxis > time_range(1) & timeaxis < time_range(2));
		if isempty(ind)
			continue;
		end
		timeaxis = timeaxis(ind);
		data = choose_data(stadata(staid),comp,freq_band);
		data = data(ind);
		mk_sound(data,timeaxis(2) - timeaxis(1));
	end
	if bot == 'f'
		isfill = ~isfill;
	end
	if bot == 'd'
		is_dist = ~is_dist;
	end
	if bot == '.'
		if is_mark
			is_mark = 0;
		else
			is_mark = 1;
			[x2 y2] = ginput(1);
			markertime = [x x2];
			markerdist = [y y2];
		end
	end
	if bot == 'a'
		[x2 y2 ampstr] = ginput(1);
		temp = ampstr - '0';
		if temp > 0 & temp < 10
			amp = temp;
		end
	end
	if bot == 'e'
		disp(sprintf('Current azimuth range: %f %f',azi_range(1),azi_range(2)));
		try
			stemp = input('Input azimuth range:','s');
			[azi_range(1) azi_range(2)] = strread(stemp,'%f %f');
		catch e
			disp('Input error');
		end
		if azi_range(1) > azi_range(2)
			azi_range(1) = azi_range(1)-360;
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
			if is_mark
				markertime = markertime - deg2km(markerdist)./ref_v;
			end
		else
			time_range = time_range + deg2km(mean(dist_range))./ref_v;
			for izoom = 1:size(hist_time_range,1)
				hist_time_range(izoom,:) = hist_time_range(izoom,:) + deg2km(mean(dist_range))./ref_v;
			end
			if is_mark
				markertime = markertime + deg2km(markerdist)./ref_v;
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
		plot([x x],dist_range,'r','linewidth',2);
		[x2 y2] = ginput(1);
		plot([x2 x2],dist_range,'r','linewidth',2);
		pause(0.5);
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
		plot(time_range,[y y],'r','linewidth',2);
		[x2 y2] = ginput(1);
		plot(time_range,[y2 y2],'r','linewidth',2);
		pause(0.5)
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
		azi_range = [0 360];
		isfill = 0;
		is_reduce_v = 0;
		single_norm = 1;
		amp = 5;
		ref_v = 10;
		is_dist = 1;
    end
    
    if bot == 'w'
        if (plot_bw == 0)
            plot_bw = 1; %black and white trace plotting - default
        else
            plot_bw = 0; %color traces by dist/azi
        end
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
    if bot == 'C'
        plot(x,y,'b.','MarkerSize',30);
        pause(0.5)
        cheat_loc = [x y];
        is_newcheatsheet = ~is_newcheatsheet;
    end
	if bot == 'b'
		is_bin = ~is_bin;
    end
    
    %addLinesStart - Martin added URL for station data
    if bot == 'k'
        [i,j]=min(abs(dists-y));
        web(['http://ds.iris.edu/mda/' stadata(j).net '/' stadata(j).stnm])
        figure(401)
        axesm('MapProjection','miller','MapLatLimit',[stadata(j).stla-20 stadata(j).stla+20],'MapLonLimit',[stadata(j).stlo-20 stadata(j).stlo+20],'MeridianLabel', 'on','ParallelLabel', 'on');
        gridm on; framem on; axis off;
        S = shaperead('landareas.shp', 'UseGeoCoords', true);
        geoshow(S, 'FaceColor', [0.5 0.5 1])
        circleRs = floor(dist_range(1)/10)*10:10:ceil(dist_range(2)/10)*10;
        for i=1:length(circleRs)
            [lats,lons] = scircle1(evla,evlo,circleRs(i));
            geoshow(lats,lons,'color',[0.0235    0.4431    0.5804]);
            ind = find(lats > 50 & lats < 70 & lons > -180 & lons < -130);
            textm(mean(lats(ind)),mean(lons(ind)),num2str(circleRs(i)),'fontsize',20);
        end
        circleRs = floor(azi_range(1)/10)*10:10:ceil(azi_range(2)/10)*10;
        rnd = 0:5:180;
        for i=1:length(circleRs)
            [lats,lons] = reckon(evla,evlo,rnd,circleRs(i));
            geoshow(lats,lons,'color',[0.0235    0.4431    0.5804]);
            ind = find(lats > 50 & lats < 70 & lons > -180 & lons < -130);
            textm(mean(lats(ind)),mean(lons(ind)),num2str(circleRs(i)),'fontsize',15);
        end
        [RNG, AZ] = distance(evla,evlo,stadata(j).stla,stadata(j).stlo);
        plotm(stadata(j).stla,stadata(j).stlo,'v','Color',[0.8118    0.1804    0.192],'MarkerSize',10,'MarkerFaceColor',[0.8118    0.1804    0.192])
        str = sprintf('%s\n%s\n',['Station: ' stadata(j).stnm '  Network: ' stadata(j).net],['Distance: ' num2str(RNG)],['Azimuth: ' num2str(AZ)]);
        title(str,'fontsize',15)
    end
    %addLinesEnd
end

