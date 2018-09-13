%% Function 06: Exit program
function [] = exitScript(~)
button = questdlg('Ready to exit script?','Exit Dialog','Yes','No','No');
switch button
    case 'Yes'
        disp('Exiting Beautifuly')
        error('You are out')
    case 'No'
        exit cancel;
end
end