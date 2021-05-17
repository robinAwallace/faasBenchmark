function [] = workloadPlot(folder,frameworks,functionName,tests,extractFromFile,fun,plot)
%TEST Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(frameworks)
    for t=1:length(tests)
        fileFramework=strcat(folder,"/",frameworks(i));
        nrReqFile=strcat("_",functionName,"_",string(tests(t))); % Fix replication variable
        fileName=strcat(fileFramework,nrReqFile);
        
        fileName=strcat(fileName,".csv");
        value = extractFromFile(fileName);          
        
        values(t,i) = fun(value);
    end
end
nexttile
hold on
%plot(valuesMin,tests,frameworks);
plot(values,tests,frameworks);
%plot(valuesMax,tests,frameworks);
hold off


