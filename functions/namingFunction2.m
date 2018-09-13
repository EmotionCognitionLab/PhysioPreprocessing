function [tableResults,dictArray,responseBackup] = namingFunction2(dictArray,tableResults)

%   Here will will start gathering inputs from the user on the identity of
%   each segment. We will first fill all the responses and back it up.
%   Afterwhich, we will start the process of naming.
responseBackup = zeros(height(tableResults),1);
for i=1:height(tableResults)
    temp1 = cell2mat(tableResults.participantNumber(i));
    temp2 = num2str(tableResults.numberOfTask(i));
    temp3 = num2str(tableResults.numberOfTR(i));
    fprintf(['Participant number: %s \nPlace: %s, ', ...
        '\nNumber of TRs: %s \n'], temp1,temp2,temp3)
    for j=1:height(dictArray)-1
        disp(strcat(['Press ', num2str(j), ' for ', cell2mat(dictArray{j,1}),', Number of TR: ',num2str(dictArray{j,2})]));
    end
    disp('Press 999 for missing. Press 0 to look again.');
    disp('Press 22 for segments that need concatenation');
    while 1
        response1 = input('Enter your response?\n');
        if ismember(response1,[[1:11] 999 0])
            tableResults.taskNameNumber(i) = num2cell(response1);
            responseBackup(i) = response1;
            break
        elseif response1 == 22
            while 1
                concateSegmentNum = input('Press the number of the concatenated task\n');
                if ismember(concateSegmentNum ,[1:11])
                    tableResults.taskNameNumber(i) = {[num2cell(response1),num2cell(concateSegmentNum)]};
                    responseBackup(i) = 22;
                    break
                else
                    disp('Not a legal reply');
                end
            end
            break
        else
            disp('Not a legal reply');
        end
    end
end



end