function [task,taskWithAddition,labelsFromFile] = roughSegmentationFinerCut(subjectNumber, segmentBoundaries)

additionToRSP = 12*(10^4);

suffix = '_post_matlabVersion.mat';
filename = [subjectNumber '_SegmentationReady' suffix];

struct1 = load(filename, 'data','labels','units');
dataFromFile = struct1.data;
disp(['File length is: ',num2str(length(dataFromFile))]);

labelsFromFile = struct1.labels;

indexLeft = segmentBoundaries(1);
disp(['Index left is: ',num2str(segmentBoundaries(1))]);

indexRight = segmentBoundaries(2);
disp(['Index right is: ',num2str(segmentBoundaries(2))]);

indexRightWithAddition = indexRight + additionToRSP;
disp(['Index rightwithAddition is: ',num2str(indexRightWithAddition)]);


task = dataFromFile(indexLeft:indexRight,:);
try
    taskWithAddition = dataFromFile(indexLeft:indexRightWithAddition,:);
catch
    taskWithAddition = dataFromFile(indexLeft:end,:);
end

disp('Finished File')
end





