%%  Function 02: findMaxThreshold
function [xValues, yValues] = findMaxThreshold(dataAnalysis,thresholdFunction)

%   Preparing the loop
%   setting loop length
N = length(dataAnalysis);

%   setting loop parameters
localMaxPointsAll = [];
localMaxPointsAllIndex = [];
indexMaxEdgesLeftThreshold = [1];
indexMaxEdgesRightThreshold = [];
localMaxPoint = 0;
localMaxPointIndex = 0;
localIndexEdgeLeft = 1;
localIndexEdgeRight = 1;

if ~isnumeric(thresholdFunction(1))
    disp(thresholdFunction{1})
end

%   The loop
for i=2:N-1
    %   Dividing the dataAnalysis according to threshold
    if ~isnumeric(thresholdFunction(1))
        differenceCatalyst = thresholdFunction{1};
    else
        floatNumber = double(i);
        differenceCatalyst = polyvalm(thresholdFunction,floatNumber);
    end
        
    if dataAnalysis(i)<differenceCatalyst
        %   Recognizing transition points from above to below threshold
        if dataAnalysis(i-1)>=differenceCatalyst
            localIndexEdgeRight = i;
            indexMaxEdgesRightThreshold = [indexMaxEdgesRightThreshold localIndexEdgeRight];
            [localMaxPoint, localMaxPointIndex] = max(dataAnalysis(localIndexEdgeLeft:localIndexEdgeRight));
            localMaxPointIndex = localIndexEdgeLeft + localMaxPointIndex - 1; % A point is being counted twice
            % [localMinPoint, localMinPointIndex] = findpeaks(dataAnalysis(localIndexEdgeLeft:localIndexEdgeRight),'MinPeakDistance',10);
            localMaxPointsAll = [localMaxPointsAll localMaxPoint];
            localMaxPointsAllIndex = [localMaxPointsAllIndex localMaxPointIndex];
        %   Recognizing transition points from below to above threshold
        elseif dataAnalysis(i+1)>=differenceCatalyst
            localIndexEdgeLeft = i+1;
            indexMaxEdgesLeftThreshold = [indexMaxEdgesLeftThreshold localIndexEdgeLeft];
        end
    end
end

%   Taking care of the extreme right instance (I know it exists beause
%   I looked at the graph). The extreme case to the left was already
%   hanled.
localIndexEdgeRight = N;
indexMaxEdgesRightThreshold = [indexMaxEdgesRightThreshold localIndexEdgeRight];
[localMaxPoint, localMaxPointIndex] = max(dataAnalysis(localIndexEdgeLeft:localIndexEdgeRight));
localMaxPointIndex = localIndexEdgeLeft + localMaxPointIndex - 1;
localMaxPointsAll = [localMaxPointsAll localMaxPoint];
localMaxPointsAllIndex = [localMaxPointsAllIndex localMaxPointIndex];

%   Organizing indexes (xValues) and values (yValues)
%   Preparing a table for it
localMaxPointsAll = transpose(localMaxPointsAll);
localMaxPointsAllIndex = transpose(localMaxPointsAllIndex);

xValues = localMaxPointsAllIndex;
yValues = localMaxPointsAll;

end
     