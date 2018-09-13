function [xMaxValuesIntersect,yMaxValuesIntersect] = intersectMaxValues(data,thresholdPool,upper1)

xMaxValuesIntersect = findMaxThreshold(data,thresholdPool{1});
for s=2:upper1-1
    xMaxValuesIntersectInstance = findMaxThreshold(data,thresholdPool{s});
    xMaxValuesIntersect = intersect(xMaxValuesIntersect,xMaxValuesIntersectInstance);
end
yMaxValuesIntersect = [];
T = length(xMaxValuesIntersect);
for a=1:T
    yValue = data(xMaxValuesIntersect(a));
    yMaxValuesIntersect = [yMaxValuesIntersect yValue];
end
end