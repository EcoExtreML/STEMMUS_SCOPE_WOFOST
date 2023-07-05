function [wofostpar] = parameterExtract_TemSum(wofostpar,V,F,path_input)
%   Extract wofost parameters based on temperature sum (author: Danyang Yu)
%   Extracted parameters: CSTART  = The start time of crop simulation 
%                         CEND    = The end time of crop simulation
%                         TSUMEA  = Temperature sum from emergence to anthesis [oC]
%                         TSUMAM  = Temperature sum from anthesis to maturity [oC]
%                         LAIEM   = Initial LAI value

%% 1. Load time, LAI and air temperature data
Dataset_dir         = '';

% load the time information
t_file              = char(F(6).FileName);
year_file           = char(F(7).FileName);
doy                 = load([path_input,Dataset_dir,'/' ,t_file] );
years               = load([path_input,Dataset_dir,'/',year_file]);

% load LAI data
LAI_file            = char(F(17).FileName);
if  ~isempty(LAI_file)
    LAItable        = load([path_input,Dataset_dir,'/',LAI_file]);
    V(22).Val       = LAItable(:,2);
else
    V(22).Val          = canopy.LAI*ones(size(time_));
end
lai_data = V(22).Val;

% load air temperature data
Ta_file             = char(F(11).FileName); 
if ~isempty(Ta_file)%air temperature
    V(31).Val           = load([path_input,Dataset_dir,'/',Ta_file]);
else
    V(31).Val           = V(31).Val*ones(size(t_));
end


%% 2. Calculate the tempurature sum for each day of year
% Initialize an array to store the data of temperature sum
cumulative_temperatures = [];
NstepDay = 24/wofostpar.TSTEP;      % Number of tsteps on one day

% calculate the effective temperature
Tadata = V(31).Val;
TaEffective = Tadata - wofostpar.TBASE;
TaEffective(TaEffective<0) = 0;

% Calculate the temperature sum for each year
unique_years = unique(years);
for i = 1:numel(unique_years)
    year = unique_years(i);
    year_indices = find(years == year);

    Ta_year = TaEffective(year_indices);
    cumulative_temperatures_year = cumsum(Ta_year)/NstepDay;
    cumulative_temperatures = [cumulative_temperatures,cumulative_temperatures_year'];
end

%% 3. Determine the day for sensonal start and end based on temperature sum
% Initialize an array to store the index of sensonal start and end
CSTART = [];
CPEAK  = [];
CEND   = [];

% Input the parameters of temperature sum to define the phenological stage
TsumStart = wofostpar.TSUMSTART;
TsumEA    = wofostpar.TSUMEA;
TsumAM    = wofostpar.TSUMAM;

% Return the index of start and end date for each season
for i = 1:numel(unique_years)
    year = unique_years(i);
    year_indices = find(years == year);

    TaSum_year   = cumulative_temperatures(year_indices);
    CSTART_year  = find(TaSum_year>TsumStart);
    CPEAK_year   = find(TaSum_year>(TsumStart+TsumEA));
    CEND_year    = find(TaSum_year>(TsumStart+TsumEA+TsumAM));

    CSTART_index = year_indices(CSTART_year(1));
    CPEAK_index  = year_indices(CPEAK_year(1));
    if isempty(CEND_year)
        CEND_index   = year_indices(end);
    else
        CEND_index   = year_indices(CEND_year(1));
    end

    CSTART       = [CSTART,CSTART_index];
    CPEAK        = [CPEAK,CPEAK_index];
    CEND         = [CEND,CEND_index];
    
end

%% 4. Update the crop parameters
% number of crop growth seasons
nSeasons = length(CSTART);

% calculate the TSUMEA and TSUMAM, and Update the LAIEM
TSUMEA = TsumEA * ones(1,nSeasons);
TSUMAM = TsumAM * ones(1,nSeasons);
LAIEM  = LAItable(CSTART(:),2);

% update the crop parameters for time series
wofostpar.CSTARTSeries = CSTART;
wofostpar.CENDSeries   = CEND;
wofostpar.TSUMEASeries = TSUMEA;
wofostpar.TSUMAMSeries = TSUMAM;
wofostpar.LAIEMSeries  = LAIEM;

%% plotting
ax1 = subplot(2,1,1);
plot(lai_data,'g.-');
hold on;

scatter(CSTART,lai_data(CSTART),'red','s','filled');
scatter(CPEAK,lai_data(CPEAK),'blue','s','filled');
scatter(CEND,lai_data(CEND),'black','s','filled');
ylabel('LAI (m^3/m^3)');

yyaxis right;
plot(cumulative_temperatures,'red');
legend('Original Data','Start Point','Anthesis Point','End Point','Temperature Sum');
ylabel('Cumulated temperature (^oC)');
hold off;

end

