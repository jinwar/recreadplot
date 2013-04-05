clear


event = '201303270203';

delta = 0.5;
lowfilter = [200 20];
midfilter = [30 5];
highfilter = [10 2];
lowfilter = [200 50];
midfilter = [40 10];
highfilter = [10 5];

sacZfiles = dir([event,'/*.BHZ.sac']);

% read in the data
for ista = 1:length(sacZfiles)
	clear sacZ sacR sacT
	sacZ = readsac(fullfile(event,sacZfiles(ista).name));
	stadata(ista).stla = sacZ.STLA;
	stadata(ista).stlo = sacZ.STLO;
	stadata(ista).stnm = sacZ.KSTNM;
	stadata(ista).b = sacZ.B;
	stadata(ista).e = sacZ.E;
	old_timeaxis = sacZ.B:sacZ.DELTA:sacZ.B + sacZ.DELTA*(sacZ.NPTS-1);
	new_timeaxis = old_timeaxis(1):delta:old_timeaxis(end);
	stadata(ista).timeaxis = new_timeaxis;
	stadata(ista).odataZ = interp1(old_timeaxis,sacZ.DATA1,new_timeaxis);
	filename = dir([event,'/*.',stadata(ista).stnm,'.*BHR.sac']);
	sacR = readsac(fullfile(event,filename.name));
	stadata(ista).odataR = interp1(old_timeaxis,sacR.DATA1,new_timeaxis);
	filename = dir([event,'/*.',stadata(ista).stnm,'.*BHT.sac']);
	sacT = readsac(fullfile(event,filename.name));
	stadata(ista).odataT = interp1(old_timeaxis,sacT.DATA1,new_timeaxis);
	for n=0:9
		command = ['stadata(ista).t',num2str(n),' = sacZ.T',num2str(n),';'];
		eval(command);
		command = ['stadata(ista).kt',num2str(n),' = sacZ.KT',num2str(n),';'];
		eval(command);
	end
	disp(stadata(ista).stnm)
end

evla = sacZ.EVLA;
evlo = sacZ.EVLO;
evdp = sacZ.EVDP/1e3;

% apply filter
W = 2*delta./lowfilter;
[lowb lowa] = butter(2,W);
W = 2*delta./midfilter;
[midb mida] = butter(2,W);
W = 2*delta./highfilter;
[highb higha] = butter(2,W);
for ista = 1:length(sacZfiles)
	stadata(ista).low_dataZ = filtfilt(lowb,lowa,stadata(ista).odataZ);
	stadata(ista).low_dataR = filtfilt(lowb,lowa,stadata(ista).odataR);
	stadata(ista).low_dataT = filtfilt(lowb,lowa,stadata(ista).odataT);
	stadata(ista).mid_dataZ = filtfilt(midb,mida,stadata(ista).odataZ);
	stadata(ista).mid_dataR = filtfilt(midb,mida,stadata(ista).odataR);
	stadata(ista).mid_dataT = filtfilt(midb,mida,stadata(ista).odataT);
	stadata(ista).high_dataZ = filtfilt(highb,higha,stadata(ista).odataZ);
	stadata(ista).high_dataR = filtfilt(highb,higha,stadata(ista).odataR);
	stadata(ista).high_dataT = filtfilt(highb,higha,stadata(ista).odataT);
end

save(event,'stadata','evla','evlo','evdp');
