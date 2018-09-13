%%  Function 03: extractData
%   This function organizes .mat files to array format, from the output
%   format that the python conversion script created.

function [channelsDataOutside,labelsDataOutside,channelTR,unitsDataOutside] = extractData(filename)

data = load(filename);

%   Preparing just the data for comparison between data and Compare
N1 = length(data.channels);
M1 = length(data.channels{1,1}.data);

channelsDataOutside = zeros(M1,N1);

for i=1:N1
    for j=1:M1
        channelsDataOutside(j,i) = data.channels{1,i}.data(1,j);
    end
end

%   Extracting other values: These include labels and units of the channels
%   that were measured
labelsDataOutside = cell(N1,1);
unitsDataOutside = cell(N1,1);

%   The loop to take out the other important values from the disorganized
%   .mat files. These are strings, not numbers. The strcat and cellstr
%   function are used due to that.
for i=1:N1
    labelsDataOutside(i,1) = cellstr(strcat(transpose(data.channels{1,i}.name(:))));
    unitsDataOutside(i,1) = cellstr(strcat(transpose(data.channels{1,i}.units(:))));
end

%   I also want to know which channel is the TR channel. I do this here.
sizeLabels = length(labelsDataOutside); 
channelTR = 0;

for j=1:sizeLabels
    try
        if contains(labelsDataOutside{j},'TR') || contains(labelsDataOutside{j},'Trigger')
            channelTR = j;
        end
    catch
        trFlag = input('How do you label the TR trigger channel?\n','s');
        if contains(labelsDataOutside{j},trFlag)
            channelTR = j;
        end
    end
end

end