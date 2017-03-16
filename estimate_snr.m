% Function to calculate SNR on traces for recreadplot
% 
% data = data (ostensibly for the vertical component)
% time = time axis
% stla = station latitude
% stlo = station longitude
% evla = event latitude
% evlo = event longitude
% 
% NJA, 3/16/2017

function snr = estimate_snr(data,time,stla,stlo,evla,evlo)

% Identify the time of the P-wave
