function [] = organizeToFolders(dictArray,labelList,listing,filepathOrigins,filepathData)

tasksNames = dictArray.tasksNames(1:height(dictArray)-1);

labelListNoTR = {};
for l=1:length(labelList)
    if ~contains(labelList{l},'TR')
        labelListNoTR = [labelListNoTR labelList{l}];
    end
end

sizeListing = size(listing);

transportedListing = table('Size',[sizeListing(1),2],'VariableTypes',{'string','double'},'VariableNames',{'taskName','marker'});
for a = 1:sizeListing(1)
    transportedListing.taskName(a) = listing(a).name;
end
transportedListing.marker = zeros(sizeListing(1),1);

for k = 1:length(tasksNames)
    mkdir([filepathOrigins '/Stage7'],tasksNames{k})
    mkdir([filepathOrigins '/Stage7/' tasksNames{k}],'otherFiles')
    
    for j=1:length(labelListNoTR)
        mkdir([filepathOrigins '/Stage7/' tasksNames{k}],labelListNoTR{j})
    
        for i = 1:sizeListing(1)
            listingName = listing(i).name;
            
            if contains(listingName,tasksNames{k})
                
                if contains(listingName,labelListNoTR{j})
                
                    source71 = [filepathData '/' listingName];
                    destination71 = [filepathOrigins '/Stage7/' tasksNames{k} '/' labelListNoTR{j}];
                    copyfile(source71,destination71)
                    
                    disp(['filename: ' listingName ' - copied'])
                    
                    transportedListing.marker(i) = 1;
                    
                end
                    
            end
            
        end
        
    end
        
end

notMoved = transportedListing.marker == 0;
notMovedTable = transportedListing(notMoved,:);

for l1=1:height(notMovedTable)
    listingNameNotMoved = notMovedTable{l1,1};
    
    for l2 = 1:length(tasksNames)
        if contains(listingNameNotMoved,tasksNames{l2})
            
            source72 = strcat(filepathData,'/',listingNameNotMoved);
            destination72 = [filepathOrigins '/Stage7/' tasksNames{l2} '/otherFiles'];
            copyfile(source72,destination72)
            
            disp(['filename: ' listingName ' - copied to other'])
            
        end
        
    end
    
end

end

