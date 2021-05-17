function [xO,ok,xE,error] = extractDataFromCSVXYOKError(fileName,xColumn,yColumn,scale,format)
%EXTRACTDATAFROMCSV Summary of this function goes here
%   Detailed explanation goes here
    T=readtable(fileName,'Format',format);
    
    tmp = T;
    tmp(T.status_code > 200,:) = [];
    T(T.status_code == 200,:) = [];
    
    ok = tmp{:,yColumn}*scale;
    xO = tmp{:,xColumn}*scale;
    
    error = T{:,yColumn}*scale; 
    xE = T{:,xColumn}*scale;
end