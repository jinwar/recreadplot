function mk_sound(data,delta)
% function to make sound out of a seismic record
% written by Ge Jin, ge.jin@ldeo.columbia.edu

sound_length = 20;  % in second
lowf = 0.005;
highf = 0.1;
data = data(:);
fN = 1/delta/2;
[b a] = butter(2,[lowf/fN,highf/fN]);
data = filtfilt(b,a,data);
data = detrend(data);
Nt = length(data);
%data = [zeros(round(Nt/10),1);data;zeros(round(Nt/10),1)];
%Nt = length(data);



fs = 44100; % sample rate
dt = 1/fs;

s_taxis = 0:dt:sound_length;
s_taxis = s_taxis(:);
N = length(s_taxis);

f0 = 2*146.8; % reference frequency

ScaleTable = [1 9/8 5/4 3/2 5/3];  % do re mi so la
ScaleTable = [ScaleTable/2 ScaleTable ScaleTable*2];
amp_tune = loud_weight(ScaleTable.*f0);

% prepare the seismic data
% define 15 frequency band based on the scale table
centfs = linspace(log(lowf),log(highf),length(ScaleTable));
centfs = exp(centfs);

gaus_filters = build_gaus_filter(centfs,delta,length(data),0.1,0.3);
fft_data = fft(data(:));
data_taxis = [0:Nt-1]*delta;
data_sound_taxis = linspace(0,sound_length,Nt);

for ifreq = 1:length(centfs)
	nband = fft_data .* [gaus_filters(:,ifreq); zeros(Nt-length(gaus_filters(:,ifreq)),1)];
	nband = ifft(nband);
	nband = abs(nband).^2;
	nband = nband./sum(nband);
	nbdata(:,ifreq) = nband(:);
end
nbdata = nbdata ./max(nbdata(:));

% plot seismic spectrum
[xi yi] = ndgrid(data_taxis,1./centfs);
%[xi yi] = ndgrid(data_taxis,ScaleTable);
figure(28)
clf
surface(xi,yi,nbdata);
shading flat;

sound_data = zeros(length(s_taxis),length(centfs));
for ifreq = 1:length(centfs)
	nband = interp1(data_sound_taxis,nbdata(:,ifreq),s_taxis);
	sound_data(:,ifreq) = nband.*amp_tune(ifreq).*cos(2*pi*ScaleTable(ifreq)*f0*s_taxis);
end

clear M
final_sound = mean(sound_data,2);
final_sound = final_sound./max(final_sound(:));

figure(30)
clf
plot(s_taxis,final_sound);

figure(29)
clf
hold on
Nframe = 100;
plot(data_taxis,data);
for iframe = 1:Nframe
	marker_time = data_taxis(round(Nt/Nframe*(iframe-1)+1));
	plot([marker_time marker_time],[min(data) max(data)],'r')
	M(iframe) = getframe;
end

sound_obj = audioplayer(final_sound,fs);
play(sound_obj);
movie(M,1,round(Nframe/sound_length));


