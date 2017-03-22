clear;

setenv('PATH',[path ':/usr/bin:/usr/local/TauP-2.1.2/bin']); % change path for specific computer
javaaddpath('/Users/hjaniszewski/Documents/MATLAB/data_func_matTaup/matTaup/lib/matTaup.jar')

phasenames = {'P','S','PP','PPP','PKIKP','SSS','SSSS','PKKP','PKKKP','PKIKKIKP',...
'pP','sS','SS','SKS','ScS','SKKS','PcP','Pdiff','Sdiff','SP','PPPP','PSP','SSP',...
'SKKKS','SKIKKIKS','SSP','PPSS','PcP','ScS','ScSScS',...
'PKKS','ScP','PcPPKP','PKPPKS','SKIKP','SKKKKS','SKP','SKiKP','PKIIKP','SKIIKS','SKIIKP'...
'PKIKPPKIKP','PKPSKS','SKSSKS','PKKKP','PcPPKPPKP','SKIKKIKP','SKIKSSKIKS','PcPPcP','PcPPcPPcP'...
'PcPPcPPcPPcP','ScSScSScS','ScSScSScSScS','ScSPcPScS','PcPScSPcPScS','PKPScP',...
'pS','sP','sS','PKiKP','PKP','PKPPKP'};

phasenames = unique(phasenames); %check for duplicates

degrees = [5:5:180];

if exist('data/phasedb.mat','file')
	load data/phasedb.mat
	exist_phase_names = [phases.name];
else
	phases = [];
	exist_phase_names = {};
end

if exist('data/raypathdbfine.mat','file')
	load data/raypathdbfine.mat
	exist_phase_names = [raypath.name];
else
	raypath = [];
	exist_raypath_names = {};
end

for ip = 1:length(phasenames)
	if ismember(phasenames(ip),exist_phase_names)
		continue;
	end
	disp(char(phasenames(ip)));
	phases(end+1).name = phasenames(ip);
	system(['taup_table -model prem -ph ',char(phasenames(ip)),' | awk ''{print $2,$3,$5}'' > data/phasetemp.txt']);
	data = load('data/phasetemp.txt');
	evdp = data(:,2);
	depths = unique(evdp);
	for id = 1:length(depths)
		ind = find(evdp == depths(id));
		dist = data(ind,1);
		traveltime = data(ind,3);
		phases(end).event(id).time = traveltime;
		phases(end).event(id).dist = dist;
		phases(end).event(id).evdp = depths(id);
	end
	phases(end).evdps = depths;

    if ismember(phasenames(ip),exist_raypath_names)
		continue;
    end
    disp(char(phasenames(ip)));
	raypath(end+1).name = phasenames(ip);
    ii=1;
    for id = 1:length(depths)
        depth = depths(id);
        for idegs = 1:length(degrees)
            deg = degrees(idegs);
            try
            tt_path=taupPath('prem',depth,char(phasenames(ip)),'deg',deg);
            catch
                continue
            end
            raypath(end).event(ii).evdepth = depth;
            raypath(end).event(ii).evdeg = deg;
            raypath(end).event(ii).distance = tt_path(1).path.distance;
            raypath(end).event(ii).depth = tt_path(1).path.depth;
            ii = ii+1;
        end
    end
end

save('data/phasedb.mat','phases');
save('data/raypathfine.mat','raypath');