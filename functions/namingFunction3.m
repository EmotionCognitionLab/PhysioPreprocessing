function [tableResults,dictArray,tableCleaned] = namingFunction3(dictArray,tableResults)

%   Before we gathered numbers for task names. Now we want to convert these
%   numbers to the actual names they recognize. This next loop does it.
for j=1:height(tableResults)
    try
        if ~ismember(tableResults{j,{'taskNameNumber'}}{1},[0 999 22])
            tableResults{j,{'taskName'}} = dictArray{tableResults.taskNameNumber{j,1},1};
        else
            tableResults{j,{'taskName'}} = {'Missing'};
        end
    catch
        tableResults{j,{'taskName'}} = dictArray{tableResults.taskNameNumber{j}{2},1};
    end
end

%   Now we want to handle the segments that we need to concatenate. We have
%   to be careful with using tableResults parameters, since we are adding
%   to the table inside the loop. We could have also created a seperate
%   table, append to that, and then add the entire other table to the
%   tableResults.
segmentStart = 0;
segmentEnd = 0;
markerIn = 0;
flagInOut = 0;
flagAdd = 0;
markerOut = 0;
heightConstant = height(tableResults);
minTRgroup = [];
for j=1:heightConstant
    if ~flagInOut
        if iscell(tableResults{j,{'taskNameNumber'}}{1})
            markerIn = j;
            segmentStart = tableResults{markerIn,{'indicesLimits'}}{1}(1);
            minTRgroup = tableResults{markerIn,{'minTROriginal'}};
            flagInOut = 1;
        end
    end
    
    if flagInOut
        if ~iscell(tableResults{j,{'taskNameNumber'}}{1})
            markerOut = j-1;
            segmentEnd = tableResults{markerOut,{'indicesLimits'}}{1}(2);
            flagInOut = 0;
            flagAdd = 1;
        else
            minTRgroup = [minTRgroup tableResults{j,{'minTROriginal'}}];
        end
    end
    
    if markerIn < markerOut && flagAdd == 1
        addRow = tableResults(markerIn,:);
        
        tempCell = minTRgroup;
        
  
        tempCellCopy = tempCell;
        for s = 1:length(tempCell)-1
            if isequal(tempCell(s),tempCell(s+1))
                tempCellCopy(s+1) = [];
            end
        end
        
        tempCellCopy2 = tempCellCopy;
        concatCell = {};
        for q = 1:length(tempCellCopy2)
            temp1 = tempCellCopy2{q};
            for a = 1:length(tempCellCopy2{q})
                concatCell = [concatCell;temp1(a,:)];
            end
        end    
        concatCellArray = cell2mat(concatCell);
        
        addRow.minTROriginal = {concatCellArray};
               
        addRow.indicesLimits = [segmentStart segmentEnd];
        addRow.numberOfTR = length(concatCellArray);
        addRow.taskNameNumber = tableResults{markerIn,{'taskNameNumber'}}{1}(2);
        
        disp(addRow)
        
        tableResults = [tableResults;addRow];
        flagAdd = 0;
        numberOfTR = 0;
        tempCell = [];
    end
    
end

%   Here we create two structures. The first is tableReadyforExport, which
%   we will use to export everything. The second is passtoExport, which
%   will give us an indication on which line, from the tableResults file,
%   we will send to export.
passToExport = [];
for k=1:height(tableResults)
    if ~isequal(tableResults{k,{'taskName'}}{1},'Missing') || ~iscell(tableResults{k,{'taskNameNumber'}})
        passToExport = [passToExport k];
    end
end

%   Here we copy to the tableResults the passToExport array. We could have done
%   this a faster way then a loop, but never mind, since we did a loop
%   already.
passToExportTable = zeros(height(tableResults),1);
for u=1:height(tableResults)
    if ismember(u,passToExport)
        passToExportTable(u) = 1;
    end
end
tableResults.passToExport = passToExportTable;

%   And at the end, what we really need
tableCleaned = tableResults(passToExport,:);

%   Here, we add indices
for s=1:height(tableCleaned)
    disp('hello')
    tableCleaned.indexVector(s) = s;
end

end