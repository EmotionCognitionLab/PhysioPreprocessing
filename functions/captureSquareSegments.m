function tableGroupCleanStage2 = captureSquareSegments(table)

tableAmount = height(table);
flagFirst = 0;

for l = 2:tableAmount-1
    
    if table{l,2} ~= table{l-1,2} && table{l,2} ~= table{l+1,2}
        
        table{l,4} = 1;
    
    elseif flagFirst == 0 && table{l,2} == table{l+1,2}

        table{l,4} = 1;
        flagFirst = 1;
        
    elseif flagFirst == 1 && table{l,2} ~= table{l+1,2}

        table{l,4} = 1;
        flagFirst = 0;
        
    end

end

tableGroupCleanStage1 = array2table([table{1,:} ; table{table{:,4} == 1,:} ; table{height(table),:}]);
tableAmountStage1 = height(tableGroupCleanStage1);

tableGroupCleanStage1{1,4} = 1;
tableGroupCleanStage1{tableAmountStage1,4} = 1;

for r = 1:tableAmountStage1 - 1
    if tableGroupCleanStage1{r,3} == tableGroupCleanStage1{r+1,3}
        if tableGroupCleanStage1{r,3} == 1
            tableGroupCleanStage1{r+1,4} = 0;
        else
            tableGroupCleanStage1{r,4} = 0;
        end
    end
end
 
tableGroupCleanStage2 = array2table(tableGroupCleanStage1{tableGroupCleanStage1{:,4} == 1,:});

end