function [rss,rbs] = calc_rssrbs(SMC,LAI,rbs)
global SaturatedMC ResidualMC fieldMC
aa=0.3;  % Yangling 3.8
rss = exp((aa+5.9)-aa*(SMC-ResidualMC(1))/(fieldMC(1)-ResidualMC(1))); %yangling 4.1
rbs            = rbs*LAI/3.85; % yangling 4.3