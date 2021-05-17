function [] = replicationPlotOverTime(folder,replications,frameworks,functionName,tests,extractFromFile,plotFun)
%TEST Summary of this function goes here
%   Detailed explanation goes here
for i=1:length(frameworks)
    for r=1:length(replications)
        for t=1:length(tests)
            fileFramework=strcat(folder,"/",frameworks(i));
            nrReqFile=strcat("_",functionName,"_",string(replications(r)),"_",string(tests(t))); % Fix replication variable
            fileframeworknrReqFile=strcat(fileFramework,nrReqFile);
            fileName=strcat(fileframeworknrReqFile,"_*.csv");
            dataFiles = dir(fileName); 
            n=length(dataFiles);
            for k=1:n
                fileNumber=strcat("_",string(k));
                fileName=strcat(fileframeworknrReqFile,fileNumber);
                fileName=strcat(fileName,".csv");
                [xO,ok,xE,error] = extractFromFile(fileName);
            end            
        end
    end
    nexttile
    hold on
    plotFun(xO,ok)
    plotFun(xE,error)
    %plot(valuesMin,tests,frameworks);
    %scatter(values,tests,frameworks);
    %plot(valuesMax,tests,frameworks);
    %hold off
    titleName=strcat("Framework: ", string(frameworks(i)));
    title(titleName)
end
end

