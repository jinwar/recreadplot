function data = choosedata(stadata,comp,freq_band)
% comp: 1-BHZ 2-BHR 3-BHT
% freq_band: 0-original 1-low 2-mid 3-high

	data_index = (comp-1)*4 + freq_band + 1;
	switch data_index
		case 1
			data = stadata.odataZ;
		case 2
			data = stadata.low_dataZ;
		case 3
			data = stadata.mid_dataZ;
		case 4
			data = stadata.high_dataZ;
		case 5
			data = stadata.odataR;
		case 6
			data = stadata.low_dataR;
		case 7
			data = stadata.mid_dataR;
		case 8
			data = stadata.high_dataR;
		case 9
			data = stadata.odataT;
		case 10
			data = stadata.low_dataT;
		case 11
			data = stadata.mid_dataT;
		case 12
			data = stadata.high_dataT;
	end
	data = data(:);
end

	
