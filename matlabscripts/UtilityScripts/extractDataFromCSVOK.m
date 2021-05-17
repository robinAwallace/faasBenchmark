function [value] = extractDataFromCSVOK(fileName,column,scale,format)
%EXTRACTDATAFROMCSV Summary of this function goes here
%   Detailed explanation goes here
    T=readtable(fileName,'Format',format);
    T(T.status_code > 200,:) = [];
    value = T{:,column}*scale;   
end

