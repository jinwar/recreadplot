function [isin sta_azi_out] = is_in_azirange(staazi,azi_range)

	if azi_range(1) > azi_range(2)
		azi_range(1) = azi_range(1)-360;
	end

	cent_azi = mean(azi_range);
	diff_azi = diff(azi_range)/2;

	sta_azi_diff = staazi - cent_azi;
	sta_azi_diff = wrapTo180(sta_azi_diff);
	if abs(sta_azi_diff) > diff_azi
		isin = 0;
	else
		isin = 1;
	end

	sta_azi_out = cent_azi + sta_azi_diff;


