function [value] = extractDataFromCSV(fileName,column,scale,format)
%EXTRACTDATAFROMCSV Summary of this function goes here
%   Detailed explanation goes here
    T=readtable(fileName,'Format',format);
    value = T{:,column}*scale;   
end

