function [listAnalysis] = findEdges(listing, filepathOrigin, filepathStage)

cellFromStruct = struct2cell(listing);
sizeListing = size(cellFromStruct);
T = sizeListing(2);

listAnalysis = cell(T,2);

for i = 1:T
            
    filename = cellFromStruct{1,i};
    listAnalysis{i,1} = filename;

    try
        load(filename,'data','data2','subjectNumberStr','smallChannelLabel','taskNameStr')
    catch
        load(filename,'data','subjectNumberStr','smallChannelLabel','taskNameStr')
    end

    while 1
        if ishandle(str2double([subjectNumberStr '001']))
            close(figure(str2double([subjectNumberStr '001'])))
        end

        figure(str2double([subjectNumberStr '001']))
        plot(data)

        while 1

            disp(['File details: ' subjectNumberStr '_' smallChannelLabel '_' taskNameStr])

            flagContinue = input(['Press 1 if the plot fits direct analysis\n' ...
                'Press 2 if the plot fits segmentated analysis\n' ...
                'Press 3 if the plot does not fit normal analysis\n']);

            if flagContinue == 1
                
                while 1
                    minOrMax1 = input('Press 1 to find max points, or 2 to find min points\n');
                    if minOrMax1 == 1
                        typeAnalysis = 'max';
                        break
                    elseif minOrMax1 == 2
                        typeAnalysis = 'min';                        
                        break
                    else
                        disp('Not a legal keystroke')
                    end
                end

                cd([filepathOrigin '/Stage8/figures'])
                mkdir([subjectNumberStr '_' taskNameStr '_' smallChannelLabel '_' typeAnalysis])

                cd([filepathOrigin '/Stage8/figures/' [subjectNumberStr '_' taskNameStr '_' smallChannelLabel '_' typeAnalysis]])

                while 1
                    numberOfLines1 = input('How many threshold functions do you want to use?\n');
                    if numberOfLines1 == 0
                        exitScript()
                    else
                        if numberOfLines1 > 0
                            break
                        else
                            disp('Not a legal keystroke')
                        end
                    end
                end

                if minOrMax1 == 1
                    [localMax1,localMaxIndex1] = aboveThreshold(numberOfLines1,data);

                    figure(str2double([subjectNumberStr '001']))
                    hold on
                    plot(localMaxIndex1,localMax1,'r*')
                    hold off

                elseif minOrMax1 == 2

                    [localMin1,localMinIndex1] = belowThreshold(numberOfLines1,data);

                    figure(str2double([subjectNumberStr '001']))
                    hold on
                    plot(localMinIndex1,localMin1,'b*')
                    hold off

                end

                flagOutLoop1 = input(['Are you happy with the points found?\n' ...
                    'Press 1 to continue or Press 2 to replot the figure\n']);

                if flagOutLoop1 == 1
                    figname1 = [subjectNumberStr '001'];

                    savefig(figname1)

                    cd(filepathStage)
                    if minOrMax1 == 1
                        save(filename,'localMax1','localMaxIndex1','-append')
                    elseif minOrMax1 == 2
                        save(filename,'localMin1','localMinIndex1','-append')
                    end
                    break

                elseif flagOutLoop1 == 2
                    
                    cd([filepathOrigin '/Stage8/figures'])
                    rmdir([subjectNumberStr '_' taskNameStr '_' smallChannelLabel '_' typeAnalysis])

                else
                    disp('Not a valid response')

                end
                break
                
            elseif flagContinue == 2

                while 1
                    segmentNumber = input('How many segments do you want to cut the function to?\n');
                    if segmentNumber > 1
                        break
                    else
                        disp('Please choose a number bigger than 1')
                    end
                end
                
                segmentBoundariesStart = 1;
                segmentBoundariesEnd = length(data);
                
                figure(str2double([subjectNumberStr '001']))
                hold on
                plot([segmentBoundariesStart segmentBoundariesStart],get(gca,'YLim'))
                plot([segmentBoundariesEnd segmentBoundariesEnd],get(gca,'YLim'))
                hold off
                
                segmentBoundariesLength = segmentNumber + 1;
                segmentIndex = zeros(segmentBoundariesLength,1);
                segmentIndex(1) = segmentBoundariesStart;
                segmentIndex(segmentBoundariesLength) = segmentBoundariesEnd;
                
                for a = 2:segmentBoundariesLength-1
                    while 1
                        
                        segmentIndex(a) = input(['Where do you want to cut the plot?' ...
                            '\nNotice: if you want to find minimum points, ' ... 
                            '\nplease choose points and threshold functions, ' ... 
                            '\nsuch that the the function is rising. ' ...
                            '\nVise versa is also true: if you want to find ' ...
                            '\nmaximum points, please choose points and threshold ' ...
                            '\nfunctions such that the function is declining\n']);
                        
                        if segmentBoundariesStart<segmentIndex(a)<segmentBoundariesEnd
                            break
                        else
                            disp('Not a valid choice')
                        end
                    end
                    
                    figure(str2double([subjectNumberStr '001']))
                    hold on
                    plot([segmentIndex(a) segmentIndex(a)],get(gca,'YLim'))
                    hold off
                    
                end
                                
                while 1
                    minOrMax1 = input('Press 1 to find max points, or 2 to find min points\n');
                    if minOrMax1 == 1
                        typeAnalysis = 'max';
                        segmentsValueMax = cell(1,segmentNumber);
                        segmentsIndexMax = cell(1,segmentNumber);
                        break
                    elseif minOrMax1 == 2
                        typeAnalysis = 'min';  
                        segmentsValueMin = cell(1,segmentNumber);
                        segmentsIndexMin = cell(1,segmentNumber);
                        break
                    else
                        disp('Not a legal keystroke')
                    end
                end
                    
                cd([filepathOrigin '/Stage8/figures'])
                mkdir([subjectNumberStr '_' taskNameStr '_' smallChannelLabel '_' typeAnalysis])

%                 cd([filepathOrigin '/Stage8/figures/' [subjectNumberStr '_' taskNameStr '_' smallChannelLabel '_' typeAnalysis]])
                
                for b = 1:segmentNumber
                    dataTemp = data(segmentIndex(b):segmentIndex(b+1));
                    
                    while 1
                    
                        cd([filepathOrigin '/Stage8/figures/' [subjectNumberStr '_' taskNameStr '_' smallChannelLabel '_' typeAnalysis]])

                        mkdir(['segmentNumber_' num2str(b)]);
                        cd([filepathOrigin '/Stage8/figures' ...
                            '/' [subjectNumberStr '_' taskNameStr '_' smallChannelLabel '_' typeAnalysis] ...
                            '/' ['segmentNumber_' num2str(b)]])

                        while 1
                            disp([subjectNumberStr '_' taskNameStr '_' smallChannelLabel '_' typeAnalysis '_' num2str(b) '_of_' num2str(segmentNumber)])
                            numberOfLines1 = input('How many threshold functions do you want to use?\n');
                            if numberOfLines1 == 0
                                exitScript()
                            else
                                if numberOfLines1 > 0
                                    break
                                else
                                    disp('Not a legal keystroke')
                                end
                            end
                        end

                        if minOrMax1 == 1
                            [localMax1,localMaxIndex1] = aboveThreshold(numberOfLines1,dataTemp);
                            if b > 1
                                localMaxIndex1 = localMaxIndex1 + rememberIndexMax - 1;
                            end
                            rememberIndexMax = segmentIndex(b+1); 
                            
                            if 1 < b && b < segmentNumber
                                localMin1 = localMin1(2:length(localMin1)-1);
                                localMinIndex1 = localMinIndex1(2:length(localMinIndex1)-1);
                            elseif b == segmentNumber
                                localMin1 = localMin1(2:length(localMin1));
                                localMinIndex1 = localMinIndex1(2:length(localMinIndex1));
                            elseif b == 1
                                localMin1 = localMin1(1:length(localMin1)-1);
                                localMinIndex1 = localMinIndex1(1:length(localMinIndex1)-1);
                            end                      
                            
                            figure(str2double([subjectNumberStr '001']))
                            hold on
                            plot(localMaxIndex1,localMax1,'r*')
                            hold off

                        elseif minOrMax1 == 2

                            [localMin1,localMinIndex1] = belowThreshold(numberOfLines1,dataTemp);

                            if b > 1
                                localMinIndex1 = localMinIndex1 + rememberIndexMin - 1;
                            end
                            rememberIndexMin = segmentIndex(b+1); 
                            
                            if 1 < b && b < segmentNumber
                                localMin1 = localMin1(2:length(localMin1)-1);
                                localMinIndex1 = localMinIndex1(2:length(localMinIndex1)-1);
                            elseif b == segmentNumber
                                localMin1 = localMin1(2:length(localMin1));
                                localMinIndex1 = localMinIndex1(2:length(localMinIndex1));
                             elseif b == 1
                                localMin1 = localMin1(1:length(localMin1)-1);
                                localMinIndex1 = localMinIndex1(1:length(localMinIndex1)-1);
                            end
                                
                            figure(str2double([subjectNumberStr '001']))
                            hold on
                            plot(localMinIndex1,localMin1,'b*')
                            hold off

                        end

                        flagOutLoop2 = input(['Are you happy with the points found so far?\n' ...
                            'Press 1 to continue or Press 2 to replot the figure\n']);

                        if flagOutLoop2 == 1
                            
                            cd([filepathOrigin '/Stage8/figures/' [subjectNumberStr '_' taskNameStr '_' smallChannelLabel '_' typeAnalysis]])

                            figname1 = [subjectNumberStr '_segmentNumber_' num2str(b) '_001'];

                            savefig(figname1)
                            
                            if minOrMax1 == 1
                                segmentsValueMax{b} = localMax1;
                                segmentsIndexMax{b} = localMaxIndex1;
                            else
                                segmentsValueMin{b} = localMin1;
                                segmentsIndexMin{b} = localMinIndex1;
                            end
                            
                            break

                        elseif flagOutLoop2 == 2
                          
                            cd([filepathOrigin '/Stage8/figures' ...
                                '/' [subjectNumberStr '_' taskNameStr '_' smallChannelLabel '_' typeAnalysis]])
                            
                            rmdir(['segmentNumber_' num2str(b)])

                        else
                        
                            disp('Not a valid response')

                        end
                                                
                    end

                end
                
                flagOutLoop3 = input(['Are you happy with the points found for the entire figure?\n' ...
                            'Press 1 to continue or Press 2 to replot the figure\n']);

                if flagOutLoop3 == 1
                    figname1 = [subjectNumberStr '_allSegments_001'];
                                   
                    cd(filepathStage)
                    
                    if minOrMax1 == 1
                        save(filename,'localMax1','localMaxIndex1','segmentIndex','-append')
                    elseif minOrMax1 == 2
                        save(filename,'localMin1','localMinIndex1','segmentIndex','-append')
                    end 
                    
                    savefig(figname1)
                    break

                elseif flagOutLoop3 == 2
                    cd([filepathOrigin '/Stage8/figures'])
                    rmdir([subjectNumberStr '_' taskNameStr '_' smallChannelLabel '_' typeAnalysis])                    
                else
                    disp('Not a valid response')

                end
                
            elseif flagContinue == 3
                
                break
                
            else

                disp('Not a valid choice')

            end

            listAnalysis{i,2} = flagContinue;

        end
        break
        
    end
        
    
    close(figure(str2double([subjectNumberStr '001'])))


        
end

end