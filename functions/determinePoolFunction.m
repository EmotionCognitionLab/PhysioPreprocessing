%% Function
function [thresholdPool] = determinePoolFunction(minDataValue,maxDataValue,numberOfLines)
% thresholdPool = cell(1,numberOfLines);

fprintf(['Here you will create the functions that will be used as thresholds. \n' ...
    'You have ', num2str(numberOfLines) ' functions to create.\n' ...
    'Lets begin.\n']); 
while 1
    choiceMenu = input(['What kind of function do you want to use as threshold?' ...
        '\nPress 1 for normally distributed lines between ',num2str(minDataValue),' and ',num2str(maxDataValue), ...
        '\nPress 2 for to create your own polynomial segmentated function\n']);
    if choiceMenu == 1

        thresholdPool = zeros(1,numberOfLines);
        if numberOfLines > 0
            thresholdPoolInclMaxMin = linspace(minDataValue,maxDataValue,numberOfLines+2);
            thresholdPool = thresholdPoolInclMaxMin(2:(length(thresholdPoolInclMaxMin)-1));
        end
        break
        
    elseif choiceMenu == 2
        thresholdPool = buildPolynomial(numberOfLines);
        break
        
    else
        disp('Invalid keystroke')
    end
end




end