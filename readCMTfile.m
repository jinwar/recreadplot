function [eq] = readCMTfile(CMTSOLUTIONFILE)
% Reads in Quick CMT solution file in the 'ndk' file format downloaded from: 
% http://www.globalcmt.org/CMTfiles.html
%
% Reads relevant earthquake information into eq structure
% 
% Written by Celia in 2017

fid = fopen(CMTSOLUTIONFILE);
line1 = textscan(fid,'%4s %f/%f/%f %f:%f:%f %f %f %f %f %f %s\n',1,'delimiter','\n');
line2 = textscan(fid,'%14s B:%f %f %f S: %f %f %f M:%f %f %f CMT: %f TRIHD: %f\n',1,'delimiter','\n');
line3 = textscan(fid,'CENTROID: %f %f %f %f %f %f %f %f %s\n',1,'delimiter','\n');
line4 = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f\n',1,'delimiter','\n');
line5 = textscan(fid,'%3s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n',1,'delimiter','\n');
fclose(fid);

%Moment tensor in dyne-cm
ex = line4{1};
Mrr = line4{2};
Mtt = line4{4};
Mpp = line4{6};
Mrt = line4{8};
Mrp = line4{10};
Mtp = line4{12};
M = [ Mrr Mrt Mrp;...
      Mrt Mtt Mtp;...
      Mrp Mtp Mpp];
M = M.*10^ex;

%Nodal planes (strike, dip, rake)
np1 = [line5{12} line5{13} line5{14}];
np2 = [line5{15} line5{16} line5{17}];

eq = struct([]);
eq(1).lat = line3{3};
eq.lon = line3{5};
eq.depth = line3{7};
eq.halfdur = line3{1};
eq.M = M;
eq.np1 = np1;
eq.np2 = np2;

end