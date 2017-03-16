clear;

load phasedb.mat

pid = find(ismember([phases.name],{'P'}));
pdiffid = find(ismember([phases.name],{'Pdiff'}));

odist = [phases(pid).event(1).dist;phases(pdiffid).event(1).dist];
otime = [phases(pid).event(1).time;phases(pdiffid).event(1).time];

uni_dist = unique(odist);
uni_time = uni_dist;
for id = 1:length(uni_dist)
	uni_time(id) = min(otime(find(odist == uni_dist(id))));
end
uni_dist(end+1) = 180;
uni_time(end+1) = 1150;

figure(68)
clf
hold on
plot(odist,otime,'x');
plot(uni_dist,uni_time,'ro');

p_time = uni_time;
p_dist = uni_dist;

save P_time.mat p_time p_dist;
