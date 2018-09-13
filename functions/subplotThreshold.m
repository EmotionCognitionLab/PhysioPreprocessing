function [] = subplotThreshold(data,thresholdFunction)
[xMinValues,yMinValues] = findMinThreshold(data,thresholdFunction);
T = length(xMinValues);
plot(xMinValues(1),yMinValues(1),'r*')
hold on
for j=2:T
    plot(xMinValues(j),yMinValues(j),'r*');
end
plot(data)
try
    fplot(poly2sym(thresholdFunction),'Linewidth',1);
catch
    fplot(thresholdFunction,'Linewidth',1);
end
hold off
end