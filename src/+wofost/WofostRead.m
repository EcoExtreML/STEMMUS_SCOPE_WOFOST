function [wofost] = WofostRead()
%INPUT WOFOST PARAMETERS

% Read lines from the file
path_input = '../../input/Wofost/CropD.crp';
fid = fopen(path_input);

% process it line by line 
while true
    tline = fgetl(fid);
    
    % remove empty and note line
    if ~isempty(tline) & tline(1) ~= '*'
        % judge whether the string contain the table value
        if contains(tline,'=')
            s = regexp(tline,'=','split');
            vname = strtrim(char(s(1)));
            % assign value
            if ~isempty(char(s(2)))
                values = regexp(char(s(2)),'!','split');
                value  = str2num(strtrim(char(values(1))));
                wofost.(vname) = value;    % save parameters in wofost struct
            end
        else
            % save tabel value 
            i = 1;
            table_value = [];
            while ~isempty(tline) & tline(1) ~= '*'
                s = strsplit(strtrim(tline));
                table_value(i,1) = str2num(strtrim(char(s(1))));
                table_value(i,2) = str2num(strtrim(char(s(2))));
                i = i + 1;
                tline = fgetl(fid);
%                 disp(tline);
            end
            
            wofost.(vname) = table_value;
        end
    end
   
    %end of file
    if contains(tline,'* End of .crp file !') 
        break; 
    end   
%     disp(tline);
end


end

