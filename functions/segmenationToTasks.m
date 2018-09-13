function [dataGroups,flagAnalysis,specialSeeFlag,tableTRdata,minOrMax] = segmenationToTasks(data,channelTR,participantNumber)

%   Plotting the data, to get inputs for the findpeaks function.
figure(str2double(participantNumber))
plot(data(:,channelTR))
hold on

while 1
    disp('According to the plot');
    flagAnalysis = input(['Press 1 if the TR channel is not square\n' ...
        'Press 2 if it is square\n' ...
        'Press 3 otherwhise\n']);
    
    if flagAnalysis == 1
        
        while 1
            minOrMax = input(['Press 1 if the direction of the trigger is up.\n' ...
                'Press 2 if the direction of the trigger is down.\n']);
            if minOrMax == 1 || minOrMax == 2
                break
            else
                disp('Not a legal choice')
            end
        end
        
        disp('According to the plot')
        
        if minOrMax == 1
            threshold = input(['Choose the highest value such that the lowest maximum\n' ...
                'value of interest to you is above it\n']);
        else
            threshold = input(['Choose the lowest value such that the highest minimum\n' ...
                'value of interest to you is below it\n']);
        end

        refline(0,threshold);

        spaceBetweenTR = 2*(10^4);

        tasksNumberSeen = input(['How many tasks were performed in the exam? \nPlease' ...
            ' choose the amount of tasks that the experiment had in general, \nand' ...
            ' not just the amount of tasks you want to look at. \nWe need this for' ...
            ' cutting the segments \nYou might see more tasks than you had, becuase ' ...
            '\nthere might have been a case in which some TRs are adjacent. ' ...
            '\nYou will have a chance to examine each section of TRs so that ' ...
            '\nyou can decide which TR section is which task\n']);
        
        tasksNumberReported = input('What is the reported number of tasks?\n');
        
        %   The findpeaks function works to find maximum points alone, and we want
        %   to use it to find minimum.
        if minOrMax == 2
            threshold = (-1)*threshold;
            TRdata = -1*(data(:,channelTR));
        else
            TRdata = (data(:,channelTR));
        end

        %   Using the findpeaks function to find the values at the peaks (pks),
        %   their indices (lct) and other metadata.
        [pks,lct,w,p] = findpeaks(TRdata,'MinPeakHeight',threshold,'MinPeakDistance',spaceBetweenTR);

        %   Creating a table from the data. Here we add a final column, which
        %   caculates the jumps in the lct file. Using these jumps, we can
        %   seperate the big file into our interest areas.
        try
            tableTRdata = table(pks,lct,w,p,[0;diff(lct)]);
        catch
            error('The inputs were not inserted appropriately.')
        end

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

        while 1
            flag = input('Does the plot look okay? \nPress 1 for yes or 0 for no\n');
            if flag == 1
                break
            elseif flag == 0
                error('Something went wrong')
            else
                disp('Not a valid response')
            end
        end

        savefig(participantNumber);
        close(figure(str2double(participantNumber)))

        %   Preparing a data structure for all the segments.
        dataGroups = cell(height(lastElementInGrouping),12);
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
        
        if tasksNumberSeen == tasksNumberReported
            specialSeeFlag = 1;
        else
            specialSeeFlag = 2;
        end
        
        break
        
    elseif flagAnalysis == 2
        
%         while 1
%             minOrMax = input(['Press 1 if the direction of the trigger is up.\n' ...
%                 'Press 2 if the direction of the trigger is down.\n']);
%             if minOrMax == 1 || minOrMax == 2
%                 break
%             else
%                 disp('Not a legal choice')
%             end
%         end
        
        tasksNumberSeen = input(['How many tasks were performed in the exam? \nPlease' ...
            ' choose the amount of tasks that the experiment had in general, \nand' ...
            ' not just the amount of tasks you want to look at. \nWe need this for' ...
            ' cutting the segments \nYou might see more tasks than you had, becuase ' ...
            '\nthere might have been a case in which some TRs are adjacent. ' ...
            '\nYou will have a chance to examine each section of TRs so that ' ...
            '\nyou can decide which TR section is which task\n']);
        
        tasksNumberReported = input('What is the reported number of tasks?\n');
        
        if tasksNumberSeen == tasksNumberReported
            specialSeeFlag = 1;
        else
            specialSeeFlag = 2;
        end
        
        TRdata = (data(:,channelTR));

%         %   The findpeaks function works to find maximum points alone, and we want
%         %   to use it to find minimum.
%         if minOrMax == 2
%             threshold = (-1)*threshold;
%             TRdata = -1*(data(:,channelTR));
%         else
%             TRdata = (data(:,channelTR));
%         end
% 
%         %   Using the findpeaks function to find the values at the peaks (pks),
%         %   their indices (lct) and other metadata.
%         [pks,lct,w,p] = findpeaks(TRdata,'MinPeakHeight',threshold,'MinPeakDistance',spaceBetweenTR);
% 
%         %   Going back from negative values to positive, so that the previously
%         %   discovered maximum points are now minimum points.
%         if minOrMax == 2
%             pks = (-1)*pks;
%             tableTRdata.pks(:) = -1*tableTRdata.pks(:);
%         end
%         
%         %   Plotting on the same figure, to if all the maximum points are okay. The
%         %   points here are in red.
%         plot(lct,pks,'r*')

        baseline = input('What is the baseline of the channel?\n');
        groupStartNow = [];
        groupEndNow = [];
        groupStart = [];
        groupEnd = [];
        
        %   Grouping all the segments which are squares
        for g = 1:length(TRdata)-1
            if TRdata(g) ~= baseline
                if isempty(groupStartNow)
                    groupStartNow = g;
                else 
                    if ...
                        TRdata(g) ~= baseline && ... 
                        TRdata(g) ~= TRdata(g+1) && ... 
                        TRdata(g+1) ~= groupStartNow
                            groupEndNow = g;
                            groupStart = [groupStart groupStartNow]; 
                            groupEnd = [groupEnd groupEndNow];
                            groupStartNow = [];
                    end
                    
                end
            end
        end
        
        groupAmount = length(groupStart);
        arrayGroupStart = zeros(length(groupStart),4);
        arrayGroupEnd = zeros(length(groupEnd),4);
        for r = 1:groupAmount
           arrayGroupStart(r,1) = groupStart(r);
           arrayGroupStart(r,2) = TRdata(groupStart(r));
           arrayGroupStart(r,3) = 1;
           arrayGroupEnd(r,1) = groupEnd(r);
           arrayGroupEnd(r,2) = TRdata(groupEnd(r));
           arrayGroupEnd(r,3) = 2;
        end
        
        disp(arrayGroupStart)
        disp(arrayGroupEnd)
        
        bigTable = array2table([arrayGroupStart;arrayGroupEnd]);
        bigTableSorted = sortrows(bigTable, 1);
        
        disp(bigTableSorted)
        
        bigTableSortedClean = captureSquareSegments(bigTableSorted);
      
        disp(bigTableSortedClean)
        
        tableGroupStart = array2table(bigTableSortedClean{bigTableSortedClean{:,3} == 1,:});
        tableGroupEnd = array2table(bigTableSortedClean{bigTableSortedClean{:,3} == 2,:});

%         figure(str2double(participantNumber))
        plot(tableGroupStart{:,1},tableGroupStart{:,2},'g*')
        plot(tableGroupEnd{:,1},tableGroupEnd{:,2},'k*')
                    
        dataGroups = cell(length(groupAmount),12);
 
        for j=1:height(groupAmount)
            dataGroups{j,1} = participantNumber;
            dataGroups{j,2} = j;
            dataGroups{j,3} = tasksNumberReported;
            dataGroups{j,4} = tasksNumberSeen;
            dataGroups{j,5} = groupAmount;
            dataGroups{j,6} = flagAnalysis;
            dataGroups{j,7} = data(arrayGroupStart(j,1):arrayGroupEnd(j,1));
            dataGroups{j,8} = arrayGroupEnd(j,2) - arrayGroupStart(j,2) + 1;       
            dataGroups{j,9} = {[arrayGroupStart(j,1) arrayGroupEnd(j,1)]};
            dataGroups{j,10} = arrayGroupStart(j,2);
            dataGroups{j,11} = [];
            dataGroups{j,12} = {};
        end
       
        %   At the end, just to make it more concise, I create a table.
        dataGroups = cell2table(dataGroups,'VariableNames',{'participantNumber','numberOfTask','tasksTotalReported', ...
            'tasksTotalSeen','groupAmount', 'flagAnalysis', 'dataFromTask', 'groupLength' ...
            'indicesLimits', 'segmentTRIdentifier', 'taskNameNumber','taskName'});
        
        if tasksNumberSeen == tasksNumberReported
            specialSeeFlag = 1;
        else
            specialSeeFlag = 2;
        end
        
        break
        
    elseif flagAnalysis == 3
        
        close(figure(str2double(participantNumber)))
        dataGroups = {};
        specialSeeFlag = 0;
        break
        
    else
        
        disp('Not a valid option')
        
    end
    
end
    
end