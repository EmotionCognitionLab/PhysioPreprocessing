%%  Function 01: belowThreshold
function [localMinPointsAll,localMinPointsAllIndex] = belowThreshold(numberOfLines,data)
   
% strFile = load(filename);
% dataCO2 = strFile.data(:,2);

minDataValue = min(data);
maxDataValue = max(data);

thresholdPool = determinePoolFunction(minDataValue,maxDataValue,numberOfLines);
if ~iscell(thresholdPool)
    thresholdPool = num2cell(thresholdPool);
end

if ishandle(2)
    close(figure(2));
end
figure(2)

if mod(numberOfLines+1,2)==1
    subplot((4+numberOfLines)/2,2,1);
else
    subplot((3+numberOfLines)/2,2,1);
end
plot(data)

for k=1:numberOfLines
    if mod(numberOfLines+1,2)==1
        subplot((4+numberOfLines)/2,2,k+1);
    else
        subplot((3+numberOfLines)/2,2,k+1);
    end
    if iscell(thresholdPool{1})
        subplotThresholdMax(data,cell2mat(thresholdPool{k}));
    else
        subplotThresholdMax(data,thresholdPool{k});
    end
end

if mod(numberOfLines+1,2)==1
    subplot((4+numberOfLines)/2,2,numberOfLines+3);
else
    subplot((3+numberOfLines)/2,2,numberOfLines+2);
end

[finalMaxX,finalMaxY] = intersectMaxValues(data,thresholdPool,numberOfLines+1);
Q = length(finalMaxX);
plot(finalMaxX(1),finalMaxY(1),'r*')
hold on
for i=2:Q
    plot(finalMaxX(i),finalMaxY(i),'r*')
end
plot(data)
hold off

%   Finding minimum points from the maximum
%   taking care of first point
[localMinxPoint1, localMinPointsAllIndex1] = min(data(1:finalMaxX(1)));
%   inserting the first min point into the lists
localMinPointsAll = [localMinxPoint1];
localMinPointsAllIndex = [localMinPointsAllIndex1];

%   using a loop to gather all the minimum points between the first minimum
%   and the last minimum
L = length(finalMaxX);
for i=2:L
    [localMinPoint, localMinPointIndex] = min(data(finalMaxX(i-1):finalMaxX(i)));
    localMinPointIndex = finalMaxX(i-1) + localMinPointIndex - 1;
    localMinPointsAll = [localMinPointsAll localMinPoint];
    localMinPointsAllIndex = [localMinPointsAllIndex localMinPointIndex];
end

%   taking care of the last case
[localMinPoint2, localMinPoint2Index] = min(data(finalMaxX(L):(length(data))));
localMinPoint2Index = finalMaxX(length(finalMaxX)) + localMinPoint2Index - 1;
localMinPointsAll = [localMinPointsAll localMinPoint2]; 
localMinPointsAllIndex = [localMinPointsAllIndex localMinPoint2Index];

localMinPointsAll = transpose(localMinPointsAll);
localMinPointsAllIndex = transpose(localMinPointsAllIndex);

%   plotting the maximum points
if mod(numberOfLines+1,2)==1
    subplot((4+numberOfLines)/2,2,4+numberOfLines);
else
    subplot((3+numberOfLines)/2,2,3+numberOfLines);
end

plot(data);
hold on

T5 = length(localMinPointsAllIndex);
plot(localMinPointsAllIndex(1),localMinPointsAll(1),'b*');
for i=2:T5
    plot(localMinPointsAllIndex(i),localMinPointsAll(i),'b*')
end
hold off

savefig(num2str(2))

close(figure(2))

end

