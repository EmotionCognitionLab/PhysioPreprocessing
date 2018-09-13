%%  Function 02: findMinThreshold
function [xValues, yValues] = findMinThreshold(dataAnalysis,thresholdFunction)

%   Preparing the loop
%   setting loop length
N = length(dataAnalysis);

%   setting loop parameters
localMinPointsAll = [];
localMinPointsAllIndex = [];
indexMinEdgesLeftThreshold = [1];
indexMinEdgesRightThreshold = [];
localMinPoint = 0;
localMinPointIndex = 0;
localIndexEdgeLeft = 1;
localIndexEdgeRight = 1;

    
% try 
%     disp('Entering function')
% 
%     br = thresholdFunction(1).breaks;
%     cf = thresholdFunction(1).coefs;
%     sizePW = length(br)-2;
% 
%     syms x
%     for k=1:sizePW
%         
%         if k == 1
%             pw = piecewise(x<=br(1),cf(1));
%         elseif k ~= sizePW
%             pw = piecewise(br(k-1)<x<=br(k),cf(k),pw);
%         else
%             pw = piecewise(x>br(k),cf(k+1),pw);
%         end
%         
%     end
% catch
%     disp('Entering loop');
% end

%   The loop
for i=2:N-1
    %   Dividing the dataAnalysis according to threshold
      
    try
        
        if iscell(thresholdFunction(1))
            differenceCatalyst = thresholdFunction{1};
        elseif isvector(thresholdFunction(1))
            floatNumber = double(i);
            differenceCatalyst = polyvalm(thresholdFunction,floatNumber);
        end
                
    catch
                
        differenceCatalyst = ppval(thresholdFunction(1),i);
        disp(i)
        
    end        
        
    if dataAnalysis(i)>differenceCatalyst
        %   Recognizing transition points from above to below threshold
        if dataAnalysis(i-1)<=differenceCatalyst
            localIndexEdgeRight = i;
            indexMinEdgesRightThreshold = [indexMinEdgesRightThreshold localIndexEdgeRight];
            [localMinPoint, localMinPointIndex] = min(dataAnalysis(localIndexEdgeLeft:localIndexEdgeRight));
            localMinPointIndex = localIndexEdgeLeft + localMinPointIndex - 1; % A point is being counted twice
            % [localMinPoint, localMinPointIndex] = findpeaks(dataAnalysis(localIndexEdgeLeft:localIndexEdgeRight),'MinPeakDistance',10);
            localMinPointsAll = [localMinPointsAll localMinPoint];
            localMinPointsAllIndex = [localMinPointsAllIndex localMinPointIndex];
        %   Recognizing transition points from below to above threshold
        elseif dataAnalysis(i+1)<=differenceCatalyst
            localIndexEdgeLeft = i+1;
            indexMinEdgesLeftThreshold = [indexMinEdgesLeftThreshold localIndexEdgeLeft];
        end
    end
end

%   Taking care of the extreme right instance (I know it exists beause
%   I looked at the graph). The extreme case to the left was already
%   hanled.
localIndexEdgeRight = N;
indexMinEdgesRightThreshold = [indexMinEdgesRightThreshold localIndexEdgeRight];
[localMinPoint, localMinPointIndex] = min(dataAnalysis(localIndexEdgeLeft:localIndexEdgeRight));
localMinPointIndex = localIndexEdgeLeft + localMinPointIndex - 1;
localMinPointsAll = [localMinPointsAll localMinPoint];
localMinPointsAllIndex = [localMinPointsAllIndex localMinPointIndex];

%   Organizing indexes (xValues) and values (yValues)
%   Preparing a table for it
localMinPointsAll = transpose(localMinPointsAll);
localMinPointsAllIndex = transpose(localMinPointsAllIndex);

xValues = localMinPointsAllIndex;
yValues = localMinPointsAll;

end
     