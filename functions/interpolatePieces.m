function [] = interpolatePieces(listing, filepathOrigin, filepathStage)

cellFromStruct = struct2cell(listing);
sizeListing = size(cellFromStruct);
T = sizeListing(2);

for i = 1:T
            
    filename = cellFromStruct{1,i};
    
    try
        
        load(filename,'indexTROriginal','indexTRCurrent','smallChannelLabel', ...
            'subjectNumberStr','taskNameStr','data','TR','localEdgesIndex1', ...
            'interestPoints1')
        minTROriginal = indexTROriginal;
        minTRCurrent = indexTRCurrent;
                
    catch

        load(filename,'minTROriginal','minTRCurrent','smallChannelLabel', ...
            'subjectNumberStr','taskNameStr','data','TR','localEdgesIndex1', ...
            'interestPoints1')
        
    end
    
    interpolationArray = interp1(localEdgesIndex1,interestPoints1,minTRCurrent(:,2));
    interpolationArray = [interpolationArray minTRCurrent(:,2)];
        
    figure(str2double([subjectNumberStr '011']))

    subplot(2,1,1)
    plot(data)
    hold on
    plot(localEdgesIndex1,interestPoints1,'g*')
    plot(interpolationArray(:,2),interpolationArray(:,1),'b*')
    hold off
    
    subplot(2,1,2)
    plot(TR)
    hold on
    plot(minTRCurrent(:,2),minTRCurrent(:,1),'r*')
    hold off
    
%     cd([filepathOrigin '/Stage8/interpolationFigures'])
%     mkdir([subjectNumberStr '_' taskNameStr '_' smallChannelLabel])
    cd([filepathOrigin '/Stage8/figures/' [subjectNumberStr '_' taskNameStr '_' smallChannelLabel]])
    
    savefig([subjectNumberStr '011'])
    
    close(figure(str2double([subjectNumberStr '011'])))
    
    cd(filepathStage)
    save(filename,'interpolationArray','-append')
    
    filename2 = [taskNameStr '_' smallChannelLabel 'Max_Itp_' subjectNumberStr '.mat'];
    save(filename2,'data','minTRCurrent','TR','interpolationArray')
    
    source81 = [filepathStage '/' filename2];
    destination81 = [filepathOrigin '/Stage8/interpolationData'];
    movefile(source81,destination81)
            
end

end
    
    
        
        
        
        