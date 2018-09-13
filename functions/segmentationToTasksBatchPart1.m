function [dataGroupsBatch1, flagAnalysis, specialSeeFlag,minOrMax] = segmentationToTasksBatchPart1(data,channelTR,participantNumber)

%   Plotting the data, to get inputs for the findpeaks function.
figure(str2double(participantNumber))
plot(data(:,channelTR))
hold on

while 1
    disp('According to the plot');
    flagAnalysis = input('Is the TR fit for normal analysis? \nPress 1 for yes or 2 for no\n');
    if flagAnalysis == 1
        
        %   Gathering inputs for mass production
        disp('According to the plot');
        
        while 1
            minOrMax = input(['Press 1 if the direction of the trigger is up.\n' ...
                'Press 2 if the direciton of the trigger is down.\n']);
            if minOrMax == 1 || minOrMax == 2
                break
            else
                disp('Not a legal choice')
            end
        end
        
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

        hold off

        %   Saving figures for later analysis
        close(figure(str2double(participantNumber)))

        dataGroupsBatch1 = cell(1,4);
        dataGroupsBatch1{1,1} = participantNumber;
        dataGroupsBatch1{1,2} = tasksNumberReported;
        dataGroupsBatch1{1,3} = tasksNumberSeen;
        dataGroupsBatch1{1,4} = threshold;
        dataGroupsBatch1{1,5} = spaceBetweenTR;

        %   At the end, just to make it more concise, I create a table.
        dataGroupsBatch1 = cell2table(dataGroupsBatch1,'VariableNames',{'participantNumber','tasksTotalReported', ...
            'tasksTotalSeen','thresholdInput', 'spaceBetweenTRInput'});
        
        if tasksNumberSeen == tasksNumberReported
            specialSeeFlag = 1;
        else
            specialSeeFlag = 2;
        end
        
        break
    
    elseif flagAnalysis == 2
        
        close(figure(str2double(participantNumber)))
        dataGroupsBatch1 = {};
        specialSeeFlag = 0;
        break
        
    else
        
        disp('Not a valid option')
        
    end
    
end