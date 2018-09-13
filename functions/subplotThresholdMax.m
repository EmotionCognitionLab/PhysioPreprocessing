function [] = subplotThresholdMax(data,thresholdFunction)
[xMaxValues,yMaxValues] = findMaxThreshold(data,thresholdFunction);
T = length(xMaxValues);
plot(xMaxValues(1),yMaxValues(1),'r*')
hold on
for j=2:T
    plot(xMaxValues(j),yMaxValues(j),'r*');
end
plot(data)
fplot(poly2sym(thresholdFunction),'Linewidth',1);
hold off
end