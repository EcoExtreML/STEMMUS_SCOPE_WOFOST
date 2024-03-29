function [wofostpar,nSeasions] = parameter_update(wofostpar,KT,nSeasions)
%   Update wofost parameters to use the extraced parameters 
%   from LAI time series (author: Danyang Yu)
%   Updated parameters: CSTART  = The start time of crop simulation 
%                       CEND    = The end time of crop simulation
%                       TSUMEA  = Temperature sum from emergence to anthesis [oC]
%                       TSUMAM  = Temperature sum from anthesis to maturity [oC]
%                       LAIEM   = Initial LAI value

%% 1. Update the crop parameters
wofostpar.CSTART = wofostpar.CSTARTSeries(nSeasions);
wofostpar.CEND   = wofostpar.CENDSeries(nSeasions);
wofostpar.TSUMEA = wofostpar.TSUMEASeries(nSeasions);
wofostpar.TSUMAM = wofostpar.TSUMAMSeries(nSeasions);
wofostpar.LAIEM  = wofostpar.LAIEMSeries(nSeasions);

%% 2. Update the growth seasion numbers
if KT == 1
   nSeasions = 1; 
else
   maxSeasions = length(wofostpar.CSTARTSeries);
   nSeasions = nSeasions + 1;
   nSeasions = min(maxSeasions,nSeasions);
end

end

