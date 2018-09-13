%%  Function 01: aboveThreshold
function [localMaxPointsAll,localMaxPointsAllIndex] = aboveThreshold(numberOfLines,data)
   
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
    
    disp(thresholdPool)
    
    if iscell(thresholdPool{1})
        subplotThreshold(data,cell2mat(thresholdPool{k}));
    else
        subplotThreshold(data,thresholdPool{k});
    end
end

if mod(numberOfLines+1,2)==1
    subplot((4+numberOfLines)/2,2,numberOfLines+3);
else
    subplot((3+numberOfLines)/2,2,numberOfLines+2);
end

[finalMinX,finalMinY] = intersectMinValues(data,thresholdPool,numberOfLines+1);
Q = length(finalMinX);
plot(finalMinX(1),finalMinY(1),'r*')
hold on
for i=2:Q
    plot(finalMinX(i),finalMinY(i),'r*')
end
plot(data)
hold off

%   Finding maximum points from the minimum
%   taking care of first point
[localMaxPoint1, localMaxPointsAllIndex1] = max(data(1:finalMinX(1)));
%   inserting the first max point into the lists
localMaxPointsAll = [localMaxPoint1];
localMaxPointsAllIndex = [localMaxPointsAllIndex1];

%   using a loop to gather all the maximum points between the first maximum
%   and the last maximum
L = length(finalMinX);
for i=2:L
    [localMaxPoint, localMaxPointIndex] = max(data(finalMinX(i-1):finalMinX(i)));
    localMaxPointIndex = finalMinX(i-1) + localMaxPointIndex - 1;
    localMaxPointsAll = [localMaxPointsAll localMaxPoint];
    localMaxPointsAllIndex = [localMaxPointsAllIndex localMaxPointIndex];
end

%   taking care of the last case
[localMaxPoint2, localMaxPoint2Index] = max(data(finalMinX(L):(length(data))));
localMaxPoint2Index = finalMinX(length(finalMinX)) + localMaxPoint2Index - 1;
localMaxPointsAll = [localMaxPointsAll localMaxPoint2]; 
localMaxPointsAllIndex = [localMaxPointsAllIndex localMaxPoint2Index];

localMaxPointsAll = transpose(localMaxPointsAll);
localMaxPointsAllIndex = transpose(localMaxPointsAllIndex);

%   plotting the maximum points
if mod(numberOfLines+1,2)==1
    subplot((4+numberOfLines)/2,2,4+numberOfLines);
else
    subplot((3+numberOfLines)/2,2,3+numberOfLines);
end

plot(data);
hold on

T5 = length(localMaxPointsAllIndex);
plot(localMaxPointsAllIndex(1),localMaxPointsAll(1),'b*');
for i=2:T5
    plot(localMaxPointsAllIndex(i),localMaxPointsAll(i),'b*')
end
hold off

savefig(num2str(2))

close(figure(2))

end

