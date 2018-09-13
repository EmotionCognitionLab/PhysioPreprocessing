function [thresholdFunction]=buildPolynomial(numberOfLines)

thresholdFunctionTemp = cell(numberOfLines,1);
thresholdFunction = cell(numberOfLines,1);

for k=1:numberOfLines
    while 1
        segmentNumbers = input(['Function number ',num2str(k), ...
            '\nHow many parts do you want the function to have?' ...
            '\nPress 1 for polynomial function' ...
            '\nPress 2 and above for segmentated polynomial function\n']);
                
        if segmentNumbers == 1
            
            highestPower = input(['What is the highest power presented in ' ...
                        'the polynomial?\n']);

            if highestPower >= 0
                thresholdPoolCoefficient = zeros(1,highestPower+1);
                for i=1:length(thresholdPoolCoefficient)
                    while 1
                        thresholdPoolCoefficient(i) = input(['What is the coefficient of the ' ...
                            num2str(highestPower+1-i),' power in the polynomial\n']);
                        if ischar(thresholdPoolCoefficient(i))
                            disp('Invalid entry. Entry must be a non negative numberic number')
                        else
                            break
                        end
                    end
                end
                thresholdFunction{k} = thresholdPoolCoefficient;

                break
            end

        elseif segmentNumbers > 1
            
            coefs = zeros(1,segmentNumbers);

            thresholdFunctionTemp{k,1} = zeros(1,segmentNumbers);
            thresholdFunctionTemp{k,2} = [];

            for j=1:segmentNumbers
                                   
                segmentIndexEnd = input([ ...
                    'Function number ',num2str(k), ...
                    '\nSegment number ',num2str(j), ...
                    '\nWhere do you want the segment to end?\n']);
                    
                thresholdFunctionTemp{k,1}(j) = segmentIndexEnd;
                
                highestPower = input([ ...
                    'What is the highest power presented in ' ...
                    '\nFunction number ',num2str(k), ...    
                    '\nSegment number ',num2str(j), ...
                    '\nthe segmentated polynomial?\n']);
                
                if highestPower >= 0
                    thresholdPoolCoefficient = zeros(1,highestPower+1);
                    for i=1:highestPower+1
                        
                        while 1
                            thresholdPoolCoefficient(i) = input(['What is the coefficient of the ' ...
                                num2str(highestPower+1-i),' power in the polynomial\n']);
                            if ischar(thresholdPoolCoefficient(i))
                                disp('Invalid entry')
                            else
                                break
                            end
                        end
                        
                    end
                    
                    thresholdFunctionTemp{k,2} = [thresholdFunctionTemp{k,2}; thresholdPoolCoefficient];
                    
                else

                    disp('Not a legal choice')

                end
            
            end
            
            breaks = [0 thresholdFunctionTemp{k,1}];
            coefs = thresholdFunctionTemp{k,2};
            thresholdFunction{k} = mkpp(breaks,coefs);
            
            break
            
        else
            
            disp('not a legal choice')
            
        end
        
    end
end