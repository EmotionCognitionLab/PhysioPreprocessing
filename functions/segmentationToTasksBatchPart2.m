function dataGroups = segmentationToTasksBatchPart2(participantNumber,tableResultsBatch1,b,suffix,filepath0,filepath3,minOrMax)

filename_4 = strcat(participantNumber,'_SegmentationReady',suffix);

struct2 = load(filename_4,'data', 'labels','channelTR');

data = struct2.data;
labels = struct2.labels{:};
channelTR = struct2.channelTR;

threshold = tableResultsBatch1{b,4};
tasksNumberReported = tableResultsBatch1{b,2};
tasksNumberSeen = tableResultsBatch1{b,3};
spaceBetweenTR = tableResultsBatch1{b,5};


%   Opening the plot so the end user can see what is going on.   
figure(str2double(participantNumber))
plot(data(:,channelTR))
hold on

%   The findpeaks function works to find maximum points alone, and we want
%   to use it to find minimum.
if minOrMax == 2
    threshold = (-1)*threshold;
    TRdata = -1*(data(:,channelTR));
else
    TRdata = data(:,channelTR);
end

%   Using the findpeaks function to find the values at the peaks (pks),
%   their indices (lct) and other metadata.
[pks,lct,w,p] = findpeaks(TRdata,'MinPeakHeight',threshold,'MinPeakDistance',spaceBetweenTR);

%   Creating a table from the data. Here we add a final column, which
%   caculates the jumps in the lct file. Using these jumps, we can
%   seperate the big file into our interest areas.
tableTRdata = table(pks,lct,w,p,[0;diff(lct)]);

%   Adding indices for the extreme points. This is important becuase we
%   need to bind groups of extreme data values.
for i=1:length(lct)
    tableTRdata.Index(i) = i;
end

%   Going back from negative values to positive, so that the previously
%   discovered maximum points are now minimum points.
if minOrMax == 2
    pks = (-1)*pks;
    tableTRdata.pks(:) = -1*tableTRdata.pks(:);
end

%   Plotting on the same figure, to if all the maximum points are okay. The
%   points here are in red.
plot(lct,pks,'r*')

%   Exracting the first row in the tableTRdata, becuase we want to remember
%   the special case for the first trigger. It is here where the first
%   segment probably beings.
remember1stTR = tableTRdata(1,{'pks','lct','Index'});

%   We use a different table for sorting. Remember the Var5 variable? It is
%   the difference between extreme points indices. We need to research
%   these differences to find where the biggest jumps in index were. From
%   there we can know where new segments begin, and also later, where the
%   previous segments end.
tableSortDiff = sortrows(tableTRdata,'Var5','descend');

%   Explanation needed
amountToAddSmall = 0;
noiseCountBefore = 0;
amountToAddBig = 0;
notNoiseCountBefore = 0;

while 1

    noiseCountNow = 0;
    notNoiseCountNow = 0;

    lastPositionWithoutAddition = tasksNumberSeen + amountToAddSmall;
    additionFactorTable = tableSortDiff(1:lastPositionWithoutAddition,{'Index'});
    additionFactorTable = sortrows(additionFactorTable,'Index','descend');
    disp(additionFactorTable)
    disp(amountToAddSmall)
    disp(noiseCountBefore)
    noiseArray = zeros(1,lastPositionWithoutAddition-1);
    for t=1:lastPositionWithoutAddition-1
        if additionFactorTable.Index(t)-additionFactorTable.Index(t+1) < 5
            noiseArray(t) = 1;
            noiseCountNow = noiseCountNow + 1;
        else
            noiseArray(t) = 2;
            notNoiseCountNow = notNoiseCountNow + 1;
        end
    end
    
    disp(noiseCountNow)
    disp(notNoiseCountNow)
    
    %   Explanation needed
    if notNoiseCountNow < tasksNumberSeen - 1
        
        % Having problems in: 5001, 5011, 
            
        if notNoiseCountNow < notNoiseCountBefore
            
            break
            
        elseif notNoiseCountNow == notNoiseCountBefore
            
            amountToAddSmall = amountToAddSmall + 1;
            
        else
            
            amountToAddBig = amountToAddSmall;
            amountToAddSmall = amountToAddSmall + 1;
            
        end
        notNoiseCountBefore = notNoiseCountNow;
        noiseCountBefore = noiseCountNow;
                
    else
        
        break
        % Having problems in: 5007, 5005, 5009
        
    end
end
    
amountToAdd = amountToAddBig;
%   Explanation needed

beginningSectionsIndices = [remember1stTR; tableSortDiff(1:(tasksNumberSeen+amountToAdd),{'pks','lct','Index'});];
beginningSectionsIndices = unique(beginningSectionsIndices);
%   We create a transitionTable in order to get to the end Indices.
transitionTable = sortrows(beginningSectionsIndices,'lct','ascend');

%   A little complicated. We create an array from the beginning points. The
%   first entry in this array are reached from the table containing all the
%   indices for the maximum points, minus 1. Then we reach the endings of
%   the previous sections. Then, to bound the last section, we reach the
%   last element in table for TR.
lookingAtTheEndIndices = [transitionTable{2:height(transitionTable),{'Index'}}-1;tableTRdata{height(tableTRdata),{'Index'}}];
lookingAtTheEndIndices = unique(lookingAtTheEndIndices);

lookingAtTheStartIndices = transitionTable;

%   Here we create a table for both the beginning and the end of the
%   segments.
lastElementInGrouping = tableTRdata(lookingAtTheEndIndices ,{'pks','lct','Index'});
firstElementInGrouping = tableTRdata(lookingAtTheStartIndices{:,{'Index'}},{'pks','lct','Index'});


%   Continuing the tradition, we plot the points that begiin the
%   dataGroups. This plot is in green.
%   Afterwards, we plot the end indices in black.
plot(firstElementInGrouping{:,{'lct'}},firstElementInGrouping{:,{'pks'}},'g*')
plot(lastElementInGrouping{:,{'lct'}},lastElementInGrouping{:,{'pks'}},'k*')
hold off

%     while 1
%         flag = input('Does the plot look okay? \nPress 1 for yes or 0 for no\n');
%         if flag == 1
%             break
%         elseif flag == 0
%             error('Something went wrong')
%         else
%             disp('Not a valid response')
%         end
%     end

savefig(participantNumber);
source32 = [filepath3 '/' num2str(participantNumber) '.fig'];
destination32 = [filepath0 '/Stage3/figures'];
movefile(source32,destination32)

close(figure(str2double(participantNumber)))

%   Preparing a data structure for all the segments.
dataGroups = cell(tasksNumberSeen,8);
%   Creating the segments. Notice that we take the indices at the beginning
%   from the start table, and the ending from the end table. Notice: I also
%   take other parts from this analysis: First the position of the segment
%   (j). Then I take the inputs the user put in. In column 5 I add to the 
%   discovered number of tasks the quantity which lets me take enough
%   numbers from the sorted tableTRdata. Only then do I take the
%   data for each task, including the amount of TR in that sample. Then
%   we have a column for indices limits and the two last columns are place
%   holders for tasNameNumber and taskNamk. They go well with part 5 of the
%   Preprocessing function.
for j=1:height(lastElementInGrouping)
    dataGroups{j,1} = participantNumber;
    dataGroups{j,2} = j;
    dataGroups{j,3} = tasksNumberReported;
    dataGroups{j,4} = [tasksNumberSeen amountToAdd];
    dataGroups{j,5} = threshold*(-1);
    dataGroups{j,6} = spaceBetweenTR;
    dataGroups{j,7} = data(firstElementInGrouping{j,{'lct'}}:lastElementInGrouping{j,{'lct'}},:);
    dataGroups{j,8} = lastElementInGrouping{j,{'Index'}}-firstElementInGrouping{j,{'Index'}} + 1;       
    dataGroups{j,9} = {[firstElementInGrouping{j,{'lct'}} lastElementInGrouping{j,{'lct'}}]};
    dataGroups{j,10} = tableTRdata{firstElementInGrouping{j,{'Index'}}:lastElementInGrouping{j,{'Index'}},{'pks','lct'}};
    dataGroups{j,11} = [];
    dataGroups{j,12} = {};
end

%   At the end, just to make it more concise, I create a table.
dataGroups = cell2table(dataGroups,'VariableNames',{'participantNumber','numberOfTask','tasksTotalReported', ...
    'tasksTotalSeen','thresholdInput', 'spaceBetweenTRInput', 'dataFromTask', 'numberOfTR' ...
    'indicesLimits', 'minTROriginal', 'taskNameNumber','taskName'});

save([participantNumber '_cutToSegments' suffix],'labels','channelTR','dataGroups','tableTRdata','minOrMax','-v7.3')

try
    % We should check if the following works
    source3 = [filepath3 '/' [participantNumber '_cutToSegments' suffix]];
    destination3 = [filepath0 '/Stage3/files'];
    movefile(source3,destination3)
    % end of check
catch
    disp('Move was not successful')
end
                    


end