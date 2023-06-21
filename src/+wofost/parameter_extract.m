function [wofostpar] = parameter_extract(wofostpar,V,F,path_input)
%   Extract wofost parameters from LAI time series (author: Danyang Yu)
%   Extracted parameters: CSTART  = The start time of crop simulation 
%                       CEND    = The end time of crop simulation
%                       TSUMEA  = Temperature sum from emergence to anthesis [oC]
%                       TSUMAM  = Temperature sum from anthesis to maturity [oC]
%                       LAIEM   = Initial LAI value

%% 1. Load LAI and air temperature data
Dataset_dir         = '';
LAI_file            = char(F(17).FileName);
if  ~isempty(LAI_file)
    LAItable        = load([path_input,Dataset_dir,'/',LAI_file]);
else
    V(22).Val          = canopy.LAI*ones(size(time_));
end

Ta_file             = char(F(11).FileName); 
if ~isempty(Ta_file)%air temperature
    V(31).Val           = load([path_input,Dataset_dir,'/',Ta_file]);
else
    V(31).Val           = V(31).Val*ones(size(t_));
end

%% 2. Smooth LAI time series using HANTS method
ndata = length(LAItable(:,2));             % the total number of LAI data
tday  = 1: (24/wofostpar.TSTEP): ndata;    % decrease the time step to day step 

ni    = length(tday);               % total number of actual samples of the time series
nb    = ni;                         % length of the base period, measured in virtual samples
nf    = 50;                         % number of frequencies to be considered above the zero frequency
ts    = 1:ni;                       % array of size ni of time sample indicators
y     = LAItable(tday,2);           % array of input sample values (e.g. NDVI values)
HiLo  = "none";                     % high or low outliers
low   = 0;                          % valid range minimum
high  = 5;                          % valid range maximum
fet   = 0.1;                        % fit error tolerance
dod   = 1;                          % degree of overdeterminedness
delta = 0.1;                        % small positive number (e.g. 0.1) to suppress high amplitudes

[amp,phi,yr]=wofost.HANTS(ni,nb,nf,y,ts,HiLo,low,high,fet,dod,delta);

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

%% 4. Determine the day for sensonal start and end
% Set the percentage threshold for the value increase
threshold_percentage = 0.4; % Adjust this value according to your needs

% Initialize an array to store the indices that meet the threshold condition
indices_valley_left  = [];
indices_valley_right = [];

% Traverse the time indices and corresponding values
for i = 1:length(filtered_valley_indices)
    valley_index = filtered_valley_indices(i);
    valley_value = lai_data(valley_index);

    % Calculate the threshold value
    threshold_value = valley_value * (1 + threshold_percentage);
    
    % Check if the value exceeds the threshold
    above_threshold_indices = find(lai_data > threshold_value);
    
    % Add the indices which meet the threshold
    indice_left  = above_threshold_indices(find(above_threshold_indices<valley_index));
    indice_right = above_threshold_indices(find(above_threshold_indices>valley_index));

    indices_valley_left  = [indices_valley_left,indice_left(end)];
    indices_valley_right = [indices_valley_right,indice_right(1)];
end

% judge the start point whether lower than end point
if indices_valley_right(1) > indices_valley_left(1)
   indices_valley_right = [1,indices_valley_right];
end

if indices_valley_right(end) > indices_valley_left(end)
   indices_valley_right = indices_valley_right(1:end-1);
end

%% 4. Update the crop parameters
% retrieval to the hour steps
NstepDay = 24/wofostpar.TSTEP; %Number of tsteps on one day
CSTART = indices_valley_right*NstepDay;
CEND   = indices_valley_left*NstepDay;
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
plot(y,'b.-');
hold on;
plot(yr,'g.-');
scatter(filtered_peak_indices,filtered_peaks,'red','*'); 
scatter(filtered_valley_indices,filtered_valleys,'black','*');

scatter(CSTART/NstepDay,lai_data(CSTART/NstepDay),'red','s','filled');
scatter(CEND/NstepDay,lai_data(CEND/NstepDay),'black','s','filled');

legend('Original Data','HANTS Data','LAI Peaks','LAI Valleys','Start Point','End point')
end

