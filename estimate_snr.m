% Function to calculate SNR on traces for recreadplot
%
% data = data (ostensibly for the vertical component)
% time = time axis
% dist = distance event-station distance
% evdp = event depth
%
% NJA, 3/16/2017
function snr = estimate_snr(data,time,delta,stdist,evdp)

isfigure = 0;
setup_parameters;
saved_data = data;

% Make sure there's enough data to do it
if length(data) < 1e3
    disp('Not enough data!')
    snr = 0;
    return
end
% Loop throug the different filters
nfilter = 1;
% snrvec = [0;0;0];
snrvec = zeros(nfilter,1);
for ii = 2:2
    
    if ii == 1
        freqfilter = highfilter;
    elseif ii == 2
        freqfilter = midfilter;
    else
        freqfilter = lowfilter;
    end
    
    % Filter the data
    W = 2*delta./freqfilter;
    [filtb filta] = butter(2,W);
    data = filtfilt(filtb,filta,saved_data);
    
    % Load in the travel time data
    load data/phasedb.mat
    
    % If the station is within 90 degrees use the P
    if stdist < 90
        phasei = 1;
        
        % make sure we know where in the structure the awve is
        if ~strcmp(phases(phasei).name,'P')
            error('Cant identify the P arrival in the structure!')
        end
        
    else
        phasei = 15;
        
        if ~strcmp(phases(phasei).name,'PP')
            error('Cant identify the P arrival in the structure!')
        end
    end
    
    
    % Find the event depth closest to ours
    dpind = find(abs(phases(phasei).evdps-evdp) == min(abs(phases(phasei).evdps-evdp)));
    
    event = phases(phasei).event(dpind);
    
    % Pull out the distances from the structure
    pdist = event.dist;
    
    % Find the closest distance to our station distance
    ind = find(abs(pdist-stdist) == min(abs(pdist-stdist)));
    if length(ind) > 1
        ind = ind(1);
    end
    tphase = event.time(ind);
    % Plot things if you want to check
    if isfigure
        
        figure(1)
        if ii == 1; clf; end;
        subplot()
        plot(time,data,'-b')
        hold on
        plot(tphase,0,'or','markersize',20)
        plot([tphase-50,tphase+50],[0,0],'*g')
        xlim([tphase-100 tphase+100])
    end
    
    % Calculate the value of the signal
    signal_wind = 50;
    noise_wind = 100;
    signal_ind = find(time > tphase-signal_wind & time <= tphase+signal_wind);
    signal_amp = sum(data(signal_ind).^2)/length(signal_ind);
    
    if stdist <= 90
        noise_wind = signal_wind;
    else
        noise_wind = signal_wind+500;
    end
    noise_ind = find(time <= tphase-noise_wind & time > tphase-noise_wind*2);
    noise_amp = sum(data(noise_ind).^2)/length(noise_ind);
    
    % Check to see if the time axis is long enough
    if tphase > max(time) || tphase < min(time)
        disp('Time axis doesnt include the P wave!')
        break
    end
 
    try
    snrvec(ii) = (signal_amp/noise_amp)^.5;
    catch
        disp('here');
    end
    if isfigure
        figure(2)
        if ii == 1; clf; end;
        subplot(3,1,ii)
        hold on
        plot(time(noise_ind),data(noise_ind),'-b');
        plot(time(signal_ind),data(signal_ind),'-r');
    end
end

snr = mean(snrvec);