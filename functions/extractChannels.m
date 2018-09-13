function [] = extractChannels(listing,filepathOrigins,filepathData)

sizeListing = size(listing);
for i = 1:sizeListing(1)
    listingName = listing(i).name;
    struct1 = load(listingName);
    
    disp(struct1)
    
    if i == 1
        tableExport = struct1.tableCleaned;
        tableExport = sortrows(tableExport,{'taskName'}, 'ascend');
    end
   
    bigChannelValuesExact = struct1.taskAllChannelsExact;
    bigChannelValuesExt = struct1.taskAllChannelsWithAddition;
    bigChannelLabels = struct1.taskLabels;
    
    tableCleanedID = struct1.tableCleanedIndex;
    tableExportIndex = find(tableExport.indexVector == tableCleanedID);
    
    sizeLabels = size(bigChannelLabels); 
    taskName = tableExport.taskName{tableExportIndex};
    subjectNumber = tableExport.participantNumber{tableExportIndex};
    TRnumber = tableExport.numberOfTR(tableExportIndex);
    minTROriginal = tableExport.minTROriginal(tableExportIndex);
    minTRCurrent = minTROriginal{1};
    minTRCurrent(:,2) = minTRCurrent(:,2) - minTRCurrent(1,2) + 1;
    
    TRnotlabel = [];
    for j=1:sizeLabels(1)
        if contains(bigChannelLabels{j},'TR')
            TRlabel = j;
        else
            TRnotlabel = [TRnotlabel j];
        end
    end
    
    for k=1:length(TRnotlabel)
        
        fileNameFormCell = strcat(taskName,'_',bigChannelLabels{TRnotlabel(k)},'_',num2str(subjectNumber),'.mat');
        smallChannelLabel = bigChannelLabels{TRnotlabel(k)};
        subjectNumberStr = num2str(subjectNumber);
        taskNameStr = taskName;
        fileNameForm = fileNameFormCell;
        
        if contains(bigChannelLabels{TRnotlabel(k)},'Respiration')
            
            data = bigChannelValuesExact(:,TRnotlabel(k));
            TR = bigChannelValuesExact(:,TRlabel);
            data2 = bigChannelValuesExt(:,TRnotlabel(k));
            TR2 = bigChannelValuesExt(:,TRlabel);
            save(fileNameForm,'TR','TRnumber','minTROriginal','minTRCurrent','TR2','data','data2','smallChannelLabel','bigChannelLabels','tableExport','subjectNumberStr','taskNameStr','tableCleanedID');
                        
        % elseif ~contains(bigChannelLabels{TRnotlabel(k)},'TR')
        else
            
            data = bigChannelValuesExact(:,TRnotlabel(k));
            TR = bigChannelValuesExact(:,TRlabel);
            save(fileNameForm,'TR','TRnumber','minTROriginal','minTRCurrent','data','smallChannelLabel','bigChannelLabels','tableExport','subjectNumberStr','taskNameStr','tableCleanedID');
            
        end
        
%         try
            % We should check if the following works
            source6 = [filepathData '/' fileNameForm];
            destination6 = [filepathOrigins '/' 'Stage6'];
            movefile(source6,destination6)
            % end of check
%         catch
%             disp('Move was not successful')
%         end
        
        disp(['passed: channel ',num2str(TRnotlabel(k)),' in line ',num2str(i)])
        
    end
    
    clearvars -except sizeListing listing filepathData filepathOrigins tableExport

end
end
