function [dictTable] = namingFunction(googleSheet)

%   Fixing some variable for easy access: These include the first row,
%   which hold the markers for TR's, and the variable names.
assignmentNamePool = googleSheet.Properties.VariableNames;
assignmentTRPool = table2cell(googleSheet(1,:));

%   First, we start by preparing a dictTable to help us in naming tasks.
%   Here we set a loop to gather all the results from the googleSheet, that
%   are not empty and do not equal 0. In case there was a translation to
%   character, we use the try-catch mechanism. We gather evertyhing in the
%   markersTR cell. These markers signify the column of the participants.
%   Using this column we will grab all the information on the order used in
%   the MRI session.
markersTR = {};
for i=1:length(assignmentTRPool)
    try
        num1 = assignmentTRPool{1,i};
        markersTRbinary = ~isnan(num1) & ~isequal(num1,0);
        if markersTRbinary == 1
            markersTR = [markersTR i];
        end    
    catch
        num1 = str2double(cell2mat(assignmentTRPool{1,i}));
        markersTRbinary = ~isnan(num1) & ~isequal(num1,0);
        if markersTRbinary == 1
            markersTR = [markersTR i];
        end 
    end
end
markersTR = transpose(markersTR);

%   Here we add columns for TR and for names. These will be places at the
%   start of the dictTable. Notice that we are just trying to catch
%   elements in the headline and in the first row. Notice we are using the
%   elements we have named in the first two rows.
tasksNames = cell(length(markersTR),1);
tasksTR = cell(length(markersTR),1);
for j=1:length(markersTR)
    tasksNames{j} = assignmentNamePool{markersTR{j}};
    if ~isnumeric(assignmentTRPool{markersTR{j}})
        assignmentTRPool{markersTR{j}} = str2double(assignmentTRPool{markersTR{j}});
    end
    tasksTR{j} = assignmentTRPool{markersTR{j}};
end

%   Now we create a table from the array. Remember: taskNames holds the
%   names of the tasks, tasksTR holds the amount of TR of each task.
dictArray = [tasksNames tasksTR];
dictTable = cell2table(dictArray);
dictTable.Properties.VariableNames = {'tasksNames','tasksTR'};

%   Signifying which rows hold the information we are about to see. That
%   information will be displayed here in columns
dictTable.locationsGoogleSheet = markersTR;

%   This is the tableToAdd. Here we will add to the dictTable the
%   information regarding the order of the tasks. First we grab everything
%   in a cell. Then we translate it to a table.
width1 = height(googleSheet);
height1 = length(markersTR);
cellAdd = cell(height1,width1);
for k=1:width1-1
    for l=1:length(markersTR)
        cellAdd{l,k} = googleSheet{k+1,markersTR{l}};
    end
end
cellAdd(:,end) = [];

tableToAdd = cell2table(cellAdd);

%   Grabbing the headlines for tableToAdd. These are actually the names
%   of the participants.
participantsOnSheetFile = num2cell(googleSheet.(2));
for d=2:length(participantsOnSheetFile)
    participantsOnSheetFile{d} = ['Participant',num2str(participantsOnSheetFile{d})];
end
participantsOnSheetFile = participantsOnSheetFile(2:end);

tableToAdd.Properties.VariableNames = participantsOnSheetFile;

%   Adding to the dictTable
dictTable = [dictTable tableToAdd];

end