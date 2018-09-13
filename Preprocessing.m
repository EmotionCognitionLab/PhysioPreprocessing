%   This script, written by Spiderman, came to help Mara Mather's lab at
%   USC. The purpose of this function is to help in orgzanizing data after
%   physio examinations. There are two outside python files that have to be
%   run before this script, in order for this script to run smoothly. More
%   explanation on the .py files ahead

%   Assignments left open: 
%   1)  Section 4.1: Get dictArray and tableResults to work together under
%   namingFunction3.m. Maybe something with Excel? Maybe GUI? I think I
%   solved it with uitable!
%   2)  Checking if the file actions I scattered all over the place work. If
%   they work, I can evens start thinking about discarding the folder
%   prompts. Maybe if we try-catch it, this option might work: The 'try'
%   part will be automatic and the catch will be manual.
%   3)  In extractChannels.m, can we improve the function? I think we can
%   at least pull outside the tableResults.
%   4)  Write comments for section 3, segmenationToTasks and also the
%   BatchPart2 file.
%   5)  Add comments to last functions
%   6) Complete section in Stage8.
%   7) indexTROriginal comes out as a cell, not as an array. This might
%   actually be okay, since I don't want easy access to that original
%   value.
%   8) Maybe I should have all the foldername input at the beginning?
%   9) I should do Stage3 onwards, since I changed a column name in
%   tableCleaned.
%   10) I need to see if I can make just one function for the final
%   analysis at the ending (sections 8 and 9). I think that I can do it,
%   but I need to check. Maybe if I just input the task name and channel!
%   For now, I just analyse to the Stage8 folder, then rename it, and then,
%   if I want to make another analysis, I do it again using a new Stage8
%   folder.
%   11) How do I incorporate the Excel sheet for the inputs?
%   12) Inside findEdges.m, I need to find a solution for the case in which
%   we have extended data inside.
%   13) We need to use another function from before, the one that allows
%   narrowing and widening of the segments before cutting them. We probably
%   need that to be inside tableClean or something, for each segment! Then
%   we need to remember that while extracting the segments.
%   14) We need to prepare the script for Shelby's information. To do that,
%   I started working on the single-file track. After I finish that, I need
%   to change the multi-track, and then run QA on both Jun's files and
%   Shelby's files.

%%  Cleaning data and preparing folders

clear
clc

try
    %   Choose the folder that will contain all the files
    while 1
        filepath0 = uigetdir;
        if ~isequal(filepath0,0)
            cd(filepath0);
            break
        else
            disp('Please choose a folder')
        end
    end

    %   We should check if the following works
%     mkdir(filepath0,'Stage1')
    mkdir(filepath0,'Stage2')
    
    mkdir(filepath0,'Stage3')
    mkdir([filepath0,'Stage3'],'files')
    mkdir([filepath0,'Stage3'],'figures')
    
    mkdir(filepath0,'Stage5')
    mkdir(filepath0,'Stage6')
    mkdir(filepath0,'Stage7')
    
    mkdir(filepath0,'Stage8')
    mkdir([filepath0,'Stage8'],'data')
    mkdir([filepath0,'Stage8'],'figures')
    mkdir([filepath0,'Stage8'],'raw')
    
    mkdir([filepath0,'Stage8'],'interpolationData')
%     mkdir([filepath0,'Stage8'],'interpolationFigures')

    %   End of check
catch
    disp('Creating folders was not successful')
end

%%  Stage 0.0
%   Run acq2matGeneral.py

%   Convert acq files to disorganized .mat files

while 1
    flagStage0 = input(['Have you converted the files from acq to .MAT?\n' ...
        'Press 1 for yes, and 2 for no\n']);
    if flagStage0 == 1
        break
    elseif flagStage0 == 2
        disp('Please convert and pass the files into the Stage1 folder')
    else
        disp('Not a legal response')
    end
end

%%  Stage 1
%   Inputs

%   Choose the folder that contains the disorganized .mat files.
try
    
    filepath1 = [filepath0,'/Stage1'];
    cd(filepath1);
    
catch

    while 1
        filepath1 = uigetdir;
        if ~isequal(filepath1,0)
            cd(filepath1);
            break
        else
            disp('Please choose a folder')
        end
    end
    
end

%   Here we list all the files in the folder and create a copy for backup.
listing1 = dir(filepath1);
copylisting = listing1;

%   Moving from structure 2 cell
cellFromStruct = struct2cell(listing1);

%   Now we need to extract a cell with all the names of the subjects. So
%   first we take the size of the listing.
sizeListing = size(cellFromStruct)-2;
sizeListing = sizeListing(2);
subjectNumbersStr = cell(sizeListing,1);

%   Track success in the different stages of this script. The amount of
%   columns are as the amount of files that are in the main file. The
%   amount of columns are as the amount of stages we have.
successArray = zeros(sizeListing,5);

%   Going inside the loop to take the names of the participants. Notice: 
%   files in the folder are supposed to be organized matlab files that were
%   just converted from the python script.
for i=1:sizeListing
    try
        listingName = cellFromStruct(1,3:end);
        subjectNumbersStr{i} = listingName{i}(1:4);
        successArray(i,1) = 1;
    catch
        successArray(i,1) = 0;
        error(['Problem with file number ', num2str(i)]);
    end
end
    
%   Our first step is to take the length of the files we succeeded to take
%   from th elisting.
L = length(subjectNumbersStr);

%   Add a suffix to recognize disorganizeded .mat files
suffixMiddle = input('What name appears before _matlabVersion.mat\n','s');
suffix = ['_' suffixMiddle '_matlabVersion.mat'];

%   Also, converting the participant numbers from strings to numbers. That
%   will help us keeping track on where some of the stages went wrong. It
%   will be placed in the 2nd column of our successArray. There might be
%   more numbers in the first column of that array, but it doesn't matter,
%   since there couldn't be less. L is always smaller than the number of
%   files in the folder we choose at the beginning.
for i = 1:L
    successArray(i,2) = str2double(cell2mat(subjectNumbersStr(i)));
end

%%  Stage 2
%   Running extractData.m

%   Choose the folder that will the organized .mat files.
try
    
    filepath2 = [filepath0,'/Stage2'];
    cd(filepath2);
    
catch
    
    while 1
        filepath2 = uigetdir;
        if ~isequal(filepath2,0)
            cd(filepath2);
            break
        else
            disp('Please choose a folder')
        end
    end
    
end

%   Loop for conversion
%   We set the right filename, and then we extract data to arrays. Then we
%   save it all. Afterwards, we clear the unneeded variables and start
%   again. If we have any problems, they are registered in the successArray
%   we had created, in the 3rd column.

for i=1:L
    filename_2 = [subjectNumbersStr{i} suffix];
%     try
        [data, labels, channelTR, units] = extractData([filepath1,'/', filename_2]); 
        
        %   Last minute addition. I need the labelList variable for Stage7
        if i == 1
            labelList = labels;
        else
            for p = 1:length(labels)
                if max(contains(labelList,labels(p))) == 1
                    labelList = [labelList labelps(p)];
                end
            end
        end
        %   Last minute addition. I need the labelList variable for Stage7
        
        participantNumber = subjectNumbersStr{i};
        save([subjectNumbersStr{i} '_SegmentationReady' suffix],'data','labels','units', ...
           'channelTR','participantNumber','-v7.3')
        
       try  
           % We should check if the following works
           source21 = [filepath2 '/' [subjectNumbersStr{i} '_SegmentationReady' suffix]];
           destination21 = [filepath0 '/' 'Stage2'];
           movefile(source21,destination21)
            % end of check
       catch
           disp('Move was not successful')
       end

        clearvars data labels units channelTR participantNumber;
        successArray(i,3) = 1;        
%     catch
%         disp([filename_2 ' did not pass']);
%         successArray(i,3) = 0;
%     end
end
save('stage2Finished.mat')

try
    % We should check if the following works. Maybe consider just using cd
    % in to the folder that you want to save in, and cd out to come back to
    % the current folder.
    pwd
    currentFolder22 = pwd;
    source22 = [currentFolder22 '/stage2Finished.mat'];
    destination22 = filepath0;
    movefile(currentFolder22,destination22)
    % end of check
catch
    disp('Move was not successful')
end

clearvars -except L successArray subjectNumbersStr suffix filepath0 labelList

%%  Stage 3 - 01

%   Run googleDocsMRI.py

%   Extract important data form the MRI form

%%  Stage 3 - 02
%   First we need the .csv file we extracted from the googleDocsMRI.py
%   script. We need to know the number of tasks in each valid experiment
%   run. Let's find it.
filename1 = uigetfile;

%   Then we read the file.
googleSheetWeek7 = readtable(filename1);

%   And create dictArray. You will need it to see if there was any mismatch
%   between the number of reported TRs and number of real TRs
[dictArray] = namingFunction(googleSheetWeek7);

uf0 = uifigure;
t0 = uitable(uf0,'Data',dictArray);


%%  Stage 3 - 1
%   Running segmentationToTasks.m

%   Now we take the files that we saved in the previous session, and,
%   one-by-one, we start dividing them to channels. At the beginning of each
%   file, we will get a plot to decide on some parameters which are needed
%   for our analysis. Notice: we are only able, here, to divide the big
%   file into pieces, but we can't still say what those pieces are. This
%   will come in a later stage.

%   First, we load the folder that holds the segmenationReady files
try
    
    filepath3 = [filepath0,'/Stage3'];
    cd(filepath3);
    
catch

    while 1
        filepath3 = uigetdir;
        if ~isequal(filepath3,0)
            cd(filepath3);
            break
        else
            disp('Please choose a folder')
        end
    end
    
end

%   We give two options here: One is file-by-file analysis, which finishes
%   the entire segmentation on one file before it starts dealing with the
%   next file. The second is batch analysis, which follows the same
%   procedure as the first analysis, just that it lets the user examine and
%   input all the variables he or she wants to insert at the beginning,
%   before getting in into the files.

while 1
    crossRoad = input('Do you want to go file by file, or to process the files in batch? \nPress 1 for file by file or 2 for batch\n');
    if crossRoad == 1
        %   Now we load the files one by one to the workspace, and perform the
        %   special function segmenataionToTasks. We use the previously created
        %   filename to load the files. We also set up the beginning of a mechanism
        %   to name the labels. We save some important parameters to the cell
        %   function tableResults. We will use tableResults in stage 5. Notice that
        %   we only take lines 1 to 4, and 6 to 8 in the dataGroups structure. The
        %   reason for this is that row 5 contains all the tasks from a specific
        %   assignment, and if we gather all these segments in one place, it might
        %   take a lot of space, too much space.
        for m=1:L
            filename_3 = [subjectNumbersStr{m} '_SegmentationReady' suffix];
%             try
                struct1 = load(filename_3, 'data', 'labels','channelTR','participantNumber');
                data = struct1.data;
                labels = struct1.labels{:};
                channelTR = struct1.channelTR;
                participantNumber = struct1.participantNumber;
                [dataGroups,flagAnalysis,specialSeeFlag,tableTRdata,minOrMax] = segmenationToTasks(data,channelTR,participantNumber);
                
                if flagAnalysis == 2
                    
                    successArray(m,4) = 2;
                    disp('Continuing to next file')
                    
                else
                
                    if m == 1
                        tableResults = dataGroups(:,[1:6,8:12]);
                    else
                        tableResults = [tableResults; dataGroups(:,[1:6,8:12])];
                    end
                    save([subjectNumbersStr{m} '_cutToSegments' suffix],'labels','channelTR','dataGroups','tableTRdata','minOrMax','-v7.3')
                    clearvars dataGroups lables data channelTR minOrMax
                    
                    % We should check if the following works
                    source3 = [filepath3 '/' [subjectNumbersStr{m} '_cutToSegments' suffix]];
                    destination3 = [filepath0 '/' 'Stage3'];
                    movefile(source3,destination3)
                    % end of check
                    
                    successArray(m,4) = 1;
                    successArray(m,5) = specialSeeFlag;
                end
                
%             catch
%                 disp('Something went wrong')
%                 successArray(m,4) = 0;
%             end
        end
        break
        
    elseif crossRoad == 2
       for a = 1:L
            filename_3 = [subjectNumbersStr{a} '_SegmentationReady' suffix];
            try
                struct1 = load(filename_3, 'data', 'labels','channelTR','participantNumber');
                data = struct1.data;
                labels = struct1.labels{:};
                channelTR = struct1.channelTR;
                participantNumber = struct1.participantNumber;
                [dataGroupsBatch1, flagAnalysis, specialSeeFlag,minOrMax] = segmentationToTasksBatchPart1(data,channelTR,participantNumber);
                
                
                if flagAnalysis == 2
                    
                    successArray(a,4) = 2;
                    disp('Continuing to next file')
                    
                else
                    
                    if a == 1
                        tableResultsBatch1 = dataGroupsBatch1;
                    else
                        tableResultsBatch1 = [tableResultsBatch1; dataGroupsBatch1];
                    end

                    successArray(a,4) = 1/2;
                    successArray(a,5) = specialSeeFlag;
                end

                clearvars dataGroupsBatch1 data channelTR struct1
                
            catch
                disp('Something went wrong in stage 3-1-1')
                successArray(a,4) = 0;
            end

       end
       
       for b=1:height(tableResultsBatch1)
           
           try
               participantNumber = tableResultsBatch1{b,1}{1};

               tableResultsBatch2 = segmentationToTasksBatchPart2(participantNumber,tableResultsBatch1,b,suffix,filepath0,filepath3,minOrMax);
               
               if b == 1
                    tableResults = tableResultsBatch2(:,[1:6,8:12]);
               else
                    tableResults = [tableResults; tableResultsBatch2(:,[1:6,8:12])];
               end
               successArray(b,4) = 1;

               clearvars tableResultsBatch2 channelTR
               
           catch   
               disp('Something went wrong in stage 3-1-2')
               successArray(b,4) = 0;  
           end

       end
       break
       
    else
        disp('Not a legal entry');

    end
end

save('stage3Finished.mat')

try
    % We should check if the following works
    pwd
    currentFolder32 = pwd;
    source32 = [currentFolder32 '/stage3Finished.mat'];
    destination32 = filepath0;
    movefile(source32,destination32)
    % end of check
catch
    disp('Move was not successful')
end

clearvars -except L successArray subjectNumbersStr suffix tableResults googleSheetWeek7 dictArray filepath0 labelList minOrMax
save('beforeStage4.mat')
%   Very important to have, after this section, the successArray and the
%   tableResults. The tableResults is especially important.

%%  Stage 4.0
%   Another function, namingFunction2 handles the actual naming of the
%   files. It does the heavy lifting, although, to be honest, the
%   tableResults really does a lot for us.

uf1 = uifigure;
t1 = uitable(uf1,'Data',dictArray);

uf2 = uifigure;
t2 = uitable(uf2,'Data',tableResults);

[tableResults,dictArray,responseBackup] = namingFunction2(dictArray,tableResults);

save('beforeStage41.mat')
close(t2)
close(t1)

try
    % We should check if the following works
    pwd
    currentFolder41 = pwd;
    source41 = [currentFolder41 '/beforeStage41.mat'];
    destination41 = filepath0;
    movefile(source41,destination41)
    % end of check
catch
    disp('Move was not successful')
end

%%  Stage 4.1

[tableResults,dictArray,tableCleaned] = namingFunction3(dictArray,tableResults);

save('beforeStage5.mat','tableResults','dictArray','successArray','tableCleaned', 'filepath0')

try
    % We should check if the following works
    pwd
    currentFolder42 = pwd;
    source42 = [currentFolder42 '/beforeStage5.mat'];
    destination42 = filepath0;
    movefile(source42,destination42)
    % end of check
catch
    disp('Move was not successful')
end

%%  Stage 5
%   Exporting everything to different files

%   Here a cut on all the data according to tableCleaned.

%   Remember: for cap we need the right index to be 12*(10^4) to the
%   right, becuase we want to take 12 more seconds of everything. That's
%   why it is crucial to have information about the labels.

%   Here we choose the folder named Stage2
try
    
    filepath5 = [filepath0,'/Stage2'];
    cd(filepath5);
    
catch

    while 1
        filepath5 = uigetdir;
        if ~isequal(filepath5,0)
            cd(filepath5); 
            break
        else
            disp('Please choose a folder')
        end
    end
    
end
    
for a = 1:height(tableCleaned)
    [taskAllChannelsExact,taskAllChannelsWithAddition,taskLabels] = roughSegmentationFinerCut(tableCleaned{tableCleaned.indexVector(a),'participantNumber'}{1},tableCleaned{tableCleaned.indexVector(a),'indicesLimits'}{1});
    nameOfFile = cell2mat([tableCleaned{a,{'taskName'}}(1),'_allChannels_participant_',tableCleaned{a,{'participantNumber'}}{1},'_post.mat']);
    tableCleanedIndex = tableCleaned.indexVector(a);
    save(nameOfFile,'taskAllChannelsExact','taskAllChannelsWithAddition','taskLabels','tableCleaned','dictArray','tableCleanedIndex','labelList');
    try
        % We should check if the following works
        source5 = [filepath5 '/' nameOfFile];
        destination5 = [filepath0 '/Stage5'];
        movefile(source5,destination5)
        % end of check
    catch
        disp('Move was not successful')
    end
end


%%  Stage 6
%   Run cuttingBigFilesToPieces.m

%   Here we divide the big file into channels.

%   Remember: TR doesn't get its own channel. Nevertheless, it is 
%   added to each other channel.
%   Choose the folder that contains the organized .mat files.
try

    filepath6 = [filepath0,'/Stage5'];
    cd(filepath6);
    
catch
    
    while 1
        filepath6 = uigetdir;
        if ~isequal(filepath6,0)
            cd(filepath6);
            break
        else
            disp('Please choose a folder')
        end
    end
    
end

%   Here we list all the files in the folder and create a copy for backup.
listing3 = dir;
copylisting = listing3;

listing3(1) = [];
listing3(1) = [];

extractChannels(listing3,filepath0,filepath6)

%%  Stage 7
%   Run organizeToFolder.m

%   Choosing a folder
try

    filepath7 = [filepath0,'/Stage6'];
    cd(filepath7);
    
catch

    while 1
        filepath7 = uigetdir;
        if ~isequal(filepath7,0)
            cd(filepath7);
            break
        else
            disp('Please choose a folder')
        end
    end
    
end

%   Here we list all the files in the folder and create a copy for backup.
listing4 = dir;
copylisting = listing4;

listing4(1) = [];
listing4(1) = [];

organizeToFolders(dictArray,labelList,listing4,filepath0,filepath7)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  From here on:
%   It's about analysis.


%%  Stage 8 - 0
%   Run findEdges.m

%   In the following stage:
%   Query files to populate the raw data folder, and then choose it.

while 1
    flagQuery1 = input(['Have you copied the files you are interested at to ' ...
        '\nthe raw and to the data folders inside the Stage8 folder?' ...
        '\nPress 1 to continue\n']);
    if flagQuery1 == 1
        break
    else
        disp('Please perform the query')
    end
end

%   Transfer interest files to Stage8/raw and Stage8/data
%   Choosing folder with data to work on it.
try
    
    filepath80 = [filepath0,'/Stage8/data'];
    cd(filepath80);
    
catch

    while 1
        filepath80 = uigetdir;
        if ~isequal(filepath80,0)
            cd(filepath80);
            break
        else
            disp('Please choose a folder')
        end
    end
    
end

listing5 = dir;
copylisting = listing5;

listing5(1) = [];
listing5(1) = [];

listAnalysis = findEdges(listing5, filepath0, filepath80);


%%  Stage 8 - 1
%   Interpolate
%   Run Edges

%   Transfer interest files to Stage8/raw and Stage8/data
%   Choosing folder with raw data
try
    
    filepath81 = [filepath0 '/Stage8/data'];
    cd(filepath81);

catch

    while 1
        filepath81 = uigetdir;
        if ~isequal(filepath81,0)
            cd(filepath81);
            break
        else
            disp('Please choose a folder')
        end
    end
    
end

listing6 = dir;
copylisting = listing6;

listing6(1) = [];
listing6(1) = [];

interpolatePieces(listing6, filepath0, filepath81)

