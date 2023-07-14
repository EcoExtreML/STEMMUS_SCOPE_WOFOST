function [wofostpar] = parameterExtract_LAI(wofostpar,V,F,path_input)
%   Extract wofost parameters from LAI time series (author: Danyang Yu)
%   Extracted parameters: CSTART  = The start time of crop simulation 
%                       CEND    = The end time of crop simulation
%                       TSUMEA  = Temperature sum from emergence to anthesis [oC]
%                       TSUMAM  = Temperature sum from anthesis to maturity [oC]
%                       LAIEM   = Initial LAI value

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
else
    V(22).Val          = canopy.LAI*ones(size(time_));
end

% load air temperature data
Ta_file             = char(F(11).FileName); 
if ~isempty(Ta_file)%air temperature
    V(31).Val           = load([path_input,Dataset_dir,'/',Ta_file]);
else
    V(31).Val           = V(31).Val*ones(size(t_));
end

%% 2. Smooth LAI time series using HANTS method
ndata = length(LAItable(:,2));      % the total number of LAI data
NstepDay = 24/wofostpar.TSTEP;      % Number of tsteps on one day
tday  = NstepDay: NstepDay: ndata;  % decrease the time step to day step 

ni    = length(tday);               % total number of actual samples of the time series
nb    = ni;                         % length of the base period, measured in virtual samples
nf    = 1:100;                          % number of frequencies to be considered above the zero frequency
ts    = 1:ni;                       % array of size ni of time sample indicators
y     = LAItable(tday,2);           % array of input sample values (e.g. NDVI values)
HiLo  = "none";                     % high or low outliers
low   = 0;                          % valid range minimum
high  = 5;                          % valid range maximum
fet   = 0.1;                        % fit error tolerance
dod   = 1;                          % degree of overdeterminedness
delta = 0.1;                        % small positive number (e.g. 0.1) to suppress high amplitudes

% find the optimized nf parameter
rmseSeries = [];
for inf = nf
    [amp,phi,y_model] = wofost.HANTS(ni,nb,inf,y,ts,HiLo,low,high,fet,dod,delta);
    rmse    = sqrt(mean((y_model - y).^2));
    rmseSeries = [rmseSeries,rmse];
end
[minValue, minIndex] = min(rmseSeries);
nf_opt = nf(minIndex);

% output the optimal hants smooth results
[amp,phi,yr]=wofost.HANTS(ni,nb,nf_opt,y,ts,HiLo,low,high,fet,dod,delta);

%% 3. Find the peak and valley value of LAI for all growth seasons
lai_data = yr;

[peaks, peak_indices] = findpeaks(lai_data); % obtain the index of LAI peaks
[valleys, valley_indices] = findpeaks(-lai_data); % obtain the index of LAI valley
valleys = -valleys; % retrievl the valley values

% filter out the peaks that are below the mean lai
meanLai = mean(lai_data,'omitnan');
valid_peak_indices = peaks >= meanLai;
filtered_peaks = peaks(valid_peak_indices);
filtered_peak_indices = peak_indices(valid_peak_indices);

% filter out the valleys that are above the mean lai
valid_valleys_indices = valleys <= meanLai;
filtered_valleys = valleys(valid_valleys_indices);
filtered_valley_indices = valley_indices(valid_valleys_indices);

% find out the minimum valleys if some of them are too closed
min_valley_distance = 1/2 * mean(diff(filtered_peak_indices));   % the threshold is set as the 1/2 distance of peaks
groups = {}; % Store groups
min_values = []; % Store minimum values
min_indices = []; % Store indices of minimum values
group_start_index = 1; % Initialize the start index of the first group

for i = 2:length(filtered_valleys)
    distance = filtered_valley_indices(i) - filtered_valley_indices(i-1);
    if distance > min_valley_distance
       group_end_index = i - 1;
       group_values = filtered_valleys(group_start_index:group_end_index);
       groups{end+1} = group_values;
          
       % Calculate the minimum value and its index within the current group
       [min_value, min_index] = min(group_values);
        
       % Store the minimum value and its index
       min_values(end+1) = min_value;
       min_indices(end+1) = group_start_index + min_index - 1;
        
       % Update the start index for the next group
       group_start_index = i;
    end
end

group_values = filtered_valleys(group_start_index:end); % Process the last group
groups{end+1} = group_values;
[min_value, min_index] = min(group_values);
min_values(end+1) = min_value;
min_indices(end+1) = group_start_index + min_index - 1;

filtered_valleys = min_values; % Update the filtered vallyes and indices
filtered_valley_indices = filtered_valley_indices(min_indices);

% find out the maximum peaks if some of them are too closed
min_peak_distance = 1/2 * mean(diff(filtered_valley_indices));   % the threshold is set as the 1/2 distance of vallyes
groups = {}; % Store groups
max_values = []; % Store minimum values
max_indices = []; % Store indices of minimum values
group_start_index = 1; % Initialize the start index of the first group

for i = 2:length(filtered_peaks)
    distance = filtered_peak_indices(i) - filtered_peak_indices(i-1);
    if distance > min_peak_distance
       group_end_index = i - 1;
       group_values = filtered_peaks(group_start_index:group_end_index);
       groups{end+1} = group_values;
          
       % Calculate the minimum value and its index within the current group
       [max_value, max_index] = max(group_values);
        
       % Store the minimum value and its index
       max_values(end+1) = max_value;
       max_indices(end+1) = group_start_index + max_index - 1;
        
       % Update the start index for the next group
       group_start_index = i;
    end
end

group_values = filtered_peaks(group_start_index:end); % Process the last group
groups{end+1} = group_values;
[max_value, max_index] = max(group_values);
max_values(end+1) = max_value;
max_indices(end+1) = group_start_index + min_index - 1;

filtered_peaks = max_values; % Update the filtered vallyes and indices
filtered_peak_indices = filtered_peak_indices(max_indices);

%% 4. Determine the day for sensonal start and end
% Set the percentage threshold for the value increase
threshold_percentage = wofostpar.THRESHOLD; % Adjust this value according to your needs

% Initialize an array to store the indices that meet the threshold condition
indices_peak_left  = [];
indices_peak_right = [];

% judge whether the valley index smaller than peak index at start
if filtered_valley_indices(1) > filtered_peak_indices(1)
   filtered_valley_indices = [1;filtered_valley_indices];
end

if filtered_valley_indices(end) < filtered_peak_indices(end)
   filtered_valley_indices = [filtered_valley_indices;ts(end)];
end
filtered_valleys = lai_data(filtered_valley_indices);

% Traverse the time indices and corresponding values
for i = 1:length(filtered_peak_indices)
    % determint the index and value of peaks and valleys
    peak_index         = filtered_peak_indices(i);
    peak_value         = lai_data(peak_index);

    valley_index_left  = filtered_valley_indices(i);
    valley_index_right = filtered_valley_indices(i+1);
    valley_value_left  = lai_data(valley_index_left);
    valley_value_right = lai_data(valley_index_right);

    % Calculate the threshold value
    threshold_value_start = valley_value_left  + (peak_value-valley_value_left)*threshold_percentage;
    threshold_value_end   = valley_value_right + (peak_value-valley_value_right)*threshold_percentage;

    % Determine the index that crop starts or ends to grow up 
    lai_growth_seasion    = lai_data(valley_index_left:valley_index_right);
    above_threshold_left  = find(lai_growth_seasion > threshold_value_start)+valley_index_left-1;
    above_threshold_right = find(lai_growth_seasion > threshold_value_end)+valley_index_left-1;

    indices_peak_left   = [indices_peak_left,above_threshold_left(1)];
    indices_peak_right  = [indices_peak_right,above_threshold_right(end)];
end


%% 5. Update the crop parameters
% retrieval to the hour steps
CSTART = indices_peak_left*NstepDay;
CEND   = indices_peak_right*NstepDay;
PEAKS  = filtered_peak_indices*NstepDay;

% calculate the effective temperature
Tadata = V(31).Val;
TaEffective = Tadata - wofostpar.TBASE;
TaEffective(TaEffective<0) = 0;

% calculate the TSUMEA and TSUMAM, and Update the LAIEM
TSUMEA = [];
TSUMAM = [];
LAIEM  = [];
for m = 1:length(CSTART)
    TSUMEA(m) = sum(TaEffective(CSTART(m):PEAKS(m)))/NstepDay;
    TSUMAM(m) = sum(TaEffective(PEAKS(m):CEND(m)))/NstepDay;
    LAIEM(m)  = LAItable(CSTART(m),2);
end

% update the crop parameters for time series
wofostpar.CSTARTSeries = CSTART;
wofostpar.CENDSeries   = CEND;
wofostpar.TSUMEASeries = TSUMEA;
wofostpar.TSUMAMSeries = TSUMAM;
wofostpar.LAIEMSeries  = LAIEM;

%% plotting
ax1 = subplot(1,1,1);
plot(y,'b.-');
hold on;
plot(yr,'g.-');

scatter(filtered_peak_indices,filtered_peaks,'red','*'); 
scatter(filtered_valley_indices,filtered_valleys,'black','*');
scatter(CSTART/NstepDay,lai_data(CSTART/NstepDay),'red','s','filled');
scatter(CEND/NstepDay,lai_data(CEND/NstepDay),'black','s','filled');
ylabel('LAI (m^3/m^3)')
legend('Original Data','HANTS Data','LAI Peaks','LAI Valleys','Start Point','End Point');
hold off;

end

