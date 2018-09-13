function [xMinValuesIntersect,yMinValuesIntersect] = intersectMinValues(data,thresholdPool,upper1)

xMinValuesIntersect = findMinThreshold(data,thresholdPool{1});
for s=2:upper1-1
    xMinValuesIntersectInstance = findMinThreshold(data,thresholdPool{s});
    xMinValuesIntersect = intersect(xMinValuesIntersect,xMinValuesIntersectInstance);
end
yMinValuesIntersect = [];
T = length(xMinValuesIntersect);
for a=1:T
    yValue = data(xMinValuesIntersect(a));
    yMinValuesIntersect = [yMinValuesIntersect yValue];
end
end