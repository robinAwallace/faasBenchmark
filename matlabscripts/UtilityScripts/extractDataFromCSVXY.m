function [x,y] = extractDataFromCSVXY(fileName,xColumn,yColumn,scale,format)
%EXTRACTDATAFROMCSV Summary of this function goes here
%   Detailed explanation goes here
    T=readtable(fileName,'Format',format);
    x = T{:,xColumn}*scale;
    y = T{:,yColumn}*scale;
end